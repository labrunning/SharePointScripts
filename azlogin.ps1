# Login to the azure server

$passwd = convertto-securestring -AsPlainText -Force -String v5v5naklyb
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "AD\spdevadmin",$passwd
$session = enter-pssession -computername azspstfdapp1 -authentication "CredSSP" -credential $cred