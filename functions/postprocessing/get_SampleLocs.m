function [Locs]=get_SampleLocs(data_struct,Labels)
    BranchList=data_struct.branchList;
    BranchList=[BranchList [1:length(BranchList)]'];
    Locs=zeros([1 9]);
    for i=1:9
        LOC = Labels{i,3};
        LOC = str2num(LOC); 
        if length(LOC)>=1 %Then a Location was stored
            ves = Labels{i,2}; %default grab the vessel
            ves = str2num(ves);
            if length(ves)>1 %If multiple vessels in array
                ves = Labels{i,3};
                ves = str2num(ves);
                ves = ves(1); %Store first vessel
            end
            if length(LOC)>1 %Separate vessel and location
                temp=LOC;
                LOC=temp(2); %Assign only second location as loc
                ves=temp(1); %Assign vessel
            end
            [idx1,~]=find(BranchList(:,4)==ves);
            Data=BranchList(idx1,:);
            [idx2,~]=find(Data(:,5)==LOC+1); %Plus 1 because GUI numbering starts from zero but branches count from 1.
            VesLoc=Data(idx2,:);
            Locs(i)=VesLoc(6);
        end
    end
end
