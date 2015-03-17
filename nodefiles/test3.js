var fs = require('fs');
var arglength = process.argv.length; 
console.log(arglength); 
for (var i = 0; i < arglength; i++)
    console.log(process.argv[i]); 

var buf = fs.readFileSync(process.argv[0]);
var str = buf.toString(); 
console.log(str); 