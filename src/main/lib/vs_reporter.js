// MSBuild/VisualStudio-compatible reporter, based on information from:
// http://blogs.msdn.com/b/msbuild/archive/2006/11/03/msbuild-visual-studio-aware-error-messages-and-message-formats.aspx
// This reporter does not set process exit code (via process.exit(...)) like default reporter does,
// because it makes writes to stdout unreliable - they may not get flushed before node.js terminates.
module.exports = {
    reporter: function (results) {
        'use strict';
        var format = '%s(%d,%d): error JSHint: %s';

        results.forEach(function (result) {
            var error = result.error;
            console.log(format, result.file, error.line, error.character, error.reason);
        });
    }
};
