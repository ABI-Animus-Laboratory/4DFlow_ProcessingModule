% This function will load demographics for your study cohort if they're
% stored in a BIDS formatted sourcedata directory. It reads the first DICOM
% file for each subject and collects demographics from DICOM header. 
%% Initialization
clear
clc
path2bids='C:\Users\sdem348\Desktop\MultiResTestISO';
%path2bids='C:\Users\sdem348\Desktop\HyperKatTest';
path2bids='Z:\personal\Sergio\Dempsey2024PITC_Cohort';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Don't change below %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Or do
path2subs=fullfile(path2bids,'sourcedata');
DIR=dir(path2subs);
Demos=struct;
for i=3:length(DIR(:))
    path2patient=fullfile(path2subs,DIR(i).name); %4D flow folder
    DIR2=dir(path2patient); %Dicom folder
    DIR3=dir(fullfile(path2patient,DIR2(3).name));
    filename=DIR3(3).name;
    INFO=dicominfo(fullfile(fullfile(path2patient,DIR2(3).name),filename));
    try
    	Demos.Name(i-2,1)={DIR(i).name};
    end
    try
        Demos.SubName(i-2,1)={DIR(i).name};
    end
    try
        Demos.Age(i-2,1)=str2num(INFO.PatientAge(2:3));
    end
    try
        Demos.Sex(i-2,1)={INFO.PatientSex};
    end
    try
        Demos.Weight(i-2,1)=INFO.PatientWeight;
    end
    try
        Demos.RepT(i-2,1)=INFO.RepetitionTime;
    end
    try
        Demos.EchoT(i-2,1)=INFO.EchoTime;
    end
    try
        Demos.Bandwidth(i-2,1)=INFO.PixelBandwidth;
    end
    try
        Demos.ImFreq(i-2,1)=INFO.ImagingFrequency;
    end
    try
        Demos.FlipA(i-2,1)=INFO.FlipAngle;
    end
    try
        Demos.HR(i-2,1)=INFO.HeartRate;
    end
    try
        Demos.Venc(i-2,1)=INFO.Private_0019_10cc;
    end
    try
        Demos.Scale(i-2,1)=INFO.Private_0019_10e2;
    end
    try
        Demos.InPlaneRes(i-2,1:2)=INFO.PixelSpacing;
    end
    try
        Demos.Spacing(i-2,1)=INFO.SpacingBetweenSlices;
    end
end
save(fullfile(path2bids,'derivatives','QVT','population','Demographics.mat'),'Demos')