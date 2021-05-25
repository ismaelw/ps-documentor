Function Get-FunctionsFromFile {
    <#
        .SYNOPSIS
        Extracts all functions from a script file and creates a new temporary script file containing all those functions
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The path to the original script file')]
        [String]$File,
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the script file without the extension')]
        [String]$FileNoExt
    )

    Try {
        $ReturnValue = New-Object -TypeName PSObject -Property @{
            Success = ""
            Value   = ""
        }

        $TempFilePath = "$global:RootFolder\Temp\Temp-$FileNoExt-$(Get-RandomValue -Count 5).ps1"

        $Tokens = $null
        $Errors = $null
        $Ast = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$Tokens, [ref]$Errors)

        $FunctionDefinitions = $Ast.FindAll( {
                param([System.Management.Automation.Language.Ast] $Ast)
                $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and ($PSVersionTable.PSVersion.Major -lt 5 -or $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])
            }, $true)

        Write-Verbose "Creating temp script file '$TempFilePath'"
        $null = Add-Content -Path $TempFilePath -Value $FunctionDefinitions

        $ReturnValue.Success = $true
        $ReturnValue.Value = $TempFilePath

    } Catch {
        $ReturnValue.Success = $false
        $ReturnValue.Value = $_.Exception.Message
    }

    Return $ReturnValue
}