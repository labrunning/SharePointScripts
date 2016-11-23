function Get-HUSPMDriveAudit {
	[CmdletBinding()]
    Param()

    $currLocation = (Get-Item -Path ".\" -Verbose).FullName

    Write-Verbose "Current Location is $currLocation"

    $illegalFileTypes = @(
        "*.ade","*.adp","*.asa","*.ashx","*.asmx","*.asp","*.bas","*.bat","*.cdx","*.cer","*.chm","*.class","*.cmd","*.cnt","*.com","*.config","*.cpl","*.crt","*.csh","*.der","*.dll","*.exe","*.fxp","*.gadget","*.grp","*.hlp","*.hpj","*.hta","*.htr","*.htw","*.ida","*.idc","*.idq","*.ins","*.isp","*.its","*.jse","*.json","*.ksh","*.lnk","*.mad","*.maf","*.mag","*.mam","*.maq","*.mar","*.mas","*.mat","*.mau","*.mav","*.maw","*.mcf","*.mda","*.mdb","*.mde","*.mdt","*.mdw","*.mdz","*.msc","*.msh","*.msh1","*.msh1xml","*.msh2","*.msh2xml","*.mshxml","*.msi","*.ms-one-stub","*.msp","*.mst","*.ops","*.pcd","*.pif","*.pl","*.prf","*.prg","*.printer","*.ps1","*.ps1xml","*.ps2","*.ps2xml","*.psc1","*.psc2","*.pst","*.reg","*.rem","*.scf","*.scr","*.sct","*.shb","*.shs","*.shtm","*.shtml","*.soap","*.stm","*.svc","*.url","*.vb","*.vbe","*.vbs","*.vsix","*.ws","*.wsc","*.wsf","*.wsh","*.xamlx","._*",".DS*"
    )
    
    <#$illegalFileTypes = @(
        "*.lnk","*.url"
    )#>

    If ($currLocation -eq "M:\" ) {
        
        # Create the object collection
        $myAuditCollection=@()

        # Go through all the directories begging with 1 to 6
        Get-ChildItem ./[1-6]* -Attributes Directory -Name | Sort | ForEach {
            Write-Verbose "Files listed for $_ :"
            
            # Loop through all the illegal file types§
            ForEach ($fileType in $illegalFileTypes) {
                Write-Verbose "Checking for $fileType files..."
                
                # For each detected file, create an object and add the property values we want
                Get-ChildItem ./$_ -include "$fileType" -Recurse -Force | ForEach-Object {

                    Write-Verbose "File $_.Name flagged in $_.DirectoryName"
                    
                    $myAuditObject = New-Object PSObject
                
                    Add-Member -InputObject $myAuditObject -MemberType NoteProperty -Name DirectoryName -Value ""
                    Add-Member -InputObject $myAuditObject -MemberType NoteProperty -Name Name -Value ""
                    Add-Member -InputObject $myAuditObject -MemberType NoteProperty -Name CreationTime -Value ""
                    Add-Member -InputObject $myAuditObject -MemberType NoteProperty -Name LastAccessTime -Value ""
                    Add-Member -InputObject $myAuditObject -MemberType NoteProperty -Name Owner -Value ""

                    $myAuditObject.DirectoryName = $_.DirectoryName
                    $myAuditObject.Name = $_.Name
                    $myAuditObject.CreationTime = $_.CreationTime
                    $myAuditObject.LastAccessTime = $_.LastAccessTime
                    $myAuditObject.Owner = ((Get-ACL $_.FullName).Owner)

                    $myAuditCollection += $myAuditObject
                }
            }
        }
    
        $myAuditCollection | Format-Table -Autosize
    
    } else {
        Write-Host "Wrong Directory!" 
    }
}
