$key = 'SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
$valuename = 'WUServer'
$outputFile = ".\GetWUServerL3.0-$(Get-Date -Format MMddyyyy_HHmmss).csv"
$results = New-Object System.Collections.Generic.List[System.Object]

Get-ADObject -SearchBase "OU=L30_PCN,OU=Assets,DC=wmgpcn,DC=local" -LDAPFilter "(objectClass=computer)" | 
Where-Object { $_.Name -notlike "PCNVS*" -and $_.Name -notlike "DEVVS*" -and $_.Name -notlike "PCNVC*" } | 
Select-Object -ExpandProperty Name | Set-Variable -Name computers
#$computers = "pcnpic01"

Write-Host "`nRunning... Please wait..."

foreach ($computer in $computers) {
	Try { 
        Test-Connection $computer -Count 1 -ErrorAction Stop > $nul
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
	    $regkey = $reg.opensubkey($key)
	    #Write-Host "$($computer): $($regkey.getvalue($valuename))"
        #Add-Content -Value "$($computer): Not Available" -Path $outputFile
        $results.add([PSCustomObject]@{'Hostname'=$computer ; 
                                       'WUServer' = $($regkey.getvalue($valuename))
                                      }
                    )
    }
    Catch { 
        #Write-Host "$($computer): Not Available"
        #Add-Content -Value "$($computer): Not Available" -Path $outputFile
        $results.add([PSCustomObject]@{'Hostname'=$computer ; 
                                       'WUServer' = "Not Available"
                                      }
                    )
     }
}

$results | Sort-Object WUServer, Hostname | Export-CSV -Path $outputFile -NoTypeInformation
$results | Sort-Object WUServer, Hostname


# References
# https://social.technet.microsoft.com/Forums/windows/en-US/0835c303-2edd-4c06-bbc9-5c7952402d0c/powershell-to-get-the-registry-key-value-from-remote-server-with-txt-file?forum=winserverpowershell