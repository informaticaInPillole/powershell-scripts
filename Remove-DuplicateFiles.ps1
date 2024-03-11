[Cmdletbinding()]
param(
    [string[]] $Paths
)

$hashtable = [System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[string]]]::new()

foreach ($path in $Paths) {
    if(!(Test-Path $path))
    {
        Write-Host "Path $path not found"
        continue;
    }

    $items = Get-ChildItem -Path $path -Recurse
    Write-Host "Found $($items.Count) items"
    
    foreach ($item in $items) {

        $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256).Hash
        if(!$hashtable.ContainsKey($hash))
        {
            $hashtable.Add($hash, [System.Collections.Generic.List[string]]::new())
        }

        $hashtable[$hash] += $item.FullName
    }
    
}
$hashtable.Values | ?{$_.Count -gt 1}