Bleacon = require('bleacon');
uuid = process.argv[2]
Bleacon.startScanning(uuid);

Bleacon.on('discover', function(bleacon) {
   console.log(JSON.stringify(bleacon));
});
