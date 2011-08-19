properties {
	${node.url} = 'http://nodejs.org/dist/v0.5.4/node.exe'

	${sln.dir} = '.'	
	${build.dir} = "${sln.dir}/build"
	${src.dir} = "${sln.dir}/src"
	${lib.build.dir} = "${sln.dir}/lib/build"
	${lib.runtime.dir} = "${sln.dir}/lib/runtime"
	${node} = "${lib.runtime.dir}/node/node.exe"	
}

task default -depends nuget-package

task clean -depends clean-build-dir, clean-node

task clean-build-dir {
	if (Test-Path -Path ${build.dir}) {
		Remove-Item -Recurse -Force -Path ${build.dir}
	}
}

task clean-node {
	if (Test-Path -Path ${node}) {
		Remove-Item -Force -Path ${node}
	}
}

task prepare-build-dir {
	if (!(Test-Path -Path ${build.dir})) {
		New-Item -ItemType container -Path ${build.dir}
	}
}

task git-submodules-update {
	"Running git:`ngit submodule update --init --recursive"
	exec { git submodule update --init --recursive }
}

task build-cli -depends clean-build-dir, prepare-build-dir, git-submodules-update, download-node {
	New-Item -ItemType container -Path "${build.dir}/cli"

	Copy-Item -Recurse -Path "${src.dir}/main/*" -Destination "${build.dir}/cli"
	Copy-Item -Include 'changelog.txt', 'license.txt', 'readme.txt' -Path "${sln.dir}/*" -Destination "${build.dir}/cli"
	Copy-Item -Path $node -Destination "${build.dir}/cli/lib"
	
	New-Item -ItemType container -Path "${build.dir}/cli/lib/node_modules"
	
	New-Item -ItemType container -Path "${build.dir}/cli/lib/node_modules/argsparser"
	Copy-Item -Include 'index.js', 'package.json' -Path "${lib.runtime.dir}/node-argsparser/*" -Destination "${build.dir}/cli/lib/node_modules/argsparser/"
	New-Item -ItemType container -Path "${build.dir}/cli/lib/node_modules/argsparser/lib"
	Copy-Item -Path "${lib.runtime.dir}/node-argsparser/lib/argsparser.js" -Destination "${build.dir}/cli/lib/node_modules/argsparser/lib/"

	New-Item -ItemType container -Path "${build.dir}/cli/lib/node_modules/jshint"
	Copy-Item -Recurse -Include 'lib', 'HELP', 'LICENSE', 'package.json' -Path "${lib.runtime.dir}/node-jshint/*" -Destination "${build.dir}/cli/lib/node_modules/jshint/"
	New-Item -ItemType container -Path "${build.dir}/cli/lib/node_modules/jshint/packages/jshint"
	Copy-Item -Path "${lib.runtime.dir}/node-jshint/packages/jshint/jshint.js" -Destination "${build.dir}/cli/lib/node_modules/jshint/packages/jshint/"
}

task download-node {
	if (Test-Path -Path $node) {
		"Skipping node download. Node already exists at: ${node}"
	} else {
		Remove-Module BitsTransfer -ErrorAction SilentlyContinue
		Import-Module BitsTransfer
		${node.dir} = Split-Path -Parent -Path $node
		if (!(Test-Path ${node.dir})) {
			New-Item -ItemType container -Path ${node.dir}
		}
		Start-BitsTransfer -DisplayName "Downloading node from ${node.url}" -Source ${node.url} -Destination $node
	}
}

task nuget-package-layout -depends build-cli {
	New-Item -ItemType container -Path "${build.dir}/nuget-package-layout"
	New-Item -ItemType container -Path "${build.dir}/nuget-package-layout/tools"
	Copy-Item -Recurse -Exclude 'changelog.txt', 'license.txt', 'readme.txt' -Path "${build.dir}/cli/*" -Destination "${build.dir}/nuget-package-layout/tools"
	Copy-Item -Include 'changelog.txt', 'license.txt', 'readme.txt' -Path "${build.dir}/cli/*" -Destination "${build.dir}/nuget-package-layout"
}

task nuget-package -depends nuget-package-layout {
	New-Item -ItemType container -Path "${build.dir}/nuget-package"
	
	exec { & "${lib.build.dir}/NuGet/nuget.exe" pack "${src.dir}/nuget-package/package.nuspec" -BasePath "${build.dir}/nuget-package-layout" -OutputDirectory "${build.dir}/nuget-package" }
}

task test -depends build-cli, test-uses-vs-reporter-by-default, test-writes-report-file

task test-uses-vs-reporter-by-default {
	Remove-Module jshint -ErrorAction SilentlyContinue
	Import-Module "${build.dir}/cli/jshint.psm1"
	$actual = Invoke-JSHint -PathList "${src.dir}/test/broken.js"
	$expected = "./src/test/broken.js(1,14): warning JSHint: Unmatched '{'."
	Assert ($actual -eq $expected) "Expected: '$expected'`n`tbut got:  '$actual'"
}

task test-writes-report-file {	
	Remove-Module jshint -ErrorAction SilentlyContinue
	Import-Module "${build.dir}/cli/jshint.psm1"
	${report.file} = "${build.dir}/report.txt"
	Invoke-JSHint -PathList "${src.dir}/test/broken.js" -ReportFile ${report.file}
	$actual = Get-Content -Path ${report.file}
	Remove-Item -Path ${report.file} -ErrorAction SilentlyContinue
	$expected = "./src/test/broken.js(1,14): warning JSHint: Unmatched '{'."
	Assert ($actual -eq $expected) "Expected: '$expected'`n`tbut got:  '$actual'"	
}