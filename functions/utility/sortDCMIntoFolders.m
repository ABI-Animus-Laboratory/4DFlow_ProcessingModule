clear
clc
path2data='C:\Users\sdem348\Desktop\A';
DIR=dir(path2data);
DIR(1:2)=[];
Names{1,1}={};
count=2;
Type=cell(length(DIR),2);
for i=1:length(DIR)
    series='';
    try INFO=dicominfo(fullfile(path2data,DIR(i).name));
        series=INFO.SeriesDescription;
    end
    if ~isempty(series)
        flag=strcmp(series,Names);
        if sum(flag)==0
            Names{count,1}=series;
            count=count+1;
            Type{i,1}=count-2;
            Type{i,2}=fullfile(path2data,DIR(i).name);
        else
            [a,~]=find(flag==1);
            Type{i,1}=a-1;
            Type{i,2}=fullfile(path2data,DIR(i).name);
        end
    end
    if mod(i,250)==0
        fprintf('%2.0f percent complete\n',100*i/length(DIR))
    end
end
Names(1)=[];
for i=1:length(Names)
    Name2 = erase(Names{i},":");
    try mkdir(fullfile(path2data,Name2))
    end
    Names{i,1}=Name2;
end
for i=1:length(DIR)
    if ~isempty(Type{i,1})
        movefile(Type{i,2},fullfile(path2data,Names{Type{i,1}}))
    end
end

