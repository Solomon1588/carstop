function [points,gradients,spaces] = interpolate(road, spaces)
    % input 1: a road matrix, like roads(1).segments
    % input 2: either an (increasing) array of the distance to each point or
    %          a single number indicating the distance between each point
    % output 1: the interpolated points
    % output 2: the gradient at each interpolated point
    % output 3: leftover spaces, if any (will return [] if all are used)
    %           Ex: if spaces = [1, 2, 5, 7] and the road is 4 meters
    %           long, the leftover will be [1, 3].
% 4/23/16 added bit for going past the road

    if nargin == 1
        spaces = 1;
    end
    % calculate length of each segment of road
    segmentLengths = zeros(size(road,1),1);
    for i = 1:size(road,1)
       if road(i,3) < 0
           segmentLengths(i) = road(i,4);
       else
           segmentLengths(i) = abs(road(i,3)*road(i,5));
       end
    end
    % set up even spaces across road
    if length(spaces) == 1
        spaces = (0 : spaces : sum(segmentLengths))';
    end
    if size(spaces,1) == 1
        spaces = spaces';
    end
    
%    points = zeros(0,2);
%    gradients = zeros(0,2);
%    for i = 1:size(road,1)
%        spacesubset = spaces(spaces <= segmentLengths(i));
%        spaces = spaces(spaces>segmentLengths(i)) - segmentLengths(i);
%        
%        points = cat(1, points, interpSeg(road(i,:), spacesubset));
%        gradients = cat(1, gradients, ...
%            ang2vec(tangentSeg(road(i,:), spacesubset)));
%    end
   points = zeros(length(spaces),2);
   gradients = zeros(length(spaces),2);
   roadLengthSoFar = cumsum([0; segmentLengths]);
   for i = 1:size(road,1)
       spacesubset = (spaces >= roadLengthSoFar(i)-.1).*...
                     (spaces <= roadLengthSoFar(i+1)+.1) > 0;
       pointssubset = spaces(spacesubset)-roadLengthSoFar(i);
       points(spacesubset,:) = interpSeg(road(i,:), pointssubset);
       gradients(spacesubset, :) = ang2vec(tangentSeg(road(i,:), ...
                                                    pointssubset));
   end
   pastsubset = spaces >= roadLengthSoFar(end);
   if any(pastsubset)
    pointssubset = spaces(pastsubset)-roadLengthSoFar(length(roadLengthSoFar)-1);
    points(pastsubset,:) = interpSeg(road(end,:), pointssubset);
    gradients(pastsubset, :) = ang2vec(tangentSeg(road(i,:),pointssubset));
   end
end


function points = interpSeg(segment, spaces)
    if segment(3) < 0
        %d_spread = 0 : space : segment(4);
        x_spread = segment(1) + spaces*cos(segment(5));
        y_spread = segment(2) + spaces*sin(segment(5));
    else
        arc_spread = spaces / segment(3) * sign(segment(5));
        x_spread = segment(1) + segment(3)*cos(segment(4)+arc_spread);
        y_spread = segment(2) + segment(3)*sin(segment(4)+arc_spread);
    end
    points = [x_spread y_spread];
end

function angles = tangentSeg(segment, spaces)
    if segment(3) < 0
        angles = zeros(size(spaces)) + segment(5);
    else
        arc_spread = spaces / segment(3) * sign(segment(5));
        angles = segment(4) + arc_spread + pi/2*sign(segment(5));
    end
end