#!/usr/bin/env python3

import struct
import time
from smbus import SMBus

I2C_BUS = 7
ESP32_ADDR = 0x42

MAGIC = 0xC3A1
VERSION = 1

THROTTLE_NEUTRAL = 1500
STEERING_CENTRE = 1500

PACKET_FORMAT = "<HBBIhh"

sequence = 0


def send_command(bus, throttle_us, steering_us):
    global sequence

    packet = struct.pack(
        PACKET_FORMAT,
        MAGIC,
        VERSION,
        0,
        sequence,
        int(throttle_us),
        int(steering_us),
    )

    bus.write_i2c_block_data(
        ESP32_ADDR,
        0x00,
        list(packet),
    )

    sequence += 1


def main():
    bus = SMBus(I2C_BUS)

    try:
        print("Sending neutral for 1 second")

        start = time.time()

        while time.time() - start < 1.0:
            send_command(bus, THROTTLE_NEUTRAL, STEERING_CENTRE)
            time.sleep(0.03)

        print("Testing steering left/right")

        for _ in range(20):
            send_command(bus, 1500, 1700)
            time.sleep(0.03)

        for _ in range(20):
            send_command(bus, 1500, 1500)
            time.sleep(0.03)

        for _ in range(20):
            send_command(bus, 1500, 1300)
            time.sleep(0.03)

        for _ in range(20):
            send_command(bus, 1500, 1500)
            time.sleep(0.03)

        print("Testing gentle forward")

        for _ in range(20):
            send_command(bus, 1550, 1500)
            time.sleep(0.03)

        print("Back to neutral")

        for _ in range(30):
            send_command(bus, 1500, 1500)
            time.sleep(0.03)

    finally:
        bus.close()


if __name__ == "__main__":
    main()
