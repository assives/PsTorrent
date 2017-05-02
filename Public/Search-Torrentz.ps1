function Search-Torrentz {
    <#
    .SYNOPSIS
        A function for searching torrentz.ht
    .DESCRIPTION
        A function for searching torrentz.ht
        First scrapes the search result page for links, then goes to each of those links, scraping 
        information from the page to create a PowerShell object with a Title, Size, MagnetUri and FileSize
        properties as well as the DownloadTorrent method.
    .EXAMPLE
        $WalkingDead = Search-Torrentz -Query "Walking Dead"
        $Selected = $WalkingDead | Out-GridView -PassThru
        $Selected | Start-MangetLink

        Gets the first fifty results from a search for Walking Dead and stores it in a variable.
        That variable is then passed to Out-GridView for a simple menu selection.
        The selected items are stored in a varable which is piped to Start-MagnetLink to actully start
        downloading those torrents.

    .EXAMPLE
        $LinuxOS = Search-Torrentz -Query "ubuntu iso","CentOS iso" -Verbose
        $LinuxOS | Where {$_.FileSize -ge 500MB}

        Gets the results from both a search for ubuntu iso and CentOS iso using the Verbose message output and
        stores it in a variable. That variable is then piped to Where-Object to filter down to only the results
        that are greater or equal to 500MB. Demonstrates the ability to filter by FileSize on returned object.

    .INPUTS
        A string or array of strings
    .OUTPUTS
        A Torrentz.SearchList type object.
    .NOTES
        This function is a little slower than the others due to having to do quite a bit more
        Invoke-WebRequests to get the relevant information for the search results.
    #>
    [CmdletBinding()]
    param (
        # The string or array of strings to search for
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $Query
    )
    
    begin {
        $TorrentzBaseURI = 'https://torrentz.ht/search?f'
    }
    
    process {
        foreach($Search in $Query)
        {
            $search = $Search -replace "/s+",'+'
            $results = Invoke-WebRequest -Uri "$TorrentzBaseURI=$Search"
            # extract links
            $NotThese = @("Torrentz","Search","myTorrentz","Profile","Help")
            Write-Verbose "Getting torrent links for search result for $search"
            $Links = $results.links | Where {$_.href -like "https://torrentz.ht/*" -and $_.outerText -notin $NotThese}
            $Torrentz = foreach($link in $Links)
            {
                Write-Verbose "Getting information from each link"
                # Get actual value and magnet uris for first page of search results. 50 results.
                $TorrentInfo = Invoke-WebRequest -Uri $link.href
                # Gather the three pieces of info required for a MagnetUri, Title, hash, and trackers
                Write-Verbose "Gathering trackers"
                $TorrentzTrackers = ($TorrentInfo.Links | Where {$_.outerText -like "udp://*"}).outerText
                Write-Verbose "Getting hash for torrent"
                $TorrentHash = ($TorrentInfo.InputFields | Where {$_.Name -eq 'hash'}).value
                # This page has no good id tags, so gonna parse the entire thing into a two property object
                Write-Verbose "Parsing rawcontent to get Title and Size"
                $i = 0
                $TorrentInfoByLine = $TorrentInfo.RawContent.Split([Environment]::NewLine) | ForEach-Object {
                    New-Object -TypeName psobject -Property @{LineText=$_;LineNumber=$i}
                    $i++
                }
                $Start = ($TorrentInfoByLine | Where {$_ -like "*div*Size:*"}).LineNumber
                $End = ($TorrentInfoByLine | Where {$_ -like "*Please note that this*"}).LineNumber -1
                $TableInfo = $TorrentInfoByLine[$Start..$End]
                # strip out HTML chars
                $Info = $TableInfo.LineText.Trim() -replace "<\w+>" -replace "</\w+>" -replace ".*>" | Where {$_}
                $SizeString = $Info[0] -replace "Size: "
                $Title = $Info[2]
                Write-Verbose "Creating magnet uri from gathered Title, Hash, and trackers"
                $MagnetUri = 'magnet:?xt=urn:btih:' + $TorrentHash + '&amp;dn=' + $Title + $($TorrentzTrackers.ForEach({'&amp;tr=' + $_}) -join "")
                # $Title =
                $props = @{
                    Title=$Title
                    Size=$SizeString
                    MagnetUri=$MagnetUri
                } 
                New-Object -TypeName psobject -Property $props
            }
            # Pipe to format to add method DownloadTorrent and add FileSize property.
            $Torrentz | Format-TorrentzSearch
        }

    }
    
    end {
    }
}
