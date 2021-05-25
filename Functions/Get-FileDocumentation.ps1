Function Get-FileDocumentation {
    <#
        .SYNOPSIS
            Gets the details to all functions inside of a script
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, HelpMessage = 'The path to the temporary script file')]
        [String]$Script,
        [Parameter(Mandatory = $true, HelpMessage = 'The path to the original script file')]
        [String]$OriginalScript
    )

    Try {
        $ReturnValue = New-Object -TypeName PSObject -Property @{
            Success   = ""
            Functions = @()
            Error     = ""
        }

        # dot source Script File
        . $Script

        # Get the AST of the file
        $Tokens = $Errors = $null
        $Ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $Script,
            [ref]$Tokens,
            [ref]$Errors)

        $BuiltInParameters = @(
            "Verbose",
            "Debug",
            "ErrorAction",
            "WarningAction",
            "InformationAction",
            "ErrorVariable",
            "WarningVariable",
            "InformationVariable",
            "OutVariable",
            "OutBuffer",
            "PipelineVariable"
        )

        $Functions = @()
        $Command = ""

        $FunctionDefinitions = $Ast.FindAll( {
                param([System.Management.Automation.Language.Ast] $Ast)
                $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and ($PSVersionTable.PSVersion.Major -lt 5 -or $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])
            }, $true)

        ForEach ($FunctionDefinition in $FunctionDefinitions) {
            Write-Verbose "Processing Function $($FunctionDefinition.Name)"
            Try {
                $FunctionDetails = Get-ChildItem -Path Function:$($FunctionDefinition.Name) -ErrorAction Stop
                $FunctionParameters = @()
                ForEach ($ParameterSet in $FunctionDetails.ParameterSets.Parameters) {
                    If ($ParameterSet.Name -notin $BuiltInParameters) {
                        $FunctionParameters += $ParameterSet
                    }
                }
                $Command = $FunctionDefinition.Name
                $Location = $OriginalScript
            } Catch {
                $Location = $Command
            }

            $Syntax = (Get-Command $FunctionDefinition.Name -Syntax -ErrorAction SilentlyContinue)
            
            If ($Syntax) {
                $Syntax = $Syntax.Split("`r`n") | Where-Object { $_ -ne "" } 
                $Syntax = $Syntax -Join "`r`n"
            }

            $FunctionDescription = (Get-Help -Name $FunctionDefinition.Name).Description
            $FunctionSynopsis = ((Get-Help -Name $FunctionDefinition.Name).Synopsis).Replace("`n", "").Replace("`r", "")
            $EscapedSyntax = $Syntax -replace "\[", "``[" -replace "\]", "``]"
            
            If ($FunctionDescription -like "*$EscapedSyntax*") {
                $FunctionDescription = "-"
            }
            
            $Examples = Get-Help -Name $FunctionDefinition.Name -Examples
            $FunctionExamples = @()

            ForEach ($Example in $Examples.examples.example) {
                $FunctionExample = New-Object -TypeName PSObject -Property @{
                    Title       = $Example.title.TrimStart('-').TrimEnd('-').Trim(' ')
                    Description = $Example.code
                }
                $FunctionExamples += $FunctionExample    
            }

            $Function = New-Object -TypeName PSObject -Property @{
                Name        = $FunctionDefinition.Name
                Parameters  = $FunctionParameters
                Location    = $Location
                Syntax      = $Syntax
                Description = $FunctionDescription.Text
                Synopsis    = $FunctionSynopsis
                Examples    = $FunctionExamples
            }

            $Functions += $Function
        }

        $Functions = $Functions | Sort-Object -Property Name -Unique

        $ReturnValue.Success = $true
        $ReturnValue.Functions = $Functions
    } Catch {
        $ReturnValue.Success = $false
        $ReturnValue.Error = $_.Exception.Message
    }

    Return $ReturnValue
}