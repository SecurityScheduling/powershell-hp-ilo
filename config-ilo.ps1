$enclosure = "g1b0297"
$bay = 14
$newHostname = "g1t6563c"

#get blade info
$fqdnenclosure = $enclosure + "oa.austin.hp.com"
$ipinfo = [System.Net.Dns]::GetHostAddresses($fqdnenclosure)
$pw = "OA@" + $enclosure.substring($enclosure.length-4, 4)
$conObj = Connect-HPOA $ipinfo.IPAddressToString -Username ADMIN -Password $pw
$info = Get-HPOAServerInfo -Connection $conObj -bay $bay

#get configured hostname
$bladeFull = $info.serverblade.servername
$bladeHn = $bladeFull.split('.')[0].toupper()
"iLO IP,SerialNumber,Enclosure,BladeHost,ConfigHostname,iLoVersion,iLoFwVersion"
$ipinfo.IPAddressToString + "," + $info.serverblade.SerialNumber + "," + $enclosure.toupper() + "," + $bladeHn + "," + $newHostname.toupper() + "," + $info.serverblade.ManagementProcessorInformation.Type + "," + $info.serverblade.ManagementProcessorInformation.FirmwareVersion.split(" ")[0]

#check firmware for iLo and update if necessary (this is only if iLo has already been configured!!!!)
$iLoVersion = $info.serverblade.ManagementProcessorInformation.Type
$iLoFwVersion = $info.serverblade.ManagementProcessorInformation.FirmwareVersion.split(" ")[0]
$iLoIp = $info.serverblade.ManagementProcessorInformation.ipaddress
$iLoName = $info.serverblade.ManagementProcessorInformation.Name
$iLoPwTmp = $iLoName -replace '\D+' 
$iLoPw = "Admin@" + $iLoPwTmp.substring( $iLoPwTmp.length-4,4)

switch($iLoVersion) 
{
    "iLO4" {
                if([double]$iLoFwVersion -lt 1.5) {
                    "iLo FW Needs to be updated! Updating..."
                    Update-HPiLOFirmware -Server $iLoIp -Username Admin -Password $iLoPw -TPMEnabled -Location "C:\scripts\ilo4_151.bin"
                } else {
                    "iLo FW does not need update"
                }
            }
    "iLO3"  {
                if([double]$iLoFwVersion -lt 1.5) {
                    "iLo FW Needs to be updated! Updating..."
                    #Update-HPiLOFirmware -Server $iLoIp -Username Admin" -Password $iLoPw -TPMEnabled -Location "ilo3_170.bin"
                } else {
                    "iLo FW does not need update"
                }
            }
    "iLO2"  {
                if([double]$iLoFwVersion -lt 1.5) {
                    "iLo FW Needs to be updated! Updating..."
                    #Update-HPiLOFirmware -Server $iLoIp -Username Admin" -Password $iLoPw -TPMEnabled -Location "ilo2_205.bin"
                } else {
                    "iLo FW does not need update"
                }
            }
}

