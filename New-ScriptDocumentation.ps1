Function New-ScriptDocumentation {
    <#
        .SYNOPSIS
            Script that automatically creates Markdown Documentations for all functions inside a script file or inside of multiple scripts in a folder.
        .DESCRIPTION
            Script that automatically creates Markdown Documentations for all functions inside a script file or inside of multiple scripts in a folder.
            This works by parsing the script files and just exporting all functions. The temporary function file can then be dot-sourced to make all functions available to the console.
            In the console this script can use Get-Help and Get-Command to get all details to each function.
        .PARAMETER File
            The path to the script file that needs to be documented.
        .PARAMETER Folder
            The path to the folder containing multiple script files that needs to be documented.
        .PARAMETER FileTypes
            An array of extensions to select which files should be documented recursively.
        .PARAMETER Output
            Single or Multi - Defines whether only one documentation should be created or one per script file.
        .PARAMETER Assemblies
            An array of assemblies needed by the script.
        .PARAMETER Destination
            Defines where the documentation files are beeing saved.
        .OUTPUTS
            [Destination]\yyyyMMddHHmmss_Documentation_[ScriptfileName].md | Returns a PSObject containing details to all generated documentation files and all functions from all script files
        .EXAMPLE
            PS C:\> New-ScriptDocumentation -File 'C:\Scripts\ProjectOne\Script.ps1'
            Creates a Markdown Documentation for all functions inside one Scriptfile.
        .EXAMPLE
            PS C:\> New-ScriptDocumentation -File 'C:\Scripts\ProjectOne\Script.ps1' -Destination 'C:\Temp\'
            Creates a Markdown Documentation for all functions inside one Scriptfile. The documentation will be saved inside C:\Temp.
        .EXAMPLE
            PS C:\> New-ScriptDocumentation -Folder 'C:\Scripts\ProjectOne' -FileTypes '.ps1','.psm' -Destination 'C:\Temp\'
            Creates a Markdown Documentation for each script files inside of a folder. The documentations will be saved inside C:\Temp.
        .EXAMPLE
            PS C:\> New-ScriptDocumentation -Folder 'C:\Scripts\ProjectOne' -FileTypes '.ps1','.psm' -Output 'Single' -Destination 'C:\Temp\'
            Creates one Markdown Documentation for all script files inside of a folder. The single documentation will be saved inside C:\Temp.
        .NOTES
            Function Name : New-ScriptDocumentation
            Created by    : Ismael Wismann <ismael@wismann.ch>
            Date Coded    : 05/13/2021
    #>
    [CmdletBinding(DefaultParameterSetName = 'Folder')]
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'File', HelpMessage = 'The path to the script file that needs to be documented.')]
        [String]$File,

        [Parameter(Mandatory = $true, ParameterSetName = 'Folder', HelpMessage = 'The path to the folder containing multiple script files that needs to be documented.')]
        [String]$Folder,

        [Parameter(Mandatory = $true, ParameterSetName = 'Folder', HelpMessage = 'An array of extensions to select which files should be documented recursively.')]
        [String[]]$FileTypes,

        [Parameter(Mandatory = $false, ParameterSetName = 'Folder', HelpMessage = 'Single or Multi - Defines whether only one documentation should be created or one per script file.')]
        [ValidateSet('Single', 'Multi')]
        [String]$Output = 'Multi',

        [Parameter(Mandatory = $false, HelpMessage = 'An array of assemblies needed by the script.')]
        [String[]]$Assemblies,

        [Parameter(Mandatory = $false, HelpMessage = 'Defines where the documentation files are beeing saved.')]
        [String]$Destination = "$PSScriptRoot\Output"
    )

    $Result = @()
    $global:RootFolder = $PSScriptRoot

    $FunctionsDirectory = "$global:RootFolder\Functions\"
    Get-ChildItem -Path $FunctionsDirectory | ForEach-Object {
        . $_.FullName
    }

    If ($Destination.Chars($Destination.Length - 1) -eq '\') {
        $Destination = ($Destination.TrimEnd('\'))
    }

    # load all assemblies
    ForEach ($Assembly in $Assemblies) {
        Write-Verbose "Loading Assembly '$Assembly'"
        Try {
            Add-Type -AssemblyName $Assembly
        } Catch {
            Write-Error "Error occured while loading an assembly '$Assembly': $($_.Exception.Message)"
        }
    }

    If ($PSCmdlet.ParameterSetName -eq 'File') {
        Write-Verbose "Processing single file '$File'"
        If (Test-Path -Path $File) {
            Write-Verbose "File '$File' exists. Start processing"
            $ProcessName = (Get-Item $File).Basename
            $CurrentFile = Start-FileProcessing -File $File
            $Result += $CurrentFile
        } Else {
            Write-Error "The file '$File' doesn't exist!"
        }
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'Folder') {
        Write-Verbose "Processing folder '$Folder'"
        If (Test-Path -Path $Folder -PathType Container) {
            Write-Verbose "Folder '$Folder' exists. Start processing"
            $ProcessName = (Get-Item $Folder).Basename
            $Files = Get-ChildItem -Path $Folder -Recurse | Where-Object { $_.Extension -in $FileTypes }
            ForEach ($FileElement in $Files) {
                $CurrentFile = Start-FileProcessing -File $FileElement.FullName
                $Result += $CurrentFile
            }
        } Else {
            Write-Error "The folder '$Folder' doesn't exist!"
        }     
    }

    If ($Result.Count -ge 1) {
        $Documentation = New-MarkdownDocumentation -Output $Output -Data $Result -ProcessName $ProcessName -Destination $Destination
        If ($Documentation.Success -contains $false) {
            Write-Error "Documentation finished with errors"
        }
    } Else {
        Write-Warning "No functions found in the file/s."
    }

    $EndResult = New-Object -TypeName PSObject -Property @{
        Documentation = $Documentation
        Scripts       = $Result
    }
    
    Return $EndResult

    #TODO: Figure out how to deal with duplicate attributes beeing documented when using multiple parameter sets
    #TODO: Find a way to automatically parse script files to find all assemblies
}