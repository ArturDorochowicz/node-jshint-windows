module.exports = {
    reporter: function (results) {
        process.stdout.write("Errors: " + results.length + "\n");
    }
};
