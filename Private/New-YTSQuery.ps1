Function New-YTSQuery
{
    [CmdletBinding()]
    param 
    (
		[Parameter(Mandatory=$False)]            
        $options         
    )
    Begin{}
    Process
    {
        If($options)
        {
            try 
            {
            $jsonObj = $options | ConvertFrom-Json -ErrorAction Stop
            }
            catch 
            {
                Write-Warning "Please enter a Here-String or json file as input for `$options. Returning `$null"
                $null
            }
            $optionsQuery = ''
            $Properties = $jsonObj |
            Get-Member |
            Where-Object {$_.MemberType -like "NoteProperty"} |
            Select-Object -ExpandProperty Name
            ForEach($property in $Properties)
            {
                $optionsQuery = $optionsQuery + "&" + $property + "=" + $jsonObj.$($property)
            }
            # Remove leadinng & , add in actual function instead
            $Options = $optionsQuery.TrimStart("&")
            $KeyString = $options
        }
        else 
        {
            $KeyString = ''          

        }
        $KeyString # return the keystring
    } 
    End{}
}