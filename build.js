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
	//makeNode();
	buildOmapImage();

	console.log('All DONE!');	
}

function makeNode() {
	var args = [ workdir, CONFIG.nodegit, CONFIG.nodeversion, nodedeploy ];
	var cmd = path.join(workdir, '../lib/nodejs.sh');
	console.log('Getting/compiling node '); 
	var build_process = spawn(cmd, args);
	build_process.stderr.on('data', function(data) {
        	console.error('build err:', data.toString());
	      });
	build_process.stdout.on('data', function(data) {
		console.log('build data:', data.toString());
		});
	build_process.on('exit', function(x) { console.log('build done:', x);});
	
}

function buildOmapImage() {
	var args = [ workdir, CONFIG.omapimagebuildergit, CONFIG.omapimagebuilderbranch];
	var cmd = path.join(workdir, '../lib/omapimage.sh');
        console.log('Building the image!' + args)
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
