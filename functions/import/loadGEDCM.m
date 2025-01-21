function [MAG,v,VENC,INFO,filetype,nframes,timeres,res,matrix,slicespace,VoxDims] = loadGEDCM(handles,directory,Vendor,res,UPSMP)
    [Anatpath,APpath,LRpath,SIpath] = retFlowFolders(directory,Vendor,res);
    %Load each velocity (raw phase) and put into phase matrix
    %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%ANTERIOR
    %%%%%%%%%%%%%%%%%%%%%
    [VAP,INFO] = shuffleDCM3(APpath,0);
    VENC=single(INFO.Private_0019_10cc); %This is for GE scanners, maybe not others?
    [a,c,b,d]=size(VAP);
    if UPSMP==1
        v=zeros([(a),(c),(b),3,d],'single');
        v(:,:,:,1,:)=1.*squeeze(VAP(:,:,:,:));
        clear VAP
    else
        v=zeros([(2*a-1),(2*c-1),(2*b-1),3,d],'single');
        VAP2=zeros((2*a-1),(2*c-1),(2*b-1),d,'single');
        [Xq,Yq,Zq] = meshgrid((1:0.5:a),(1:0.5:c),(1:0.5:b));
        for i=1:d
            VAP2(:,:,:,i)=interp3(squeeze(VAP(:,:,:,i)),Xq,Yq,Zq);
        end
        v(:,:,:,1,:)=1.*squeeze(VAP2(:,:,:,:));
        clear VAP VAP2
    end
    set(handles.TextUpdate,'String','Loading .DCM Data 20%'); drawnow;

    %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%LEFTRIGHT
    %%%%%%%%%%%%%%%%%%%%%
    [VLR,~] = shuffleDCM3(LRpath,0);
    if UPSMP==1
        v(:,:,:,2,:)=1.*squeeze(VLR(:,:,:,:));
        clear VLR
    else
        VLR2=zeros((2*a-1),(2*c-1),(2*b-1),d,'single');
        for i=1:d
            VLR2(:,:,:,i)=interp3(squeeze(VLR(:,:,:,i)),Xq,Yq,Zq);
        end
        v(:,:,:,2,:)=1.*squeeze(VLR2(:,:,:,:));
        clear VLR VLR2
    end
    set(handles.TextUpdate,'String','Loading .DCM Data 40%'); drawnow;

    %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%SUPINF
    %%%%%%%%%%%%%%%%%%%%%
    [VSI,~] = shuffleDCM3(SIpath,0);
    if UPSMP==1
        v(:,:,:,3,:)=1.*squeeze(VSI(:,:,:,:));
        clear VSI
    else
        VSI2=zeros((2*a-1),(2*c-1),(2*b-1),d,'single');
        for i=1:d
            VSI2(:,:,:,i)=interp3(squeeze(VSI(:,:,:,i)),Xq,Yq,Zq);
        end
        v(:,:,:,3,:)=1.*squeeze(VSI2(:,:,:,:));
        clear VSI VSI2
    end
    set(handles.TextUpdate,'String','Loading .DCM Data 60%'); drawnow;
    %niftiwrite(squeeze(imageData.V(:,:,:,3)),'test3.nii')
    %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%MAG
    %%%%%%%%%%%%%%%%%%%%%
    %Load MAGnitude image
    [MAG,~] = shuffleDCM3(Anatpath,0);
    MAG = mean(MAG,4);
    if UPSMP==1
    else
        MAG2=interp3(MAG,Xq,Yq,Zq);
        MAG=MAG2;
        clear MAG2
    end
    set(handles.TextUpdate,'String','Loading .DCM Data 80%'); drawnow;
    

    filetype = 'dcm';
    nframes = INFO.CardiacNumberOfImages; %number of reconstructed frames
    timeres = INFO.NominalInterval/nframes; %temporal resolution (ms)
    if UPSMP==1
        res = INFO.PixelSpacing(1); %spatial res (mm) (ASSUMED ISOTROPIC IN PLANE)
        if strcmp('GE',Vendor)
            slicespace=INFO.SpacingBetweenSlices;
        elseif strcmp('Siemens',Vendor)
            slicespace=INFO.SliceThickness;
        end
        matrix(1) = INFO.Rows; %number of pixels in rows
        matrix(2) = INFO.Columns;
        matrix(3) = length(MAG(1,1,:)); %number of slices
        VoxDims=[res res slicespace];
    else
        res = INFO.PixelSpacing(1)./2; %spatial res (mm) (ASSUMED ISOTROPIC IN PLANE)
        if strcmp('GE',Vendor)
            slicespace=INFO.SpacingBetweenSlices./2;
        elseif strcmp('Siemens',Vendor)
            slicespace=INFO.SliceThickness./2;
        end
        matrix(1) = (2*a-1); %number of pixels in rows
        matrix(2) = (2*a-1);
        matrix(3) = length(MAG(1,1,:)); %number of slices
        VoxDims=[res res slicespace];
    end
end
