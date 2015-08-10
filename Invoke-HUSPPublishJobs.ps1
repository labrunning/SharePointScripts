<#
.SYNOPSIS
Runs the Content Type Publishing Jobs
.DESCRIPTION
This script runs the Content Type Publishing Jobs. When you are working on Content Types and want to see the effect of a change you have published you will sometimes want to run the Content Type Publishing timer jobs immediately. This script does just that.
.EXAMPLE
Set-PublishJobs
.NOTES
Even though this job runs the Content Type Publishing jobs immediately the effects of changes to content types can still take a while to appear in sites.
#>
function Invoke-HUSPPublishJobs {
    Write-Verbose 'Running CT Publishing Timer Job...'
    Get-SPTimerJob MetadataHubTimerJob | Start-SPTimerJob
    Write-Verbose 'Running CT Subscriber Timer Job...'
    Get-SPTimerJob MetadataSubscriberTimerJob | Start-SPTimerJob
}