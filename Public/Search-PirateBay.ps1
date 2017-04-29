function Search-PirateBay {
    <#
    .SYNOPSIS
        A function for searching the PirateBay for torrents.
    .DESCRIPTION
        A function for searching the PirateBay for torrents.
        Parses the webpage of the first set of results retuned from a search on the PirateBay.
    .EXAMPLE
        $Search = Search-PirateBay -Query "PowerShell","Python"
        $Search

        This searches PirateBay first for PowerShell and then for Python, storing the results
        in a variable named $Search, which is then output to the console.

    .EXAMPLE
        $Search = Search-PirateBay -Query "PowerShell","Python"
        # Sort by FileSize (this property is the size in bytes)
        $Search | Sort FileSize -Descending
        # Sort by Upload Date
        $Search | Sort UploadDate -Descending

        This demonstrates the sorting that can be done using the different returned properties, specifically
        the FileSize and UploadDate properties. The FileSize is not part of the default display set, as there
        are propeties that are not displayed when this function is run, but are available.

    .EXAMPLE
        $Search = Search-PirateBay -Query "PowerShell","Python" -Verbose
        $Search | Where {$_.Title -like "*CBT*"} | Start-MagnetLink

        This example does the same search for PowerShell and Python with the Verbose messages displayed.
        The results are then filtered down to ones with CBT in the title and piped
        to Start-MagnetLink which will start the magnet link and the torrent download for each
        one of them.

    .EXAMPLE
        $CivilizationSearch = Search-PirateBay -Query "Civilization 6"
        $SelectedTorrent = $CivilizationSearch | OutGridView -OutputMode Single
        $SelectedTorrent.DownloadTorrent()

        This first starts a search for Civilization 6, storing the results in a variable.
        This variable is then piped to Out-GridView to make a single selection from a simple GUI window.
        The DownloadTorrent method is then used on that selection to initiate the download using the Magent link.
        This will open the torrent in whatever torrent client has the default association with MagnetLinks.
    .INPUTS
        A string or array of strings
    .OUTPUTS
        A custom object
    .NOTES
        Produces an object with a DownloadTorrent method as well as a property that can be piped
        to Start-MagentLink to start the download of the torrent.
    #>
    [CmdletBinding()]
    param (
        # The string or array of strins to search the PirateBay for
        [Parameter(Mandatory=$true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Query,
        # The url for thepiratebay search
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [string]
        $PbURI = "https://thepiratebay.org/search"
    )
    
    begin {
    }
    
    process {
        foreach($search in $Query) {
            try {
                $response = Invoke-WebRequest -Uri "$PbURI/$search/0/99/0" -ErrorAction Stop
                $Responded = $true                
            }
            catch {
                Write-Warning "Failed to reach PirateBay, review error message"
                Write-Error $_
                $Responded = $false
                Continue
            }
            If($Responded) {
                Write-Verbose "Getting links from url of $PbURI/$search/0/99/0"
                $Links = $response.Links
                Write-Verbose "Filtering links down to detaled link and magnet links"
                $EndResults = $Links | Where {$_.Class -eq "detLink" -or $_.title -like "Download this torrent using magnet"}
                Write-Verbose "Getting description informaion for each result"
                $FontTags = $response.ParsedHtml.getElementsByTagName("font")
                $Descriptions = $FontTags | Where {$_.className -eq "detDesc"} | Select -ExpandProperty innerText
                # Counters for $EndResults and $Descriptions respectively
                $i = 0
                $d = 0
                $SearchResults = do {
                    $Title = $EndResults[$i].innerText
                    $Description = $Descriptions[$d]
                    $d++
                    Write-Verbose "Creating properties of upload date, size, and uploader out of description text"
                    $CurrentYear = (Get-Date).Year
                    $DateString = ($Description -split ',')[0]
                    If($DateString -match ':') {
                        $UploadDate = Get-Date (($DateString -replace "Uploaded ","") -replace "\s+.*"," $CurrentYear")
                    } else {
                        $UploadDate = Get-Date ($DateString -replace "Uploaded ","")                  
                    }
                    # Code to get size into format that is sortable
                    $SizeString = (((($Description -split ',')[1] -replace " Size ","") -replace "i"))
                    $SizeUnit = ($SizeString -split " ")[-1]
                    $Size = ($SizeString -replace "\s+")
                    $FileSize = Convert-Size -To Bytes -From $SizeUnit -Value $($SizeString -replace "\s+.*")
                    $Uploader = ($Description -split ',')[2] -replace ".*by\s+"
                    $PbLink = $EndResults[$i].href
                    $i++
                    $MagnetLink = $EndResults[$i].href
                    $i++
                    $props = @{
                        Title=$Title
                        UploadDate=$UploadDate
                        Size=$Size
                        FileSize=$FileSize
                        Uploader=$Uploader
                        Description=$Description
                        PbLink = $PbLink
                        MagnetLink = $MagnetLink
                    }
                    New-Object -TypeName psobject -Property $props
                    Write-Verbose "Count for `$EndResults variable is at $i and count for `$Descriptions is at $d"
                } until ($i -ge $EndResults.Count)
                $SearchResults | ForEach-Object {
                    $_ | Format-PirateBaySearch
                }
            }
        }
    }
    
    end {
    }
}
