$nodeUrl = 'http://nodejs.org/dist/v0.5.2/node.exe'

$slnDir = '.'
$buildDir = "$slnDir/build"
$node = "$slnDir/node.exe"

if (Test-Path $buildDir) {
	Remove-Item -Recurse -Force -Path "$buildDir/*"
} else {
	New-Item -ItemType container -Path $buildDir 
}

git submodule update --init --recursive

New-Item -ItemType container -Path "$buildDir/node_modules"

New-Item -ItemType container -Path "$buildDir/node_modules/argsparser"
Copy-Item -Include @('index.js', 'package.json') -Path "$slnDir/node-argsparser/*" -Destination "$buildDir/node_modules/argsparser/"
New-Item -ItemType container -Path "$buildDir/node_modules/argsparser/lib"
Copy-Item -Path "$slnDir/node-argsparser/lib/argsparser.js" -Destination "$buildDir/node_modules/argsparser/lib/"

New-Item -ItemType container -Path "$buildDir/node_modules/jshint"
Copy-Item -Recurse -Include @('lib', 'HELP', 'LICENSE', 'package.json') -Path "$slnDir/node-jshint/*" -Destination "$buildDir/node_modules/jshint/"
New-Item -ItemType container -Path "$buildDir/node_modules/jshint/packages/jshint"
Copy-Item -Path "$slnDir/node-jshint/packages/jshint/jshint.js" -Destination "$buildDir/node_modules/jshint/packages/jshint/"

Copy-Item -Path "$slnDir/src/*" -Destination $buildDir

if (!(Test-Path -Path $node)) {
	Import-Module BitsTransfer
	try {
		Start-BitsTransfer -DisplayName "Downloading node from $nodeUrl" -Source $nodeUrl -Destination $node
	} finally {
		Remove-Module BitsTransfer
	}
}
Copy-Item -Path $node -Destination $buildDir
