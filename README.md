# SharePointScripts

A repository of SharePoint scripts intended for my own personal use on a work project.

## WARNING

These scripts only perform the most rudimentary of checks, do NOT run them unless you know the effects.

## Help

Each script contains a help file using the standard PowerShell Get-Help functionality. Well, most of them do but often I forget! To access this, first load the script;

    Import-Module .\Get-HUSPDocumentValues.ps1

If you make changes to a script, use the force flag `-Force` as well to make sure the changes are loaded. You can then get help on the script by running

    Get-Help Get-HUSPDocumentValues

All the scripts are named with a description of what they do so hopefully you can find one that does what you need. The verbs are prefixed with 'HU' to prevent clashes with standard Powershell commands.

Added to GitHub for redundancy and maybe, just maybe, someone else like me may find them useful.