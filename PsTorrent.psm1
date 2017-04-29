# Module for torrenting using PowerShell
# Works againt EZTV (TV Shows) and YTS (Movies)
# Will implement other media items in future, like eBooks, Games, etc


# Variables used by the module and its function
$global:EZTVBaseURI = "https://eztv.ag"

$script:YTSTrackers = @(
    'udp%3A%2F%2Fopen.demonii.com%3A1337',
    'udp%3A%2F%2Ftracker.istole.it%3A80',
    'udp%3A%2F%2Ftracker.publicbt.com%3A80',
    'udp%3A%2F%2Ftracker.openbittorrent.com%3A80',
    'udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969',
    'udp%3A%2F%2Fexodus.desync.com%3A6969'
)
$script:YTSBaseURI = "https://yts.ag/api/v2/"

# endregion variables used by module

#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename