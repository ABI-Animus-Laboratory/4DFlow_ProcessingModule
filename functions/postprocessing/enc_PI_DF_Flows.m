function [DF,PI,Flows,FlowErr,D] = enc_PI_DF_Flows(PI_scat,data_struct,Labels,path2data,params)
    % Load Necessities from labels and processed data
    load(fullfile(path2data,'RawPITC.mat'));
    BranchList=data_struct.branchList;
    BranchList=[BranchList [1:length(BranchList)]'];
    FlowData=data_struct.flowPulsatile_val;
    PIData=data_struct.PI_val;
    order=[1,2,9,3,5,4,6,7,8]; %L_ICA R_ICA BA LMCA LACA RMCA RACA LPCA RPCA
    DFPI=-1.*ones([9,5]);
    PI=zeros([1 9]);
    D=zeros([1 9]);
    Flows=zeros([20 9]); %%assuming 20 cardiac phases
    FlowErr=zeros([20 9]); %%assuming 20 cardiac phases
    [Locs]=get_SampleLocs(data_struct,Labels);
    for i=1:9
        loc=Locs(order(i));
        if i>7
            j=3;
        elseif i>5
            j=2;
        elseif i>3
            j=1;
        else
            j=i;
        end
        if loc>0
            PI(1,order(i))=mean(abs(PIData((loc-2):(loc+2)))); 
            switch params.FlowType
                    case 'Local'
                        Flows(:,order(i))=mean(FlowData((loc-2):(loc+2),:));%5 point mean flow
                        FlowErr(:,order(i))=std(FlowData((loc-2):(loc+2),:));%5 point mean flow
                end
            [idx3,~]=find(PI_scat(:,3,j)==loc);
            if ~isempty(idx3)
                D(1,order(i))=mean(PI_scat((idx3-2):(idx3+2),1,j));
                DFPI(order(i),:)=mean(abs(PI_scat((idx3-2):(idx3+2),:,j)));
            end
        end
    end
    StartPI=DFPI([1 2 9],:);
    EndPI=DFPI([3 5 4 6 7 8],:);
    DF=[0 0 0];
    for k=1:3
        Matt=EndPI((1+(k-1)*2):(2+(k-1)*2),2);
        [a,~]=find(Matt(:,1)>0);
        if StartPI(k,2)>0.1
            if length(a)==1
                DF(1,k)=Matt(a,:)./StartPI(k,2);
            elseif length(a)==2
                DF(1,k)=mean(EndPI((1+(k-1)*2):(2+(k-1)*2),2))./StartPI(k,2);
            end
        end
    end
    if params.SaveData==1
        save(fullfile(path2data,'DFdata.mat'),'DF','EndPI','StartPI');
    end
end