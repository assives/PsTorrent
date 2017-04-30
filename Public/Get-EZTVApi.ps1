function Get-EZTVApi {
    <#
    .SYNOPSIS
        A function for using the EZTV torrent API.
    .DESCRIPTION
        A function using the EZTV API. Currently only has this one endpoint and is in
        early beta.
    .EXAMPLE
        Get-EZTVApi

        This will get the first ten torrent results from the API, returning an object with a MagnetURI property
        and the DownloadTorrent method.

    .EXAMPLE
        $ThreeHundred = Get-EZTVApi -NumberOfPages 3 -limit 100
        $ThreeHundred
        $ThreeHundred | Where {$_.size_bytes -le 600MB}
        This will get the first three hundred results from the API, returning an object with a MagnetURI property
        and the DownloadTorrent method and storing it in a variable named ThreeHundred. The second part shows that
        the size_bytes property can be used to filter by file size.

    .NOTES
        Other EZTV functions were made before this API was available. Please try to use the API over 
        the web scraping methods of the other two functions.
    #>
    [CmdletBinding()]
    param (
        [int]$NumberOfPages = 1,
        [int]$limit = 10
    )
    
    begin {
    }
    
    process {
        foreach($page in (1..$NumberOfPages))
        {
            $results = Invoke-RestMethod -Uri "$EZTVBaseURI/api/get-torrents?limit=$limit&page=$page"
            $results.torrents | Format-EZTVApi
        }
        
    }
    
    end {
    }
}

# https://eztv.ag/api/get-torrents?limit=10&page=1 
