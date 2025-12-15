"""Blink LED example — uses gpiozero on a Raspberry Pi, simulates elsewhere."""

import time

try:
    from gpiozero import LED
    on_pi = True
except Exception:
    on_pi = False

GPIO_PIN = 17

if on_pi:
    led = LED(GPIO_PIN)
    print("Running on Raspberry Pi — blinking LED on GPIO {}".format(GPIO_PIN))
    try:
        while True:
            led.on()
            time.sleep(0.5)
            led.off()
            time.sleep(0.5)
    except KeyboardInterrupt:
        led.off()
        print("Stopped")
else:
    print("Not on a Raspberry Pi — simulating blink. Press Ctrl-C to stop.")
    try:
        while True:
            print("LED ON")
            time.sleep(0.5)
            print("LED OFF")
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("Stopped")
