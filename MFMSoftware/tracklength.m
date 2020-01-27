function tracklength()
%This function will compute the track lengths (in seconds) for a given list of
%particletracks or particletracks_analyzed files, and save the results in a
%new .mat file with "tracklengths" appended to the originial file name.

[filelist,pathname] = uigetfile('*.mat','Choose particle tracks .mat file(s)','multiselect','on');
if ~iscell(filelist)
    filelist = {filelist};
end

numfiles = length(filelist);

for a = 1:numfiles
    disp(['Analyzing file ' num2str(a) ' of ' num2str(numfiles)]);
    data = load(fullfile(pathname,filelist{a}));
    [~,filestem] = fileparts(fullfile(pathname,filelist{a}));
    if isfield(data,'tracks')
        filetype = 'tracks';
    elseif isfield(data,'output')
        filetype = 'tracksanalyzed';
    else
        error('tracks file not recognized')
    end
    
    switch filetype
        case 'tracksanalyzed'
            csvfilename = [filestem(1:(end-24)) '.h5_metadata.csv'];
            tracks = data.output.tracks;
           
        case 'tracks'
            csvfilename = [filestem(1:(end-15)) '.h5_metadata.csv'];
            tracks = data.tracks;
    end
    
    isfile = exist(fullfile(pathname,csvfilename),'file');
    if isfile == 2
        metadata = csvread(fullfile(pathname,csvfilename),0,0);
    else
        error('Cant find metadata file');
    end
    
    timestamps = metadata(:,5);
    numtracks = length(tracks);
    tracklengths = zeros(numtracks,1);
    for b = 1:numtracks
        currtrack = tracks{b};
        startframe = currtrack(1,4)+1;
        endframe = currtrack(end,4)+1;
        tracklengths(b) = timestamps(endframe) - timestamps(startframe);
    end
    
    newfilename = [filestem '_tracklengths.mat'];
    save(fullfile(pathname,newfilename),'tracklengths');
end
    
    
    
        
        
    
    
    
    
    
    
            
            
            
            
            
            
    


end

