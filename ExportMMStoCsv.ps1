    # Outputs CSV of the specified termset from the specificed termstore/group
# Example call:
# .\ExportMMStoCsv.ps1 "https://contoso.com:12345" "Managed Metadata Service"
param ([string]$centralAdminUrl = "https://contoso.com:12345",
[string] $termStoreName = "Managed Metadata Service"
)
Add-PSSnapin microsoft.sharepoint.powershell

$maxLevels = 5
 
function Export-SPTermStoreGroupTerms()
{
 
    $isValid = $true;
    $message = "";
 
    if ($centralAdminUrl.Length -eq 0) { $message = "Please provide a central admin URL"; $isValid = $false; }
 
    if ($isValid -eq $false)
    {
        write-host "ERROR OCCURRED`t$message"
        write-host "NAME`tExport-SPTermStoreGroupTerms"
        write-host "SYNOPSIS`tReturns a CSV file containing a listing of term names and identifiers from the supplied term set."
        write-host "SYNTAX`tExport-SPTermStoreGroupTerms centralAdminUrl termStoreName termGroupName termSetName outPutDir"
        write-host "EXAMPLES Export-SPTermStoreGroupTerms ""http://sp2010"" ""Managed Metadata Service"" ""Enterprise Metadata"" ""Business Units"""
        return;
    }
 
    try
    {
        $ErrorActionPreference = "Stop";
 
        try
        {
            $site = Get-SPSite $centralAdminUrl;
            $taxSession = new-object Microsoft.SharePoint.Taxonomy.TaxonomySession($site, $true);
 
            try
            {
                $termStore = $taxSession.TermStores[$termStoreName];
 
                if ($termStore -ne $null)
                {
                    try
                    {
                        $filename = $centralAdminUrl.Replace("https://","").Replace("/","").Replace(":","")
                        $time = (Get-Date).tostring("ddMMyyyy_hhmmss")
                        $outPutFile =  (Get-Location).Path + [string]::Format("\{0}_{1}.csv", $filename,$time);
                        $sb = new-object System.Text.StringBuilder;
                        $sb.Append("TermGroup, TermSet,Term,Level2, Level3,Level4,Level5,UpdatedTitle,Url,FriendlyUrl,CatalogTargetUrl,CatalogChildTargetUrl,TargetUrl,ChildTargetUrl,LastModified,Action,Status");

                        [Byte[]] $ampersand = 0xEF,0xBC,0x86;

                        foreach ($termGroup in $termStore.Groups)
                        {
                            $termgroupName =  $termGroup.Name.Replace([System.Text.Encoding]::UTF8.GetString($ampersand), "&") 

                            if ($termgroupName.equals("system", [stringcomparison]::OrdinalIgnoreCase) -eq $false)
                            {
                                try
                                {
                                    foreach($termSet in $termGroup.TermSets)
                                    {
                                        $termsetName  = $termSet.Name.Replace([System.Text.Encoding]::UTF8.GetString($ampersand), "&")

                                        foreach ($term in $termSet.Terms)
                                        { 
                                            write-host $termgroupName ","$termsetName","$termName
                                            $termName = $term.Name.Replace([System.Text.Encoding]::UTF8.GetString($ampersand), "&")

                                            $custProp1 = $term.LocalCustomProperties["_Sys_Nav_SimpleLinkUrl"]
                                            $custProp2 = $term.LocalCustomProperties["_Sys_Nav_FriendlyUrlSegment"]
                                            $custProp3 = $term.LocalCustomProperties["_Sys_Nav_CatalogTargetUrl"];
                                            $custProp4 = $term.LocalCustomProperties["_Sys_Nav_CatalogTargetUrlForChildTerms"];
                                            $custProp5 = $term.LocalCustomProperties["_Sys_Nav_TargetUrl"];
                                            $custProp6 = $term.LocalCustomProperties["_Sys_Nav_TargetUrlForChildTerms"];
                                            $custProp7 = $term.LastModifiedDate.ToString("MM/dd/yyyy HH:mm:ss");

                                            $sb1 = new-object System.Text.StringBuilder;
                                            addOutPutField -sb1 $sb1 -field $termgroupName
                                            addOutPutField -sb1 $sb1 -field $termsetName
                                            addOutPutField -sb1 $sb1 -field $termName 
                                           
                                            $path = $sb1.ToString();
                                            addEmptyFields -sb1 $sb1 -count 5
                                            
                                            addOutPutField -sb1 $sb1 -field $custProp1
                                            addOutPutField -sb1 $sb1 -field $custProp2
                                            addOutPutField -sb1 $sb1 -field $custProp3
                                            addOutPutField -sb1 $sb1 -field $custProp4
                                            addOutPutField -sb1 $sb1 -field $custProp5
                                            addOutPutField -sb1 $sb1 -field $custProp6
                                            addOutPutField -sb1 $sb1 -field $custProp7
                                            addEmptyFields -sb1 $sb1 -count 2

                                            $sb.AppendLine();
                                            $sb.Append($sb1.ToString());
                                            $sb1.Clear()
                                            GetChildTerms -term $term -path $path -sb $sb
                                        }                                    
                                    }
                                }
                                catch
                                {
                                    "Unable to acquire the termset from the term group"
                                }
                            }
                        }

                        $sw = new-object system.IO.StreamWriter($outPutFile);
                        $sw.Write($sb.ToString());
                        $sw.close();
                        write-host "Your CSV has been created at $outPutFile";
                    }
                    catch
                    {
                        "Unable to acquire term store group"
                    }
                }
            }
            catch
            {
                "Unable to acquire term store"
            }
        }
        catch
        {
            "Unable to acquire session for the site $centralAdminUrl"
        }
    }
    catch
    {
 
    }
    finally
    {
        $ErrorActionPreference = "Continue";
    }
}

