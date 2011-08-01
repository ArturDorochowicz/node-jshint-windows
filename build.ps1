$nodeUrl = 'http://nodejs.org/dist/v0.5.2/node.exe'

$slnDir = '.'
$buildDir = "$slnDir/build"
$node = "$slnDir/node.exe"

if (Test-Path $buildDir) {
	Remove-Item -Recurse -Force "$buildDir/*"
} else {
	New-Item -ItemType 'container' $buildDir 
}

git submodule update --init --recursive

New-Item -ItemType container "$buildDir/node_modules"

New-Item -ItemType container "$buildDir/node_modules/argsparser"
New-Item -ItemType container "$buildDir/node_modules/argsparser/lib"
Copy-Item -Path "$slnDir/node-argsparser/lib/argsparser.js" -Destination "$buildDir/node_modules/argsparser/lib/"
Copy-Item -Path "$slnDir/node-argsparser/index.js" -Destination "$buildDir/node_modules/argsparser/"
Copy-Item -Path "$slnDir/node-argsparser/package.json" -Destination "$buildDir/node_modules/argsparser/"

New-Item -ItemType 'container' "$buildDir/node_modules/jshint"
Copy-Item -Path "$slnDir/node-jshint/package.json" -Destination "$buildDir/node_modules/jshint/"
Copy-Item -Path "$slnDir/node-jshint/HELP" -Destination "$buildDir/node_modules/jshint/"
Copy-Item -Recurse -Path "$slnDir/node-jshint/lib" -Destination "$buildDir/node_modules/jshint/"
New-Item -ItemType container "$buildDir/node_modules/jshint/packages/jshint"
Copy-Item -Path "$slnDir/node-jshint/packages/jshint/jshint.js" -Destination "$buildDir/node_modules/jshint/packages/jshint/"

Copy-Item -Path "$slnDir/src/*" -Destination $buildDir

if (!(Test-Path $node)) {
	Import-Module BitsTransfer
	try {
		Start-BitsTransfer -DisplayName "Downloading node from $nodeUrl" -Source $nodeUrl -Destination $node
	} finally {
		Remove-Module BitsTransfer
	}
}
Copy-Item -Path $node -Destination $buildDir
