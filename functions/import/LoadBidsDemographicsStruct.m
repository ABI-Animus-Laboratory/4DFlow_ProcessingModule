% This function will load demographics for your study cohort if they're
% stored in a BIDS formatted sourcedata directory. It reads the first DICOM
% file for each subject and collects demographics from DICOM header. 
%% Initialization
path2bids='C:\Users\sdem348\Desktop\Dempsey2023MultiRes_Cohort';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Don't change below %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Or do
path2subs=fullfile(path2bids,'sourcedata');
DIR=dir(path2subs);
Demos=struct;
for i=3:length(DIR(:))
    path2patient=fullfile(path2subs,DIR(i).name);
    DIR2=dir(path2patient);
    DIR3=dir(fullfile(path2patient,DIR2(3).name));
    filename=DIR3(3).name;
    INFO=dicominfo(fullfile(fullfile(path2patient,DIR2(3).name),filename));
    Demos.Name(i-2,1)={DIR(i).name};
    Demos.SubName(i-2,1)={DIR(i).name};
    Demos.Age(i-2,1)=str2num(INFO.PatientAge(2:3));
    Demos.Sex(i-2,1)={INFO.PatientSex};
    Demos.Weight(i-2,1)=INFO.PatientWeight;
    Demos.RepT(i-2,1)=INFO.RepetitionTime;
    Demos.EchoT(i-2,1)=INFO.EchoTime;
    Demos.Bandwidth(i-2,1)=INFO.PixelBandwidth;
    Demos.ImFreq(i-2,1)=INFO.ImagingFrequency;
    Demos.FlipA(i-2,1)=INFO.FlipAngle;
    Demos.HR(i-2,1)=INFO.HeartRate;
    Demos.Venc(i-2,1)=INFO.Private_0019_10cc;
    Demos.Scale(i-2,1)=INFO.Private_0019_10e2;
end
save(fullfile(path2bids,'derivatives','QVT','population','Demographics.mat'),'Demos')