Function New-YTSRssFeed
{
    <#
    .SYNOPSIS
        Short
    .DESCRIPTION
        Long description
    .EXAMPLE
        example

    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param 
    (
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True)]            
        $Results    
    )
    Begin
    {
        $FinalRSS = @()
        $RssHereStringStart = @"
<rss xmlns:torrent="http://xmlns.ytsrss.ag/0.1/" version="2.0">
<channel>
<title>ytsRSS - Movie List Feed</title>
<description>Custom RSS feed for Movie List</description>
"@
        $FinalRSS += $RssHereStringStart
    }
    Process
    {
        # create RSS ShowFeed out of Magent Links
        $i = 0
        ForEach($link in $Results.MagnetLinks)
        {
            # $YTSMoviesFormat[0].torrents.quality
            # $YTSMoviesFormat[0].torrents.size
            $title = "$($Results.title -replace "&",'and') $($Results.torrents[$i].quality) $($Results.torrents[$i].size)"
            $i++
            Write-Verbose "Using $title"
            $MovieHereString = @"
<item>
<title>$($title)</title>
<link>$($link)</link>
</item>
"@
            $FinalRSS += $MovieHereString
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