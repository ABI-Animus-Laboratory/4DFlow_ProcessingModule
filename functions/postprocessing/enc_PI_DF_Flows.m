function [DF,PI,Flows,FlowErr] = dev_enc_PI_DF_Flows(PI_scat,data_struct,Labels,path2data,params)
    % Load Necessities from labels and processed data
    load(fullfile(path2data,'RawDamping.mat'));
    %%
    BranchList=data_struct.branchList;
    BranchList=[BranchList [1:length(BranchList)]'];
    FlowData=data_struct.flowPulsatile_val;
    roots=[1,2,9]; %L_ICA R_ICA BA
    CoWA=[3,5,4,6,7,8];% LMCA LACA RMCA RACA LPCA RPCA
    StartPI=[];
    EndPI=[];
    PI=zeros([1 9]);
    Flows=zeros([20 9]); %%assuming 20 cardiac phases
    FlowErr=zeros([20 9]); %%assuming 20 cardiac phases
    for i=1:3
        ves = Labels{roots(i),2};
        ves = str2num(ves);
        if length(ves)>1
            ves = Labels{roots(i),3};
            ves = str2num(ves);
            ves=ves(1);
        end
        LOC = Labels{roots(i),3};
        LOC=str2num(LOC);
        if length(LOC)>1
            temp=LOC;
            LOC=temp(2);
            ves=temp(1);
        end
        [idx1,~]=find(BranchList(:,4)==ves);
        Data=BranchList(idx1,:);
        [idx2,~]=find(Data(:,5)==LOC);
        VesLoc=Data(idx2,:);
        [idx3,~]=find(PI_scat(:,3,i)==VesLoc(6));
        StartPI(i,:)=abs(PI_scat(idx3,:,i));
        PI(1,roots(i))=abs(PI_scat(idx3,2,i));
        switch params.FlowType
            case 'Local'
                Flows(:,roots(i))=mean(FlowData((VesLoc(6)-2):(VesLoc(6)+2),:));
                FlowErr(:,roots(i))=std(FlowData((VesLoc(6)-2):(VesLoc(6)+2),:));
        end
    end
    loci=[3 5 4 6 7 8];
    for i=1:6
        if i>4
            j=3;
        elseif i>2
            j=2;
        else
            j=1;
        end
        ves = Labels{loci(i),2};
        ves = str2num(ves);
        if length(ves)>1
            ves = Labels{roots(i),3};
            ves = str2num(ves);
            ves=ves(1);
        end
        LOC = Labels{loci(i),3};
        LOC=str2num(LOC);
        if length(LOC)>1
            temp=LOC;
            LOC=temp(2);
            ves=temp(1);
        end
        if ves>0
            [idx1,~]=find(BranchList(:,4)==ves);
            Data=BranchList(idx1,:);
            [idx2,~]=find(Data(:,5)==LOC);
            VesLoc=Data(idx2,:);
            [idx3,~]=find(PI_scat(:,3,j)==VesLoc(6));
            EndPI(i,:)=mean(PI_scat((idx3-2):(idx3+2),:,j));
            PI(1,loci(i))=mean(PI_scat((idx3-2):(idx3+2),2,j));
        switch params.FlowType
            case 'Local'
                Flows(:,loci(i))=mean(FlowData((VesLoc(6)-2):(VesLoc(6)+2),:));
                FlowErr(:,loci(i))=std(FlowData((VesLoc(6)-2):(VesLoc(6)+2),:));
        end
        else
            EndPI(i,:)=[-1 -1 -1 -1];
        end
    end
    DF=[];
    for k=1:3
        Matt=EndPI((1+(k-1)*2):(2+(k-1)*2),2);
        [a,~]=find(Matt(:,1)>0);
        if length(a)<2
            DF(k,1)=Matt(a,:)./StartPI(k,2);
        else
            DF(k,1)=mean(EndPI((1+(k-1)*2):(2+(k-1)*2),2))./StartPI(k,2);
        end
    end
    DF=DF';
    if params.SaveData==1
        save(fullfile(path2data,'DFdata.mat'),'DF','EndPI','StartPI');
    end
end