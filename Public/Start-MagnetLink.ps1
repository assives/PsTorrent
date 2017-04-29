function Start-MagnetLink {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        [ValidatePattern("magnet:\?xt=urn.*tr=udp.*")] # simple regex to check that string has some of the MagnetLink syntax.
        [Alias("MagnetURI")]
        $MagnetLink
    )
    
    begin {
    }
    
    process {
        Write-Verbose "Starting magnet link in torrent client assoicated with Magnet files"
        Start-Process $MagnetLink
    }
    
    end {
    }
}