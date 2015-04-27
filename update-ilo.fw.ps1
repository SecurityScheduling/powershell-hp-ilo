param (
    [Parameter(Mandatory=$true)]
    [string]$enclosure,
    [Parameter(Mandatory=$true)]
    [string]$blade
)

#get blade info
$fqdnenclosure = $enclosure + "oa.austin.hp.com"
$ipinfo = [System.Net.Dns]::GetHostAddresses($fqdnenclosure)
$pw = "OA@" + $enclosure.substring($enclosure.length-4, 4)
$conObj = Connect-HPOA $ipinfo.IPAddressToString -Username ADMIN -Password $pw
$info = Get-HPOAServerInfo -Connection $conObj -bay $blade
$iLoIp = $info.serverblade.ManagementProcessorInformation.ipaddress
$bladeFull = $info.serverblade.servername
$consoleName = $bladeFull + "-c"
$bladeHn = $bladeFull.split('.')[0].toupper()
$iLoPwTmp = $bladeHn -replace '\D+' 
$bladePw = "Admin@" + $iLoPwTmp.substring( $iLoPwTmp.length-4,4)
$serialNum = $info.serverblade.SerialNumber
$iLoVersion = $info.serverblade.ManagementProcessorInformation.Type
$iLoFwVersion = $info.serverblade.ManagementProcessorInformation.FirmwareVersion.split(" ")[0]

"iLo Version: " + $iLoVersion + " Current F/W Version: " + $iLoFwVersion + " Required Version: >=1.5"

switch($iLoVersion) 
{
    "iLO4" {
                if([double]$iLoFwVersion -lt 1.5) {
                    "iLo FW Needs to be updated!"
                    
                    $go = Read-Host 'Would you like to update now?'
                    if($go.substring(0,1).toupper() -eq 'Y') {
                        "Updating Firmware..."
                        #Update-HPiLOFirmware -Server $iLoIp -Username Admin -Password $iLoPw -TPMEnabled -Location "C:\scripts\ilo4_151.bin"
                    } else {
                        "Skipping Update..."
                    }
                    
                } else {
                    "iLo FW does not need update"
                }
            }
    "Integrity iLO 3"   {
                if([double]$iLoFwVersion -lt 1.5) {
                    "iLo FW Needs to be updated!"
                    $go = Read-Host 'Would you like to update now?'
                    if($go.substring(0,1).toupper() -eq 'Y') {
                        "Updating Firmware..."
                        #Update-HPiLOFirmware -Server $iLoIp -Username Admin -Password $iLoPw -TPMEnabled -Location "C:\scripts\ilo3_170.bin"
                    } else {
                        "Skipping Update..."
                    }
                } else {
                    "iLo FW does not need update"
                }
            }
    "iLO2"  {
                if([double]$iLoFwVersion -lt 1.5) {
                    "iLo FW Needs to be updated!"
                    $go = Read-Host 'Would you like to update now?'
                    if($go.substring(0,1).toupper() -eq 'Y') {
                        "Updating Firmware..."
                        #Update-HPiLOFirmware -Server $iLoIp -Username Admin -Password $iLoPw -TPMEnabled -Location "C:\scripts\ilo2_205.bin"
                    } else {
                        "Skipping Update..."
                    }
                } else {
                    "iLo FW does not need update"
                }
            }
}

