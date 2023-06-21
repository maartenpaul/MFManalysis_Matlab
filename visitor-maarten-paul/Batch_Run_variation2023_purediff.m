datasets = ['diffusion/Deconvolution/' ];
%%'20190312/Deconvolution'; '20190313/Deconvolution'; 

%/media/DATA/Maarten/MFM/results_2023/diffusion/Deconvolution/pure_3D_diffusion_model_output.csv
%/media/mount/2023_purediffusion/Deconvolution/Traj_190313exp1_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002__Ch1_preprocessed.tif.csv
for z=1:length(datasets(:,1))
    disp(['Running dataset: ' datasets(z,:)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% User Settings
    rootDir = ['/media/DATA/Maarten/MFM/results_2023/' datasets(z,:)];
    pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
    timeBetweenFrames = 0.052;

    minTrackLength = 10;
    numberOfDiffusionStates = 1;
    cd(rootDir);
    filesStr = dir('Traj_*Ch1_preprocessed.tif.csv');

    %need to fix this regular expression because transformed files will also be
    %analyzed (proably will give an error)
    cropFromEdge=8;
    startFrame=0;


    saveDir = ['/media/DATA/Maarten/MFM/results_2023/' datasets(z,:)];
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
        objectMaskImageName = strsplit(trackingFileName,'Traj_');
        objectMaskImageName = objectMaskImageName{1,2};
        objectMaskImageName = strsplit(objectMaskImageName,'__Ch1_preprocessed.tif.csv');
        objectMaskImageName = objectMaskImageName{1,1};
        trackingFileName = ['Traj_',objectMaskImageName,'__Ch1_preprocessed.tif.csv'];
        objectMaskImageName = [objectMaskImageName,'__Ch2.h5'];

        conditionName = split(trackingFileName,'.');
        conditionName =  char(conditionName(1));
        cropFromEdge = 8;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['load data at: ' datestr(now,'HH:MM:SS')]);
        %% HMM-Bayes
        trackData = HMM_Bayes.CSVimport(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));

        
        if ~isfile(fullfile(saveDir,['imBW_' conditionName '.mat']))
            disp(['interpolate and get mask at: ' datestr(now,'HH:MM:SS')]);
            im = InterpolateFrames(rootDir,objectMaskImageName,false);
            imBW = GetMask(im);
            save(fullfile(saveDir,['im_' conditionName '.mat']),'im','-v7.3');
            
            save(fullfile(saveDir,['imBW_' conditionName '.mat']),'imBW');
        else
            disp(['loading im and imBW at: ' datestr(now,'HH:MM:SS')]);

            load(fullfile(saveDir,['im_' conditionName '.mat']));
            load(fullfile(saveDir,['imBW_' conditionName '.mat']));
        end
        disp(['correlate tracks with mask at: ' datestr(now,'HH:MM:SS')]);
        trackData = CoorelateTrackWithMaskMPv3(trackData,im,imBW,pixelSize,cropFromEdge,startFrame);
        disp(['save tracks: ' datestr(now,'HH:MM:SS')]);
        saveTrackData2(saveDir,conditionName,trackData);
        for m=1:3
            %% Get DNA Damage Mask
            random=rand(1);
            disp(['run GT ' num2str(m) ' at: ' datestr(now,'HH:MM:SS')]);
            
            if ~isfile(fullfile(saveDir,['transformed_' num2str(m) 'imBW_' conditionName '.mat']))
                imSize = size(imBW);
                imBWGT = zeros(imSize);
            
                imTemp = native_ground_truth_3d_no_z_displacement(imBW(:,:,:,:,1));
            
                parfor l=1:imSize(5)
                    imBWGT(:,:,:,:,l) = imTemp;
                end

                save(fullfile(saveDir,['transformed_' num2str(m) 'imBW_' conditionName '.mat']),'imBWGT');
            else
                disp(['loading imBWGT at: ' datestr(now,'HH:MM:SS')]);
                load(fullfile(saveDir,['transformed_' num2str(m) 'imBW_' conditionName '.mat']));
            end


           
            %% Assosiate the masked GT data with the track data
            disp(['correlate tracks with GT mask at: ' datestr(now,'HH:MM:SS')]);
            trackData = CoorelateTrackWithMaskMPv3(trackData,im,imBWGT,pixelSize,cropFromEdge,startFrame);
            disp(['save GT tracks: ' datestr(now,'HH:MM:SS')]);
            saveTrackData2(saveDir,['Traj_transformed_' num2str(m) '_' conditionName],trackData);
            % HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);
            %saveToMtrackJ(rootDir,conditionName,trackData,cropFromEdge,startFrame,4);


        end
        %% Plot (optional)
        % HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
        % PlotTracks(im,trackData,pixelSize,fullfile(rootDir,conditionName));

    end
end