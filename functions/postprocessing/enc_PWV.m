function [PWV,R,RawPWV]=enc_PWV(data_struct,PI_scat,time,Labels,params)
    PWV=zeros([1 15]);
    R=zeros([1 12]);
    RawPWV={};
    ExPWV={};
    Flows=data_struct.flowPulsatile_val;
    if params.PWV(1)==1
        %=======================================
        %Process Bjornfoot 2021 Individual Roots Bjornfoot Weights
        %=======================================
        for root=1:3
            Vals=squeeze(PI_scat(:,[1 3 4 5],root));
            [row,~]=find(Vals(:,2)==0);
            Vals(row,:)=[];
            if ~isempty(Vals(:,1))
                [pwv,A]=enc_PWV_WO(Flows,Vals,time,0,params);
                PWV(1,root) = pwv;
                W{root}=A;
            end
        end
    end
    if params.PWV(2)==1
        %========================================
        %Process Fielding (Xcor) Individual Roots Bjornfoot Weights
        %========================================
        for root=1:3
            Vals=squeeze(PI_scat(:,[1 3 4 5],root)); %D, ID, Q, A
            [row,~]=find(Vals(:,2)==0);
            Vals(row,:)=[];
            if ~isempty(Vals(:,1))
                [pwv,r,Raw1,Ex1]=enc_PWV_XCor(Vals,data_struct,Labels,time,0,W{root},params,root);
                RawPWV{1,root}=Raw1;
                ExPWV{1,root}=Ex1;
                PWV(1,root+3) = pwv;
                R(1,root+3) = r;
            end
        end
    end
    if params.PWV(3)==1
        %===================================
        %Process Markl(TTU) Individual Roots Bjornfoot Weights
        %===================================
        for root=1:3
            Vals=squeeze(PI_scat(:,[1 3 4 5],root)); %D, ID, Q, A
            [row,~]=find(Vals(:,2)==0);
            pwvs=PWV([root (root+3)]);
            pwvs(pwvs<0)=[];
            pwvlim=min(pwvs)-0.5;
            Vals(row,:)=[];
            if ~isempty(Vals(:,1))
                [pwv,r,Raw2,Ex2]=enc_PWV_TTU(Vals,data_struct,Labels,time,0,W{root},params,root,pwvlim);
                RawPWV{2,root}=Raw2;
                ExPWV{2,root}=Ex2;
                PWV(1,root+6) = pwv;
                R(1,root+6) = r;
            end
        end
    end


    if params.PWV(4)==1
        %=======================================
        %Process Bjornfoot 2021 Individual Roots Dempsey Weights
        %=======================================
        for root=1:3
            Vals=squeeze(PI_scat(:,[1 3 4 5],root));
            [row,~]=find(Vals(:,2)==0);
            Vals(row,:)=[];
            if ~isempty(Vals(:,1))
                [pwv,~]=enc_PWV_WO(Flows,Vals,time,1,params);
                PWV(1,root+9) = pwv;
            end
        end
    end

    if params.PWV(5)==1
        %========================================
        %Process Fielding (Xcor) Individual Roots Dempsey Weights
        %========================================
        for root=1:3
            Vals=squeeze(PI_scat(:,[1 3 4 5],root)); %D, ID, Q, A
            [row,~]=find(Vals(:,2)==0);
            Vals(row,:)=[];
            if ~isempty(Vals(:,1))
                [pwv,r,Raw3,Ex3]=enc_PWV_XCor(Vals,data_struct,Labels,time,1,[],params,root);
                RawPWV{3,root}=Raw3;
                ExPWV{3,root}=Ex3;
                PWV(1,root+12) = pwv;
                R(1,root+12) = r;
            end
        end        
    end
    if params.PWV(6)==1
        %=======================================
        %Process Fielding (TTU) Individual Roots Dempsey Weights
        %=======================================
        for root=1:3
            Vals=squeeze(PI_scat(:,[1 3 4 5],root)); %D, ID, Q, A
            [row,~]=find(Vals(:,2)==0);
            pwvs=PWV([root (root+3)+9]);
            pwvs(pwvs<0)=[];
            pwvlim=min(pwvs)-0.5;
            Vals(row,:)=[];
            if ~isempty(Vals(:,1))
                [pwv,r,Raw4,Ex4]=enc_PWV_TTU(Vals,data_struct,Labels,time,1,[],params,root,pwvlim);
                RawPWV{4,root}=Raw4;
                ExPWV{4,root}=Ex4;
                PWV(1,root+15) = pwv;
                R(1,root+15) = r;
            end
        end
        if params.PltFlag==1
            plot_PWVfit(RawPWV)
            if params.SaveData==1
                path2data=string(fullfile(params.data_dir,'derivatives\QVT',params.subject));
                saveas(gcf,fullfile(path2data,'PWVFit2.jpg'))
                close(gcf)
            end    
        end
        if params.SaveData==1
            path2data=string(fullfile(params.data_dir,'derivatives\QVT',params.subject));
            save(fullfile(path2data,'RawPWV2.mat'),'RawPWV','ExPWV')
        end    
    end
end
