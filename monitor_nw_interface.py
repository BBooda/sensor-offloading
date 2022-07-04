#!/usr/bin/env python

import sys
from scipy import io
import time

data_list = []

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
    # convert bytes to bits
    data = (bytes_after-bytes_before)*8
    return data


if __name__ == "__main__":
    counter = 1
    devname = "hnet0"
    timestep = 1 # Seconds
    
    Kb_th = 1000
    Mb_th = 1000000
    Gb_th = 1000000000

    try:
        while True:
            data = transmissionrate(devname, "rx", timestep)
            # append to list to save to matlab file
            data_list.append(data)
            if data > Kb_th:
                print(str(data/Kb_th) + " Kbps")
            elif data > Mb_th:
                print(str(data/Mb_th) + " Mbps")
            elif data > Gb_th:
                print(str(data/Gb_th) + " Gbps")
            else:
                print(str(data) + " bps")
    except KeyboardInterrupt:
        if len(sys.argv) > 1:
            fname = sys.argv[1]
        else:
            fname = "default_name"
        io.savemat(fname + ".mat", 
            {'data_rate' : data_list, 'time_interval' : timestep})
        print("\nExit logger! Save data to matlab file.")