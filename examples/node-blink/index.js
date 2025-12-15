const INTERVAL = 500;
let onPi = true;
try {
  var Gpio = require('onoff').Gpio;
} catch (e) {
  onPi = false;
}

const pin = 17;
if (onPi) {
  const led = new Gpio(pin, 'out');
  console.log(`Running on Pi — blinking GPIO ${pin}`);
  setInterval(() => {
    led.writeSync(led.readSync() ^ 1);
  }, INTERVAL);
} else {
  console.log('Not on a Pi — simulating blink.');
  let state = 0;
  setInterval(() => {
    state ^= 1;
    console.log(state ? 'LED ON' : 'LED OFF');
  }, INTERVAL);
}