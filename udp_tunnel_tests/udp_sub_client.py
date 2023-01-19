#!/usr/bin/env python
from socket import socket
import sys
from typing import Dict
import rospy
import socket 
from nav_msgs.msg import Odometry
from sensor_msgs.msg import Image
from sensor_msgs.msg import CompressedImage
from geometry_msgs.msg import TwistStamped

# parse command line arguments 
# print(type(sys.argv))
# print(sys.argv)

# # get ros name from command line arguments
# rospy.init_node(sys.argv[2])

class SendData(socket.socket):
    def __init__(self, port_number, ip) -> None:
        addr_info = socket.getaddrinfo(str(ip), int(port_number), proto=socket.IPPROTO_UDP)

        print(addr_info)

        super().__init__(addr_info[0][0], addr_info[0][1], addr_info[0][2])

        rospy.loginfo("Socket created uri: {sock_uri}, port num: {port_num}".format(sock_uri = str(ip), port_num = int(port_number)))

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

        capturer_node = rospy.init_node('udp_client_' + sys.argv[2], anonymous=True)
        
        # create socket
        sock = SendData(int(sys.argv[4]), sys.argv[3])
        sock.set_port_and_ip(int(sys.argv[4]), sys.argv[3])

        # create subscriber
        # subscriber = rospy.Subscriber('/pixy/vicon/demo_crazyflie6/demo_crazyflie6/odom', Odometry, stack_data)
        
        if len(sys.argv) >= 2:
            rospy.loginfo("Topic to subscribe to: " + str(sys.argv[1]))
            # rospy.loginfo(sys.argv[1])
            rospy.Subscriber(sys.argv[1], TwistStamped, stack_data, callback_args=sock)
            
        else:
            rospy.Subscriber('/pixy/vicon/demo_crazyflie6/demo_crazyflie6/odom', Odometry, stack_data, callback_args=sock)

        # rospy.Subscriber('/camera/color/image_raw/compressed', CompressedImage, stack_data, callback_args=sock)


        rospy.spin()
    except rospy.ROSInterruptException:
        pass


