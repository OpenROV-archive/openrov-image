var CONFIG = require('./config')
	,fs = require('fs')
	,exec = require('child_process').exec
	;

var mode = 0755;
var workDirectory = './work/';

function main() {

	console.log('Welcome to the OpenROV image builder!');

	if (fs.existsSync(workDirectory) == false )
	{
		fs.mkdir(workDirectory, mode, function(err) { if (err) {throw err; }});	
	}
	process.chdir(workDirectory);
	getNode();

}

function getNode() {
	console.log('Getting NodeJS version ' + CONFIG.nodeversion);
 	var child = exec('git clone ' + CONFIG.nodegit);
	child.on('data', function(data) { console.log(data); });
	child.on('exit', function(code) { console.log('git clone exited with code ' + code); });
}

main();
