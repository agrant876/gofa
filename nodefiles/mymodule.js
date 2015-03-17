var fs = require('fs'); 
var path = require('path'); 

module.exports = function (dir, givenExt, callback) {
   
    var givenExt = '.' + givenExt;
    fs.readdir(dir, function(err, list) { 
	    if (err) {
		//console.log(callback); 
		return callback(err, null);  
	    }
	    var filteredList = [];
	    var i = 0; 
	    list.forEach(function (val, index, array) {
		    var ext = path.extname(val); 
		    //console.log(ext); 
		    //console.log(givenExt); 
		    if (ext == givenExt) { 
			filteredList[i] = val; 
			i++; 
			//console.log(val); 
		    }
		}); 
	    callback(null, filteredList);  
	}); 
}; 
    

