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

task clean -depends clean-build-dir

task clean-build-dir {
	if (Test-Path -Path ${build.dir}) {
		Remove-Item -Recurse -Force -Path ${build.dir}
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

	Copy-Item -Path "${src.dir}/main/*" -Destination "${build.dir}/cli"	
	Copy-Item -Include 'changelog.txt', 'license.txt', 'readme.txt' -Path "${sln.dir}/*" -Destination "${build.dir}/cli"
	Copy-Item -Path $node -Destination "${build.dir}/cli"
	
	New-Item -ItemType container -Path "${build.dir}/cli/node_modules"
	
	New-Item -ItemType container -Path "${build.dir}/cli/node_modules/argsparser"
	Copy-Item -Include 'index.js', 'package.json' -Path "${lib.runtime.dir}/node-argsparser/*" -Destination "${build.dir}/cli/node_modules/argsparser/"
	New-Item -ItemType container -Path "${build.dir}/cli/node_modules/argsparser/lib"
	Copy-Item -Path "${lib.runtime.dir}/node-argsparser/lib/argsparser.js" -Destination "${build.dir}/cli/node_modules/argsparser/lib/"

	New-Item -ItemType container -Path "${build.dir}/cli/node_modules/jshint"
	Copy-Item -Recurse -Include 'lib', 'HELP', 'LICENSE', 'package.json' -Path "${lib.runtime.dir}/node-jshint/*" -Destination "${build.dir}/cli/node_modules/jshint/"
	New-Item -ItemType container -Path "${build.dir}/cli/node_modules/jshint/packages/jshint"
	Copy-Item -Path "${lib.runtime.dir}/node-jshint/packages/jshint/jshint.js" -Destination "${build.dir}/cli/node_modules/jshint/packages/jshint/"
}

task download-node {
	if (Test-Path -Path $node) {
		"Skipping node download. Node already exists at: ${node}"
	} else {
		Import-Module BitsTransfer
		try {
			New-Item -ItemType container -Path (Split-Path -Parent -Path $node)
			Start-BitsTransfer -DisplayName "Downloading node from ${node.url}" -Source ${node.url} -Destination $node
		} finally {
			Remove-Module BitsTransfer
		}
	}
}

task nuget-package-layout -depends build-cli {
	New-Item -ItemType container -Path "${build.dir}/nuget-package-layout"
	New-Item -ItemType container -Path "${build.dir}/nuget-package-layout/tools"
	Copy-Item -Recurse -Exclude 'changelog.txt', 'license.txt', 'readme.txt' -Path "${build.dir}/cli/*" -Destination "${build.dir}/nuget-package-layout/tools"
	Copy-Item -Include 'changelog.txt', 'license.txt', 'readme.txt' -Path "${build.dir}/cli/*" -Destination "${build.dir}/nuget-package-layout"
	Copy-Item -Path "${src.dir}/nuget-package/node-jshint-windows.nuspec" -Destination "${build.dir}/nuget-package-layout"
}

task nuget-package -depends nuget-package-layout {
	New-Item -ItemType container -Path "${build.dir}/nuget-package"
	
	exec { & "${lib.build.dir}/NuGet/nuget.exe" pack "${build.dir}/nuget-package-layout/node-jshint-windows.nuspec" -OutputDirectory "${build.dir}/nuget-package" }
}
