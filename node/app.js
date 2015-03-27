var apn = require('apn');
var express = require('express');
var bodyParser = require('body-parser'); 
var Firebase = require('firebase'); 

var app = express();
app.set('port', process.env.PORT || 3000);

app.use(bodyParser.json());
//app.use(bodyParser.urlencoded({ extended: true }));

// firebase url
var firebaseRef = new Firebase('https://gofa.firebaseio.com/')


// set up connection to Apple Push Notification Service (APNS)
var options = { };
var apnConnection = new apn.Connection(options);




//res.send('Hey there iphone!');

	/*
	if (!req.body) {
	    return res.sendStatus(400);
	    }*/
	



// sending to my iphone 
var token = "c47701a27a9335022c54cc558046a658d22780215a0fdc04c89d33f6df0e715d";
var myDevice = new apn.Device(token);                    

app.post('/unseenNotif', function(req, res) { 
	var userid = req.body.userid;
	var userRef = firebaseRef.child('users/'+userid); 
	userRef.once("value", function(snapshot) { 
		var userInfo = snapshot.val(); 	
		if ('transactions' in userInfo) { 
		    var transactions = userInfo["transactions"]; 
		    console.log("1");
		    //var retTrans = []; // array of transaction dictionaries to return
		    console.log(transactions); 
		    for (key in transactions) {
			console.log("2"); 
			if (transactions[key] == 'pending') { 
			    console.log("3"); 
			    var transactionRef = firebaseRef.child('transactions/'+key); 
			    transactionRef.once("value", function(snapshot) { 
				    var transactionInfo = snapshot.val();
				    transactionInfo["id"] = key;
				    console.log("I was called!"); 
				    res.json({"transaction": transactionInfo});
				});
			}
		    }
		} else {
		    res.json({"transaction": null}); 
		}
	    });
    });

app.post('/getTransactionInfo', function(req, res) { 
	var transactionid = req.body.transactionid; 
	var transRef = firebaseRef.child('transactions/'+transactionid); 
	transRef.once("value", function(snapshot) { 
		var transInfo = snapshot.val(); 
		var tripRef = firebaseRef.child('trips/'+transInfo["trip"]); 
		var userRef = firebaseRef.child('users/'+transInfo["customer"]); 
		tripRef.once("value", function(snapshot) { 
			var tripInfo = snapshot.val(); 
			var locid = tripInfo["location"]; 
			var locRef = firebaseRef.child('locations/'+locid); 
			locRef.once("value", function(snapshot) {
				var locInfo = snapshot.val(); 
				var locName = locInfo['name']; 
				userRef.once("value", function(snapshot) { 
					var userInfo = snapshot.val(); 
					var userName = userInfo["username"]; 
					res.json({"locName": locName, "userName": userName}); 
				    }); 
			    }); 
		    }); 
	    }); 
    }); 



app.post('/deferTransaction', function(req, res) {
        var transactionid = req.body.transactionid;
	var userid = req.body.userid; 
        var userRef = firebaseRef.child('users/'+userid+'/transactions/'+transactionid).set('deferred');
	res.json({"status": "success"});
    }); 

app.post('/bag', function(req, res) { 
	var bagInfo = req.body; 
	console.log(bagInfo.contents); 
	var bagid = bagInfo.locationid+':'+bagInfo.userid; 
	var bagRef = firebaseRef.child('bags/'+bagid); 
	bagRef.set({
		location: bagInfo.locationid, 
		    user: bagInfo.userid,
		    contents: bagInfo.contents
		    });
	res.json({"status": "success"});
    }); 

app.post('/getbag', function(req, res) {
	var bagInfo = req.body; 
	var bagid = bagInfo.locationid+':'+bagInfo.userid;
	var bagRef = firebaseRef.child('bags'); 
	bagRef.once("value", function(snapshot) { 
		var bags = snapshot.val(); 
		console.log(bags); 
		console.log(bagid); 
		if (bagid in bags) {
		    console.log("what?"); 
		    var bag = bags[bagid];
		    var bagContents = bag["contents"];
		    console.log(bagContents); 
		    res.json({"contents": bagContents}); 
		} else { 
		    res.json({"contents": null}); 
		}
	    }); 
    }); 

app.post('/ping', function (req, res) {
        
	var senderInfo = req.body;
	//console.log(req.body); 
	console.log(senderInfo.userid); 
	var senderRef = firebaseRef.child('users/'+senderInfo.userid);
	var userRef = firebaseRef.child('users/simplelogin:8'); 
	userRef.once("value", function(snapshot) { 
		var userInfo = snapshot.val(); 
		var deviceToken = userInfo.deviceToken; 
				
		console.log(deviceToken); 
		senderRef.once("value", function(snapshot) { 
			var senderInfo2 = snapshot.val(); 
			var username = senderInfo2.username; 
			
			var note = new apn.Notification();
			var device = new apn.Device(deviceToken);                    
			note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
			note.badge = 1;
			note.sound = "ping.aiff";
			note.alert = "\uD83D\uDCE7 \u2709 You have a new message from " + username;
			note.payload = {'messageFrom': username};
			//console.log(myDevice); 
			//console.log(note); 
			//console.log(options); 
			apnConnection.pushNotification(note, device);
			res.json({"status": "success"});
		    }); 
	    }); 
    });    

