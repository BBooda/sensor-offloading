#!/usr/bin/env python

import sys
from scipy import io
import time
import subprocess
from datetime import date, datetime

# run this to get a nad cid
# sudo qmicli -p -d /dev/cdc-wdm0 --nas-noop --client-no-release-cid
# this script should be run as sudo python3 {cid_number} {matlab_output_file_name}


# create lists to save to matlab files.
signal_strength = []
cell_location_info = []
signal_info = []
time_list = []

# commands to run
# sudo qmicli -p -d /dev/cdc-wdm0 --nas-get-signal-strength --client-cid=4 --client-no-release-cid
# sudo qmicli -p -d /dev/cdc-wdm0 --nas-noop --client-no-release-cid
def get_signal_strength(f_cid):
    command = ["qmicli", "-p", "-d", "/dev/cdc-wdm0", "--nas-get-signal-strength", 
    "--client-cid={cid}".format(cid=f_cid), "--client-no-release-cid"]
    out = subprocess.run(command, stdout=subprocess.PIPE).stdout.decode('utf-8')
    return out

def get_time():
    current_time = datetime.now()
    return current_time.timestamp()

def get_signal_info(f_cid):
    command = ["qmicli", "-p", "-d", "/dev/cdc-wdm0", "--nas-get-signal-info", 
    "--client-cid={cid}".format(cid=f_cid), "--client-no-release-cid"]
    out = subprocess.run(command, stdout=subprocess.PIPE).stdout.decode('utf-8')
    return out

def get_signal_cell_location_info(f_cid):
    command = ["qmicli", "-p", "-d", "/dev/cdc-wdm0", "--nas-get-cell-location-info", 
    "--client-cid={cid}".format(cid=f_cid), "--client-no-release-cid"]
    out = subprocess.run(command, stdout=subprocess.PIPE).stdout.decode('utf-8')
    return out


if __name__ == "__main__":
    # save data 
    try:
        while True:

            # grab cid from command line arguments 
            cid = sys.argv[1]
            # get signal strength
            
            signal_strength.append(get_signal_strength(cid))

            cell_location_info.append(get_signal_cell_location_info(cid))

            signal_info.append(get_signal_info(cid))
            
            # log time
            time_list.append(get_time())
    except KeyboardInterrupt:
        if len(sys.argv) > 2:
            fname = sys.argv[2]
        else:
            fname = "default_name"
        io.savemat(fname + ".mat", 
            {'signal_strength' : signal_strength, 'time_list' : time_list, 'signal_info': signal_info, 'cell_location_info' : cell_location_info})
        print("\nExit logger! Save data to matlab file.")
        print(sys.argv)