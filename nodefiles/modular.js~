var fs = require('fs'); 
var path = require('path'); 
var mymodule = require('./mymodule.js'); 

mymodule(process.argv[2], process.argv[3], function(err, list) { 
	if (err) console.log(err); 
	else { 
	    list.forEach(function(val) { 
		    console.log(val); 
		}); 
	}
    }); 
		
