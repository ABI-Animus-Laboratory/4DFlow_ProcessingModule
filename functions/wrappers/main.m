%% Running a Directory
%==================================================
% Running a BIDS processed derivates folder for PI, PI_DF, PI_TC, PWV is below
%==================================================
% This function is designed to run assuming you store your data in BIDS 
% format. If not, modify to run a folder or what not, BIDS is much easier
clear;clc;
path2bids='C:\Users\sdem348\Desktop\HERMRI';
params=init_params(path2bids);
params.SaveData=1;%Save Interim Data
params.PltFlag=1; %Make plots
params.PWV=[1 1 1 1 1 1 1 1 1]; %Compute all PWVs
Results=struct;
for i=12:20
    subject=strcat('sub-',num2str(i,'%03.0f'));
    params.subject=subject;
    fprintf(strcat('Now Processing Case:',num2str(i),'\n'))
    path2data=string(fullfile(params.data_dir,'derivatives\QVT',subject));
    if exist(path2data,'dir')==7
        [data_struct,Labels,~]=import_QVTplusData(path2data);
        [PI_scat]=enc_PITC_process(data_struct,Labels,path2data,params,[]);
        [PITC,globPI] = enc_PITC_fit(PI_scat,path2data,params);
        [DF,PI,LocFlows,FlowErr,D] = enc_PI_DF_Flows(PI_scat,data_struct,Labels,path2data,params);
        [Area] = enc_VesArea(data_struct,Labels,path2data,params);
        [time,Flow,FlowErrVes]=enc_HQVesselFlows(data_struct,Labels,params);
        [PWV,~,~]=enc_PWV(data_struct,PI_scat,time,Labels,params);
        [AllVals,Qvel] =enc_VelocityArea(data_struct,PI_scat,path2data,params);
        
        Results.Vel(i,:)=AllVals; % mean max, mean veloctiy, and area
        Results.Area(i,:)=Area; %Landmark cross sectional area, 
        Results.PI(i,:)=[globPI PITC(end,:) PI]; %Landmark standard pulsatility
        Results.Flow(i,:)=[mean(LocFlows)]; %Landmark vessel mean flow data
        Results.Flow2{i}=LocFlows; %Landmark vessel flow data
        Results.Flow2err{i}=FlowErr; %Landmark vessel flow data
        Results.PITC(i,:)=PITC(1,:); %pulsatility tranmission
        Results.PITCerr(i,:)=PITC(4,:); %pulsatility transmission slope CI (1sigma)
        Results.DF(i,:)=DF; %damping factor
        Results.D(i,:)=D; %damping factor
        Results.PWV(i,:)=PWV;%pulse wave velocity (time consuming)
    else
    end
end
save(fullfile(params.data_dir,'derivatives\QVT\population\Results.mat'),"Results")
% %% Running 
% %==================================================
% % Running a single instance of the post processing for PI, PI_DF, PI_TC, PWV is below
% %==================================================
% clear;clc;
% path2data='C:\Users\sdem348\Documents\MATLAB\CHM\QVTplus\testdata'; %should have the  LabelsQVT and qvtData inside
% params=init_params(path2data);
% params.PltFlag=1; %Plot your results
% params.SaveData=1; %Save results and plots
% params.rerun=1; %rerun PITCH algorithm, or use stored data
% Results=struct;
% [data_struct,Labels]=import_QVTplusData(path2data);
% [PI_scat]=enc_PITC_process(data_struct,Labels,path2data,params,[]);
% [PITC,globPI] = enc_PITC_fit(PI_scat,path2data,params);
% [DF,PI,LocFlows,LocFlowErr] = enc_PI_DF_Flows(PI_scat,data_struct,Labels,path2data,params);
% [time,Flow,FlowErr]=enc_HQVesselFlows(data_struct,Labels,params);
% close all
% Results.PITC=PITC(1,:);
% Results.PI=[globPI PITC(end,:) PI];
% Results.DF=DF;
% Results.Flow=[mean(LocFlows)];
% save(fullfile(path2data,'ResultsALL.mat'),"Results")
