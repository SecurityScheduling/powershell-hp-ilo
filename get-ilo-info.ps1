param (
    [string]$enclosure,
    [string]$blade
)

#get enclosure info
$fqdnenclosure = $enclosure + "oa.austin.hp.com"
$ipinfo = [System.Net.Dns]::GetHostAddresses($fqdnenclosure)
$pw = "OA@" + $enclosure.substring($enclosure.length-4, 4)
$conObj = Connect-HPOA $ipinfo.IPAddressToString -Username ADMIN -Password $pw
$info = Get-HPOAServerInfo -Connection $conObj -bay $blade

#get iLo info
$iLoIp = $info.serverblade.ManagementProcessorInformation.ipaddress
$bladeFull = $info.serverblade.servername
$bladeHn = $bladeFull.split('.')[0].toupper()
$consoleName = $bladeHn + "-c"
$iLoPwTmp = $bladeHn -replace '\D+' 
$bladePw = "Admin@" + $iLoPwTmp.substring( $iLoPwTmp.length-4,4)
$serialNum = $info.serverblade.SerialNumber
$iLoVersion = $info.serverblade.ManagementProcessorInformation.Type
$iLoFwVersion = $info.serverblade.ManagementProcessorInformation.FirmwareVersion.split(" ")[0]
try {
    $test = [System.Net.Dns]::GetHostAddresses($consoleName)
} catch {
    $test = 0
}
if($test -ne 0) {
    $iLoLicense = Get-HPiLOLicense -Server $consoleName -Username admin -Password $bladePw -ErrorAction stop
    $users = Get-HPiLOUserList -Server $consoleName -Username admin -Password $bladePw -ErrorAction SilentlyContinue
    $iLoDirInfo = Get-HPiLODirectory -Server $consoleName -Username admin -Password $bladePw -ErrorAction SilentlyContinue
    $dirServerAddr = $iLoDirInfo.DIR_SERVER_ADDRESS
    $dirObjectDn = $iLoDirInfo.DIR_OBJECT_DN
    $nicinfo = Get-HPiLONICInfo -Server $consoleName -Username admin -Password $bladePw -ErrorAction SilentlyContinue
    $iLoHostname = $nicinfo.hostname.split('.')[0].toupper()
    $iLoLicenseKey = $iLoLicense.license_key
    $userLogins = $users.user_login
} else {
    "ERROR: Unable to resolve " + $consoleName
    "========================"
    $iLoLicense = "n/a"
    $users = "n/a"
    $iLoDirInfom = "n/a"
    $dirServerAddr = "n/a"
    $dirObjectDn = "n/a"
    $iLoHostname = "n/a"
    $iLoLicenseKey = "n/a"
    $userLogins = "n/a"
}

#show results
"Enclosure: " + $enclosure
"Blade: " + $blade
"Blade Hostname: " + $bladeHn
"Serial#: " + $serialNum
"iLo Version: " + $iLoVersion
"iLo FW Version: " + $iLoFwVersion
"iLo License: " + $iLoLicenseKey
"iLo Users: " + $userLogins
"Directory Server Address: " + $dirServerAddr  
"LOM Object Distinguished Name: " + $dirObjectDn
"iLO Subsystem Name: " + $iLoHostname
