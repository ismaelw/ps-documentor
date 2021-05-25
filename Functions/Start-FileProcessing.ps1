Function Start-FileProcessing {
    <#
        .SYNOPSIS
        Processes a script file passed to it and calls the other functions to get the documentation object
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The path to the original script file')]
        [String]$File
    )

    $FileName = Split-Path -Path $File -Leaf
    $FilePath = Split-Path -Path $File -Parent
    $FilenameNoExt = (Get-Item $File).Basename

    $ResultItem = New-Object -TypeName PSObject -Property @{
        File      = $FileName
        Path      = $FilePath
        Success   = ""
        Functions = @()
        Error     = ""
    }

    $TempFile = Get-FunctionsFromFile -File $File -FileNoExt $FilenameNoExt

    If ($TempFile.Success) {
        Write-Verbose "Generating documentation data for Script '$FileName'"
        $Documentation = Get-FileDocumentation -Script $TempFile.Value -OriginalScript "$FilePath\$FileName"
        Write-Verbose "Removing temporary script file"
        If ($Documentation.Success) {
            Remove-Item $TempFile.Value
            $ResultItem.Success = $true
            $ResultItem.Functions = $Documentation.Functions
        } Else {
            Remove-Item $TempFile.Value
            $ResultItem.Success = $false
            $ResultItem.Error = "Error getting the file documentation: $($Documentation.Error)"

        }
    } Else {
        $ResultItem.Success = $false
        $ResultItem.Error = "Error reading and processing file '$Filename': $($TempFile.Value)"
    }
    Return $ResultItem
}