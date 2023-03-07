var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
    name: 'VersionDiffPSSvc',
    description: 'Service Listener for Version Diff Calls',
    script: 'D:\\DeployTools\\VersionDiff\\versiondiff_website\\server.js'
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install', function () {
    svc.start();
});

svc.install();