#!/usr/bin/env python
import sys
from typing import Dict
import rospy, rostopic
rospy.init_node('statistics_node')

# parse command line arguments 
print(type(sys.argv))
print(sys.argv)


class BwData:
    #object to structurly store BW data from rostopic tools
    def __init__(self) -> None:
        self.list_of_data = []
    
    def append_to_data(self, my_dict):
        # appends data to the list
        self.list_of_data.append(my_dict)
    
    def get_stored_data(self):
        print(len(self.list_of_data))
        return self.list_of_data

class HzData:
    #object to structurly store Hz data from rostopic tools
    def __init__(self) -> None:
        self.list_of_data = []
    
    def append_to_data(self, my_dict):
        # tuple to dict
        my_dict = {"rate" : my_dict[0], "min_delta" : my_dict[1], 
        "max_delta" : my_dict[2], "std_dev" : my_dict[3], "n_plus_1" : my_dict[4]}
        # appends data to the list
        self.list_of_data.append(my_dict)
    
    def get_stored_data(self):
        return self.list_of_data

class CollectData:
    def __init__(self) -> None:
        self.bw_m = BwData()
        self.hz_m = HzData()
        try:
            from scipy import io
        except ImportError as error:
            print(error)

    def collect_bw_data(self, dict):
        # use instance method to append measurement to the bw instance
        self.bw_m.append_to_data(dict)

    def collect_hz_data(self, dict):
        # use instance method to append measurement to the bw instance
        self.hz_m.append_to_data(dict)

    def save_bw_to_matlab(self, fname):
        from scipy import io
        io.savemat(fname + ".mat", 
        {'bw_list' : self.bw_m.get_stored_data()})

    def save_hz_to_matlab(self, fname):
        from scipy import io
        io.savemat(fname + ".mat", 
        {'hz_list' : self.hz_m.get_stored_data()})



# topic_name = '/pixy/vicon/demo_crazyflie9/demo_crazyflie9/odom'

# get topic name from command arguments
topic_name = sys.argv[1]

r = rostopic.ROSTopicHz(-1)
s = rospy.Subscriber(topic_name, rospy.AnyMsg, r.callback_hz, callback_args=topic_name)
# s = rospy.Subscriber(topic_name, rospy.AnyMsg, r.callback_hz, callback_args=topic_name)
# rospy.sleep(1)
r.print_hz([topic_name])

b = rostopic.ROSTopicBandwidth()  
s2 = rospy.Subscriber(topic_name, rospy.AnyMsg, b.callback)  
# rospy.sleep(1)  
b.print_bw()

rate = rospy.Rate(1)

# d = rostopic.ROSTopicDelay(50)
# d1 = rospy.Subscriber(topic_name, rospy.AnyMsg, d.callback_delay) 

# overide print_bw method to get measurements in a structure form
try:
    from types import MethodType
    import time

    def get_bw(self):
        """print the average publishing rate to screen""" 
        if len(self.times) < 2: 
            return 
        with self.lock: 
            n = len(self.times) 
            tn = time.time() 
            t0 = self.times[0] 
            
            total = sum(self.sizes) 
            bytes_per_s = total / (tn - t0) 
            mean = total / n 

            #std_dev = math.sqrt(sum((x - mean)**2 for x in self.sizes) /n) 

            # min and max 
            max_s = max(self.sizes) 
            min_s = min(self.sizes) 

        #min/max and even mean are likely to be much smaller, but for now I prefer unit consistency 
        if bytes_per_s < 1000: 
            bw, mean, min_s, max_s = ["%.2fB"%v for v in [bytes_per_s, mean, min_s, max_s]] 
        elif bytes_per_s < 1000000: 
            bw, mean, min_s, max_s = ["%.2fKB"%(v/1000) for v in [bytes_per_s, mean, min_s, max_s]]   
        else: 
            bw, mean, min_s, max_s = ["%.2fMB"%(v/1000000) for v in [bytes_per_s, mean, min_s, max_s]] 
            
        print("average: %s/s\n\tmean: %s min: %s max: %s window: %s"%(bw, mean, min_s, max_s, n)) 
        bw_stat_dict = {'bw' : bw, 'mean' : mean, 'min_s' : min_s, 'max_s' : max_s, 'n' : n}
        return bw_stat_dict

    b.get_bw = MethodType(get_bw, b)
except ImportError as error:
    print(error)
except:
    print("Not import error!!")

# initialize collection objects
data_collector = CollectData()

counter = 1

while not rospy.is_shutdown():
        # r.print_hz([topic_name])
        hz_tuple = r.get_hz(topic_name)
        if hz_tuple is not None:
            # print(hz_tuple[0])
            bw = b.print_bw()
            
            raw_bw = b.get_bw()
            data_collector.collect_hz_data(hz_tuple)
            data_collector.collect_bw_data(raw_bw)

        # testing!
        # if counter == 5:
        #     # data_collector.bw_m.get_stored_data()
        #     data_collector.save_bw_to_matlab("test")

        counter += 1
            
        # d.print_delay()
        
        # lat.pub = rospy.Publisher('/clock_topic', String, queue_size=1)
        # pub = rospy.Publisher('/clock_topic', String, queue_size=1)
        # pub.publish(str("Real Time: " + str(rospy.Time.now().nsecs)))       

        rate.sleep()


if len(sys.argv) > 2:
    data_collector.save_bw_to_matlab("bw_data_" + sys.argv[2])
    data_collector.save_hz_to_matlab("hz_data_" + sys.argv[2])
else:
    data_collector.save_bw_to_matlab("bw_data")
    data_collector.save_hz_to_matlab("hz_data")   