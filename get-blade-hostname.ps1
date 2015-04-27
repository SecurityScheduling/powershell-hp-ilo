$path = ".\enclosures.csv"
$csv = Import-Csv $path
foreach($oaitem in $csv) {
    $enclosure = $oaitem.enclosure
    $bay = $oaitem.blade
    $fqdnenclosure = $enclosure + "oa.austin.hp.com"
    $ipinfo = [System.Net.Dns]::GetHostAddresses($fqdnenclosure)
    $pw = "OA@" + $enclosure.substring($enclosure.length-4, 4)
    $conObj = Connect-HPOA $ipinfo.IPAddressToString -Username ADMIN -Password $pw
    $info = Get-HPOAServerInfo -Connection $conObj -bay $bay
    $bladeFull = $info.serverblade.servername
    $bladeHn = $bladeFull.split('.')[0].toupper()
    $fqdnenclosure + " Blade: " + $bay + " => " + $bladeHn
}
