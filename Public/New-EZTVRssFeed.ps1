Function New-EZTVRssFeed
{
    <#
    .SYNOPSIS
        Used to create RSS feed from GetMagnetLinks() method returned as part of the object returned by Get-EZTVShows.
    .DESCRIPTION
        Long description
    .EXAMPLE
        $ShowList = Get-EZTVShows
        $PickedShows  = $ShowList | Out-GridView -PassThru # Use Out-GridView to pick from list of shows 
        $BrooklynMags = $PickedShows[1].GetMagnetLinks() # Get Mangnet links for the second element in $PickedShows
        $BrooklynMags | New-EZTVRssFeed -ShowName $BrooklynMags[0].ShowName | Out-File .\BrooklynNine.xml # Create an XML file of RSS for Torrent client in Current Directory.
        This will create an xml file that can be consumed by a torrent client for the show picked from the scraping Results
        from the EZTV website.
        One way to simply serve this from your computer, is to use Python as a simple HTTP server. For Python 3, refer to
        localhostWebserver.py. Run by python.exe .\localhostWebserver.py from Powershell or CMD.

    #>
    [CmdletBinding()]
    param 
    (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True)]            
        $Results,
		[Parameter(Mandatory=$True)]            
        [string]$ShowName        
    )
    Begin
    {

        Write-Verbose "Using $ShowName"
        $FinalRSS = @()
        $RssHereStringStart = @"
<rss xmlns:torrent="http://xmlns.ezrss.it/0.1/" version="2.0">
<channel>
<title>ezRSS - $ShowName Feed</title>
<description>Custom RSS feed for $ShowName</description>
"@
        $FinalRSS += $RssHereStringStart
    }
    Process
    {
        # create RSS ShowFeed out of Magent Links
        ForEach($link in $Results)
        {
            $EpisodeHereString = @"
<item>
<title>$($link.title)</title>
<link>$($link.magnetURI)</link>
</item>
"@
            $FinalRSS += $EpisodeHereString
        }
    }
    End 
    {
        $EndRSSTags = @"
</channel>
</rss>
"@
        $FinalRSS += $EndRSSTags
        $FinalRSS
    }
}