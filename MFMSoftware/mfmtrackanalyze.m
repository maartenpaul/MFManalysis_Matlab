function mfmtrackanalyze(gamma,anomolous,rsqthresh)
%MFMTRACKANALYZE will "Bulk" fit MFM tracks data to a Brownian/Anomolous
%model to extract and save diffusion constants (D) and alpha values
%
%INPUTS:
%   gamma = 4 for 2D and 6 for 3D diffusion
%   anomolous = 0 for brownian or 1 for anomolous model diffusion
%   rsqthresh = the R-squared threshold value for fitting data to model.
%               Fitted tracks that result in R2 value of less than this
%               will be ignored.
%
%OUTPUT:
%   all data is automatically saved as a .mat file of the same name as the
%   tracks file, with "analyzed" appended to the end

[trackslist,pathdata] = uigetfile('*.mat','Choose particle tracks (.mat) files','multiselect','on');
if ~iscell(trackslist)
    trackslist = {trackslist};
end

numtrackfiles = length(trackslist);

for a = 1:numtrackfiles
    currfile = trackslist{a};
    disp(['Analyzing ' currfile])
    [~,currfilepart] = fileparts(currfile);
    csvfile = fullfile(pathdata,[currfilepart(1:(end-15)) '.h5_metadata.csv']);
    if exist(csvfile,'file')~=2
        error('Cannot find metadata!');
    end
    tracks = load(fullfile(pathdata,trackslist{a}));
    tracks = tracks.tracks;
    metadata = csvread(csvfile,1,0);
    timestamps = metadata(:,5);
    acqtime = mean(diff(timestamps));
    [D,alpha] = diffusionconst(tracks,acqtime,gamma,anomolous,rsqthresh);
    [~,filepart] = fileparts(trackslist{a});
    if anomolous
        Dkeep = D((D>0)&(alpha>0));
        akeep = alpha((D>0)&(alpha>0));
        trackskeep = tracks((D>0)&(alpha>0));
        output.tracks = trackskeep;
        output.D = Dkeep;
        output.alpha = akeep; 
        save(fullfile(pathdata,[filepart '_analyzed.mat']),'output');
    else
        Dkeep = D(D>0);
        trackskeep = tracks(D>0);
        output.tracks = trackskeep;
        output.D = Dkeep;
        save(fullfile(pathdata,[filepart '_analyzed.mat']),'output');
    end
end
        
        
    
    
    
    
    
    








end

