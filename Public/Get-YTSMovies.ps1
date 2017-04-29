Function Get-YTSMovies
{
    <#
    .SYNOPSIS
        Function for the list_movies section of the YTS API. Only API used by this module.
    .DESCRIPTION
        Long description
    .EXAMPLE
        $MovieList = Get-YTSMovies
        Gets the first 20 results from YTS.

    .EXAMPLE
        $MovieList = Get-YTSMovies
        $MovieList | New-YTSRssFeed | Out-File .\WebServer\Feeds\YTSMovieFeeds.xml

        Gets the first 20 results from YTS. Pipes that to New-YTSRssFeed and creates an xml file out of results.
        To be used by a torrent client like qBittorrent.

    .EXAMPLE
        Get-YTSMovies -options "{'query_term':'frozen'}" -ov FrozenResults -Verbose

        Finds movies using the query parameter of the API.

    .EXAMPLE
        Get-YTSMovies -options "{'query_term':'frozen','genre':'family'}" -ov FrozenResultsFamily -Verbose

        Finds movies using the query and genre parameters of the API. Shows how to use mutliple parameters.

    .EXAMPLE
        $query = Read-Host "Search for a movie"
        $genre = Read-Host "Enter genre to filter down to"
        $jsonObj = @"
        {'query_term':'$query',
         'genre':'$genre',
         'quality':'720p'
        }
        "@
        Get-YTSMovies -options $jsonObj -ov jsonObjResults -Verbose

        Demonstrates using a Here-String to build the json needed for the -options parameter. This is the best way to use
        variables in the options parameter.

    .EXAMPLE
        $FantasyMovies = Get-YTSMovies -options "{'genre':'fantasy'}"
        $CountOfFantasyMovies = $FantasyMovies[0].MovieCount
        $NumberOfRuns = [int]($CountOfFantasyMovies / 50)
        $AllFantasyMovies = ForEach($num in (1..$NumberOfRuns))
        {
            Get-YTSMovies -options '{"genre":"fantasy","page":"$num","limit":"50"}' -Verbose
        }

        Demonstrates looping to get an object back with all of the results found by the YTS API.

    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName="Options")]
    param 
    (
		[Parameter(Mandatory=$False, ParameterSetName = "Options")]            
        $options,
        # Parameter help description
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true, ParameterSetName = "Movie")]
        [string]
        $Movie,
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Movie")]
        [ValidateSet("720p", "1080p", "3D")] 
        [string]
        $Quality    
    )
    Begin{}
    Process
    {
        If($options)
        {
            # Below will not create a $url if New-YTSQuery returns $null
            $QueryResult = New-YTSQuery -options $options
            If($QueryResult)
            {
                $url = $YTSBaseUri + 'list_movies.json?' +  '&' + $($QueryResult)
            }

        }
        If($Movie -notlike "")
        {
            $jsonObj = @"
            {'query_term':'$Movie',
            'quality':'$Quality'
            }
"@
            $QueryResult = New-YTSQuery -options $jsonObj
            If($QueryResult -ne $null)
            {
                $url = $YTSBaseUri + 'list_movies.json?' +  '&' + $($QueryResult)
            }
        }
        else 
        {
            $url = $YTSBaseUri + 'list_movies.json?'
        }
        If($url)
        {
            Write-Verbose "Sending Url of $url"        
            $Results = Invoke-RestMethod -Uri $url # Refer to https://yts.ag/api for info about API
            If($Results.status -eq 'OK')
            {
                $ResultCount = $Results.data.movie_count
                If($ResultCount -ne 0)
                {
                    $Results = $Results.data.movies # get the results from json data returned from YTS API
                    $Results | Format-YTSMovieList -Count $ResultCount
                }
                else {
                    Write-Warning "Did not find a result using url of $($url)"
                    $Results
                }
            }
            else 
            {
                Write-Warning "Did not get succcessful return from YTS API" 
                $Results  
            }
        }
        else 
        {
            Write-Warning "Failed to create a valid url to send"
        }
    }
    End{}  
}