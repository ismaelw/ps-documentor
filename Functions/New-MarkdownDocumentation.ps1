Function New-MarkdownDocumentation {
    <#
        .SYNOPSIS
        Generates one or more markdown documentation files
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Single or Multi - Defines whether only one documentation should be created or one per script file.')]
        [ValidateSet('Single', 'Multi')]
        [String]$Output,
        [Parameter(Mandatory = $true, HelpMessage = 'PSObject containing all the script files and functions')]
        [System.Object[]]$Data,
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the process. This will define how the folder that gets created is called. This Process name is either the folders name or the name of the script file without extension.')]
        [String]$ProcessName,
        [Parameter(Mandatory = $true, HelpMessage = 'Defines where the documentation files are beeing saved.')]
        [String]$Destination
    )

    $DestinationPath = "$Destination\$ProcessName"

    If (-not (Test-Path($DestinationPath))) {
        New-Item -Path $Destination -ItemType Directory -Name $ProcessName
    }

    $ReturnFiles = @()
    $Date = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
    $FilenameDate = Get-Date -Format "yyyyMMddHHmmss"

    If ($Output -eq 'Multi') {
        Write-Verbose "Generating multiple documentation files for each script"
        ForEach ($Element in $Data) {
            $ReturnFile = New-Object -TypeName PSObject -Property @{
                Success = ""
                File    = ""
                Error   = ""
            }

            Try {
                $FilenameNoExt = (Get-Item -Path "$global:ProjectFolderParent$($Element.Path)\$($Element.File)").Basename
                $OutputFile = "$DestinationPath\$($FilenameDate)_Documentation_$($FilenameNoExt).md"
                Add-Content -Path $OutputFile -Value @(
                    "# PowerShell Script Functions Documentation",
                    "``````YAML",
                    "Script: $($Element.File)",
                    "Path: $($Element.Path)",
                    "Date: $Date",
                    "``````" 
                )
                If ($Element.Functions.Count -ne 0) {
                    Add-Content -Path $OutputFile -Value "## Contents"
                
                    ForEach ($ContentItem in $Element.Functions) {
                        Add-Content -Path $OutputFile -Value " - [$($ContentItem.Name)](#$($($ContentItem.Name).ToLower()))"
                    }

                    ForEach ($FunctionItem in $Element.Functions) {
                        Add-Content -Path $OutputFile -Value "## $($FunctionItem.Name)"
                        Add-Content -Path $OutputFile -Value "Location: $($FunctionItem.Location)"
                        If (Test-Path -Path "$global:ProjectFolderParent$($FunctionItem.Location)") {
                            Add-Content -Path $OutputFile -Value @(
                                "### Syntax",
                                "``````",
                                "$($FunctionItem.Syntax)",
                                "``````"
                            )

                            If (-not ([String]::IsNullOrEmpty($FunctionItem.Synopsis))) {
                                Add-Content -Path $OutputFile -Value @(
                                    "### Synopsis",
                                    "$($FunctionItem.Synopsis) `r`n"
                                )
                            }
                            
                            If (-not ([String]::IsNullOrEmpty($FunctionItem.Description))) {
                                Add-Content -Path $OutputFile -Value @(
                                    "### Description",
                                    "$($FunctionItem.Description) `r`n"
                                )
                            }

                            If ($FunctionItem.Examples.Count -gt 0) {
                                Add-Content -Path $OutputFile -Value "### Examples"
                                ForEach ($ExampleItem in $FunctionItem.Examples) {
                                    Add-Content -Path $OutputFile -Value "#### $($ExampleItem.Title)"
                                    Add-Content -Path $OutputFile -Value $ExampleItem.Description
                                }
                            }

                            If ($FunctionItem.Parameters.Count -gt 0) {
                                Add-Content -Path $OutputFile -Value "### Parameters"
                                ForEach ($ParameterItem in $FunctionItem.Parameters) {
                                    Add-Content -Path $OutputFile -Value @(
                                        "``-$($ParameterItem.Name)``",
                                        "`r`n",
                                        "$($ParameterItem.HelpMessage)",
                                        "<table>",
                                        "<tr><td>Type</td><td>$($ParameterItem.ParameterType)</td></tr>",
                                        "<tr><td>Is Mandatory</td><td>$($ParameterItem.IsMandatory)</td></tr>",
                                        "<tr><td>Aliases</td><td>$($ParameterItem.Aliases)</td></tr>",
                                        "<tr><td>Accept pipeline input</td><td>$($ParameterItem.ValueFromPipeline)</td></tr>",
                                        "</table>",
                                        "`r`n"
                                    )
                                }
                            } 
                        } Else {
                            Add-Content -Path $OutputFile -Value "Sub Function of '$($FunctionItem.Location)'"
                        }
                    }
                } Else {
                    Add-Content -Path $OutputFile -Value "**No functions found**"
                }
                Write-Verbose "Markdown file generated: '$OutputFile'"
                $ReturnFile.Success = $true
            } Catch {
                $ReturnFile.Success = $false
                $ReturnFile.Error = $_.Exception.Message
                Write-Error "Markdown File couldn't be generated '$OutputFile' - $($_.Exception.Message)"
            }

            $ReturnFile.File = $OutputFile
            $ReturnFiles += $ReturnFile
        }
    } Else {
        Write-Verbose "Generating one documentation file for all scripts"
        $ReturnFile = New-Object -TypeName PSObject -Property @{
            Success = ""
            File    = ""
            Error   = ""
        }

        Try {
            $OutputFile = "$DestinationPath\$($FilenameDate)_Documentation_$($ProcessName).md"
            
            Add-Content -Path $OutputFile -Value @(
                "# PowerShell Script Functions Documentation",
                "``````YAML",
                "Date: $Date",
                "``````",
                "## Script Files"
            )

            ForEach ($ScriptFile in $Data) {
                Add-Content -Path $OutputFile -Value " - [$($ScriptFile.File)](#$($($ScriptFile.File).ToLower()))"
            }

            ForEach ($Element in $Data) {
                Add-Content -Path $OutputFile -Value "## $($Element.File)"
                Add-Content -Path $OutputFile -Value "Path: $($Element.Path)"
                If ($Element.Functions.Count -ne 0) {
                    Add-Content -Path $OutputFile -Value "### Contents"
                
                    ForEach ($ContentItem in $Element.Functions) {
                        Add-Content -Path $OutputFile -Value " - [$($ContentItem.Name)](#$($($ContentItem.Name).ToLower()))"
                    }

                    ForEach ($FunctionItem in $Element.Functions) {
                        Add-Content -Path $OutputFile -Value "### $($FunctionItem.Name)"
                        Add-Content -Path $OutputFile -Value "Location: $($FunctionItem.Location)"
                        If (Test-Path -Path "$global:ProjectFolderParent$($FunctionItem.Location)") {
                            Add-Content -Path $OutputFile -Value @(
                                "### Syntax",
                                "``````",
                                "$($FunctionItem.Syntax)",
                                "``````"
                            )

                            If (-not ([String]::IsNullOrEmpty($FunctionItem.Synopsis))) {
                                Add-Content -Path $OutputFile -Value @(
                                    "### Synopsis",
                                    "$($FunctionItem.Synopsis) `r`n"
                                )
                            }
                            
                            If (-not ([String]::IsNullOrEmpty($FunctionItem.Description))) {
                                Add-Content -Path $OutputFile -Value @(
                                    "### Description",
                                    "$($FunctionItem.Description) `r`n"
                                )
                            }

                            If ($FunctionItem.Examples.Count -gt 0) {
                                Add-Content -Path $OutputFile -Value "### Examples"
                                ForEach ($ExampleItem in $FunctionItem.Examples) {
                                    Add-Content -Path $OutputFile -Value "#### $($ExampleItem.Title)"
                                    Add-Content -Path $OutputFile -Value $ExampleItem.Description
                                }
                            }

                            If ($FunctionItem.Parameters.Count -gt 0) {
                                Add-Content -Path $OutputFile -Value "### Parameters"
                                ForEach ($ParameterItem in $FunctionItem.Parameters) {
                                    Add-Content -Path $OutputFile -Value @(
                                        "``-$($ParameterItem.Name)``",
                                        "`r`n",
                                        "$($ParameterItem.HelpMessage)",
                                        "<table>",
                                        "<tr><td>Type</td><td>$($ParameterItem.ParameterType)</td></tr>",
                                        "<tr><td>Is Mandatory</td><td>$($ParameterItem.IsMandatory)</td></tr>",
                                        "<tr><td>Aliases</td><td>$($ParameterItem.Aliases)</td></tr>",
                                        "<tr><td>Accept pipeline input</td><td>$($ParameterItem.ValueFromPipeline)</td></tr>",
                                        "</table>",
                                        "`r`n"
                                    )
                                }
                            }                                
                        } Else {
                            Add-Content -Path $OutputFile -Value "Sub Function of '$($FunctionItem.Location)'"
                        }
                    }
                } Else {
                    Add-Content -Path $OutputFile -Value "**No functions found**"
                }
            }
            Write-Verbose "Markdown file generated: '$OutputFile'"
            $ReturnFile.Success = $true
        } Catch {
            $ReturnFile.Success = $false
            $ReturnFile.Error = $_.Exception.Message
            Write-Error "Markdown File couldn't be generated '$OutputFile' - $($_.Exception.Message)"
        }
        
        $ReturnFile.File = $OutputFile
        $ReturnFiles += $ReturnFile
    }

    Return $ReturnFiles
}