Function Format-YTSMovieList
{
    [CmdletBinding()]
    param 
    (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True)]            
        $Results,
		[Parameter(Mandatory=$True,
		ValueFromPipelineByPropertyName=$True)]            
        $Count        
    )
    Process
    {
        $Results.PSTypeNames.Insert(0,"YTS.MovieList")
        Write-Verbose "Currently working on $($Results.title)" # title
        Update-TypeData -TypeName "YTS.MovieList" -MemberType NoteProperty -MemberName MovieCount -Value $Count -Force
        Update-TypeData -TypeName "YTS.MovieList" -MemberType ScriptProperty -MemberName MagnetLinks -Value {$Title = ($this.title) -replace ' & ','&amp;';; $this.torrents.ForEach({
                                                                                                                                $hash = $_.hash
                                                                                                                                $magnetURI = 'magnet:?xt=urn:btih:' + $hash + '&amp;dn=' + $Title + $($YTSTrackers.ForEach({'&amp;tr=' + $_}) -join "")
                                                                                                                                $magnetURI
                                                                                                                            })
                                                                                                            } -Force       
        Update-TypeData -TypeName "YTS.MovieList" -MemberType ScriptMethod -MemberName DownloadTorrent -Value {                                                                                                                              $magnetURI
                                                                                                                Start-Process $this.magnetLinks[0]
                                                                                                                Start-Sleep 1 # Add a little delay
                                                                                                            } -Force  
        $Results
    }
}