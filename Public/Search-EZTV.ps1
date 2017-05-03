Function Search-EZTV
{
    <#
    .SYNOPSIS
        Function for performing a search on EZTV
    .DESCRIPTION
        Function for performing a search on EZTV. Returns the magnet links found as a EZTV.ShowEpisode object.
        That object can be piped to the New-EZTVRssFeed function.
    .EXAMPLE
        Search-EZTV -Query "Once Upon A Time"
        Returns the magent links found for a search for Once Upon A Time on EZTV's website.
    .EXAMPLE
        $Show = Read-Host "Enter a show name to search EZTV for"
        $SearchTest = Search-EZTV -$Query "$Show"
        $SearchTest | Where {$_.Season -eq 6 -and $_.ShowName -like "*$Show*"} | 
        New-EZTVRssFeed -ShowName $Show | Out-File ".\$($Show) Feed.xml"

        Returns the magent links found for a search for Once Upon A Time on EZTV's website and stores it in a variable.
        This is the filtered to where the Season equals 6 and the ShowName is like Once Upon A Time. The original search result 
        may return shows that are not the show searched for (like Dexter in this example). That is then piped to New-EZTVRssFeed
        to create an XML Rss feed.
    .NOTES
        Useful for direct searching and when one show has more than 100 items, as that is the max returned on a show's page
        on EZTV.
    #>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$True,
		ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
		[string[]]$Query
	)
	Begin{}
    Process
    {
        foreach($Filter in $Query)
        {
            $Filter = $Filter -replace " ","-"
            $SearchResults = Invoke-Webrequest "$($EZTVBaseURI)/search/$($Filter)"
            $SearchMagnetLinks = $SearchResults.Links | Where {$_.class -eq "magnet"} | Format-EZTVShowEpisodes
            $SearchMagnetLinks
        }
    }  
}