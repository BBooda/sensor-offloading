#!/bin/bash

# take as a command line argument the suffix of the matlab files

SESSION=tunnel_edge

TEMP_DIR=$(pwd)

SERVINING_IP="127.0.0.1"
TARGET_IP="127.0.0.1"

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
# For the server script, First argument: topic_to_publish, 
#                        Second argument: publishing rate
#                        thrird argument: node name
#                        Forth argument: Serving IP
#                        Fifth argument: Port
tmux send-keys -t 1 "sleep 1; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_server_py.py /udp_odom 100 odometry $SERVINING_IP 30001" C-m

# NOTES:
# For the client script, First argument: topic_to_subscribe, 
#                        Second argument: node name
#                        Third argument: IP to connect to
#                        Forth argument: Port

# tmux send-keys -t 0 "sleep 2; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_sub_client.py /cmd_velocities velocities $TARGET_IP 30002" C-m

# for reading the latencies
# tmux send-keys -t 1 "sleep 1; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_server_py.py /latencies 40 latencies $SERVINING_IP 30003" C-m




tmux -2 attach-session -t $SESSION
