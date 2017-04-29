Function Get-NewMovieRelease
{
    <#
    .SYNOPSIS
        A function for scraping moviefone for new movie releases out on DVD.
    .DESCRIPTION
        A function for scraping moviefone for new movie releases out on DVD.
        Relies on www.moviefone.com/dvd and that website not changing too much.
    .EXAMPLE
        Get-NewMovieRelease
        Gets a list of the new movie release out on dvd.

    .EXAMPLE
        $Movies = Get-NewMovieRelease
        $NewMovies = $Movies | Where {$_.ReleaseDate -ge (Get-Date).AddDays(-2)}
        $YTSResults = $NewMovies | Get-YTSMovies -Quality 720p
        $FinalResults = $YTSResults | Where {$_.MagnetLinks -and $_.Title -in $NewMovies.Movie} 
        $FinalResults | 
        ForEach-Object {
            $_.DownloadTorrent() # Will use a start-process against the Magnet Link returned
        }
        # Need to add some kind of delay to DownloadTorrent method, this example crashed qBittorent

        Will get a list of new movie releases out on dvd. This is then filtered to get only results that 
        were released after Monday, since this example was done on Wednesday, hence the AddDays(-2). 
        This object is then piped to Get-YTSMovies, which will use the Yiffy YTS API to get torrent links for each of those movies.
        The results of that function are then piped to Where-Object, to get only results with a property of
        MagnetLinks that also has a Title that is in the list of $NewMovies (This gets rid of matches that may be extraneous, like
        Split returning both Split and Split Second). Those filtered results are then
        piped to a ForEach-Object, which invokes the DownloadTorrent method on those objects, which does 
        a Start-Process against the MagnetLink which will open the file in the torrent client that
        magnet links are associated with.
    .NOTES
        Relies on web scraping, so could break if website changes.
    #>
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)]
        [string]
        $url = 'https://www.moviefone.com/dvd/'     
    )
    begin {
    }
    
    process {
        # Get the date to a day before Tuesday so only current releases are displayed
        # $Date = (Get-Date)    
        # If($Date.DayOfWeek -ne "Monday")
        # {
        #     Do{
        #         $Date = $Date.AddDays(-1)
        #     }
        #     Until($Date.DayOfWeek -eq "Monday")
        # }
        $response = Invoke-WebRequest -Uri $url
        $list = $response.ParsedHtml.body.getElementsByClassName("movie-inner") | select *outerText*

        $MovieResults = foreach($movie in $list)
        {
            $MovieInfo = $movie.outerText.split([Environment]::NewLine) | Where {$_}
            $props = @{
                       Movie=$MovieInfo[0]
                       Rating=$MovieInfo[1]
                       ReleaseDate=Get-Date ($MovieInfo[-1] -replace "Available ")
            }
            New-Object -TypeName psobject -Property $props
        }
        $MovieResults
        # $MovieResults | Where {$_.ReleaseDate -ge $Date}
          
    }
    
    end {
    }
}