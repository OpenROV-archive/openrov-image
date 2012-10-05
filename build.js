var CONFIG = require('./config')
	,fs = require('fs')
	,path = require('path')
	,spawn = require('child_process').spawn
	,EventEmitter = require('events').EventEmitter
	;

var mode = 0755;
var workdir = path.resolve(CONFIG.workdir);
var additions = path.join(workdir, "additions");
var eventLoop = new EventEmitter();

var taskQueue = [ makeNode, openrov, buildOmapImage, done ];

function main() {

	console.log('Welcome to the OpenROV image builder!');

	ensureDir(workdir);

	eventLoop.on('done', function() {
		var task = taskQueue.shift();
		if (task) task();
	});
	eventLoop.emit('done');

}

function makeNode() {
	var nodedeploy = path.resolve(path.join(additions, CONFIG.nodedeploypath));
	ensureDir(nodedeploy);
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

function openrov() {
	var deploy = path.resolve(path.join(additions, "openrov"));
	ensureDir(deploy);
	var args = [ path.join(workdir, '../lib/openrov.sh'), workdir, CONFIG.openrovgit, CONFIG.openrovbranch, deploy ];
	var cmd = 'sudo' 
        console.log('setting up OpenROV Software' + args)
	executeTask(cmd, args);

}

function done() {
	console.log("All done, bye!");
}

function ensureDir(dir) {
	if (fs.existsSync(dir) == false )
	{
		fs.mkdir(dir, mode);
	}
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
