function [MAG,v,VENC,INFO,filetype,nframes,timeres,res,matrix,slicespace,VoxDims,Vs] = loadSHDCM(handles,directory,UPSMP)
    path2folder=directory;
    DIR=dir(path2folder);
    tag={'.*4D.*'};
    for i=3:length(DIR)
        match=regexp(DIR(i).name,tag{1});
        if ~isempty(match)
            if strcmp(DIR(i).name((end-1):end),'_P')
                Name=DIR(i).name;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Load Magnitude %%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DIR2=dir(fullfile(path2folder,Name(1:(end-2))));
    for i=3:length(DIR2)
        %load info
        INFO=dicominfo(fullfile(path2folder,Name(1:(end-2)),DIR2(i).name));
        %load data
        MAGslice=single(dicomread(fullfile(path2folder,Name(1:(end-2)),DIR2(i).name)));
        MAGslice=mean(MAGslice,4);
        if i==3 %Initialise mean MAG matrix
            sz=size(MAGslice);
            MAG=zeros([sz(1:2) (length(DIR2)-2)]);
        end
        %Find Slice location
        Loc=INFO.PerFrameFunctionalGroupsSequence.Item_1.FrameContentSequence.Item_1.InStackPositionNumber;
        Loc=(length(DIR2)-1)-Loc;
        %Store
        MAG(:,:,Loc)=MAGslice;
    end
    set(handles.TextUpdate,'String','Loading .DCM Data 25%'); drawnow;
    % % Test Volume Stack
    % if pltflg==1
    %     for i=1:length(MAG(1,1,:))
    %         figure(1)
    %         Image=squeeze(MAG(:,:,i));
    %         imshow(Image,[0 1900])
    %         pause(0.1)
    %     end
    % end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% Load Phase %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DIR2=dir(fullfile(path2folder,Name));
    v=zeros([sz(1:2) (length(DIR2)-2)./3 3 INFO.NumberOfTemporalPositions],'single');
    % This needs significant overhaul to identify the aquisition axis and
    % proper orientation of velocity vectors.
    Order=[2 1 3]; %Order into AP,LR,SI
    %Order=[3 1 2];
    Sign=[0 0 0];
    for i=3:length(DIR2)
        %load info
        INFO=dicominfo(fullfile(path2folder,Name,DIR2(i).name));
        %load phase data
        Vslice=single(dicomread(fullfile(path2folder,Name,DIR2(i).name)));
        %Velocity information: Gives Direction [LR AP SI], min and max in cm/s
        Vdata=INFO.PerFrameFunctionalGroupsSequence.Item_1.MRVelocityEncodingSequence.Item_1;
        EncP=abs(round(Vdata.VelocityEncodingDirection)); % encoding direction (to know what direction phase is encoded)
        Enc=find(EncP==1);
        EncS=round(Vdata.VelocityEncodingDirection(Enc)); %Sign of encoding direction (to know what way is positive)
        if Sign(Order(Enc))==0
             Sign(Order(Enc))=EncS; %Store sign direction for all three directions
        end
        %Find Slice location
        Loc=INFO.PerFrameFunctionalGroupsSequence.Item_1.FrameContentSequence.Item_1.InStackPositionNumber;
        Loc=(length(DIR2)-2)./3+1-Loc;
        %Store
        v(:,:,Loc,Order(Enc),:)=Vslice;
        %functionalgroupsequenceitem MRM modifier (tells acceleration)
        %Get general and text version of phase encoding info
        %INFO.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_10fe.Item_1;
    end
    set(handles.TextUpdate,'String','Loading .DCM Data 100%'); drawnow;
    % if pltflg==1
    %     vm=mean(v,5);
    %     figure('Position',[50 50 2000 500])
    %     for i=1:length(MAG(1,1,:))
    %         Image=squeeze(MAG(:,:,i));
    %         subplot(1,4,1)
    %         imshow(Image,[0 1900])
    %         Image=squeeze(vm(:,:,i,1));
    %         subplot(1,4,2)
    %         imshow(Image,[0 4095])
    %         Image=squeeze(vm(:,:,i,2));
    %         subplot(1,4,3)
    %         imshow(Image,[0 4095])
    %         Image=squeeze(vm(:,:,i,3));
    %         subplot(1,4,4)
    %         imshow(Image,[0 4095])
    %         pause(0.01)
    %     end
    % end

    %Upsample if requested
    [a,c,b]=size(MAG);
    UPSMP=2;
    if UPSMP==2
        set(handles.TextUpdate,'String','Upsampling...'); drawnow;
        [Xq,Yq,Zq] = meshgrid((1:0.5:(c)),(1:0.5:(a)),(1:0.5:(b))); %these are the interpolation steps within the indices
        MAG2=interp3(MAG,Xq,Yq,Zq,'linear'); %Magnitude upsampled
        MAG2(1:2:end,1:2:end,1:2:end)=MAG;
        MAG=MAG2;
        vb=zeros([(2*a-1),(2*c-1),(2*b-1),3,length(v(1,1,1,1,:))],'single'); %this is a blank full velocity matrix
        %Upsample velocity one direction a time over each cardiac phase.
        %(minimise memory overloading)
        for cp=1:length(v(1,1,1,1,:)) %for each phase
             for dd=1:3 %for each direction
                 Vp=zeros((2*a-1),(2*c-1),(2*b-1),'single'); %this is a blank upsampled volume
                 Vp(:,:,:)=interp3(squeeze(v(:,:,:,dd,cp)),Xq,Yq,Zq,'linear');
                vb(:,:,:,dd,cp)=Vp;
                vb(1:2:end,1:2:end,1:2:end,dd,cp)=squeeze(v(:,:,:,dd,cp));
             end
         end
         v=vb; clear vb Vp;
         set(handles.TextUpdate,'String','Upsampling Complete'); drawnow;
    end

    filetype = 'dcm';
    nframes = INFO.NumberOfTemporalPositions; %number of reconstructed frames
    timeres = INFO.CardiacRRIntervalSpecified/nframes; %temporal resolution (ms)
    
    res       = INFO.PerFrameFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.PixelSpacing(1); %spatial res (mm) (ASSUMED ISOTROPIC IN PLANE)
    slicespace=INFO.PerFrameFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.SliceThickness;
    if UPSMP==2
        res=res./2;
        slicespace=slicespace./2;
    end
    matrix(1) = length(MAG(:,1,1)); %number of pixels in rows
    matrix(2) = length(MAG(1,:,1)); %pixels in cols
    matrix(3) = length(MAG(1,1,:)); %number of slices
    VoxDims=[res res slicespace];
    VENC=single(Vdata.VelocityEncodingMaximumValue*10);
    vMIN=INFO.SmallestImagePixelValue;
    vMAX=INFO.LargestImagePixelValue;
    Vs=single([vMIN vMAX]);
    fprintf(strcat('\n VENC=',num2str(Vs(1),'%03.0f'),'max',num2str(Vs(1),'%03.0f')))
end