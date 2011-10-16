// MSBuild/VisualStudio-compatible reporter, based on information from:
// http://blogs.msdn.com/b/msbuild/archive/2006/11/03/msbuild-visual-studio-aware-error-messages-and-message-formats.aspx
module.exports = {
    reporter: function (results) {
        'use strict';
        var str = '';

        results.forEach(function (result) {
            var error = result.error;
            str += result.file + '(' + error.line + ',' + error.character + '): error JSHint: ' + error.reason + '\n';
        });

        process.stdout.write(str + "\n");
    }
};
