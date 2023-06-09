%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
rootDir = '/media/mount/20190320/Deconvolution/';
    pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
    timeBetweenFrames = 0.052;

    minTrackLength = 10;
    numberOfDiffusionStates = 1;
    startFrame = 50;
    
%files = ["190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0001","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0002","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0003"...
%    "190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0004","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0005","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0006"...
%    "190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0007","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0008","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0009"...
%    "190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_00010","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0011","190316exp1_53bp1_GFP_B2dBDBE4_MMC_50ms_100_f488int_0012"];

files = ["190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0001"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0002"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0003"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0004"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0005"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0006"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0007"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0008"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0009"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0010"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0011"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0012"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0013"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0014"...
"190320exp2_R54_GFP_B2WT_MMC_50ms_100_f488int_0015"];
%error at 11


for k=1:length(files)


   trackingFileName = ['Traj_' convertStringsToChars(files(k)) '__Ch1_preprocessed.tif.csv'];

    objectMaskImageName = [convertStringsToChars(files(k)),'__Ch2.h5'];
    particleImageName = [files(k),'__Ch1.h5'];




    conditionName = split(trackingFileName,'.');
    conditionName =  char(conditionName(1));
    cropFromEdge = 8;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% HMM-Bayes
    trackData = HMM_Bayes.CSVimport(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));
 %   if isfile(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']))==false
%        [trackData,results,locationError] = HMM_Bayes.Run(trackData,numberOfDiffusionStates,minTrackLength);
 %       HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
%     else
%         load(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']));
%     end
    % Run the following line if HMM_Bayes was already run
    %[trackData,results,locationError] = HMM_Bayes.LoadResults(rootDir,conditionName);

    %% Get DNA Damage Mask
    im = InterpolateFrames(rootDir,objectMaskImageName,false);
    imBW = GetMask(im);

    %writeMFMh5image(im,rootDir,'im_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.h5','uint16');
    writeMFMtiffimage(im,rootDir,['im_' conditionName '.tif'],'uint16');

    %writeMFMh5image(imBW,rootDir,'im_BW_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.h5','uint8');
    writeMFMtiffimage(imBW,rootDir,['imBW_' conditionName '.tif'],'uint8');

    %% Assosiate the masked data with the track data
    %trackData = CoorelateTrackWithMask(trackData,imBW,pixelSize);
  %  trackData = CoorelateTrackWithMaskMP(trackData,imBW,pixelSize,cropFromEdge,startFrame);
    %saveTrackData(rootDir,conditionName,trackData);
 %   HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
 %   saveToMtrackJ(rootDir,conditionName,trackData,cropFromEdge,startFrame,4);

    %% Plot (optional)
   % HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
   % PlotTracks(im,trackData,pixelSize,fullfile(rootDir,conditionName));

end
