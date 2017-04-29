Function Get-EZTVShows
{
    <#
    .SYNOPSIS
        Gets list of all Shows on EZTV's website.
    .DESCRIPTION
        Gets list of all Shows on EZTV's website. Returns them as EZTV.ShowList type objects.
        Adds two methods, OpenLink (which opens default browser to that show's page on EZTV) and 
        GetMagnetLinks (which returns an object of all the Magnet Links found on that shows page on EZTV).
        The Second method is the meat of the functionality against EZTV.
    .EXAMPLE
        $ShowList = Get-EZTVShows
        Gets all TV Shows from EZTV and stores it in variable.

    .EXAMPLE
        $ShowList = Get-EZTVShows
        $StarWarShows = $ShowList | Where {$_.ShowName -like "*Star*Wars*"}

        Gets all TV Shows from EZTV and stores it in variable.
        Then filters using Where-Object to ShowNames that are like Star Wars.

    .EXAMPLE
        $ShowList = Get-EZTVShows
        $StarWarShows = $ShowList | Where {$_.ShowName -like "*Star*Wars*"}
        ForEach($Show in $StarWarShows) {
            $ShowName = Remove-InvalidFileNameChars $Show.ShowName # Use helper function to get rid of illegal file name characters
            $Show.GetMagnetLinks() | New-EZTVRssFeed -ShowName $ShowName -Verbose | Out-File "$PWD\$ShowName Feed.xml"
        }

        Above will create an RSS feed file for each of the Star Wars shows found on EZTV.
        Use that RSS Feed file with a Torrent client like qBittorrent. If using locally only,
        you Python 3 and the localhostWebserver.py file.
    .NOTES
        This function will take a little bit to run, there is quite a bit of shows to get.
        Want to add filtering based on show status to this function.
    #>
    [CmdletBinding()]
    param()    
    # get list of all shows
    $ShowList = Invoke-WebRequest -Uri "$($EZTVBaseURI)/showlist/"
    $ShowList = $ShowList.Links | Where {$_.href -like "/shows/*"} | Format-EZTVShowList
    $ShowList
}