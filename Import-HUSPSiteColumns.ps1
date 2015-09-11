function Import-HUSPSiteColumns {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$web,
        [Parameter(Mandatory=$True,Position=2)]
        [string]$input
    )

    $destWeb = Get-SPWeb $web
    $installPath = $input
    
    #Get exported XML file
    $fieldsXML = [xml](Get-Content($installPath))
    
    $fieldsXML.Fields.Field | ForEach-Object {
        
        #Configure core properties belonging to all column types
        $fieldXML = '<Field Type="' + $_.Type + '"
        Name="' + $_.Name + '"
        ID="' + $_.ID + '"
        Description="' + $_.Description + '"
        DisplayName="' + $_.DisplayName + '"
        StaticName="' + $_.StaticName + '"
        Group="' + $_.Group + '"
        Hidden="' + $_.Hidden + '"
        Required="' + $_.Required + '"
        Sealed="' + $_.Sealed + '"'
        
        #Configure optional properties belonging to specific column types – you may need to add some extra properties here if present in your XML file
        if ($_.ShowInDisplayForm) { $fieldXML = $fieldXML + "`n" + 'ShowInDisplayForm="' + $_.ShowInDisplayForm + '"'}
        if ($_.ShowInEditForm) { $fieldXML = $fieldXML + "`n" + 'ShowInEditForm="' + $_.ShowInEditForm + '"'}
        if ($_.ShowInListSettings) { $fieldXML = $fieldXML + "`n" + 'ShowInListSettings="' + $_.ShowInListSettings + '"'}
        if ($_.ShowInNewForm) { $fieldXML = $fieldXML + "`n" + 'ShowInNewForm="' + $_.ShowInNewForm + '"'}
            
        if ($_.EnforceUniqueValues) { $fieldXML = $fieldXML + "`n" + 'EnforceUniqueValues="' + $_.EnforceUniqueValues + '"'}
        if ($_.Indexed) { $fieldXML = $fieldXML + "`n" + 'Indexed="' + $_.Indexed + '"'}
        if ($_.Format) { $fieldXML = $fieldXML + "`n" + 'Format="' + $_.Format + '"'}
        if ($_.MaxLength) { $fieldXML = $fieldXML + "`n" + 'MaxLength="' + $_.MaxLength + '"' }
        if ($_.FillInChoice) { $fieldXML = $fieldXML + "`n" + 'FillInChoice="' + $_.FillInChoice + '"' }
        if ($_.NumLines) { $fieldXML = $fieldXML + "`n" + 'NumLines="' + $_.NumLines + '"' }
        if ($_.RichText) { $fieldXML = $fieldXML + "`n" + 'RichText="' + $_.RichText + '"' }
        if ($_.RichTextMode) { $fieldXML = $fieldXML + "`n" + 'RichTextMode="' + $_.RichTextMode + '"' }
        if ($_.IsolateStyles) { $fieldXML = $fieldXML + "`n" + 'IsolateStyles="' + $_.IsolateStyles + '"' }
        if ($_.AppendOnly) { $fieldXML = $fieldXML + "`n" + 'AppendOnly="' + $_.AppendOnly + '"' }
        if ($_.Sortable) { $fieldXML = $fieldXML + "`n" + 'Sortable="' + $_.Sortable + '"' }
        if ($_.RestrictedMode) { $fieldXML = $fieldXML + "`n" + 'RestrictedMode="' + $_.RestrictedMode + '"' }
        if ($_.UnlimitedLengthInDocumentLibrary) { $fieldXML = $fieldXML + "`n" + 'UnlimitedLengthInDocumentLibrary="' + $_.UnlimitedLengthInDocumentLibrary + '"' }
        if ($_.CanToggleHidden) { $fieldXML = $fieldXML + "`n" + 'CanToggleHidden="' + $_.CanToggleHidden + '"' }
        if ($_.List) { $fieldXML = $fieldXML + "`n" + 'List="' + $_.List + '"' }
        if ($_.ShowField) { $fieldXML = $fieldXML + "`n" + 'ShowField="' + $_.ShowField + '"' }
        if ($_.UserSelectionMode) { $fieldXML = $fieldXML + "`n" + 'UserSelectionMode="' + $_.UserSelectionMode + '"' }
        if ($_.UserSelectionScope) { $fieldXML = $fieldXML + "`n" + 'UserSelectionScope="' + $_.UserSelectionScope + '"' }
        if ($_.BaseType) { $fieldXML = $fieldXML + "`n" + 'BaseType="' + $_.BaseType + '"' }
        if ($_.Mult) { $fieldXML = $fieldXML + "`n" + 'Mult="' + $_.Mult + '"' }
        if ($_.ReadOnly) { $fieldXML = $fieldXML + "`n" + 'ReadOnly="' + $_.ReadOnly + '"' }
        if ($_.FieldRef) { $fieldXML = $fieldXML + "`n" + 'FieldRef="' + $_.FieldRef + '"' }    
    
        $fieldXML = $fieldXML + ">"
        
        #Create choices if choice column
        if ($_.Type -eq "Choice") {
            $fieldXML = $fieldXML + "`n<CHOICES>"
            $_.Choices.Choice | ForEach-Object {
               $fieldXML = $fieldXML + "`n<CHOICE>" + $_ + "</CHOICE>"
            }
            $fieldXML = $fieldXML + "`n</CHOICES>"
        }
        
        #Set Default value, if specified  
        if ($_.Default) { $fieldXML = $fieldXML + "`n<Default>" + $_.Default + "</Default>" }
        
        #End XML tag specified for this field
        $fieldXML = $fieldXML + "</Field>"
        
        #Create column on the site
        $destWeb.Fields.AddFieldAsXml($fieldXML.Replace("&","&amp;"))
        Write-Verbose "Created site column" $_.DisplayName "on" $destWeb.Url
        
        $destWeb.Dispose()
    }
}
