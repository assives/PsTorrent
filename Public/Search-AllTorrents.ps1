function Search-AllTorrents {
    <#
    .SYNOPSIS
        A function for searching using all of the Search functions in this module.
    .DESCRIPTION
        A function for searching using all of the Search functions in this module.
        Gets all of the functions in this module that start with Search and gets 
        the results of querying them all.

    .EXAMPLE
        $AllResults = Search-AllTorrents -Query "Limitless"

        # Pick from menu what to download
        $AllResults | Out-GridView -PassThru |
        Start-MagnetLink
        
        This will search the torrents sites this module is set up to work against for the
        word Limitless and return the results. The second part pipes those results
        to Out-GridView with the PassThru parameter and the selected items are then piped to 
        Start-MagnetLink to initiate the download of each of those selected torrents.

    .EXAMPLE
        $AllResuls = Search-AllTorrents -Query "Limitless" -Exclude Torrentz -Verbose

        # $AllResults | Where {"ExtraTorrent.SearchList" -in $_.pstypenames} # way to get all those results back
        This searchs for the word Limitless agains all of the sources except
        Torrentz, as specified by the Exclude parameter, and displays the Verbose message output from the functions.
    .INPUTS
        A string or array of strings.
    .OUTPUTS
        An array of objects, all with MagnetUri/MagnetLinks and the DownloadTorrent method
        avaliable on them.
    .NOTES
        This funciton will auto implement new functions in this module that are using
        the Search verb. Does not search YTS.
    #>
    [CmdletBinding()]
    param (
        # The string or array of strins to search the PirateBay for
        [Parameter(Mandatory=$true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Query,
        # Parameter set for excluding some search functions
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("EZTV","Torrentz","ExtraTorrent","PirateBay")]
        [string[]]
        $Exclude       
    )
    
    begin {
        # Grabs all of the PsTorrnet module functions that start with Search
        $AllSearchers = Get-Command -Module PsTorrent | Where {$_.Name -like "Search*" -and $_.Name -ne "Search-AllTorrents"}
        If($Exclude.Count -ne 0)
        {
            # redefine which functions to use based on what is present in Exclude array.
            $AllSearchers = foreach($nosearch in $Exclude)
            {
                $AllSearchers | Where {$_.Name -notlike "*$nosearch*"}
            }
        }
    }
    
    process {
        $results = foreach($search in $AllSearchers.Name)
        {
            Write-Verbose "Currently running the function $search with a Query of $Query"
            Invoke-Expression "$search -Query $Query"
        }
        $results
    }
    
    end {
    }
}