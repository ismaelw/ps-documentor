# PowerShell Script Functions Documentation
```YAML
Script: New-ScriptDocumentation.ps1
Path: \ps-documentor\
Date: 09.06.2021 12:13:35
```
## Contents
 - [New-ScriptDocumentation](#new-scriptdocumentation)
## New-ScriptDocumentation
Location: \ps-documentor\New-ScriptDocumentation.ps1
### Syntax
```
New-ScriptDocumentation -Folder <string> -FileTypes <string[]> [-Output <string>] [-Assemblies <string[]>] [-Destination <string>] [<CommonParameters>]
New-ScriptDocumentation -File <string> [-Assemblies <string[]>] [-Destination <string>] [<CommonParameters>]
```
### Synopsis
Script that automatically creates Markdown Documentations for all functions inside a script file or inside of multiple scripts in a folder. 

### Description
Script that automatically creates Markdown Documentations for all functions inside a script file or inside of multiple scripts in a folder.
This works by parsing the script files and just exporting all functions. The temporary function file can then be dot-sourced to make all functions available to the console.
In the console this script can use Get-Help and Get-Command to get all details to each function. 

### Examples
#### EXAMPLE 1
New-ScriptDocumentation -File 'C:\Scripts\ProjectOne\Script.ps1'
Creates a Markdown Documentation for all functions inside one Scriptfile.
#### EXAMPLE 2
New-ScriptDocumentation -File 'C:\Scripts\ProjectOne\Script.ps1' -Destination 'C:\Temp\'
Creates a Markdown Documentation for all functions inside one Scriptfile. The documentation will be saved inside C:\Temp.
#### EXAMPLE 3
New-ScriptDocumentation -Folder 'C:\Scripts\ProjectOne' -FileTypes '.ps1','.psm' -Destination 'C:\Temp\'
Creates a Markdown Documentation for each script files inside of a folder. The documentations will be saved inside C:\Temp.
#### EXAMPLE 4
New-ScriptDocumentation -Folder 'C:\Scripts\ProjectOne' -FileTypes '.ps1','.psm' -Output 'Single' -Destination 'C:\Temp\'
Creates one Markdown Documentation for all script files inside of a folder. The single documentation will be saved inside C:\Temp.
### Parameters
`-Assemblies`


An array of assemblies needed by the script.
<table>
<tr><td>Type</td><td>string[]</td></tr>
<tr><td>Is Mandatory</td><td>False</td></tr>
<tr><td>Aliases</td><td></td></tr>
<tr><td>Accept pipeline input</td><td>False</td></tr>
</table>


`-Destination`


Defines where the documentation files are beeing saved.
<table>
<tr><td>Type</td><td>string</td></tr>
<tr><td>Is Mandatory</td><td>False</td></tr>
<tr><td>Aliases</td><td></td></tr>
<tr><td>Accept pipeline input</td><td>False</td></tr>
</table>


`-File`


The path to the script file that needs to be documented.
<table>
<tr><td>Type</td><td>string</td></tr>
<tr><td>Is Mandatory</td><td>True</td></tr>
<tr><td>Aliases</td><td></td></tr>
<tr><td>Accept pipeline input</td><td>False</td></tr>
</table>


`-FileTypes`


An array of extensions to select which files should be documented recursively.
<table>
<tr><td>Type</td><td>string[]</td></tr>
<tr><td>Is Mandatory</td><td>True</td></tr>
<tr><td>Aliases</td><td></td></tr>
<tr><td>Accept pipeline input</td><td>False</td></tr>
</table>


`-Folder`


The path to the folder containing multiple script files that needs to be documented.
<table>
<tr><td>Type</td><td>string</td></tr>
<tr><td>Is Mandatory</td><td>True</td></tr>
<tr><td>Aliases</td><td></td></tr>
<tr><td>Accept pipeline input</td><td>False</td></tr>
</table>


`-Output`


Single or Multi - Defines whether only one documentation should be created or one per script file.
<table>
<tr><td>Type</td><td>string</td></tr>
<tr><td>Is Mandatory</td><td>False</td></tr>
<tr><td>Aliases</td><td></td></tr>
<tr><td>Accept pipeline input</td><td>False</td></tr>
</table>


