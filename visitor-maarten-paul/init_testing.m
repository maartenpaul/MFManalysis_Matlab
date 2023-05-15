pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
timeBetweenFrames = 0.052;
minTrackLength = 10;
numberOfDiffusionStates = 1;
cropFromEdge=8;
startFrame=50;
saveDir = '/media/DATA/Maarten/results_200309/';
numberOfGroundtruth = 3;

datasets = [ '20190312/Deconvolution'; '20190313/Deconvolution'; '20190314/Deconvolution';...
    '20190315/Deconvolution'; '20190316/Deconvolution'; '20190317/Deconvolution'; '20190320/Deconvolution';...
    '20190321/Deconvolution'; '20190322/Deconvolution'];

z= 1;
k=1;
disp(['Running dataset: ' datasets(z,:)]);

rootDir = ['/media/mount/' datasets(z,:)];
cd(rootDir);
filesStr = dir('Traj_*preprocessed_tracks_mask.csv');

saveSubDir = [saveDir, datasets(z,:)];
if ~exist(saveSubDir, 'dir')
    mkdir(saveSubDir)
end

trackingFileName =  filesStr(k).name;

objectMaskImageName = strsplit(trackingFileName,'Traj_');
objectMaskImageName = objectMaskImageName{1,2};
objectMaskImageName = strsplit(objectMaskImageName,'__Ch1_preprocessed_tracks_mask.csv');
objectMaskImageName = objectMaskImageName{1,1};
trackingFileName = ['Traj_',objectMaskImageName,'__Ch1_preprocessed.tif.csv'];
objectMaskImageName = [objectMaskImageName,'__Ch2.h5'];

conditionName = split(trackingFileName,'.');
conditionName =  char(conditionName(1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['load data at: ' datestr(now,'HH:MM:SS')]);
%% Originally the plan was to use HMM Bayes to segment tracks, but
%% very slow so for now this is skipped
trackData = HMM_Bayes.CSVimport(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));

%   if isfile(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']))==false
%  [trackData,results,locationError] = HMM_Bayes.Run(trackData,numberOfDiffusionStates,minTrackLength);
%   HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
%     else
%         load(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']));
%     end
% Run the following line if HMM_Bayes was already run
%[trackData,results,locationError] = HMM_Bayes.LoadResults(rootDir,conditionName);

disp(['interpolate and get mask at: ' datestr(now,'HH:MM:SS')]);

im = InterpolateFrames(rootDir,objectMaskImageName,false);
imBW = GetMask(im);

disp(['correlate tracks with mask at: ' datestr(now,'HH:MM:SS')]);
trackData = CoorelateTrackWithMaskMPv2(trackData,im,imBW,pixelSize,cropFromEdge,startFrame);

imSize = size(imBW);

imBWGT2 = zeros(imSize);
         
         disp(['run native GT ' num2str(m) ' at: ' datestr(now,'HH:MM:SS')]);
         
         

         
         
         writeMFMtiffimage(imBW,pwd,['initial_im_' conditionName '.tif'],'uint8');
         writeMFMtiffimage(imBWGT2,pwd,['GT2_im_' conditionName '.tif'],'uint8');

         
         disp(['finished native GT ' num2str(m) ' at: ' datestr(now,'HH:MM:SS')]);