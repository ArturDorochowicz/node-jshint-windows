module.exports = {
    reporter: function (results) {
        process.stdout.on('end', function () {
            process.exit(results.length > 0 ? 1 : 0);
        });

        process.stdout.write("Errors: " + results.length + "\n");
    }
};
