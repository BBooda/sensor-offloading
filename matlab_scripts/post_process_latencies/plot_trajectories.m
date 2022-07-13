%% go to working directory 
cd('C:\Users\eamrgde\Documents\experiments\crazyflie_trajectories\rectangle\5G\edge_rect_5G\rectangle')

%% get ros data
clear;
bagselest_h20_r20 = rosbag('v6_comp_wifi_val_2022-06-20-21-19-28.bag');
bs_position_circular_h20_r20 = select(bagselest_h20_r20,'Topic','/pixy/vicon/demo_crazyflie6/demo_crazyflie6/odom');
bs_ref_circular_h20_r20 = select(bagselest_h20_r20,'Topic','/hummingbird/ref');

msgStructs_position_circular_h20_r20 = readMessages(bs_position_circular_h20_r20,'DataFormat','struct');
msgStructs_ref_circular_h20_r20 = readMessages(bs_ref_circular_h20_r20,'DataFormat','struct');
% read data MPC same frequency with vicon

for i = 1:numel(msgStructs_position_circular_h20_r20)
    x_real1(i) = msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.X;
    y_real1(i) = msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.Y;
    z_real1(i) = msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.Z;
    timing1(i) = msgStructs_position_circular_h20_r20{i}.Header.Stamp.Sec ...
        + msgStructs_position_circular_h20_r20{i}.Header.Stamp.Nsec  * 10 ^ (-9);
end

for i = 1:numel(msgStructs_ref_circular_h20_r20)
    x_ref1(i) = msgStructs_ref_circular_h20_r20{i}.Pose.Position.X;
    y_ref1(i) = msgStructs_ref_circular_h20_r20{i}.Pose.Position.Y;
    z_ref1(i) = msgStructs_ref_circular_h20_r20{i}.Pose.Position.Z;
    timingref1(i) = msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Sec ...
        + msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Nsec  * 10 ^ (-9);
end


% 3d plot
figure
plot3(x_real1,y_real1,z_real1, 'b',x_ref1,y_ref1,z_ref1)
xlabel('Displacement X (m)')
ylabel('Displacement Y (m)')
zlabel('Displacement Z (m)')
title('5G SA & MEC')
view([0,10, 10])
%% 2d plots
figure
subplot(3, 1, 1);
plot(timing1,x_real1, 'b', timingref1,x_ref1)
% xlabel('Duration of the trajectory (s)')
% ylabel('Displacement X (m)', 'Rotation', 0, 'FontSize', 20, 'Position', [0.1, 2.4], 'FontName', 'Times')
% title('(a) Response of the X axis')
% ylim([-2,2])    
% xlim([0,40]) 
hold on
subplot(3, 1, 2);
plot(timing1,y_real1, 'b',timingref1,y_ref1)
% xlabel('Duration of the trajectory (s)')
% ylabel('Displacement Y (m)', 'Rotation', 0, 'FontSize', 20, 'Position', [0.1, 6.4], 'FontName', 'Times')
% title('(b) Response of the Y axis')
% ylim([2,6])    
% xlim([0,40]) 
hold on
subplot(3, 1, 3);
% plot(timing1,z_real1,timing2,timingref1,z_ref1)
plot(timing1,z_real1, 'b', timingref1,z_ref1)
% xlabel('Duration of the trajectory (s)')
% ylabel('Displacement Z (m)', 'Rotation', 0, 'FontSize', 20, 'Position', [0.1, 2.2], 'FontName', 'Times')
% title('(c) Response of the Z axis')
% ylim([0,2])    
% xlim([0,40]) 
hold on


%% plot error over time
if length(x_ref1) > length(x_real1)
    time = timing1;
    error_x = abs(x_real1 - x_ref1(1:length(x_real1)));
    error_y = abs(y_real1 - y_ref1(1:length(y_real1)));
    error_z = abs(z_real1 - z_ref1(1:length(z_real1)));
else
    time = timingref1;
    error_x = abs(x_ref1 - x_real1(1:length(x_ref1)));
    error_y = abs(y_ref1 - y_real1(1:length(y_ref1)));
    error_z = abs(z_ref1 - z_real1(1:length(z_ref1)));
end


