<#
.SYNOPSIS
A test script to see how Write-Verbose and Write-Debug works
.DESCRIPTION
Displays some messages to screen
.EXAMPLE
Set-Messages.ps1
#>
function Set-Messages {
    [CmdletBinding()]
    Param()

    $VerboseMessage = 'This is a verbose message'
    $DebugMessage = 'This is a debug message'
    
    Write-Verbose 'Ouputting the verbose message'
    Write-Verbose -Message 'The verbose message--> $VerboseMessage <--was there'
    Write-Debug 'Ouputting the debug message'
    Write-Debug -Message "The debug message--> $DebugMessage <--was there"
}