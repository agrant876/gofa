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
		    if('responses' in transactions) { 
			var respTransactions = transactions["responses"]; 
			console.log("1");
			//var retTrans = []; // array of transaction dictionaries to return
			console.log(respTransactions); 
			for (key in respTransactions) {
			    console.log("2"); 
			    if (respTransactions[key] == 'pending') { 
				console.log("3"); 
				var transactionRef = firebaseRef.child('transactions/'+key); 
				transactionRef.once("value", function(snapshot) { 
					var transactionInfo = snapshot.val();
					transactionInfo["id"] = key;
					console.log("I was called!"); 
					res.json({"transaction": transactionInfo, "hasNotif": "true"});
				    });
			    } else { 
				res.json({"transaction": null, "hasNotif": "false"}); 
			    }
			}
		    }
		} else {
		    res.json({"transaction": null, "hasNotif": "false"}); 
		}
	    });
    });

app.post('/getTransactionInfo', function(req, res) { 
	var transactionid = req.body.transactionid; 
	var transRef = firebaseRef.child('transactions/'+transactionid); 
	var currentTime = new Date().getTime()/1000;
	transRef.once("value", function(snapshot) { 
		var transInfo = snapshot.val(); 
		var status = transInfo["status"]; 
		var customerid = transInfo["customer"]; 
		var tripownerid = transInfo["tripowner"];
		var locid = transInfo["location"]; 
		var tripid = transInfo["trip"]; 
		var tripRef = firebaseRef.child('trips/'+tripid); 
		var customerRef = firebaseRef.child('users/'+customerid); 
		
		var toa = transInfo["toa"];
		if (toa < currentTime) { 
		    // tripowner has arrived at location
		    if (status == "pending" || status == "deferred") { 
			// remove transaction if the toa of the trip has passed
			removeTransaction(transactionid, tripid, customerid, tripownerid); 
			res.json({"status": "deleted"}); 
		    } else { 
			//accepted trips D.T.R: other types
			// send transaction info with tripInfo = null
			var locRef = firebaseRef.child('locations/'+locid); 
			locRef.once("value", function(snapshot) {
				var locInfo = snapshot.val(); 
				var locName = locInfo['name']; 
				customerRef.once("value", function(snapshot) { 
				    var custInfo = snapshot.val(); 
				    var custName = custInfo["username"]; 
				    var tripOwnerRef = firebaseRef.child('users/'+tripownerid); 
				    tripOwnerRef.once("value", function(snapshot) { 
					    var tripOwnerInfo = snapshot.val(); 
					    var tripOwnerName = tripOwnerInfo["username"]; 
					    res.json({"status": "success", "id": transactionid, 
							"tripInfo": null, "toa": toa, "location": locid, "locName": locName, 
							"custName": custName, "transStatus": status,
							"tripOwnerName": tripOwnerName});
					});  
				    }); 
			    });
		    }
		} else {
		    // tripowner has not arrived at location
		    var locRef = firebaseRef.child('locations/'+locid); 
		    locRef.once("value", function(snapshot) {
			    var locInfo = snapshot.val(); 
			    var locName = locInfo['name']; 
			    customerRef.once("value", function(snapshot) { 
				    var custInfo = snapshot.val(); 
				    var custName = custInfo["username"]; 
				    var tripOwnerRef = firebaseRef.child('users/'+tripownerid); 
				    tripOwnerRef.once("value", function(snapshot) { 
					    var tripOwnerInfo = snapshot.val(); 
					    var tripOwnerName = tripOwnerInfo["username"]; 
					    var tripRef = firebaseRef.child('trips/'+tripid);
					    tripRef.once("value", function(snapshot) { 
						    var tripInfo = snapshot.val(); 
						    res.json({"status": "success", "id": transactionid, 
								"tripInfo": tripInfo, "toa": toa, "location": locid, "locName": locName, 
								"custName": custName, "transStatus": status,
								"tripOwnerName": tripOwnerName});
						}); 
					});
				});
			});
		}
	    });
    }); 

app.post('/deferTransaction', function(req, res) {
        var transactionid = req.body.transactionid;
	var userid = req.body.userid; 
        firebaseRef.child('users/'+userid+'/transactions/responses/'+transactionid).set('deferred');
	// need to defer in other transaction locations as well
	res.json({"status": "success"});
    }); 


