var http = require('http'); 
var url = require('url'); 

function parsetime (time) {
    return {
	hour: time.getHours(),
	    minute: time.getMinutes(),
	    second: time.getSeconds()
	    };
}

function unixtime (time) {
    return { unixtime : time.getTime() }; 
}


var server = http.createServer(function (req, res) {
	var parsedUrl = url.parse(req.url, true);
	var query = parsedUrl['query']; 
	var date = new Date(query['iso']); 
	//console.log(date); 
	//console.log(url.parse(req.url, true)); 
	var result;

	if (parsedUrl['pathname'] == '/api/unixtime') {
	    result = unixtime(date); 
	} else if (parsedUrl['pathname'] == '/api/parsetime') { 
	    result = parsetime(date); 
	}

	if (result) {
	    res.writeHead(200, { 'Content-Type': 'application/json' }); 
	    res.end(JSON.stringify(result)); 
	} else {
	    res.writeHead(404);
	    res.end();
	}
    });  
server.listen(Number(process.argv[2])); 



