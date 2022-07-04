#!/usr/bin/env python

import time

def transmissionrate(dev, direction, timestep):
    """Return the transmisson rate of a interface under linux
    dev: devicename
    direction: rx (received) or tx (sended)
    timestep: time to measure in seconds
    """
    path = "/sys/class/net/{}/statistics/{}_bytes".format(dev, direction)
    f = open(path, "r")
    bytes_before = int(f.read())
    f.close()
    time.sleep(timestep)
    f = open(path, "r")
    bytes_after = int(f.read())
    f.close()
    # return (bytes_after-bytes_before)/timestep
    return (bytes_after-bytes_before)


if __name__ == "__main__":
    counter = 1
    devname = "hnet0"
    timestep = 1 # Seconds
    
    while True:
        print(transmissionrate(devname, "rx", timestep))
        counter += 1