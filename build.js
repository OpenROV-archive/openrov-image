var CONFIG = require('./config')
	,fs = require('fs')
	,path = require('path')
	,spawn = require('child_process').spawn
	,EventEmitter = require('events').EventEmitter
	;

var mode = 0755;
var workdir = path.resolve(CONFIG.workdir);
var additions = path.join(workdir, "additions");
var nodedeploy = path.resolve(path.join(additions, CONFIG.nodedeploypath));
var eventLoop = new EventEmitter();

var taskQueue = [ makeNode, buildOmapImage ];
//var taskQueue = [ buildOmapImage ];

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

	eventLoop.on('done', function() {
		var task = taskQueue.shift();
		if (task) task();
	});
	eventLoop.emit('done');

	console.log('All DONE!');	
}

function makeNode() {
	var nodeBuilt = false;
	var args = [ workdir, CONFIG.nodegit, CONFIG.nodeversion, nodedeploy ];
	var cmd = path.join(workdir, '../lib/nodejs.sh');
	console.log('Getting/compiling node '); 
	console.log('Command line: ' + cmd + ' ' + args.join(' '));
	executeTask(cmd, args);
}

function buildOmapImage() {
	var args = [ path.join(workdir, '../lib/omapimage.sh'), workdir, CONFIG.omapimagebuildergit, CONFIG.omapimagebuilderbranch];
	var cmd = 'sudo' 
        console.log('Building the image!' + args)
	executeTask(cmd, args);
}

function executeTask(cmd, args) {

	var build_process = spawn(cmd, args);
	build_process.stderr.on('data', function(data) {
        	console.error(data.toString());
	      });
	build_process.stdout.on('data', function(data) {
		console.log(data.toString());
		});
	build_process.on('exit', function(x) {
		 console.log('build done:', x);
		eventLoop.emit('done');
		});
}

main();
