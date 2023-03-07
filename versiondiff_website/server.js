var express = require('express');
var app = express();
var exec = require('child_process').exec;
shell = require('node-powershell'),
    ps = new shell({
        executionpolicy: 'bypass',
        noProfile: true
    }),

    app.use(express.static(__dirname));

app.get('/versiondiff', function (request, response) {
    //response.send("Your First parameter: " + request.body.firstname)
    ps.addCommand("D:\\DeployTools\\VersionDiff\\GitLab\\gitlab_versiondiff.ps1", [{
        name: 'version1',
        value: request.query.VersionA,
    }, {
        name: 'version2',
            value: request.query.VersionB
        }]),
        
        ps.invoke().then(output => {
            //let output = data.toString();
            let style = "<style>table, th, td { border: 1px solid black; border-collapse: collapse; text-align: left; }th, td { padding: 3px; }</style>";
           if (request.query.bot === "true") {
            response.send(output);
            ps.dispose()
            } else {
               // output = output.replace(/\n/gi, '<br>\n');
                response.send('<html>' + style + '<body>' + output.toString() + '</body></html>');
            }
        })
});




/*app.get('/versiondiff', function (request, response) {
    // call and run powershell script and attach output to the response

    exec('C:\\Users\\e10115717\\Desktop\\repos\\mswufiversiondiff\\VersionDiff.ps1', [request.query.VersionA, request.query.VersionB, "html"], function (err, data) {
            let output = data.toString();

            let style = "<style>table, th, td { border: 1px solid black; border-collapse: collapse; text-align: left; }th, td { padding: 3px; }</style>";

            // If the bot param is set, don't add any html.
            if (request.query.bot === "true") {
                response.send(output);
            } else {
                output = output.replace(/\n/gi, '<br>\n');
                response.send('<html>' + style + '<body>' + output.toString() + '</body></html>');
            }
        });
});
*/




app.listen(1337, function () {
    console.log("server is not running on port 1337")
})

