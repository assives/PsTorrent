PsTorrent
==========

This is a PowerShell module for working with torrents from EZTV, YTS, ExtraTorrnet, Torrentz, and the PirateBay.
If you would like another site to be added, use the Issues feature here.

Returns objects that have magnet uris as properties.
This module requires a torrent client to already be installed and set to be associated
with Magnet Links. qBittorent, uTorrent, etc for downloading torrents to work.

It is best to already have the torrent client application running before running these commands,
but is not required.

# Instructions

```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the PsTorrent folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

# Import the module.
    Import-Module PsTorrent   #Alternatively, Import-Module \\Path\To\PsTorrent\PsTorrent.psm1

# Get commands in the module
    Get-Command -Module PsTorrent

# Get help
    Get-Help Search-PirateBay

    Get-Help Get-NewMovieRelease
```

# Examples


### Seaching the PirateBay
```PowerShell
# Search the PirateBay and Download the selected torrents

$Results = Search-PirateBay -Query "Gorillaz"
$Selected = $Results | Out-GridView -Passthru
$Selected | Start-MagnetLink


```

### Search EZTV for TV Shows
```PowerShell
# Search EZTV for a specific show and season, in this case season 7 of The Walking Dead and only 720p videos
$WalkingDead = Search-EZTV -Filter "Walking Dead"
$SeasonSeven = $WalkingDead | Where {$_.Season -eq 7 -and $_.QualityInfo -like "*720p*"}
$SeasonSeven | ForEach-Object {
    $_.DownloadTorrent()
}
```

### Use EZTV API
```PowerShell
# Get the first ten results from the API and download them
Get-EZTVApi | Start-MagnetLink
```

### Search YTS for a movie
```PowerShell
# Search YTS for a specific movie, in this case La La Land in 720p, and start a download of it.
Get-YTSMovies -Movie "La La Land" -Quality 720p |
Start-MagnetLink
```

### Search Torrentz
```PowerShell
# Search torrentz.ht, select the results using Out-GridView and start a download of selected ones.
$LinuxOS = Search-Torrentz -Query "ubuntu iso"
$LinuxOS | Out-GridView -PassThru |
Start-MagnetLink
```

### Search ExtraTorrent
```PowerShell
# Search ExtraTorrnet, select the results using Out-GridView and start a download of the selected ones.
$Vernes = Search-ExtraTorrent -Query "Jules Verne"
$Selected = $Vernes | Out-GridView -PassThru
$Selected | ForEach-Object {
    $_.DownloadTorrent()
}
```

### Search All
```PowerShell
# Search using all of the Search functions in the module
$AllResults = Search-AllTorrents -Query "Limitless"

# Pick from menu what to download
$AllResults | Out-GridView -PassThru |
Start-MagnetLink
```