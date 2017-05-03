function Format-ExtraTorrent {
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
        $Results.PSTypeNames.Insert(0,"ExtraTorrent.SearchList")
        Write-Verbose "Currently formatting object for $($Results.title)"
        # Not sure what about the below to breaks this formatting, but they do if they are used.
        # Update-TypeData -TypeName "ExtraTorrent.SearchList" -MemberType ScriptProperty -MemberName MagnetLink -Value {$this.magnetUri.'#cdata-section'} -Force
        # Update-TypeData -TypeName "ExtraTorrent.SearchList" -MemberType ScriptProperty -MemberName TitleString -Value {$this.title.'#cdata-section'} -Force
        # Update-TypeData -TypeName "ExtraTorrent.SearchList" -MemberType ScriptProperty -MemberName Seeders -Value {If($this.seeders -match '---'){$null}else{[int]$this.seeders}} -Force
        Update-TypeData -TypeName "ExtraTorrent.SearchList" -MemberType ScriptMethod -MemberName DownloadTorrent -Value {Start-Process $this.MagnetUri} -Force
        
       Update-TypeData -TypeName "ExtraTorrent.SearchList" -DefaultDisplayPropertySet Title, Size, seeders, leechers  -Force 
        $Results        
    }
    
    end {
    }
}