Bleacon = require('bleacon');
var uuid = process.argv[2];
var major = parseInt(process.argv[3], 10);
var minor = parseInt(process.argv[4], 10);
var measuredPower = parseInt(process.argv[5], 10);
Bleacon.startAdvertising(uuid, major, minor, measuredPower);