function addOutPutField($sb1, $field){
    $val = "";
    if ($field)
    {
        $val = $field;
    }

    if($sb1.Length -gt 0)
    {
        $sb1.AppendFormat(",{0}",$val);
    }
    else
    {
        $sb1.Append($val);
    }
}

function addEmptyFields($sb1, $count){
    for($i=1; $i -le $count; $i++)
    {
        $sb1.Append(",");
    }
}

function GetChildTerms($term, [object]$path, $sb){
    if ($term.TermsCount -gt 0)
    {
        foreach ($childterm in $term.terms)
        { 
            $termName = $childterm.Name.Replace([System.Text.Encoding]::UTF8.GetString($ampersand), "&")
            $custProp1 = $childterm.LocalCustomProperties["_Sys_Nav_SimpleLinkUrl"]
            $custProp2 = $childterm.LocalCustomProperties["_Sys_Nav_FriendlyUrlSegment"]
            $custProp3 = $childterm.LocalCustomProperties["_Sys_Nav_CatalogTargetUrl"];
            $custProp4 = $childterm.LocalCustomProperties["_Sys_Nav_CatalogTargetUrlForChildTerms"];
            $custProp5 = $childterm.LocalCustomProperties["_Sys_Nav_TargetUrl"];
            $custProp6 = $childterm.LocalCustomProperties["_Sys_Nav_TargetUrlForChildTerms"];
            $custProp7 = $childterm.LastModifiedDate.ToString("MM/dd/yyyy HH:mm:ss");

            $sb11 = new-object System.Text.StringBuilder;
            addOutPutField -sb1 $sb11 -field $path
            addOutPutField -sb1 $sb11 -field $termName
            [object] $childpath = $sb11.ToString();
            $fields = $sb11.ToString().split(',')
            addEmptyFields -sb1 $sb11 -count ($maxLevels - $fields.length + 3)
            addOutPutField -sb1 $sb11 -field $custProp1
            addOutPutField -sb1 $sb11 -field $custProp2
            addOutPutField -sb1 $sb11 -field $custProp3
            addOutPutField -sb1 $sb11 -field $custProp4
            addOutPutField -sb1 $sb11 -field $custProp5
            addOutPutField -sb1 $sb11 -field $custProp6
            addOutPutField -sb1 $sb11 -field $custProp7
            addEmptyFields -sb1 $sb11 -count 2

            $sb.AppendLine();
            $sb.Append($sb11.ToString());
            write-host $childpath;
            $sb11.Clear()
            #$sw.writeline($towrite);
            
            GetChildTerms -term $childterm -path $childpath -sb $sb
        }
    }

    $path = "";
}

Export-SPTermStoreGroupTerms