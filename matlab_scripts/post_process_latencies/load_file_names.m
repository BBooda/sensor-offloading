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