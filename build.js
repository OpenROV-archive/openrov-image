var CONFIG = require('./config')
	,fs = require('fs')
	,path = require('path')
	,spawn = require('child_process').spawn
	;

var mode = 0755;
var workdir = path.resolve(CONFIG.workdir);
var nodedeploy = path.resolve(path.join(workdir, CONFIG.nodedeploypath));

function main() {

	console.log('Welcome to the OpenROV image builder!');

	if (fs.existsSync(workdir) == false )
	{
		fs.mkdir(workdir, mode);
	}
	if (fs.existsSync(nodedeploy) == false )
	{
		fs.mkdir(nodedeploy, mode);
	}
	makeNode();

}

function makeNode() {
console.log('WorkDir: ' + workdir); 
	var args = [ workdir, CONFIG.nodegit, CONFIG.nodeversion, nodedeploy ];
	var cmd = path.join(workdir, '../lib/nodejs.sh');
	console.log('Getting/compiling node ' + cmd); 
 	/*var child = exec(cmd);
	child.on('data', function(data) { console.log(data); });
	child.on('exit', function(code) { console.log('lib/nodejs.sh exiting with code ' + code); });*/
	//exec(cmd, {silent:false, async:false});
	var build_process = spawn(cmd, args);
	build_process.stderr.on('data', function(data) {
        	console.error('build err:', data.toString());
	      });
	build_process.stdout.on('data', function(data) {
		console.log('build data:', data.toString());
		});
	build_process.on('exit', function(x) { console.log('build done:', x);});
	
}

main();
