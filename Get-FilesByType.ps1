$fType = "picture"
 
$sql_query = "SELECT System.ItemName, System.Size, System.ItemTypeText, System.Kind FROM SystemIndex WHERE scope ='file:C:/' AND System.Kind = '$fType'"
 
$provider = "Provider=Search.CollatorDSO;Extended Properties=""Application=Windows"""
 
$connection = New-Object System.Data.OleDb.OleDbConnection -argument $provider
 
$connection.Open();
 
$commnand = New-Object System.Data.OleDb.OleDbCommand -argument $sql_query, $connection
 
$found = $commnand.ExecuteReader();
 
$totalSize = 0;
 
$nFiles = 0;
 
foreach ($item in $found)
 
{
 
    Write-Host $item[0] + " " + $item[1] + " " + $item[2] + " " + $item[3]
 
    $totalsize += $item[1];
 
    $nFiles += 1;
 
}
 
$connection.Clone();
 
Write-Host "Trovati $($nFiles) di tipo $($fType) per un totale di $($totalSize/1024) MBytes"