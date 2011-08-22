node-jshint-windows

Copyright (c) 2011 Artur Dorochowicz

Packaging of node command line interface for JSHint with Windows version of node.js.
Ready to use on Windows (and Windows alone).


1. Command line interface via jshint.bat

For details, look at node-jshint readme file in lib\node_modules\jshint directory. 
Please note that .jshintignore files are ignored due to unavailability of glob module on Windows.


2. PowerShell jshint.psm1 module

The module exports one function: Invoke-JSHint.
By default it will use an MSBuild/Visual Studio-compatible reporter.
