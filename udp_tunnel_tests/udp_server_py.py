import socket, pickle

from numpy import empty

from nav_msgs.msg import Odometry
import rospy, threading
from sensor_msgs.msg import Image
from sensor_msgs.msg import CompressedImage

# socket class
class SocketServer(threading.Thread):
    def __init__(self, uri, port_num, ros_node) -> None:

        threading.Thread.__init__(self)
        self.uri = uri
        self.port_num = port_num
        self.addr_info = socket.getaddrinfo(uri, port_num, proto=socket.IPPROTO_UDP)
        # sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket = socket.socket(self.addr_info[0][0], self.addr_info[0][1], self.addr_info[0][2])
        self.ros_node = ros_node
        self.should_run = True
        self.socket.settimeout(5)        
        
    
    def bind_socket(self):

        self.socket.bind((self.uri, self.port_num))

        try:
            while self.should_run and not rospy.is_shutdown():
                # data size is equal to 4096, !!!check if this is the maximum
                data, addr = self.socket.recvfrom(4096) # buffer 4096 bytes
                data_variable = pickle.loads(data)
                self.ros_node.create_odometry_msg(data_variable)

        except KeyboardInterrupt:
            print('interrupted!')
    
    # receive data
    def run(self):
        rospy.loginfo("Run socket thread...")
        rospy.loginfo(self.addr_info)
        self.bind_socket()





class Pub_Node():

    def __init__(self) -> None:
        # threading.Thread.__init__(self)
        # set node's rate.
        self._rate = 100
        # initialize odometry message
        self.message = Odometry()
        self.checksum = 1
        self.udp_server_node = rospy.init_node('udp_server_node', anonymous=True)
    
    def run_node(self):

        # initiate node
        n_rate = rospy.Rate(self._rate)
        self.pub = rospy.Publisher('udp_odometry', Odometry, queue_size=1)

        while True and not rospy.is_shutdown():

            self.pub.publish(self.message)
            n_rate.sleep()

    def create_odometry_msg(self, data):
        self.message = data
        # debug
        self.checksum = self.checksum + 1
        # rospy.loginfo(data)

    def run(self):
        self.run_node()

        


if __name__ == '__main__':
    # create ROS node
    try:
        pub_node = Pub_Node()
        my_socket = SocketServer("127.0.0.1", 50007, pub_node)
        my_socket.start()
        pub_node.run_node()

        # kill socket thread
        my_socket.should_run = False
        my_socket.join()
        print("Socket thread is shutdown")        
        
    except rospy.ROSInterruptException:
        print("rospy interrupted")

    


    


