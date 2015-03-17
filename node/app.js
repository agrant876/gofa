var apn = require('apn');
var express = require('express');
var bodyParser = require('body-parser'); 
var Firebase = require('firebase'); 

var app = express();
app.set('port', process.env.PORT || 3000);

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// firebase url
var firebaseRef = new Firebase('https://gofa.firebaseio.com/')


// set up connection to Apple Push Notification Service (APNS)
var options = { };
var apnConnection = new apn.Connection(options);



// sending to my iphone 
var token = "c47701a27a9335022c54cc558046a658d22780215a0fdc04c89d33f6df0e715d";
var myDevice = new apn.Device(token);                    

app.get('/ping', function (req, res) {
        //res.send('Hey there iphone!');

	//	if (!req.body) {
	//  return res.sendStatus(400);

	var userRef = firebaseRef.child('users/simplelogin:8'); 
	userRef.once("value", function(snapshot) { 
		console.log(snapshot.val());
		console.log(snapshot.key()); 
		res.send(snapshot.val());
	    }); 

	//res.send('welcome, ' + req.body.userid);
       
	/*
	var note = new apn.Notification();
	note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
	note.badge = 1;
	note.sound = "ping.aiff";
	note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
	note.payload = {'messageFrom': 'Andrew Grant'};
	console.log(myDevice); 
	console.log(note); 
	console.log(options); 
	apnConnection.pushNotification(note, myDevice);
	*/
    });    

var server = app.listen(3000, function () {
	
	var host = server.address().address;
	var port = server.address().port;
	
	console.log('Example app listening at http://%s:%s', host, port);
	
    });