% tolerance in every axis
x_tol = 0.2 * ones(1, length(time));
y_tol = 0.2 * ones(1, length(time));
z_tol = 0.4 * ones(1, length(time));

figure();
subplot(3, 1, 1)
plot(time, error_x, 'b', time, x_tol);
title("x error in time");
subtitle(strcat("mean_x: ", num2str(mean(error_x))))

subplot(3, 1, 2)
plot(time, error_y, 'b', time, y_tol);
title("y error in time");
subtitle(strcat("mean_y: ", num2str(mean(error_y))))

subplot(3, 1, 3)
plot(time, error_z, 'b', time, z_tol);
title("z error in time");
subtitle(strcat("mean_z: ", num2str(mean(error_z))))

%% compare runs, 
x_old = x_real1;
y_old = y_real1;
z_old = z_real1;


%% calculate mean square error
mse_x = immse(x_real1, x_ref1(1:length(x_real1)));
mse_y = immse(y_real1, y_ref1(1:length(y_real1)));
mse_z = immse(z_real1, z_ref1(1:length(z_real1)));

avg_mse = (mse_x + mse_y + mse_z)/3;

real_traj = [x_real1; y_real1; z_real1];
ref_traj = [x_ref1(1:length(x_real1)); y_ref1(1:length(y_real1)); z_ref1(1:length(z_real1))];
rmse_of_traj = sqrt(mse(real_traj, ref_traj));

key_set = {'mse_x', 'mse_y', 'mse_z', 'avg_mse', 'rmse_of_traj'};
value_set = {mse_x, mse_y, mse_z, avg_mse, rmse_of_traj};
errors = containers.Map(key_set, value_set);
sprintf("mse_x: %f, mse_y: %f, mse_z: %f, \n avg_mse: %f, rmse_of_traj: %f", ...
    errors("mse_x"), errors("mse_y"), errors("mse_z"), errors("avg_mse"), errors("rmse_of_traj"))


%% plot error over time


%% compare if not same length
figure
subplot(3, 1, 1);
plot(timing1,x_real1, 'b', timingref1,x_ref1, 'g',timing1, x_old, 'r')
xlabel('Duration of the trajectory (s)')
ylabel('Displacement X (m)', 'Rotation', 0, 'FontSize', 20, 'Position', [0.1, 2.4], 'FontName', 'Times')
title('(a) Response of the X axis')
ylim([-2,2])
xlim([0,40])
hold on
subplot(3, 1, 2);
plot(timing1,y_real1, 'b',timingref1,y_ref1, 'g',timing1, y_old, 'r')
xlabel('Duration of the trajectory (s)')
ylabel('Displacement Y (m)', 'Rotation', 0, 'FontSize', 20, 'Position', [0.1, 6.4], 'FontName', 'Times')
title('(b) Response of the Y axis')
ylim([2,6])
xlim([0,40])
hold on
subplot(3, 1, 3);
% plot(timing1,z_real1,timing2,timingref1,z_ref1)
plot(timing1,z_real1, 'b', timingref1,z_ref1, 'g',timing1, z_old, 'r')
xlabel('Duration of the trajectory (s)')
ylabel('Displacement Z (m)', 'Rotation', 0, 'FontSize', 20, 'Position', [0.1, 2.2], 'FontName', 'Times')
title('(c) Response of the Z axis')
ylim([0,2])
xlim([0,40])
hold on
%% look at statistics
statistics_select = select(bagselest_h20_r20,'Topic','/statistics');
msgStruct_statistics = readMessages(statistics_select,'DataFormat','struct');

stat_size = length(msgStruct_statistics);
% find only odometry topic statistics
odo_index = zeros(1, stat_size);
odo_statistics = cell(1, stat_size);
for i = 1:stat_size
    if strcmp(msgStruct_statistics{i}.Topic, '/pixy/vicon/demo_crazyflie9/demo_crazyflie9/odom')
        odo_index(i) = i;
        odo_statistics{i} = msgStruct_statistics{i};
    end
end

% remove empty elements from cell 
odo_statistics = odo_statistics(~cellfun('isempty',odo_statistics));

% find if there is at least 1 sec delay somewhere
sec_delay_counter = 0;

