function [nframes,matrix,res,timeres,VENC,area_val,diam_val,flowPerHeartCycle_val, ...
    maxVel_val,PI_val,RI_val,flowPulsatile_val,velMean_val, ...
    VplanesAllx,VplanesAlly,VplanesAllz,Planes,branchList,segment,r, ...
    timeMIPcrossection,segmentFull,vTimeFrameave,MAGcrossection, imageData, ...
    bnumMeanFlow,bnumStdvFlow,StdvFromMean,segmentFullEx,autoFlow,pixelSpace, VoxDims, PIvel_val] = loadDCM(directory,handles)
% loadDCM loads dicom files and then processes them.
%
% It retursn to much to discuss, but it basically passes through all the
% processed data to paramMap.
%
% Outputs: Everything
%
% Used by: autoCollectFlow.m, and any separate functions to compute any
% saved data (PITC codes, Damping codes etc)
%
% Notes: The DICOM data may be rotated 180 (reverse flows), this may be
% allieviated by rotating the matrices using something like 
% %MAG=imrotate(MAG(:,:,:),rotImAngle);
% This should be done for all loaded matrices, HOWEVER, this was only
% required on Siemens data for some reason and may not always be needed.
%
% Dependencies: ShuffleDCM.m and all QVT processing codes
%% Initialization
clc
BGPCdone=0; %0=do backgroun correction, 1=don't do background correction.
autoFlow=1; %if you want to label and do QVT+ processing
res=[];%'05';%'0.5''1.4'; %Only needed if you have multiple resolutions in your patient folder, 
% AND the resolution is named in the file folder; put in the resolution.
UPSMP=2; %Set to 1 if no umpsampling, or 2 if upsampling (double resolution).
%'SH' Siemens Healthineers, 'GE' General Electric
Vendor='GE'; %Under construction, just leave as is, this can be developed as people share case data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Don't change below %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Or do
addpath(pwd)
set(handles.TextUpdate,'String','Loading .DCM Data'); drawnow;
if strcmp(Vendor,'GE')
    [MAG,v,VENC,INFO,filetype,nframes,timeres,res,matrix,slicespace,VoxDims] = loadGEDCM(handles,directory,res,UPSMP);
    v = ((2*(v-(-VENC))/(VENC-(-VENC))) - 1) * VENC; %range values to VENCs
else
    [MAG,v,VENC,INFO,filetype,nframes,timeres,res,matrix,slicespace,VoxDims,Vs] = loadSHDCM(handles,directory,UPSMP);
    v = (((v-Vs(1))/Vs(2)) - 0.5) * VENC; %range values to VENCs
    v(:,:,:,3,:)=-single(1).*v(:,:,:,3,:);
end
% Convert velocity
vMean = mean(v,5);
clear maxx minn
set(handles.TextUpdate,'String','Loading .DCM Data 100%'); drawnow;
%% Import Complex Difference
set(handles.TextUpdate,'String','Loading Complex Difference Data'); drawnow;
timeMIP = calc_angio(MAG, vMean, VENC);
%% Manual Background Phase Correction (if necessary)
back = zeros(size(vMean),'single');
if ~BGPCdone
    set(handles.TextUpdate,'String','Phase Correction with Polynomial'); drawnow;
    [poly_fitx,poly_fity,poly_fitz] = background_phase_correction(MAG,vMean(:,:,:,1),vMean(:,:,:,2),vMean(:,:,:,3));
    %disp('Correcting data with polynomial');
    xrange = single(linspace(-1,1,size(MAG,1)));
    yrange = single(linspace(-1,1,size(MAG,2)));
    zrange = single(linspace(-1,1,size(MAG,3)));
    [Y,X,Z] = meshgrid(yrange,xrange,zrange);
    % Get poly data and correct average velocity for x,y,z dimensions
    back(:,:,:,1) = single(evaluate_poly(X,Y,Z,poly_fitx));
    back(:,:,:,2) = single(evaluate_poly(X,Y,Z,poly_fity));
    back(:,:,:,3) = single(evaluate_poly(X,Y,Z,poly_fitz));
    vMean = vMean - back;
    for f=1:nframes
        v(:,:,:,:,f) = v(:,:,:,:,f) - back;
    end 
    clear X Y Z poly_fitx poly_fity poly_fitz xrange yrange zrange
