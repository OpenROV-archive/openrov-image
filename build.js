var CONFIG = require('./config')
	,fs = require('fs')
	,path = require('path')
	,spawn = require('child_process').spawn
	,EventEmitter = require('events').EventEmitter
	,moment = require('moment')
	;

var mode = 0755;
var workdir = path.resolve(CONFIG.workdir);
var additions = path.join(workdir, "additions");
var eventLoop = new EventEmitter();

var taskQueue = [ 
	makeNode, 
	openrov, 
	mjpgStreamer, 
	ino, 
	buildOmapImage, 
	copyImage, 
	done ];



function main() {

	console.log('Welcome to the OpenROV image builder!');

	rmDir(workdir);
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

function mjpgStreamer() {
	var deploy = path.resolve(path.join(additions, "mjpg-streamer"));
	ensureDir(deploy);
	var args = [ path.join(workdir, '../lib/mjpg-streamer.sh'), workdir, CONFIG.mjpgstreamergit, deploy ];
	var cmd = 'sudo' 
        console.log('setting up OpenROV Software' + args)
	executeTask(cmd, args);
}

function ino() {
	var deploy = path.resolve(path.join(additions, "ino"));
	ensureDir(deploy);
	var args = [ path.join(workdir, '../lib/ino.sh'), workdir, CONFIG.inogit, deploy ];
	var cmd = 'sudo' 
        console.log('setting up ino (command line Arduino programmer)' + args)
	executeTask(cmd, args);
}

function copyImage() {
	var expectedFolderName = moment().format('YYYY-MM-DD');
	var dir = path.join(workdir, 'omap-image-builder/deploy', expectedFolderName);
	if (fs.existsSync(dir) == false) {
		console.error('Expected to find the omap image directory to be: ' + expectedFolderName + " but it doesn't exist :-/");
		eventLoop.emit('done');
		return;
	}
	var files = fs.readdirSync(dir).filter(
		function(element, index, array) {
			return ( element.indexOf('.xz', element.length - 3) !== -1);
		});
	if (files.length >= 1) {
		fs.symlinkSync(path.join(dir, files[0]), path.join(workdir, files[0]));
		console.log('Successfully created link to disk image in: ' + path.join(workdir, files[0]));
		eventLoop.emit('done');	
		return; 
	}
	console.log('Found no disk image file ending on .xz');
	eventLoop.emit('done');
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

rmDir = function(dirPath) {
      try { var files = fs.readdirSync(dirPath); }
      catch(e) { return; }
      if (files.length > 0)
        for (var i = 0; i < files.length; i++) {
          var filePath = dirPath + '/' + files[i];
          if (fs.statSync(filePath).isFile())
            fs.unlinkSync(filePath);
          else
            rmDir(filePath);
        }
      fs.rmdirSync(dirPath);
    };

main();
