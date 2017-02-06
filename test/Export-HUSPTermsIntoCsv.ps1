<#
    ################################################################
    .Synopsis
     Exports term sets to CSV
    .DESCRIPTION
     A exports the term set for a given site to a CSV file in an importable format
    .Parameter url
     A valid SharePoint site url
    .Parameter out
     A valid output path
    .Parameter group
     A group name to filter the query on
    .OUTPUTS
     A CSV file with all the term store data in
    .EXAMPLE 
     Export-HUSPTermsIntoCSV.ps1 -url https://testunifunctions.hud.ac.uk/COM/University-Committees
    ################################################################
#>

function Export-HUSPTermsIntoCSV {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$url,
        [Parameter(Mandatory=$false,Position=2)]
        [string]$out="D:\SPOutput\Terms",
        [Parameter(Mandatory=$true,Position=3)]
        [string]$tsgroup
        )

    $empty = ""

    $taxonomySite = Get-SPSite -Identity $url
    #Connect to Term Store in the Managed Metadata Service Application
    $taxonomySession = Get-SPTaxonomySession -site $taxonomySite
    $taxonomyTermStore =  $taxonomySession.TermStores | Select Name
    $termStore = $taxonomySession.TermStores[$taxonomyTermStore.Name]

    foreach ($group in $termStore.Groups | Where-Object { $_.Name -eq $tsgroup }) {
        Write-Verbose -message "Checking Term Store Group $group.Name "
        foreach($termSet in $group.TermSets) {
            Write-Verbose -message "Checking Term Store TermSet $_.Name "
            $terms = @()
            #The path and file name, in this case I did C:\TermSet\TermSetName.csv
            $logTime = Get-Date -Format "dd-MM-yyyy_H-mm-ss"
            $CSVFile = $out + "\" + $logTime + "-" + $termSet.Name + ".csv"
            #From TechNet: The first line of the file must contain 12 items separated by commas
            $firstLine = New-TermLine -TermSetName $termSet.Name -TermSetDescription $empty -LCID $empty -AvailableForTagging "TRUE" -TermDescription $empty -Level1 $empty -Level2 $empty -Level3 $empty -Level4 $empty -Level5 $empty -Level6 $empty -Level7 $empty
            $terms+=$firstLine
            #Now we start to add a line in the file for each term in the term set
            foreach ($term in $termSet.GetAllTerms()) {
                $tempTerm = $term
                $counter = 0
                $tempTerms = @("","","","","","","")
                #this while loop makes sure you are using the root term then counts how many child terms there are 
                while (!$tempTerm.IsRoot) {
                    $tempTerm = $tempTerm.Parent
                    $counter = $counter + 1
                }
                $start = $counter
                #this makes sure that any columns that would need to be empty are empty
                #i.e. if the current term is 3 levels deep, then the 4th, 5th, and 6th level will be empty
                while ($counter -le 6) {
                    $tempTerms[$counter] = $empty
                    $counter = $counter + 1
                }
                #start with the current term
                $tempTerm = $term
                #fill in the parent terms of the current term (there should never be children of the current term--the child term will have its own line in the CSV)
                while ($start -ge 0) {
                    $tempTerms[$start] = $tempTerm.Name
                    $tempTerm = $tempTerm.Parent
                    $start = $start - 1
                }
                #create a new line in the CSV file
                $CSVLine = New-TermLine -TermSetName $empty -TermSetDescription $empty -LCID $empty -AvailableForTagging "TRUE" -TermDescription $empty -Level1 $tempTerms[0] -Level2 $tempTerms[1] -Level3 $tempTerms[2] -Level4 $tempTerms[3] -Level5 $tempTerms[4] -Level6 $tempTerms[5] -Level7 $tempTerms[6]
                #add the new line
                $terms+=$CSVLine
            }
            #export all of the terms to a CSV file
            Write-Verbose -message "Exporting to $CSVFile ..."
            $terms | Export-Csv $CSVFile -notype
        }
    }
    $taxonomySite.dispose()
}

#constructor
function New-TermLine() {
    param($TermSetName, $TermSetDescription, $LCID, $AvailableForTagging, $TermDescription, $Level1, $Level2, $Level3, $Level4, $Level5, $Level6, $Level7)
    $term = New-Object PSObject
    $term | Add-Member -Name "TermSetName" -MemberType NoteProperty -Value $TermSetName
    $term | Add-Member -Name "TermSetDescription" -MemberType NoteProperty -Value $TermSetDescription
    $term | Add-Member -Name "LCID" -MemberType NoteProperty -Value $LCID
    $term | Add-Member -Name "AvailableForTagging" -MemberType NoteProperty -Value $AvailableForTagging
    $term | Add-Member -Name "TermDescription" -MemberType NoteProperty -Value $TermDescription
    $term | Add-Member -Name "Level1" -MemberType NoteProperty -Value $Level1
    $term | Add-Member -Name "Level2" -MemberType NoteProperty -Value $Level2
    $term | Add-Member -Name "Level3" -MemberType NoteProperty -Value $Level3
    $term | Add-Member -Name "Level4" -MemberType NoteProperty -Value $Level4
    $term | Add-Member -Name "Level5" -MemberType NoteProperty -Value $Level5
    $term | Add-Member -Name "Level6" -MemberType NoteProperty -Value $Level6
    $term | Add-Member -Name "Level7" -MemberType NoteProperty -Value $Level7
    return $term
}