<#
.Synopsis
    PowerShell cmdlet to assign a drive letter given the partition's ID, serial, or label
.Description 
    This powershell cmdlet first moves any existing drive letter assignment to free up the DesiredDriveLetter. Once
    available, it finds the first matching partition and assigns the drive letter to it.		
	
.Parameter $DesiredDriveLetter
    The drive letter to assign to the matching partition
.Parameter $DriveID
.Parameter $DriveSerial
.Parameter $DriveLabel

.Link
    https://github.com/AquaeAtrae/Assign-DriveLetter
.Example
  Import-Module Assign-DriveLetter
	Assign-DriveLetter -DesiredDriveLetter "D" -DriveLabel "Data"
	
.Example
	Assign-DriveLetter -DesiredDriveLetter "F" -DriveSerial "916668406"
	
.Example
	Assign-DriveLetter -DesiredDriveLetter "X" -DriveID "\\?\Volume{4442da02-898c-11e9-9f9b-981f32013a0e}\"
	
#>

function Assign-DriveLetter {
    param(
       [Parameter(Position=0,Mandatory)]
       [string]$DesiredDriveLetter,

       [Parameter(Position=1)]
       [string]$DriveID,

       [Parameter(Position=2)]
       [string]$DriveSerial,

       [Parameter(Position=3)]
       [string]$DriveLabel
       )

		$Drive = $null

		if ($DriveLabel) {
        $Drive = gwmi Win32_Volume | where {$_.Label -like $DriveLabel} | select -First 1
    } 

		if ($DriveSerial) {
        $Drive = gwmi Win32_Volume | where {$_.SerialNumber -like $DriveSerial} | select -First 1
    } 
		
		if ($DriveID) {  
        $Drive = gwmi Win32_Volume | where {$_.DeviceID -like $DriveID} | select -First 1
    } 

		if (!$Drive) {
        'ERROR: Must identify the drive to assign letter with an existing DriveID, DriveSerial, or DriveLabel'
    } else {
			if ($DesiredDriveLetter + ":" -ne $Drive.DriveLetter) {
					$takenDriveLetters = (Get-PSDrive).Name -like '?'
					if ($DesiredDriveLetter -in $takenDriveLetters) {
							# Reassign existing drive to first unused drive letter to release the drive letter
							$firstUnusedDriveLetter = [char[]] (0x44..0x5a) | where { $_ -notin $takenDriveLetters } | select -first 1  # ASCII letters D through Z
							
							Write-Host "Moving existing drive from $DesiredDriveLetter`: to $firstUnusedDriveLetter`:"
							$ExistingDrive = gwmi Win32_Volume | where {$_.DriveLetter -like $DesiredDriveLetter + ":"}

							if (!$ExistingDrive) {'Boxstarter reboot required'; Invoke-Reboot}  # boxstarter reboot
							$ExistingDrive.AddMountPoint($firstUnusedDriveLetter + ":\")
							$ExistingDrive.DriveLetter = $firstUnusedDriveLetter + ":"
							$ExistingDrive.Put()
							$ExistingDrive.Mount()
					}

					if ((Get-PSDrive).Name -like $DesiredDriveLette) {'Boxstarter reboot required'; Invoke-Reboot}  # boxstarter reboot

					Write-Host "Assigning drive to $DesiredDriveLetter`:"
					$Drive.AddMountPoint($DesiredDriveLetter + ":\")
					$Drive.DriveLetter = $DesiredDriveLetter + ":"
					$Drive.Put()
					$Drive.Mount()
			}
		
		}
}