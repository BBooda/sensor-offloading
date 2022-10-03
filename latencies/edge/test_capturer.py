#!/usr/bin/env python

# Note: check if OS Time are sunchronized
from turtle import pu
import rospy
from nav_msgs.msg import Odometry
from std_msgs.msg import Header
from my_pkg.msg import Latencies

class Capturer():
    def __init__(self) -> None:
        # initialize diagnostic variables
        rospy.loginfo("test")
        self.previous_seq_number = 0

        self.publisher = rospy.Publisher('latencies', Latencies, queue_size=10000)
        
        self.subscriber = rospy.Subscriber('/pixy/vicon/demo_crazyflie6/demo_crazyflie6/odom', Odometry, self.publish_to_latencies)

        
        
    def publish_to_latencies(self, data):
        test_msg = Latencies()
        rospy.loginfo("test")

        if self.previous_seq_number == 0:
            self.previous_seq_number = data.header.seq
        else:
            # check for dropped package
            if (self.previous_seq_number + 1) != data.header.seq:
                rospy.logwarn("Dropped package!, seq_number = " + str(self.previous_seq_number + 1))
                self.previous_seq_number = data.header.seq
            else:
                # compute time difference
                sec_dif = rospy.Time.now().secs - data.header.stamp.secs
                nsec_dif = rospy.Time.now().nsecs - data.header.stamp.nsecs

                test_msg.seq_n_of_pckt = data.header.seq
                test_msg.secs_dif = sec_dif
                test_msg.nsecs_dif = nsec_dif
                # rospy.loginfo(nsec_dif)

                self.previous_seq_number = data.header.seq


        self.publisher.publish(test_msg)  

if __name__ == '__main__':
    try:
        capturer_node = rospy.init_node('latency_diagnostics', anonymous=True)
        capturer = Capturer()

        rospy.spin()
    except rospy.ROSInterruptException:
        pass


