var http = require('http'); 
var bl = require('bl');

http.get(process.argv[2], function(response) {
	response.pipe(bl(function (err, data) {
		    if (err) console.log(err); 
		    else { 
			var str = data.toString(); 
			console.log(str); 
		    }
		    getsecond(process.argv[3]); 
		})); 
    }); 

function getsecond(url) { 
    http.get(url, function(response) { 
	    response.pipe(bl(function (err, data) {
			if (err) console.log(err); 
			else { 
			    var str = data.toString(); 
			    console.log(str); 
			}
			getthird(process.argv[4]); 
		    })); 
	}); 
} 

function getthird(url) {
    http.get(url, function(response) { 
	    response.pipe(bl(function (err, data) {
			if (err) console.log(err); 
			else { 
			    var str = data.toString(); 
			    console.log(str); 
			}
		    })); 
	}); 
} 

	    	    
		
		