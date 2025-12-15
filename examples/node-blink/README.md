Node.js LED blink example

Uses `onoff` to toggle a GPIO pin. On non-Pi platforms the script will log simulated toggles.

Run on Pi:

```bash
cd examples/node-blink
npm install
node index.js
```

If `package-lock.json` is missing, the repository includes a workflow that can generate and commit it automatically. Locally, run `npm install` to create the lockfile.