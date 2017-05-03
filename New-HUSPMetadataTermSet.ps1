<#
    .SYNOPSIS
    Creates new terms in a parent term set from a CSV list 
    .DESCRIPTION
    This script creates new terms from a CSV list
    .PARAMETER url
    a valid SharePoint url
    .PARAMETER group
    a valid Managed Metadata Term Group
    .PARAMETER ts
    a valid Managed Metadata Term Set
    .PARAMETER parent
    a valid Managed Metadata Parent Term
    .PARAMETER csv
    a path to a valid CSV file of terms
    .EXAMPLE
    New-HUSPMetadataTermSet -url https://testunifunctions.hud.ac.uk/ct -group "UF Fileplan" -ts "Subjects" -parent "School of Human and Health Sciences" -csv .\scripts\csv\SHUM_Subjects.csv -Verbose
    .NOTES
    The CSV file must have one column of CSV terms with a 'TermTitle' column header
    .LINK
    stolen from; http://get-spscripts.com/2010/06/create-new-term-with-synonym-in.html
#>

function New-HUSPMetadataTermSet {
    # FIXME - need to add a what if here!
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$group,
        [Parameter(Mandatory=$true,Position=3)]
        [string]$ts,
        [Parameter(Mandatory=$true,Position=4)]
        [string]$csv,
        [Parameter(Mandatory=$false,Position=5)]
        [string]$parent
    )
    
    $ParentPresent = $PSBoundParameters.ContainsKey('parent')

    $termsCsvList = Import-Csv -Path "$csv"

    #Connect to Central Admin 
    $SPTaxonomySite = Get-SPSite $url
    
    #Connect to Term Store in the Managed Metadata Service Application 
    $SPTaxonomySession = Get-SPTaxonomySession -site $SPTaxonomySite 
    
    <#
        We can specify the term store by name, but as there is just usually one, and this
        is certainly the case in our environment I am just going to use the first one
        $TermStore = $TaxonomySession.TermStores["Managed Metadata Service Application Proxy"]
    #> 
    
    $SPTermStore = $SPTaxonomySession.TermStores[0] 

    Write-Verbose "Connection made with term store - $SPTermStore.Name"
    
    #Connect to the Group and Term Set 
    try {
        $SPTermStoreGroup = $SPTermStore.Groups[$group] 
        $SPTermSet = $SPTermStoreGroup.TermSets[$ts] 
        $SPTermSet.IsOpenForTermCreation = $true;
        # FIXME - we need to be able to adapt between term sets and parent terms to add to
        if ($ParentPresent -eq $true) {
            # if there is a parent term, get this to add into
            $SPTermAddLocation = $SPTermSet.Terms[$parent]
        } else {
            # just write it into the term set
            $SPTermAddLocation = $SPTermSet
        }
    } catch [Exception]{
        Write-Host "There was an error connecting to the metadata term objects..." -ForegroundColor Red
        Write-Error $_.Exception | format-list -force
    }

    foreach ($SPNewTerm in $termsCsvList) {
        # Get the term title from the CSV
        $SPTermToAdd = $SPNewTerm.TermTitle
        $IsTermPresent = $false
        
        # Check all the terms present in the current term location for existing values
        $SPTermAddLocationName = $SPTermAddLocation.Name
        foreach ($SPTerm in $SPTermAddLocation.Terms) {
            $SPTermName = $SPTerm.Name
            Write-Verbose -message "Checking '$SPTermName' for '$SPTermToAdd'"
            $SPCreateTerm = $true
            if ($SPTermName -eq $SPTermToAdd) {
                $IsTermPresent = $true
            }
        }
        Write-Host "Is Term $SPTermToAdd Present in $SPTermAddLocationName ? $IsTermPresent"
        if ($IsTermPresent -eq $false) {
            if ($PSCmdlet.ShouldProcess($SPTermToAdd)) {
            Write-Host "Creating term $SPTermToAdd in $SPTermAddLocationName" -ForegroundColor Red
            $SPTermAddLocation.CreateTerm($SPTermToAdd, 1033)
            # $SPTermAddLocation.SetDescription("This is a test", 1033) 
            # $SPTermAddLocation.CreateLabel("This is a test synonym", 1033, $false) 
            # Update the Term Store - we need to do this after each single term is added 
            $SPTermStore.CommitAll()
            }  
        } else {
            Write-Host "Term is already present" -ForegroundColor Yellow
        }
    }
    
    #Dispose of taxonomy site object
    $SPTaxonomySite.Dispose()
}