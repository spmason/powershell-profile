function Set-Location-Dropbox{
	Push-Location
	cd $dropbox
}
set-alias dropbox Set-Location-Dropbox

function Start-Mongo{
	push-location
	
	cd $dropbox\apps\mongo\bin
	start-process run_mongo.bat
	
	pop-location
}

function Kill-Mongo{
	killAll "mongod"
}

function Start-Cassini{
	param([string]$location)
	
	if([System.String]::IsNullOrEmpty($location)){
		$location = gl
	}
	
	if($location.StartsWith(".\")){
		$location = $location.TrimStart('.', '\', '/')
	}
	
	if([System.IO.Path]::IsPathRooted($location) -eq $false){
		$gl = gl
		$location = [System.IO.Path]::Combine($gl, $location)
	}
	
	push-location
	
	cd $dropbox\apps\CassiniDev
	.\CassiniDev4.exe /a:$location
	
	pop-location
}