clc;clear;
%This function will rename exported DICOM folders by their scan name in the
%DICOM metadata. Good for visualising during folder exploration, but
%unecessary to any processing. 
ExamN='0.8mm';
path2data=fullfile('C:\Users\sdem348\Desktop\MultiResTest\sourcedata');
DIR=dir(fullfile(path2data,ExamN));
%DIR=dir('C:\Users\sdem348\Desktop\MultiResTest\sourcedata\')
EXP='s\d*.*';
count=1;
for i=3:length(DIR)
    foldername1=DIR(i).name;
    skip=0;
    if foldername1(end-2:end)=='zip'
        try 
            unzip(fullfile(path2data,ExamN,foldername1),fullfile(path2data))
            foldername1=foldername1(1:end-4);
        catch
            skip=1;
        end
    end
    if skip==0
        if regexp(foldername1,EXP) == 1
            DIR2=dir(fullfile(path2data,ExamN,foldername1));
            path2dcms=fullfile(path2data,ExamN,foldername1);
            DIR3=dir(path2dcms);
            try
                INFO=dicominfo(fullfile(path2dcms,DIR3(3).name));
                Name=INFO.SeriesDescription;
                Name = erase(Name,":");
                    try
                        movefile(path2dcms,fullfile(path2data,ExamN,'Unpacked',Name))
                        catch
                    end
            catch
            end
        end
    else
        missed{count}=foldername1;
        count=count+1;
    end
end
