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
	
	cd $CassiniDev
	.\CassiniDev4.exe /a:$location
	
	pop-location
}