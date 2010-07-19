$dev = 'D:\_Development'

# Enable Dropbox integration - uncomment below line (and fix path)
# $dropbox = 'Path_To_Dropbox_folder'
if($dropbox -ne $null -and (Test-Path $dropbox)){
	. .\Util\Dropbox.ps1
}

# Enable Mongo integration - uncomment below line (and fix path)
# $mongo = '$dropbox\apps\mongo\bin'
if($mongo -ne $null -and (Test-Path $mongo)){
	. .\Util\Mongo.ps1
}

# Enable CassiniDev integration - uncomment below line (and fix path)
# $cassiniDev = '$dropbox\apps\cassini'
if($dropbox -ne $null -and (Test-Path $dropbox)){
	. .\Util\CassiniDev.ps1
}