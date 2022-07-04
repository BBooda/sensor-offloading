#!/bin/bash

SESSION=statistics

TEMP_DIR=/home/spotnuc/temp
SPOT_NODE="spot_node"

export ROS_IPV6=on
export ROS_MASTER_URI=http://master:11311

tmux -2 new-session -d -s $SESSION

tmux split-window -h
tmux select-pane -t 0
tmux split-window -h
tmux select-pane -t 0
tmux split-window -h
tmux select-pane -t 0
tmux split-window -v
tmux select-pane -t 0


# dsl, octomap, velodyne, fronters, path_
tmux send-keys -t 0 "sleep 1; cd $TEMP_DIR; python3 ../../monitor_nw_interface.py interface_statistics_$1 tx" C-m
tmux send-keys -t 1 "sleep 5; cd $TEMP_DIR; python3 ../log_statistics_v1.py /spot/velodyne_points velo_points_$SPOT_NODE velo_points_$1" C-m
# tmux send-keys -t 2 "sleep 5; cd $TEMP_DIR; python3 ../log_statistics_v1.py /spot/velodyne_packets velo_packets_$SPOT_NODE velo_packets_$1" C-m
#tmux send-keys -t 2 "sleep 10; source ~/spot_env/bin/activate; cd ~/ros_workspaces/driver_spot_ws/; source devel/setup.bash; roslaunch spot_driver driver.launch" C-m
#tmux send-keys -t 3 "sleep 16; cd ~/catkin_ws/spot_ws/; source devel/setup.bash; roslaunch velodyne_pointcloud VLP16_points.launch" C-m
#tmux send-keys -t 4 "sleep 20; cd ~/catkin_ws/spot_ws/; source devel/setup.bash; roslaunch vectornav vectornav.launch" C-m

tmux -2 attach-session -t $SESSION