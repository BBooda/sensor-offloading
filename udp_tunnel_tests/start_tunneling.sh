#!/bin/bash

# take as a command line argument the suffix of the matlab files

SESSION=tunnel

TEMP_DIR=$(pwd)

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

# the first argument of the script indicates the topic name to subscribe, second argument the publishing rate of that topic, and the third the node name of the script
tmux send-keys -t 1 "sleep 1; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_server_py.py /udp_odom 100 odometry" C-m
tmux send-keys -t 0 "sleep 2; export ROS_IP=127.0.0.1; cd $TEMP_DIR; python3 udp_sub_client.py /pixy/vicon/demo_crazyflie9/demo_crazyflie9/odom odometry" C-m
# tmux send-keys -t 1 "sleep 1; cd $TEMP_DIR; python3 udp_server_py.py" C-m

# dsl, octomap, velodyne, fronters, path_
# tmux send-keys -t 0 "sleep 1; cd $TEMP_DIR; python3 ../../monitor_nw_interface.py interface_statistics_$1" C-m
# tmux send-keys -t 1 "sleep 5; cd $TEMP_DIR; python3 ../log_statistics_v1.py /spot/velodyne_points velo_points_node velo_points_$1" C-m
# tmux send-keys -t 2 "sleep 5; cd $TEMP_DIR; python3 ../log_statistics_v1.py /spot/velodyne_packets velo_packets_node velo_packets_$1" C-m
# tmux send-keys -t 2 "sleep 5; cd $TEMP_DIR; python3 ../log_statistics_v1.py /camera/color/image_raw image_raw_node image_raw_$1" C-m
# tmux send-keys -t 3 "sleep 5; cd $TEMP_DIR; python3 ../log_statistics_v1.py /camera/color/image_raw/compressed image_raw_comp_node image_raw_comp_$1" C-m
#tmux send-keys -t 4 "sleep 20; cd ~/catkin_ws/spot_ws/; source devel/setup.bash; roslaunch vectornav vectornav.launch" C-m

tmux -2 attach-session -t $SESSION
