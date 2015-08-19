#---------------------------------------------------------------
# This script sets the required permissions on the content web
# applications for the service accounts used in the farm.

foreach ($web_application in Get-SPWebApplication) {
    write-host "Setting permissions for $web_application" -ForegroundColor Green
    $web_application.GrantAccessToProcessIdentity("AD\sp2013accessapp")
    #$web_application.GrantAccessToProcessIdentity("AD\sp2013access2010app")
    $web_application.GrantAccessToProcessIdentity("AD\sp2013excelapp")
    $web_application.GrantAccessToProcessIdentity("AD\sp2013perfapp")
    $web_application.GrantAccessToProcessIdentity("AD\sp2013pivotapp")
    $web_application.GrantAccessToProcessIdentity("AD\sp2013wordapp")
    $web_application.GrantAccessToProcessIdentity("AD\sp2013visioapp")
    $web_application.GrantAccessToProcessIdentity("AD\sp2013upsapp")
}
