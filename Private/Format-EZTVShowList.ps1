Function Format-EZTVShowList
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
        $Results.PSTypeNames.Insert(0,"EZTV.ShowList")
        Write-Verbose "Currently working on $($Results.innerText)"
        Update-TypeData -TypeName "EZTV.ShowList" -MemberType ScriptProperty -MemberName ShowName -Value {$this.innerText} -Force
        Update-TypeData -TypeName "EZTV.ShowList" -MemberType ScriptMethod -MemberName OpenLink -Value {Start-Process "$($EZTVBaseURI)$($this.href)"} -Force # Should open in default browser
        # below method is limited to a maxmium of 100 items. Newest items are returned first.
        Update-TypeData -TypeName "EZTV.ShowList" -MemberType ScriptMethod -MemberName GetMagnetLinks -Value {$ShowPage = Invoke-WebRequest -uri "$($EZTVBaseURI)$($this.href)"
                                                                                                              Write-Host "Currently getting Magnet Links for $($Results.innerText)"
                                                                                                              $ShowPage.Links |  Where {$_.class -eq "magnet"} | Format-EZTVShowEpisodes
                                                                                                             } -Force
        $Results
    }
}