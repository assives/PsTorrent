Function Format-PirateBaySearch
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
        $Results.PSTypeNames.Insert(0,"TBP.SearchList")
        Write-Verbose "Currently working on $($Results.title)" # title
        Update-TypeData -TypeName "TBP.SearchList" -MemberType ScriptMethod -MemberName DownloadTorrent -Value {                                                                                                                              $magnetURI
                                                                                                                Start-Process $this.MagnetLink
                                                                                                                Start-Sleep 1 # Add a little delay
                                                                                                            } -Force  
        
        Update-TypeData -TypeName "TBP.SearchList" -DefaultDisplayPropertySet Title, Uploader, Size, UploadDate -Force

        $Results
    }
}