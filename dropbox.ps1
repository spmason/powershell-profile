function Start-Mongo{
	push-location
	
	cd $dropbox\apps\mongo\bin
	.\mongo.exe
	
	pop-location
}
set-alias mongo Start-Mongo

function Start-Mongod{
	push-location
	
	cd $dropbox\apps\mongo\bin
	start-process run_mongo.bat
	
	pop-location
}
set-alias mongod Start-Mongod

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
