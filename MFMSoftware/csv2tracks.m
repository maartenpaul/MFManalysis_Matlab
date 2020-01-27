function tracks = csv2tracks(filename,minlength,objmag,d)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
xypixel = 16/objmag*150/200*1000;
data = csvread(filename,1,0);
numtracks = max(data(:,2));
ii = 0;
for a = 1:numtracks
    currows = find(data(:,2) == a);
    if length(currows)>=minlength
        ii = ii+1;
        currtrack = zeros(length(currows),4);
        currtrack(:,1) = data(currows,4)*xypixel;
        currtrack(:,2) = data(currows,5)*xypixel;
        currtrack(:,3) = data(currows,6)*d;
        currtrack(:,4) = data(currows,3);
        tracks{ii} = currtrack; %#ok<AGROW>
    end
end