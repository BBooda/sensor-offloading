#!/bin/bash

# take as a command line argument the suffix of the matlab files

SESSION=tunnel

TEMP_DIR=$(pwd)

TARGET_IP="130.240.22.40"
SERVING_IP="192.168.0.43"

tmux -2 new-session -d -s $SESSION

# tmux setenv ROS_IP 127.0.0.1

tmux split-window -h
tmux select-pane -t 0
tmux split-window -v
tmux select-pane -t 1
tmux split-window -v
# tmux select-pane -t 0
# tmux split-window -v
# tmux select-pane -t 0


# NOTES:
# For the client script, First argument: topic_to_subscribe, 
#                        Second argument: node name
#                        Third argument: IP to connect to
#                        Forth argument: Port
tmux send-keys -t 1 "sleep 2; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_sub_client.py /pixy/vicon/demo_crazyflie12/demo_crazyflie12/odom odometry $TARGET_IP 31404" C-m

# NOTES:
# For the server script, First argument: topic_to_publish, 
#                        Second argument: publishing rate
#                        thrird argument: node name
#                        Forth argument: Serving IP
#                        Fifth argument: Port

tmux send-keys -t 2 "sleep 1; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_server_twist_py.py /demo_crazyflie12/cmd_vel 30 cmd_vel $SERVING_IP 31349" C-m

# capture and send the latencies
tmux send-keys -t 3 "sleep 2; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_sub_client_twist.py /demo_crazyflie12/cmd_vel_twist_stamped late $TARGET_IP 31182" C-m

# tmux send-keys -t 1 "sleep 1; cd $TEMP_DIR; python3 udp_server_py.py" C-m


tmux -2 attach-session -t $SESSION
