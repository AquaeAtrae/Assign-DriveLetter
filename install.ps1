$modulespath = ($env:psmodulepath -split ";")[0]
$thismodule = "$modulespath\Assign-DriveLetter"

Write-Host "Creating module directory"
New-Item -Type Container -Force -path $thismodule | out-null

Write-Host "Downloading and installing"
(new-object net.webclient).DownloadString("https://raw.githubusercontent.com/AquaeAtrae/Assign-DriveLetter/main/Assign-DriveLetter.psm1") | Out-File "$thismodule\Assign-DriveLetter.psm1" 

Write-Host "Installed!"
Write-Host 'Use "Import-Module Assign-DriveLetter" and then "Assign-DriveLetter (options)"'