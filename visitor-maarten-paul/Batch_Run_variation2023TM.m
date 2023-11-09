%datasets = ['20190314/Deconvolution';...
 %   '20190315/Deconvolution'; '20190316/Deconvolution'; '20190317/Deconvolution'; '20190320/Deconvolution';...
  %  '20190321/Deconvolution'; '20190322/Deconvolution' ];


%for z=1:length(datasets(:,1))
%    disp(['Running dataset: ' datasets(z,:)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% User Settings
    %rootDir = ['/media/mount/' datasets(z,:)];
    rootDir = '/media/OIC-station2/MFM/TM/dCTD MMC/';
    pixelSize = [0.120,0.120,0.418]; % (x,y,z) in um
    timeBetweenFrames = 0.052;

    minTrackLength = 10;
    numberOfDiffusionStates = 1;
    cd(rootDir);
    
    filesStr = dir('*Ch1_preprocessed.csv');

    %need to fix this regular expression because transformed files will also be
    %analyzed (proably will give an error)
    cropFromEdge=8;
    startFrame=50;

    saveDir = rootDir;
    %saveDir = ['/media/DATA/Maarten/MFM/results_2023/' datasets(z,:)];
    if ~exist(saveDir, 'dir')
        mkdir(saveDir)
    end

    %error at 11

    for k=1:length(filesStr)
        %for k=1:48
        trackingFileName =  filesStr(k).name;
        if(contains(trackingFileName,"transf"))
            continue
        end
%        if(not(contains(trackingFileName,"53bp1")))
        if(not(contains(trackingFileName,"53bp1")))

            continue
        end
        if(contains(trackingFileName,"mask2"))
            continue
        end
        if(contains(trackingFileName,"foci_features"))
            continue
        end

     %   objectMaskImageName = strsplit(trackingFileName,'Traj_');
      %  objectMaskImageName = objectMaskImageName{1,2};
        objectMaskImageName = strsplit(trackingFileName,'__Ch1_preprocessed.csv');
        objectMaskImageName = objectMaskImageName{1,1};
        trackingFileName = [objectMaskImageName,'__Ch1_preprocessed.csv'];
        objectMaskImageName = [objectMaskImageName,'__Ch2.h5'];

        conditionName = split(trackingFileName,'.');
        conditionName =  char(conditionName(1));
        cropFromEdge = 8;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['load data at: ' datestr(now,'HH:MM:SS')]);
        % HMM-Bayes
        if isfile(fullfile(saveDir,['Traj_' conditionName '_tracks_mask2.csv']))
            continue
        end
     %   trackingFileName='/media/mount/20190312/Deconvolution/190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch1_preprocessed-spots.csv';
      %  trackData = HMM_Bayes.CSVimport(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));
        trackData = HMM_Bayes.CSVimport_trackmate(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));

        
        if ~isfile(fullfile(saveDir,'mask',['imBW_' conditionName '.mat']))
            disp(['interpolate and get mask at: ' datestr(now,'HH:MM:SS')]);
            im = InterpolateFrames(rootDir,objectMaskImageName,false);
            imBW = GetMask(im);
            save(fullfile(saveDir,'mask',['im_' conditionName '.mat']),'im','-v7.3');
            
            save(fullfile(saveDir,'mask',['imBW_' conditionName '.mat']),'imBW');
        else
            disp(['loading im and imBW at: ' datestr(now,'HH:MM:SS')]);

            load(fullfile(saveDir,'mask',['im_' conditionName '.mat']));
            load(fullfile(saveDir,'mask',['imBW_' conditionName '.mat']));
        end
        disp(['correlate tracks with mask at: ' datestr(now,'HH:MM:SS')]);
        saveFeaturesName = fullfile(saveDir,['foci_features_' conditionName]);
        trackData = CoorelateTrackWithMaskMPv3(trackData,im,imBW,pixelSize,cropFromEdge,startFrame,saveFeaturesName);
        disp(['save tracks: ' datestr(now,'HH:MM:SS')]);
        saveTrackData2(saveDir,['Traj_' conditionName],trackData);
        for m=1:3
            %% Get DNA Damage Mask
            random=rand(1);
            disp(['run GT ' num2str(m) ' at: ' datestr(now,'HH:MM:SS')]);
            
            if ~isfile(fullfile(saveDir,'mask',['transformed_' num2str(m) 'imBW_' conditionName '.mat']))
                imSize = size(imBW);
                imBWGT = zeros(imSize);
            
                imTemp = native_ground_truth_3d_no_z_displacement(imBW(:,:,:,:,1));
            
                parfor l=1:imSize(5)
                    imBWGT(:,:,:,:,l) = imTemp;
                end

                save(fullfile(saveDir,'mask',['transformed_' num2str(m) 'imBW_' conditionName '.mat']),'imBWGT');
            else
                disp(['loading imBWGT at: ' datestr(now,'HH:MM:SS')]);
                load(fullfile(saveDir,'mask',['transformed_' num2str(m) 'imBW_' conditionName '.mat']));
            end


           
            %% Assosiate the masked GT data with the track data
            disp(['correlate tracks with GT mask at: ' datestr(now,'HH:MM:SS')]);
            saveFeaturesName = fullfile(saveDir,['foci_features_transformed_' num2str(m) '_' conditionName]);

            trackData = CoorelateTrackWithMaskMPv3(trackData,im,imBWGT,pixelSize,cropFromEdge,startFrame,saveFeaturesName);
            disp(['save GT tracks: ' datestr(now,'HH:MM:SS')]);
            saveTrackData2(saveDir,['Traj_transformed_' num2str(m) '_' conditionName],trackData);
            % HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
            %saveToMtrackJ(rootDir,conditionName,trackData,cropFromEdge,startFrame,4);


        end
        %% Plot (optional)
        % HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
        % PlotTracks(im,trackData,pixelSize,fullfile(rootDir,conditionName));

    end

