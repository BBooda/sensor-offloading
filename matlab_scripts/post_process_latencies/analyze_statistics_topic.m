%% read statistics data
bag = rosbag('b4_100hz.bag');
statistics_topic = select(bag, "Topic", '/statistics');

% read information as a struct
stat_struct = readMessages(statistics_topic, 'DataFormat','struct');



%% test code 

% period mean
period_mean = zeros(1, length(stat_struct));
for i = 1:length(stat_struct)
    period_mean(i) = stat_struct{i}.PeriodMean.Nsec;
end

figure();
scatter(1:1:length(period_mean), period_mean);


% message age
stamp_age_mean = zeros(1, length(stat_struct));
for i = 1:length(stat_struct)
    stamp_age_mean(i) = stat_struct{i}.StampAgeMean.Nsec;
end

figure();
scatter(1:1:length(stamp_age_mean), stamp_age_mean);