app.post('/pingUser', function (req, res) {
        
	var reqInfo = req.body;
	//console.log(req.body); 
	var userid = reqInfo.userid; 
	var tripid = reqInfo.tripid; 
	console.log(userid);
	console.log(tripid); 
	var senderRef = firebaseRef.child('users/'+userid);
	var tripRef = firebaseRef.child('trips/'+tripid); 
	// initiate a pending transaction
	var transaction = {'customer': userid, 'trip': tripid, 'status': 'pending'};
	var userRef = firebaseRef.child('users/simplelogin:8'); 
	userRef.once("value", function(snapshot) { 
		var userInfo = snapshot.val(); 
		var deviceToken = userInfo.deviceToken; 
		// update Firebase with new transaction (pending)
		var transactionid = tripid+'_'+userid;
		userRef.child('transactions/'+transactionid).set('pending');
		firebaseRef.child('transactions/'+transactionid).set(transaction); 
		senderRef.once("value", function(snapshot) { 
			var senderInfo = snapshot.val(); 
			var username = senderInfo.username; 
			
			tripRef.once("value", function(snapshot) { 
				var tripInfo = snapshot.val(); 
				var locationid = tripInfo["location"];
				var locRef = firebaseRef.child('locations/'+locationid); 
				
				locRef.once("value", function(snapshot) { 
					var locInfo = snapshot.val(); 
					var locname = locInfo["name"]; 
					
					var bagid = locationid+':simplelogin:8';
					var bagRef = firebaseRef.child('bags/'+bagid); 
					bagRef.once("value", function(snapshot) { 
						var bagInfo = snapshot.val(); 
						var bagContents = bagInfo["contents"]; 
						
						// create notification and push 
						var note = new apn.Notification();
						var device = new apn.Device(deviceToken);                    
						note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
						note.badge = 1;
						note.sound = "ping.aiff";
						note.alert =  username + ' needs something from ' + locname + '!';
						note.payload = {'messageFrom': username, 'location': locname, 
								'bag': bagContents, 'requestInfo': {'userid': reqInfo.userid,
												    'tripid': reqInfo.tripid}};
						note.category = "REQUEST_CATEGORY"; 
						//console.log(myDevice); 
						//console.log(note); 
						//console.log(options); 
						
						
						
						apnConnection.pushNotification(note, device);
						res.json({"status": "success"});
					    });
				    }); 
			    });
		    }); 
	    }); 
    }); 

app.post('/pingUserAccept', function (req, res) {
        
	var reqInfo = req.body;
	console.log(reqInfo.userid);
	console.log(reqInfo.tripid); 
	var senderRef = firebaseRef.child('users/'+reqInfo.senderid);
	var tripRef = firebaseRef.child('trips/'+reqInfo.tripid); 

	var userRef = firebaseRef.child('users/'+reqInfo.userid); 
	userRef.once("value", function(snapshot) { 
		var userInfo = snapshot.val(); 
		var deviceToken = userInfo.deviceToken; 
		
		senderRef.once("value", function(snapshot) { 
			var senderInfo = snapshot.val(); 
			var sendername = senderInfo.username; 
			
			tripRef.once("value", function(snapshot) { 
				var tripInfo = snapshot.val(); 
				var locationid = tripInfo["location"];
				var locRef = firebaseRef.child('locations/'+locationid); 
				
				locRef.once("value", function(snapshot) { 
					var locInfo = snapshot.val(); 
					var locname = locInfo["name"]; 
					// create notification and push 
					var note = new apn.Notification();
					var device = new apn.Device(deviceToken);                    
					note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
					note.badge = 1;
					note.sound = "ping.aiff";
					note.alert =  sendername + ' is going to get what you needed from ' + locname + '!';
					note.payload = {'messageFrom': sendername, 'location': locname, 
							'requestInfo': {'userid': reqInfo.userid,
									  'tripid': reqInfo.tripid}};
					//console.log(myDevice); 
					//console.log(note); 
					//console.log(options); 
					apnConnection.pushNotification(note, device);
					res.json({"status": "success"});
				    }); 
			    });
		    }); 
	    }); 
    }); 

var server = app.listen(3000, function () {
	
	var host = server.address().address;
	var port = server.address().port;
	
	console.log('Example app listening at http://%s:%s', host, port);
	
    });
