% post process latency measurements from python capturer script, make some graphs
%% go to working directory
cd('C:\Users\eamrgde\Documents\experiments\crazyflie_trajectories\rectangle\latencies')

%% read ros bag
% clear;
% clearvars -except sa5g_ul sa5g_down kista_ul kista_down wifi_ul wifi_down lte_ul lte_down
bagselest = rosbag('v1_edge_hus_5G_Kista.bag');
% latencies_select = select(bagselest,'Topic','/latencies');

latencies_select = select(bagselest,'Topic','/cmd_vel_latencies');

% bs_ref_circular_h20_r20 = select(bagselest_h20_r20,'Topic','/hummingbird/ref');

late_msg_struct = readMessages(latencies_select,'DataFormat','struct');
% msgStructs_ref_circular_h20_r20 = readMessages(bs_ref_circular_h20_r20,'DataFormat','struct');

% parse data, pass latency measurments to two arrays, one for nsecs difference and one for sec diff

nsecs_dif = zeros(1, length(late_msg_struct));
secs_dif = zeros(1, length(late_msg_struct));
virtual_time = zeros(1, length(late_msg_struct));
dropped_msg_index = [];

previous_package_num = late_msg_struct{1}.SeqNOfPckt;
dropped_pckg_count = 0;

for i = 1:numel(late_msg_struct)
    nsecs_dif(i) = late_msg_struct{i}.NsecsDif;
    secs_dif(i) = late_msg_struct{i}.SecsDif;
    virtual_time(i) = i;

    % watch for dropped packages
    if i > 1
        if ((previous_package_num + 1) ~= late_msg_struct{i}.SeqNOfPckt)
            dropped_pckg_count = dropped_pckg_count + 1;
            dropped_msg_index = [dropped_msg_index, i];
        end
        previous_package_num = late_msg_struct{i}.SeqNOfPckt;
    end
end

% plot latencies
% find negative ones produced by the change of the second variable
index = nsecs_dif(:) < 0;

% go to secs scale
secs_latency = nsecs_dif * (10 ^ - 9);

% add 1 sec to compansate for the difference
secs_latency(index) = secs_latency(index) + 1;

% go to msec scale 

msec_latency = secs_latency * (10 ^ 3);
figure();
plot(virtual_time, msec_latency);
xlabel("Samples", 'FontWeight','bold')
ylabel("Latency in msecs", 'FontWeight','bold')
title(strcat("mean: ", num2str(mean(msec_latency)), ...
    ", std: ", num2str(std(msec_latency)), ...
    ", max: ", num2str(max(msec_latency)), ...
    ", min: ", num2str(min(msec_latency))))
msec_latency = msec_latency(:);

% view axis until where the signal stops
xlim([1, length(virtual_time)])

%temp 
% sa5g_ul = [sa5g_ul; msec_latency];
% sa5g_down = [sa5g_down; msec_latency];
% kista_ul = [kista_ul; msec_latency];
% kista_down = [kista_down; msec_latency];
% wifi_ul = [wifi_ul; msec_latency];
% wifi_down = [wifi_down; msec_latency];
% lte_ul = [lte_ul; msec_latency];
% lte_down = [lte_down; msec_latency];
% plot latencies from different diagrams
if exist('latency_concat','var') == 0
    latency_concat = [];
end
%concatanate multiple experiments
% latency_concat = cat(2, latency_concat, msec_latency);
latency_concat = [latency_concat; msec_latency(:)];

%% calculate and plot CCDF
msec_latency = wifi_round_trip;
[ycdf,xcdf] = cdfcalc(msec_latency);
xccdf = xcdf;
yccdf = 1-ycdf(1:end-1);
hold on;
loglog(xcdf,yccdf, 'LineWidth',1.5);

%% plot all ccdfs together

all_latencies = {sa5g_down; kista_down; lte_down};

figure();


