function mfmmovie(bgradius,gaussradius)

[filelist,pathname] = uigetfile('*.h5','Choose .h5 files for SIP, BG subtract, Gauss Filter...','MultiSelect','on');
if ~iscell(filelist)
    filelist = {filelist};
end

numfiles = length(filelist);
newfolder = fullfile(pathname,'Processed');
mkdir(newfolder);
for a = 1:numfiles
    disp(['Reading ' filelist{a}]);
    data = h5import2(pathname,filelist{a});
    disp('Sum Projection');
    datamax = max(data,[],3);
    datamax = squeeze(datamax);
    clear data;
    disp('BG Subtract');
    databg = bgsubtract(datamax,bgradius);
    clear datamax;
    disp('Gaussian Filter');
    datafilt = imgaussfilt(databg,gaussradius);
    clear databg;
    [~,filestem] = fileparts(filelist{a});
    newfile = [filestem '_processed.tif'];
    disp('Saving...');
    tiffwrite2(datafilt,newfolder,newfile,16,0);
end

