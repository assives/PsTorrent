function Search-ExtraTorrent {
    <#
    .SYNOPSIS
        A function for searching ExtraTorrent.cc
    .DESCRIPTION
        A function for searching ExtraTorrent.cc. Uses the RSS XML format output available
        for search results from this website. Once agian creates an object that has MagnetUri as a property and
        has the DownloadTorrent method available.
    .EXAMPLE
        $Vernes = Search-ExtraTorrent -Query "Jules Verne"
        $Selected = $Vernes | Out-GridView -PassThru
        $Selected | ForEach-Object {
            $_.DownloadTorrent()
        }

        Search ExtraTorrent for Jules Verne and stores the results into a variable. This variable
        is then piped to Out-GridView for a simple Menu selection. The Selected items are then piped
        to ForEach-Object and the DownloadTorrent method is used.
    .INPUTS
        A string or array of strings.
    .OUTPUTS
        An object with type set as ExtraTorrent.SearchLis
    .NOTES
        Function for searching using ExtraTorrent. Part of effort to incorporate more sources.
    #>
    [CmdletBinding()]
    param (
        # String or array of strings to search for
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]
        $Query
    )
    
    begin {
        $ExtraTorrnetBaseURI = 'https://extratorrent.cc/rss.xml?type=search&search='
    }
    
    process {
        foreach($search in $Query)
        {
            $search = $search -replace "\s+","+"
            $results = Invoke-RestMethod -Uri $ExtraTorrnetBaseURI=$search
            # Ugh, formatting this like the others is not working, not sure why
            # Does not like getting the Title and MagnetUri as ScriptProperties
            # Falling back to Select with Calculated Expressions and then formatting it.
            $Info = $results | Select-Object @{Name="Title";Expression={$_.title.'#cdata-section'}}, @{N="MagnetUri";e={$_.magnetUri.'#cdata-section'}}, size, `
            @{n="Seeders";e={If($_.seeders -match '---'){$null}else{[int]$_.seeders}}}, @{n="Leechers";e={If($_.leechers -match '---'){$null}else{[int]$_.leechers}}}
            $Info | Format-ExtraTorrent

        }
    }
    
    end {
    }
}

