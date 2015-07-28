<#
.SYNOPSIS
Logs in to the Azure Server
.DESCRIPTION
Logs in to the Azure SharePoint Staff Development App Server with AD\spdevadmin and the SharePoint Profile loaded
.EXAMPLE
Enter-AzureAppServer.ps1
.NOTES
! ! WARNING ! ! This file contains the spdevadmin password in plain text - DO NOT DISTRIBUTE
#>
write-verbose 'Logging in to Azure Server azspstfdapp1 with spdevadmin...'
$passwd = convertto-securestring -AsPlainText -Force -String v5v5naklyb
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "AD\spdevadmin",$passwd
$session = enter-pssession -computername azspstfdapp1 -configurationname SPProfile -authentication "CredSSP" -credential $cred