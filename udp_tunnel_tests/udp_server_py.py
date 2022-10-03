import socket, pickle

from nav_msgs.msg import Odometry
import rospy, threading
from sensor_msgs.msg import Image
from sensor_msgs.msg import CompressedImage

# socket class
class SocketServer(threading.Thread):
    def __init__(self, uri, port_num, ros_node) -> None:
        # print("in constructor")
        threading.Thread.__init__(self)
        self.uri = uri
        self.port_num = port_num
        self.addr_info = socket.getaddrinfo(uri, port_num, proto=socket.IPPROTO_UDP)
        # sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket = socket.socket(self.addr_info[0][0], self.addr_info[0][1], self.addr_info[0][2])
        self.ros_node = ros_node
        # self.bind_socket()
    
    def bind_socket(self):
        # sock.bind((UDP_IP, UDP_PORT))
        self.socket.bind((self.uri, self.port_num))

        try:
            while True:
                # print("in while true")
                # data size is equal to 4096, check if this is the maximum
                data, addr = self.socket.recvfrom(4096) # buffer 4096 bytes
                data_variable = pickle.loads(data)
                self.ros_node.create_odometry_msg(data_variable)
                # print(data_variable)
        except KeyboardInterrupt:
            print('interrupted!')
        # receive data
    def run(self):
        self.bind_socket()





class Pub_Node():

    def __init__(self) -> None:
        # set node's rate.
        self._rate = 10
        # self.message = Odometry()
        self.message = Odometry()
        self.checksum = 1
    
    def run_node(self):
        # initiate node
        self.udp_server_node = rospy.init_node('udp_server_node', anonymous=True)
        n_rate = rospy.Rate(self._rate)


        pub = rospy.Publisher('udp_odometry', Odometry, queue_size=1)

        while not rospy.is_shutdown():
            # print(self.message)
            # print(self.checksum)

            
            pub.publish(self.message)
            n_rate.sleep()

    def create_odometry_msg(self, data):
        self.message = data
        self.checksum = self.checksum + 1
        rospy.loginfo(self.checksum)

        


if __name__ == '__main__':
    # create ROS node
    try:
        pub_node = Pub_Node()
        socket = SocketServer("edge", 50007, pub_node)
        pub_node.run_node()
        socket.start()

    except rospy.ROSInterruptException:
        print("rospy interrupted")

    


    


