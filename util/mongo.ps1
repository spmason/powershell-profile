function Start-Mongo{
	push-location
	
	cd $mongo
	.\mongo.exe
	
	pop-location
}
set-alias mongo Start-Mongo

function Start-Mongod{
	push-location
	
	cd $mongo
	start-process run_mongo.bat
	
	pop-location
}
set-alias mongod Start-Mongod

function Kill-Mongod{
	Kill-All "mongod"
}

function Kill-Mongo{
	Kill-All "mongo"
}
