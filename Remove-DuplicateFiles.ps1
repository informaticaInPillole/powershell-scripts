[Cmdletbinding()]
param(
    # Array of paths to search for duplicates
    [string[]] $Paths,
    # Switch parameter to enable searching subfolders
    [switch] $Recurse
)

# Initialize variables
$files = New-Object System.Collections.Hashtable    # Hash table to store hash and file paths
$bytes = 0                                          # Total size of duplicate files (bytes)
$duplicates = 0                                     # Number of duplicate files found 

# Loop through each provided path
foreach ($path in $Paths) {
    # Check if path exists
    if(!(Test-Path $path))
    {
        Write-Host "Path $path not found"
        continue;
    }

    # Get all files from the path (including subfolders if Recurse is set)
    $items = Get-ChildItem -Path $path -Recurse:$Recurse -File

    Write-Host "$($items.Count) items to analyze"

    # Progress bar initialization
    $i = 1
    Write-Progress -Activity "Evaluating $($items.Count) files [path: $path]" -Status ([string]::Format("Duplicates: {0} ({1:N2} Mb)", $duplicates, $bytes/1Mb)) -PercentComplete 0

    # Loop through each file in the path
    foreach ($item in $items) {
        Write-Progress -Activity "Evaluating $i of $($items.Count) files [path: $path]" -Status ([string]::Format("Duplicates: {0} ({1:N2} Mb)", $duplicates, $bytes/1Mb)) -PercentComplete ($i++/$items.Count * 100)

        # Calculate SHA256 hash of the file
        $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256).Hash

        # Check if hash exists in the hash table
        if($files.ContainsKey($hash)){
            # Found duplicate! Increment counters
            $duplicates++;
            $bytes += $item.Length
        }

        # Add file path to the hash table entry for the current hash
        $files[$hash] += @($item.FullName)
       
    }
}
# Display summary of duplicate files found
Write-Host ([string]::Format("Duplicates found: {0} ({1:N2} Mb)", $duplicates, $bytes/1Mb))

# Filter keys from the hash table where there are multiple files (duplicates)
$keys = $files.Keys | Where-Object { $files[$_].Count -gt 1 }
# Create a new hash table to store duplicate file information
$duplicateFiles = New-Object System.Collections.Hashtable
foreach($key in $keys)
{
    # Add key (hash) and corresponding file paths to the duplicate files hash table
    $duplicateFiles[$key] = $files[$key]
}
# Output the hash table containing duplicate file information
Write-Output $duplicateFiles
