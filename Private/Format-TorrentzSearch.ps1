function Format-TorrentzSearch {
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
 $Results.PSTypeNames.Insert(0,"Torrentz.SearchList")
        Write-Verbose "Currently formatting object for $($Results.title)"

        Update-TypeData -TypeName "Torrentz.SearchList" -MemberType ScriptProperty -MemberName FileSize -Value {$SizeInfo = $this.Size -split '\s+'
                                                                                                                $SizeUnit = $SizeInfo[-1]
                                                                                                                $SizeString = $SizeInfo[0]
                                                                                                                Convert-Size -To Bytes -From $Unit -Value $SizeString
                                                                                                                } -Force
        
        Update-TypeData -TypeName "Torrentz.SearchList" -MemberType ScriptMethod -MemberName DownloadTorrent -Value {Start-Process $this.MagnetURI} -Force
        
       Update-TypeData -TypeName "Torrentz.SearchList" -DefaultDisplayPropertySet Title, Size  -Force 
        $Results        
    }
    
    end {
    }
}