app.post('/savebag', function(req, res) { 
	var bagInfo = req.body; 
	console.log(bagInfo.contents); 
	var bagid = bagInfo.locationid+'_'+bagInfo.userid; 
	var bagRef = firebaseRef.child('bags/'+bagid); 
	var userRef = firebaseRef.child('users/'+bagInfo.userid+'/bags/'+bagInfo.locationid);
	bagRef.set({
		location: bagInfo.locationid, 
		    user: bagInfo.userid,
		    contents: bagInfo.contents
		    });
	userRef.set(bagid);
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
		if (bags != null) {
		    if (bagid in bags) {
			var bag = bags[bagid];
			var bagContents = bag["contents"];
			console.log(bagContents); 
			res.json({"contents": bagContents}); 
		    } else { 
			res.json({"contents": null}); 
		    }
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
	var userid = reqInfo.userid; 
	var tripid = reqInfo.tripid; 
	var bagContents = reqInfo.bagContents;
	var senderRef = firebaseRef.child('users/'+userid);
	var tripRef = firebaseRef.child('trips/'+tripid); 
	
	tripRef.once("value", function(snapshot) { 
		var tripInfo = snapshot.val(); 
		var locationid = tripInfo["location"];
		var tripownerid = tripInfo["user"]; 
		var toa = tripInfo["toa"]; 
		var locRef = firebaseRef.child('locations/'+locationid); 
		var userRef = firebaseRef.child('users/'+tripownerid); 
		userRef.once("value", function(snapshot) { 
			var userInfo = snapshot.val(); 
			//var deviceToken = userInfo.deviceToken; 
			// update Firebase with new transaction (pending)
			var transactionid = tripid+'_'+userid;
			senderRef.child('transactions/requests/'+transactionid).set('pending'); 
			userRef.child('transactions/responses/'+transactionid).set('pending');
			//locRef.child('transactions/'+transactionid).set('pending'); 
			tripRef.child('transactions/'+transactionid).set('pending'); 
			
			// initiate a pending transaction
			var transaction = {'customer': userid, 'tripowner': tripownerid, 'location': locationid, 'trip': tripid, 
					   'toa': toa, 'bagContents': bagContents, 'status': 'pending'};
			// update transactions folder with transaction
			firebaseRef.child('transactions/'+transactionid).set(transaction); 

			// update customer's bag (in case it was changed during request)
			var bagid = locationid+'_'+userid;
			var bagRef = firebaseRef.child('bags/'+bagid);
			bagRef.set({
				location: locationid, 
				    user: userid,
				    contents: bagContents
				    });
			/*	
			// create notification and push 
			var note = new apn.Notification();
						var device = new apn.Device(deviceToken);                    
						note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
						note.badge = 1;
						note.sound = "ping.aiff";
						note.alert =  username + ' needs something from ' + locname + '!';
						note.payload = {'messageFrom': username, 'location': locname, 
								'bag': bagContents, 'transactionid': transactionid}
						note.category = "REQUEST_CATEGORY"; 
						//console.log(myDevice); 
						//console.log(note); 
						//console.log(options); 
						apnConnection.pushNotification(note, device);
						*/
			res.json({"status": "success"});
		    });
	    }); 
    }); 

app.post('/pingUserAccept', function (req, res) {
        
	var reqInfo = req.body;
	var transactionid = reqInfo.transactionid; 
	var userid = reqInfo.userid; 
	console.log(transactionid);
	console.log(userid); 
	var transactionRef = firebaseRef.child('transactions/'+transactionid); 
	transactionRef.once("value", function(snapshot) { 
		var transInfo = snapshot.val(); 
		var customerid = transInfo["customer"]; 
		var tripid = transInfo["trip"];
		transactionRef.child('status').set("accepted"); 
		// will have to change the status of all the other pending transations the user may have for the same location!
		// so that no more than one tripgoer serves the customer's need at that particular store, with his/her partic. bag
		var customerRef = firebaseRef.child('users/'+customerid);
		customerRef.once("value", function(snapshot) { 
			var custInfo = snapshot.val(); 
			var deviceToken = custInfo["deviceToken"]; 
			var tripRef = firebaseRef.child('trips/'+tripid);
			tripRef.once("value", function(snapshot) { 
				var tripInfo = snapshot.val(); 
				var locationid = tripInfo["location"]; 
				var userid = tripInfo["user"]; 
				// change status of transaction to ACCEPTED
				changeTransactionStatus(transactionid, tripid, customerid, userid, 'accepted')
				var locationRef = firebaseRef.child('locations/'+locationid); 
				locationRef.once("value", function(snapshot) { 
					var locInfo = snapshot.val(); 
					var locName = locInfo["name"]; 
					var userRef = firebaseRef.child('users/'+userid); 
					userRef.once("value", function(snapshot) { 
						var userInfo = snapshot.val(); 
						var userName = userInfo["username"]; 
						// create notification and push 
						/*						var note = new apn.Notification();
						var device = new apn.Device(deviceToken);                    
						note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
						note.badge = 1;
						note.sound = "ping.aiff";
						note.alert =  userName + ' is going to get what you needed from ' + locName + '!';
						note.payload = {'messageFrom': userName, 'location': locName, 
								'transactionid': transactionid}; 
						apnConnection.pushNotification(note, device);
						*/
						res.json({"status": "success"});
					    }); 
				    }); 
			    }); 
		    }); 
	    }); 
    }); 

app.post('/pingUserReject', function(req, res) { 
	var reqInfo = req.body;
	var transactionid = reqInfo.transactionid; 
	var tripownerid = reqInfo.userid; 
	var tripOwnerName = reqInfo.tripOwnerName; 
	var locName = reqInfo.locName; 
	var transactionRef = firebaseRef.child('transactions/'+transactionid); 
	transactionRef.once("value", function(snapshot) { 
		var transInfo = snapshot.val(); 
		var customerid = transInfo["customer"];
		var tripid = transInfo["trip"];
		//transactionRef.child('status').set("accepted"); 
		// remove transaction from database
		removeTransaction(transactionid, tripid, customerid, tripownerid); 
		var customerRef = firebaseRef.child('users/'+customerid);
		customerRef.once("value", function(snapshot) { 
			var custInfo = snapshot.val(); 
			var deviceToken = custInfo["deviceToken"]; 
			// create notification and push 
			var note = new apn.Notification();
			var device = new apn.Device(deviceToken);                    
			note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
			note.badge = 1;
			note.sound = "ping.aiff";
			note.alert =  tripOwnerName + ' can\'t get what you needed from ' + locName + ', sorry!';
			note.payload = {'messageFrom': tripOwnerName, 'location': locName, 
					'transactionid': transactionid}; 
			apnConnection.pushNotification(note, device);
			res.json({"status": "success"});
		    }); 
	    }); 
    }); 

app.post('/pingUserDelivered', function(req, res) { 
	var transactionid = req.body.transactionid; 
	var tripownerid = req.body.userid; 
	var tripOwnerName = req.body.tripOwnerName; 
	var locName = req.body.locName; 
	var transactionRef = firebaseRef.child('transactions/'+transactionid); 
	transactionRef.once("value", function(snapshot) { 
		var transInfo = snapshot.val(); 
		var customerid = transInfo["customer"];
		var tripid = transInfo["trip"];
		changeTransactionStatus(transactionid, tripid, customerid, tripownerid, "delivered"); 
		var customerRef = firebaseRef.child('users/'+customerid);
		customerRef.once("value", function(snapshot) { 
			var custInfo = snapshot.val(); 
			var deviceToken = custInfo["deviceToken"]; 
			// create notification and push 
			var note = new apn.Notification();
			var device = new apn.Device(deviceToken);                    
			note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
			note.badge = 1;
			note.sound = "ping.aiff";
			note.alert =  tripOwnerName + ' has delivered what you needed from ' + locName + '.';
			note.payload = {'messageFrom': tripOwnerName, 'location': locName, 
					'transactionid': transactionid}; 
			apnConnection.pushNotification(note, device);
			res.json({"status": "success"});
		    }); 
	    }); 
    }); 

app.post('/postTrip', function(req, res) { 
	var locid = req.body.locationid; 
	var userid = req.body.userid; 
	var toa = req.body.toa; 
	// D.T.R: have not accounted for public or private trip yet (all are private right now)
	// create tripid 
	var tripid = userid + '_' + toa; 

	var tripRef = firebaseRef.child('trips/'+tripid); 
	tripRef.set({user: userid, location: locid, toa: toa}); 
	var userTripRef = firebaseRef.child('users/'+userid+'/trips/'+tripid); 
	userTripRef.set(toa); 
	var locationTripRef = firebaseRef.child('locations/'+locid+'/trips/'+tripid); 
	locationTripRef.set(toa); 
	res.json({"status": "success", "tripid": tripid}); 
    }); 

app.post('/getTrips', function(req, res) { 
	var locid = req.body.locationid; 
	var locationRef = firebaseRef.child('locations/'+locid);
	var activeTrips = []; 
	var currentTime = new Date().getTime()/1000;
	console.log(currentTime); 
      	locationRef.once("value", function(snapshot) { 
		var locationInfo = snapshot.val(); 
		// check if any trips
		var trips = null; 
		if ("trips" in locationInfo) { 
		    trips = locationInfo["trips"]; 
		    // remove trips that are outdated
		    for (tripid in trips) {
			var toa = trips[tripid];
			if (toa < currentTime) { 
			    removeTrip(tripid); 
			} else { 
			    var trip = {};
			    trip["tripid"] = tripid;
			    trip["toa"] = trips[tripid];
			    console.log(trip); 
			    activeTrips.push(trip); 
			}
		    }
		    res.json({"status": "success", "trips": activeTrips}); 
		} else { 
		    res.json({"status": "success", "trips": activeTrips}); 
		}
	    }); 
    }); 
	    
app.post('/getTripInfo', function(req, res) { 
	var tripid = req.body.tripid; 
	var tripRef = firebaseRef.child('trips/'+tripid); 
	tripRef.once("value", function(snapshot) { 
		var tripInfo = snapshot.val(); 
		var userid = tripInfo["user"]; 
		var userRef = firebaseRef.child('users/'+userid); 
		userRef.once("value", function(snapshot) { 
			var userInfo = snapshot.val(); 
			var userName = userInfo["username"]; 
			tripInfo["userName"] = userName; 
			res.json({"status": "success", "tripInfo": tripInfo}); 
		    }); 
	    }); 
    });

app.post('/getTransactions', function(req, res) { 
    var userid = req.body.userid; 
    var userRef = firebaseRef.child('users/'+userid); 
    var currentTime = new Date().getTime()/1000;
    userRef.once("value", function(snapshot) { 
	    var userInfo = snapshot.val(); 
	    // check if any transactions
	    var transactions = null; 
	    if ("transactions" in userInfo) { 
		transactions = userInfo["transactions"];
		if ("requests" in transactions) { 
		    var reqTransactions = transactions["requests"]; 
		    var reqTransactionsRef = userRef.child("transactions/requests"); 
		    reqTransactionsRef.once("value", function(snapshot) { 
			    var reqTransInfo = snapshot.val();
			    if ("responses" in transactions) { 
				var resTransactionsRef = userRef.child("transactions/responses"); 
				resTransactionsRef.once("value", function(snapshot) { 
					var resTransInfo = snapshot.val(); 
					// user has requests and responses
					res.json({"status": "success", "reqTransactions": reqTransInfo, "resTransactions": resTransInfo}); 
				    }); 
			    } else {
				// user only has requests
				res.json({"status": "success", "reqTransactions": reqTransInfo, "resTransactions": null}); 
			    }
			}); 
		} else {
		    // only has transactions for trips initiated by user (responses)
		    var resTransactionsRef = userRef.child("transactions/responses"); 
		    resTransactionsRef.once("value", function(snapshot) { 
			    var resTransInfo = snapshot.val(); 
			    res.json({"status": "success", "reqTransactions": null, "resTransactions": resTransInfo}); 
			});
		} 
	    } else {
		// user has no transactions
		res.json({"status": "empty", "reqTransactions": null, "resTransactions": null}); 
	    }
	}); 
    }); 

function removeTrip(tripid) { 
    var tripRef = firebaseRef.child('trips/'+tripid); 
    tripRef.once("value", function(snapshot) { 
	    var tripInfo = snapshot.val(); 
	    var locid = tripInfo["location"]; 
	    var userid = tripInfo["user"];
	    var locRef = firebaseRef.child('locations/'+locid); 
	    locRef.child('trips/'+tripid).remove();
	    var transactions = null; 
	    if ("transactions" in tripInfo) { 
		transactions = tripInfo["transactions"];
	    }
	    for (key in transactions) { 
		if (transactions[key] == "pending") { 
		    removeTransaction(key, userid); 
		}
	    }
	    // remove trip from user's data *****NEED TO FIGURE OUT HOW, IF, WHERE, to ARCHIVE TRIPS
	    var userRef = firebaseRef.child('users/'+userid); 
	    userRef.child('trips/'+tripid).remove(); 
	    tripRef.remove(); 
	});
}

app.post('/removeTrip', function(req, res) { 
	 
    }); 

function changeTransactionStatus(transactionid, tripid, customerid, tripownerid, statusType) { 
    firebaseRef.child('transactions/'+transactionid+'/status').set(statusType);
    firebaseRef.child('trips/'+tripid+'/transactions/'+transactionid).set(statusType); 
    firebaseRef.child('users/'+customerid+'/transactions/requests/'+transactionid).set(statusType); 
    firebaseRef.child('users/'+tripownerid+'/transactions/responses/'+transactionid).set(statusType); 
}
 
	

function removeTransaction(transactionid, tripid, customerid, tripownerid) { 
    var transRef = firebaseRef.child('transactions/'+transactionid); 
    transRef.once("value", function(snapshot) { 
	    var transInfo = snapshot.val(); 
	    var custRef = firebaseRef.child('users/'+customerid); 
	    custRef.child('transactions/requests/'+transactionid).remove(); 
	    var tripownerRef = firebaseRef.child('users/'+tripownerid);
	    tripownerRef.child('transactions/responses/'+transactionid).remove(); 
	    var tripRef = firebaseRef.child('trips/'+tripid);
	    tripRef.child('transactions/'+transactionid).remove(); 
	    transRef.remove(); 
	}); 
}

var server = app.listen(3000, function () {
	
	var host = server.address().address;
	var port = server.address().port;
	
	console.log('Example app listening at http://%s:%s', host, port);
	
    });