% nsec array
nsec_array_of_delays = zeros(1, length(odo_statistics));
for i = 1 : length(odo_statistics)
    
    nsec_array_of_delays(i) = odo_statistics{i}.StampAgeMean.Nsec;
    
    if odo_statistics{i}.StampAgeMean.Sec ~= 0
        sec_delay_counter = sec_delay_counter + 1;
    end
end

%% read ros data, from achilleas and vicon running at different frequencies from the mpc
k = 1;
i = 1;
while msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.Z < 0.35
        i = i + 1;
end
j = i;
while i < length(msgStructs_position_circular_h20_r20)
    x_real1(k) = msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.X;
    y_real1(k) = msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.Y;
    z_real1(k) = msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.Z;
    timing1(k) = double(msgStructs_position_circular_h20_r20{i}.Header.Stamp.Sec) + ...
        double(msgStructs_position_circular_h20_r20{i}.Header.Stamp.Nsec) * 10 ^ (-9) - ...
        (double(msgStructs_position_circular_h20_r20{j}.Header.Stamp.Sec) + ...
        double(msgStructs_position_circular_h20_r20{j}.Header.Stamp.Nsec) * 10 ^ (-9));
    k = k + 1;
    i = i + 1;
    if msgStructs_position_circular_h20_r20{i}.Pose.Pose.Position.Z < 0.3
        break
    end
end

k = 1;
i = 1;
while double(msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Sec) ~= double(msgStructs_position_circular_h20_r20{j}.Header.Stamp.Sec) || ...
        double(msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Nsec)  * 10 ^ (-9) - ...
        double(msgStructs_position_circular_h20_r20{j}.Header.Stamp.Nsec)  * 10 ^ (-9)  > 0.05

        i = i + 1;
end
j = i;
while i < length(msgStructs_ref_circular_h20_r20)
    x_ref1(k) = msgStructs_ref_circular_h20_r20{i}.Pose.Position.X;
    y_ref1(k) = msgStructs_ref_circular_h20_r20{i}.Pose.Position.Y;
    z_ref1(k) = msgStructs_ref_circular_h20_r20{i}.Pose.Position.Z;
    timingref1(k) = double(msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Sec) + ...
        double(msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Nsec) * 10 ^ (-9) - ...
        (double(msgStructs_ref_circular_h20_r20{j}.Header.Stamp.Sec) + ...
        double(msgStructs_ref_circular_h20_r20{j}.Header.Stamp.Nsec) * 10 ^ (-9));
    
    times1(k) = (double(msgStructs_ref_circular_h20_r20{i+1}.Header.Stamp.Sec) + ...
        double(msgStructs_ref_circular_h20_r20{i+1}.Header.Stamp.Nsec) * 10 ^ (-9)) - ...
        (double(msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Sec) + ...
        double(msgStructs_ref_circular_h20_r20{i}.Header.Stamp.Nsec) * 10 ^ (-9));

    k = k + 1;
    i = i + 1;
end

%% achilleas Plot Error
x_ref_new(1) = 0;
counter = 0;
for k = 2:1:length(x_real1)
    if(timingref1(k - counter) >= timing1(k))
        counter = counter + 1;
    end
    x_ref1_new(k) = x_ref1(k - counter);
    y_ref1_new(k) = y_ref1(k - counter);
    z_ref1_new(k) = z_ref1(k - counter);    
    error_x21(k) = abs(x_ref1_new(k) - x_real1(k));
    error_y21(k) = abs(y_ref1_new(k) - y_real1(k));
    error_z21(k) = abs(z_ref1_new(k) - z_real1(k));
    t_real21_new(k) = timing1(k);
    tolerance(k) = 0.4;
end

figure;
plot(t_real21_new, error_x21, t_real21_new, error_y21, t_real21_new, error_z21, t_real21_new, tolerance)
xlabel('Duration of the trajectory (s)')
ylabel('Error between reference and real position values(m)', 'Rotation', 0, 'FontSize', 20, 'Position', [30, 0.51], 'FontName', 'Times')


%% calculate mean speed

speed_3d = zeros(length(x_real1));

for index = 1:(length(x_real1) - 1)
    speed_3d(index) = sqrt((x_real1(index + 1) - x_real1(index))^2 + ...
        (y_real1(index + 1) - y_real1(index))^2 + ...
        (z_real1(index + 1) - z_real1(index))^2)/0.025;
end