end
%% Find optimum global threshold for total branch segmentation
set(handles.TextUpdate,'String','Segmenting and creating Tree'); drawnow;
SEG=dir(strcat(directory,'\*CD.nii')); %Identifies if an external segmentation is present, otherwise uses sliding threshold.
if ~isempty(SEG)>0 && UPSMP==2
    segment = logical(niftiread(fullfile(directory,SEG(1).name)));
else
    step = 0.001; %step size for sliding threshold
    UPthresh = 0.8; %max upper threshold when creating Sval curvature plot
    SMf = 10;
    shiftHM_flag = 1; %flag to shift max curvature by FWHM
    medFilt_flag = 1; %flag for median filtering of CD image
    [~,segment] = slidingThreshold(timeMIP,step,UPthresh,SMf,shiftHM_flag,medFilt_flag);
end
areaThresh = round(sum(segment(:)).*0.002); %SD 0.005OG; %minimum area to keep
conn = 6; %connectivity (i.e. 6-pt)
segment = bwareaopen(segment,areaThresh,conn); %inverse fill holes
% save raw (cropped) images to imageData structure (for Visual Tool)
imageData.MAG = MAG;
imageData.CD = timeMIP; 
imageData.V = vMean;
imageData.Segmented = segment;
imageData.Header = INFO;

%% Feature Extraction
% Get trim and create the centerline data
sortingCriteria = 3; %sorts branches by junctions/intersects 
spurLength = 5; %minimum branch length (removes short spurs)
[~,~,branchList,~] = feature_extraction(sortingCriteria,spurLength,vMean,segment,handles);

%% You can load another segmentation here if you want which will overlap on images
Exseg=segment; %for now, dummy copy, can do feature extraction
%[~,~,branchList2,~] = feature_extraction(sortingCriteria,spurLength,vMean,logical(JSseg),[]);

%% SEND FOR PROCESSING
% Flow parameter calculation, bulk of code is in paramMap_parameters.m
SEG_TYPE = 'thresh'; %kmeans or thresh
if strcmp(SEG_TYPE,'kmeans')
    [area_val,diam_val,flowPerHeartCycle_val,maxVel_val,PI_val,RI_val,flowPulsatile_val,...
        velMean_val,VplanesAllx,VplanesAlly,VplanesAllz,r,timeMIPcrossection,segmentFull,...
        vTimeFrameave,MAGcrossection,bnumMeanFlow,bnumStdvFlow,StdvFromMean,Planes] ...
        = paramMap_params_kmeans(filetype,branchList,matrix,timeMIP,vMean, ...
    back,BGPCdone,directory,nframes,res,MAG,handles, v,slicespace);
elseif strcmp(SEG_TYPE,'thresh')
    [area_val,diam_val,flowPerHeartCycle_val,maxVel_val,PI_val,RI_val,flowPulsatile_val,...
        velMean_val,VplanesAllx,VplanesAlly,VplanesAllz,r,timeMIPcrossection,segmentFull,...
        vTimeFrameave,MAGcrossection,bnumMeanFlow,bnumStdvFlow,StdvFromMean,Planes,pixelSpace,...
        segmentFullEx,PIvel_val] ...
        = paramMap_params_threshS(filetype,branchList,matrix,timeMIP,vMean, ...
    back,BGPCdone,directory,nframes,res,MAG,handles, v,slicespace,Exseg);
else
    disp("Incorrect segmentation type selected, please select 'kmeans' or 'thresh'");
end 
set(handles.TextUpdate,'String','All Data Loaded'); drawnow;
return