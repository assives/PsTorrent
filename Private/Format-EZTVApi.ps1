function Format-EZTVApi {
    [CmdletBinding()]
    param 
    (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True)]            
        $Results
    )
    
    begin {
    }
    
    process {
 $Results.PSTypeNames.Insert(0,"EZTV.ApiInfo")
        Write-Verbose "Currently formatting object for $($Results.title)"

        Update-TypeData -TypeName "EZTV.ApiInfo" -MemberType ScriptProperty -MemberName MagnetURI -Value {$this.magnet_url} -Force
        
        Update-TypeData -TypeName "EZTV.ApiInfo" -MemberType ScriptMethod -MemberName DownloadTorrent -Value {Start-Process $this.MagnetURI} -Force
        
       Update-TypeData -TypeName "EZTV.ApiInfo" -DefaultDisplayPropertySet Title, size_bytes, filename  -Force 
        $Results        
    }
    
    end {
    }
}