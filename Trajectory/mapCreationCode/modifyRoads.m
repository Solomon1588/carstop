% the transformation to road coordinates (processSegment_roadTrue.m) fails
% on split-off lanes if they are made too short
% This file enlarges these lanes to avoid the problem, which might cause
% problems in other areas... but hopefully not
% 4/23/16
%%
load('roads_all.mat');
roads_to_mod = [4,5,6,75,76,77,78];
distances_to_add = [20,20,10,5,5,5,5];

for i = 1:length(roads_to_mod)
    ss = roads(roads_to_mod(i)).segments;
    ss(1:2) = ss(1:2) - distances_to_add(i)*[cos(ss(5)), sin(ss(5))];
    ss(4) = ss(4) + distances_to_add(i);
    roads(roads_to_mod(i)).segments = ss;
end

for i = 1:length(roads)
    roads(i).segments(:,1) = roads(i).segments(:,1) - .5;
end

save('roads_all.mat','roads','adjacencies','transitions');