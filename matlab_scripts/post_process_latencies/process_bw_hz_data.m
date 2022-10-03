%% load measurements from spot and edge corresponding to the same experiment and visualize results
path = ""
if path == ""
    path = pwd;
else
    cd(path);
end

% navigate to folders to capture measurements
% navigate to spot
cd("spot")
spot_bw_file_name = load_file_names("bw", "mat");
load(strcat(spot_bw_file_name{1}, 'at'));
[spot_bw_num, spot_size] = get_bw_m(bw_list);

edge_hz_file_name = load_file_names("hz", "mat");
load(strcat(edge_hz_file_name{1}, 'at'));
spot_hz_array = get_frq_m(hz_list);

spot_hz_file_name = load_file_names("hz", "mat");
load(strcat(spot_hz_file_name{1}, 'at'));

spot_inter_file_name = load_file_names("inter", "mat");
tx_inter = load(strcat(spot_inter_file_name{1}, 'at'));

cd(path)
% navigate to edge folder to get measurements
cd("edge")
edge_bw_file_name = load_file_names("bw", "mat");
load(strcat(edge_bw_file_name{1}, 'at'));
[edge_bw_num, edge_size] = get_bw_m(bw_list);

edge_hz_file_name = load_file_names("hz", "mat");
load(strcat(edge_hz_file_name{1}, 'at'));
edge_hz_array = get_frq_m(hz_list);

spot_inter_file_name = load_file_names("inte", "mat");
rx_inter = load(strcat(spot_inter_file_name{1}, 'at'));

% navigate back to parent folder
cd(path);

% adjust decades
for_mb = 10^6;


% visualize results
% plot bw measurements
figure();
plot(1:1:length(spot_bw_num), spot_bw_num, 'b', 1:1:length(edge_bw_num), edge_bw_num, 'r');
legend('spot', 'edge')
% plot hz measurements
figure();
plot(1:1:length(spot_hz_array), spot_hz_array, 'b', 1:1:length(edge_hz_array), edge_hz_array, 'r');
legend('spot', 'edge')
% plot inter measurements
figure();
plot(1:1:length(tx_inter.data_rate), tx_inter.data_rate/for_mb, 'b', 1:1:length(rx_inter.data_rate), rx_inter.data_rate/for_mb, 'r');
legend('spot', 'edge')
%% some functions

%function testing
[bw_num, size] = split_string_to_num(bw)

function hz_array = get_frq_m(hz_list)
    hz_array = zeros(1, length(hz_list));
    for i = 1:length(hz_list)
        temp = hz_list{i};
        hz_array(i) = temp.rate;
    end
end

function [bw_num, size] = get_bw_m(bw_list)
    bw_length = length(bw_list);
    bw = cell(1, bw_length);
    mean_bw = cell(1, bw_length);
    min_s = cell(1, bw_length);
    max_s = cell(1, bw_length);
    n = cell(1, bw_length);
    
    for i = 1:bw_length
        element = bw_list{i};
        
        % character array
        bw{i} = element.bw;
        mean_bw{i} = element.mean;
        min_s{i} = element.min_s;
        max_s{i} = element.max_s;
        n{i} = element.n;
    
    end
    
    [bw_num, size] = split_string_to_num(bw);
end

function [num_array, size] = split_string_to_num(cell_array)
    num_array = [];
    size = [];
    for i = 1:length(cell_array)
        if contains(cell_array{i}, 'K')
            numerical = split(cell_array{i}, 'K');
            num_array = [num_array; str2double(numerical{1})];
            size = [size; 'K'];
        elseif contains(cell_array{i}, 'M')
            numerical = split(cell_array{i}, 'M');
            num_array = [num_array; str2double(numerical{1})];
            size = [size; 'M'];
        else
            numerical = split(cell_array{i}, 'B');
            num_array = [num_array; str2double(numerical)];
            size = [size; 'B'];
        end
    end
end

function file_names = load_file_names(name_patern,file_patern)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
S = dir(fullfile(strcat(name_patern,'*.', file_patern))); % look at dir for imgs with this name patern
    file_names = cell(1, numel(S));
    for i = 1:numel(S)
        file_name = fullfile(S(i).name);
        file_names{i} = file_name(1:(numel(file_name) - (length(file_patern) + 1)));%drop .jpg extension
    end
end