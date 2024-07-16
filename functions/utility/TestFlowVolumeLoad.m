clear;clc;
%Load Magnitude image
[MAG,~] = shuffleDCM3('C:\Users\sdem348\Desktop\testdata\sourcedata\DTDS_sub-001_CTRL01\Ax_4DFLOW_05__Anatomy_700',0);
MAG = mean(MAG,4);
%% 
for i=1:4:length(MAG(1,1,:))
    figure(1)
    Image=squeeze(MAG(:,:,i));
    imshow(Image,[0 1900])
    pause(0.1)
end