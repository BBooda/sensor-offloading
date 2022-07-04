#!/bin/bash
SESSION=sensorts

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
# tmux send-keys -t 0 "sleep 5; cd ~/catkin_ws/rosserial; source devel/setup.bash; rosrun rosserial_python serial_node.py /dev/landingPlat" C-m
# tmux send-keys -t 1 "sleep 15; roslaunch realsense2_camera rs_camera_plus_points.launch" C-m
tmux send-keys -t 2 "sleep 5; roslaunch realsense2_camera rs_camera_plus_points.launch" C-m
#tmux send-keys -t 2 "sleep 10; source ~/spot_env/bin/activate; cd ~/ros_workspaces/driver_spot_ws/; source devel/setup.bash; roslaunch spot_driver driver.launch" C-m
# tmux send-keys -t 3 "sleep 5; cd ~/catkin_ws/spot_ws/; source devel/setup.bash; roslaunch velodyne_pointcloud VLP16_points.launch" C-m
# tmux send-keys -t 4 "sleep 10; cd ~/catkin_ws/spot_ws/; source devel/setup.bash; roslaunch vectornav vectornav.launch" C-m

tmux -2 attach-session -t $SESSION