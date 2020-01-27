%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
rootDir = 'E:\20190322\Deconvolution';
    pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
    timeBetweenFrames = 0.052;

    minTrackLength = 10;
    numberOfDiffusionStates = 1;
cd(rootDir); 
filesStr = dir('Traj_*preprocessed.tif.csv');
cropFromEdge=8;
startFrame=50;

%error at 11

for k=1:length(filesStr)
   trackingFileName =  filesStr(k).name;
   objectMaskImageName = strsplit(trackingFileName,'Traj_');
   objectMaskImageName = objectMaskImageName{1,2};
   objectMaskImageName = strsplit(objectMaskImageName,'__Ch1_preprocessed.tif.csv');
   objectMaskImageName = objectMaskImageName{1,1};
   objectMaskImageName = [objectMaskImageName,'__Ch2.h5'];

    conditionName = split(trackingFileName,'.');
    conditionName =  char(conditionName(1));
    cropFromEdge = 8;
        
    matToTrackData(rootDir,conditionName);

end