for i = 1:numel(all_latencies)
    [ycdf,xcdf] = cdfcalc(all_latencies{i});
    xccdf = xcdf;
    yccdf = 1-ycdf(1:end-1);
    if i ~= 1
        hold on;
    end
    loglog(xcdf,yccdf, 'LineWidth',1.5);
    disp(i)
    if i == 3
        legend('Local 5G & Edge', '5G with remote core & Cloud', 'Public LTE & Cloud')
    end
end
grid on;
xlabel("Latency", 'FontWeight','bold')
ylabel("CCDF", 'FontWeight','bold')

%% plot latency graph unprocessed 
figure();
subplot(2, 1, 1);
% plot(virtual_time, log(abs(nsecs_dif)))
plot(virtual_time, (nsecs_dif * 10 ^ (-9)))

subplot(2, 1, 2);
plot(virtual_time, ((secs_dif)))


%% plot jitter 
counter = 1;
jitter = zeros(1, length(msec_latency));
for i = 2:numel(msec_latency)
    jitter(counter) = abs(msec_latency(i) - msec_latency(i - 1));
    counter = counter + 1;
end
figure();
plot(1:1:numel(jitter),jitter)
title(strcat("Average Jitter: ", num2str(sum(jitter(:)/numel(jitter)))))

%% sample distributions



%% process latencies, create round trip curve, calculate jitter, and average value for jitter


% lte_round_trip = calculate_round_trip(lte_ul, lte_down);
% lte_jitter = calculate_jitter(lte_round_trip);
% 
% sa5g_round_trip = calculate_round_trip(sa5g_ul, sa5g_down);
% sa5g_jitter = calculate_jitter(sa5g_round_trip);

wifi_round_trip = calculate_round_trip(wifi_ul, wifi_down);
wifi_jitter = calculate_jitter(wifi_round_trip);

% validation_wifi_round_trip = calculate_round_trip(valid_wifi_ul, valid_wifi_down);
% validation_wifi_jitter = calculate_jitter(wifi_round_trip);

% kista_round_trip = calculate_round_trip(kista_ul, kista_down);
% kista_jitter = calculate_jitter(kista_round_trip);

% %% create boxplot of jitter
% box_values = [sa5g_jitter, wifi_jitter, kista_jitter, lte_jitter];
% labels = [create_labels('5GSA & MEC   ', numel(sa5g_jitter));
%     create_labels('Wifi & Cloud ', numel(wifi_jitter));
%     create_labels('Kista & Cloud', numel(kista_jitter));
%     create_labels('LTE & Cloud  ', numel(lte_jitter));
% ];
% box_values([sa5g_jitter, wifi_jitter, kista_jitter, lte_jitter], labels)

function [round_trip, time] = calculate_round_trip(ul, down)
    
    if length(ul) > length(down)
        ratio = length(ul)/length(down);
        ul = ul(1:ratio:end);
    else
        ratio = length(down)/length(ul);
        down = down(1:ratio:end);
    end
    
    % create round trip latency 
    if length(ul) == length(down)
        round_trip = down + ul;
        figure();
        plot(1:1:length(round_trip), round_trip)
        title(strcat("Round Trip, Mean: ", num2str(mean(round_trip(:)))));        
        ylabel("RTT (msec)", "FontWeight","bold");
        xlabel("duration", "FontWeight","bold");
    end
    
    time = 1:1:length(round_trip);
end

function [jitter, time] = calculate_jitter(round_trip)
    counter = 1;
    jitter = zeros(1, length(round_trip));
    for i = 2:numel(round_trip)
        jitter(counter) = abs(round_trip(i) - round_trip(i - 1));
        counter = counter + 1;
    end
    figure();
    plot(1:1:numel(jitter),jitter)
    title(strcat("Average Jitter: ", num2str(sum(jitter(:)/numel(jitter)))));
    time = 1:1:numel(jitter);
end

function labels = create_labels(label, num_ele)
    labels = [];
    for i = 1:num_ele
        labels = [labels; label];
    end
end
