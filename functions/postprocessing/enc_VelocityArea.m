function [AllVals,QVal] =enc_VelocityArea(data_struct,PI_scat,path2data,params)
    if params.PltFlag==1
        figure()
    end
    AllVals=[];
    for i=1:3
        Vels=data_struct.maxVel_val;
        VelsM=data_struct.velMean_val;
        Areas=data_struct.area_val;
        Vals=squeeze(PI_scat(:,:,i));
        idx=find(Vals(:,1)==0); %Different roots have diff lengths, so delete any zero tails.
        Vals(idx,:)=[];
        idx=find(Vals(:,4)<2.5); %Ignore low quality data
        Vals(idx,:)=[];
        idx=find(Vals(:,1)>100); %Ignore data beyond 100mm (So get the initial network average)
        Vals2=Vals;
        Vals2(idx,:)=[];
        AllVals([(i) (i+3)])=[mean(Vels(Vals2(:,3))) std(Vels(Vals2(:,3)))];
        AllVals([(i+6) (i+3+6)])=[mean(VelsM(Vals2(:,3))) std(VelsM(Vals2(:,3)))];
        AllVals([(i+12) (i+3+12)])=[mean(Areas(Vals2(:,3))) std(Areas(Vals2(:,3)))];
        QVal([(i) (i+3)])=[mean(Vals2(:,4)) std(Vals2(:,4))];
        if params.PltFlag==1
            subplot(2,3,i)
            plot(Vals(:,1),Vels(Vals(:,3)),'k.')
            xlabel('d (mm)')
            ylabel('max CSA Velocity (cm/s) (mm)')
            ylim([0 100])
            subplot(2,3,i+3)
            plot(Vals(:,1),VelsM(Vals(:,3)),'k.')
            xlabel('d (mm)')
            ylabel('\mu CSA Velocity (cm/s) (mm)')
            ylim([0 50])
        end
    end
    if params.PltFlag==1
        if params.SaveData==1
            saveas(gcf,fullfile(path2data,'VelPlot.jpg'))
        end
        close
    end
end