Function Get-RandomValue {
    <#
		.SYNOPSIS
			Gets a Random Number to add to another string (To prevent identical names)
	#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, HelpMessage = 'Defines the length of the generated string')]
        [Int]$Count
    )
	
    return -join ((48 .. 57) + (97 .. 122) | Get-Random -Count $Count | ForEach-Object { [char]$_ })
}