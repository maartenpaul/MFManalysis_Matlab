%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
%rootDir = 'E:\20190318\Deconvolution\processed';
%rootDir = 'E:\20190319\Deconvolution\processed';
rootDir = '/media/mount/20190318/Deconvolution/processed/';
pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
timeBetweenFrames = 0.052;
minTrackLength = 3;
numberOfDiffusionStates = 1;
cd(rootDir); 
filesStr = dir('Traj_*preprocessed.tif.csv');
cropFromEdge=8;
startFrame=0;


%error at 11

for k=1:length(filesStr)
%for k=[13:17,33:38]

   trackingFileName =  filesStr(k).name;
   objectMaskImageName = strsplit(trackingFileName,'Traj_');
   objectMaskImageName = objectMaskImageName{1,2};
   objectMaskImageName = strsplit(objectMaskImageName,'__Ch1_preprocessed.tif.csv');
   objectMaskImageName = objectMaskImageName{1,1};
   objectMaskImageName = [objectMaskImageName,'__Ch2.h5'];

    conditionName = split(trackingFileName,'.');
    conditionName =  char(conditionName(1));
    cropFromEdge = 8;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% HMM-Bayes
    trackData = HMM_Bayes.CSVimport(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));
 %   if isfile(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']))==false
      %  [trackData,results,locationError] = HMM_Bayes.Run(trackData,numberOfDiffusionStates,minTrackLength);
     %   HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
%     else
%         load(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']));
%     end
    % Run the following line if HMM_Bayes was already run
    %[trackData,results,locationError] = HMM_Bayes.LoadResults(rootDir,conditionName);

    %% Get DNA Damage Mask
    im = InterpolateFrames(rootDir,objectMaskImageName,true);
    %h5Name=objectMaskImageName;
    imBW = GetMask(im);

    %writeMFMh5image(im,rootDir,'im_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.h5','uint16');
    %writeMFMtiffimage(im,rootDir,['im_' conditionName '.tif'],'uint16');

    %writeMFMh5image(imBW,rootDir,'im_BW_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.h5','uint8');
    %writeMFMtiffimage(imBW,rootDir,['imBW_' conditionName '.tif'],'uint8');

    %% Assosiate the masked data with the track data
    %trackData = CoorelateTrackWithMask(trackData,imBW,pixelSize);
    trackData = CoorelateTrackWithMaskMP(trackData,imBW,im,pixelSize,cropFromEdge,startFrame);
    saveTrackData(rootDir,conditionName,trackData);
   % HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
    saveToMtrackJ(rootDir,conditionName,trackData,cropFromEdge,startFrame,4);

    %% Plot (optional)
   % HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
   % PlotTracks(im,trackData,pixelSize,fullfile(rootDir,conditionName));
   
end
