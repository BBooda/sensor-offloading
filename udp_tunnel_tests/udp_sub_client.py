#!/usr/bin/env python
from socket import socket
import sys
from typing import Dict
import rospy
import socket 
from turtle import pu
from nav_msgs.msg import Odometry
from sensor_msgs.msg import Image
from sensor_msgs.msg import CompressedImage

# parse command line arguments 
# print(type(sys.argv))
# print(sys.argv)

# # get ros name from command line arguments
# rospy.init_node(sys.argv[2])

class SendData(socket.socket):
    def __init__(self) -> None:
        addr_info = socket.getaddrinfo("edge", 50007, proto=socket.IPPROTO_UDP)

        super().__init__(addr_info[0][0], addr_info[0][1], addr_info[0][2])

        rospy.loginfo("Socket created uri: {sock_uri}, port num: {port_num}".format(sock_uri = "edge", port_num = 50007))

    def set_port_and_ip(self, UDP_PORT, UDP_IP):
        self.udp_port = UDP_PORT
        self.ip = UDP_IP
    
    def send_data(self, message):
        self.sendto(message, (self.ip, self.udp_port))
        # self.send(message, (self.ip, self.udp_port))


def stack_data(data, socket):
    # print("test")
    # stack data
    # ...
    import pickle
    # # HEADERSIZE = 10

    # print(data.header.stamp.secs)

    # message = pickle.dumps(data)
    message = pickle.dumps(data)
    # # message = bytes(f"{len(message):<{HEADERSIZE}}", 'utf-8')+message
    # # print(message)
    # # send data
    socket.send_data(message)
    # socket.send_data(message)

if __name__ == '__main__':
    try:
        capturer_node = rospy.init_node('udp_send', anonymous=True)
        
        # create socket
        sock = SendData()
        sock.set_port_and_ip(50007, "edge")

        # create subscriber
        # subscriber = rospy.Subscriber('/pixy/vicon/demo_crazyflie6/demo_crazyflie6/odom', Odometry, stack_data)
        rospy.Subscriber('/pixy/vicon/demo_crazyflie6/demo_crazyflie6/odom', Odometry, stack_data, callback_args=sock)
        # rospy.Subscriber('/camera/color/image_raw/compressed', CompressedImage, stack_data, callback_args=sock)


        rospy.spin()
    except rospy.ROSInterruptException:
        pass


