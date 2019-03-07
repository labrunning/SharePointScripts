# SharePointScripts

A repository of SharePoint scripts intended for my own personal use on a work project.

## WARNING

These scripts only perform the most rudimentary of checks, do NOT run them unless you know the effects.

## Usage

All the scripts are written as functions, which you need to load with the Import-Module command. Use the force flag to refresh any changes you make

    Import-Module .\Get-HUSPDocumentValues.ps1 -Force

## Help

Most files have the standard powershell comment based help, so you can see more information about the commands by using the Get-Help command;

    Get-Help Get-HUSPDocumentValues