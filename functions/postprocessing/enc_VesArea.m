function [Area] = enc_VesArea(data_struct,Labels,path2data,params)
    BranchList=data_struct.branchList;
    AreaVals=data_struct.area_val;
    BranchList=[BranchList [1:length(BranchList)]'];
    Area=zeros([1 9]);
    [Locs]=get_SampleLocs(data_struct,Labels);
    for i=1:9
        if Locs(i)>0
            Area(1,i)=mean(AreaVals(((Locs(i)-2):(Locs(i)+2)),1));
        end
    end
    if params.SaveData==1
        save(fullfile(path2data,'Area.mat'),'Area')
    end
end