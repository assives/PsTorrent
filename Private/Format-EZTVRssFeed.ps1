Function Format-EZTVRssFeed
{
    [CmdletBinding()]
    param 
    (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True)]            
        $Results
    )
    Process
    {
        $Results.PSTypeNames.Insert(0,"EZTV.ShowFeed")

        Update-TypeData -TypeName "EZTV.ShowFeed" -MemberType ScriptProperty -MemberName NewmagnetURI -Value {$this.magnetURI.'#cdata-section'} -Force
        # Create a method to open the TV show episode link returned
        Update-TypeData -TypeName "EZTV.ShowFeed" -MemberType ScriptMethod -MemberName OpenLink -Value {Start-Process "$($this.link)"} -Force # Should open in default browser
        $Results
    } 
}