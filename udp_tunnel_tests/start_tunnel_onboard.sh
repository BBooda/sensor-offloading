#!/bin/bash

# take as a command line argument the suffix of the matlab files

SESSION=tunnel

TEMP_DIR=$(pwd)

TARGET_IP="127.0.0.1"
SERVING_IP="127.0.0.1"

tmux -2 new-session -d -s $SESSION

# tmux setenv ROS_IP 127.0.0.1

tmux split-window -h
tmux select-pane -t 0
tmux split-window -v
tmux select-pane -t 2
tmux split-window -v
# tmux select-pane -t 0
# tmux split-window -v
# tmux select-pane -t 0


# NOTES:
# For the client script, First argument: topic_to_subscribe, 
#                        Second argument: node name
#                        Third argument: IP to connect to
#                        Forth argument: Port
tmux send-keys -t 0 "sleep 2; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_sub_client.py /pixy/vicon/demo_crazyflie9/demo_crazyflie9/odom odometry $TARGET_IP 30001" C-m

# NOTES:
# For the server script, First argument: topic_to_publish, 
#                        Second argument: publishing rate
#                        thrird argument: node name
#                        Forth argument: Serving IP
#                        Fifth argument: Port

# tmux send-keys -t 1 "sleep 1; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_server_py.py /cmd_velocities 40 cmd_vel $SERVING_IP 30002" C-m

# capture and send the latencies
# tmux send-keys -t 0 "sleep 2; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_sub_client.py /latencies late $TARGET_IP 30003" C-m

# tmux send-keys -t 1 "sleep 1; cd $TEMP_DIR; python3 udp_server_py.py" C-m


tmux -2 attach-session -t $SESSION
