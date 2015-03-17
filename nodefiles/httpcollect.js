var bl = require('bl');
var http = require('http');      


http.get(process.argv[2], function (response) {
	response.pipe(bl(function (err, data) {
		    if (err) console.log(err); 
		    else { 
			var str = data.toString(); 
			console.log(str.length); 
			console.log(str); 
		    }
		}));
    }); 
	    
	    
			    