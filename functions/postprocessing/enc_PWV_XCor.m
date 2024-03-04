function [PWV,SE]=enc_PWV_XCor(Vals,data_struct,Labels,time,tag,A,params,root)
    Flows=data_struct.flowPulsatile_val;
    BranchList=data_struct.branchList;
    Qual=data_struct.StdvFromMean;
    BranchList=[BranchList [1:length(BranchList(:,1))]'];
    D=Vals(:,1)./1000; %Distance (m)
    F=Flows(Vals(:,2),:); %Flow Traces
    Q=Vals(:,3); %Quality
    IDX=Vals(:,2); %Branchlist
    %% This section just grabs the ICA point to initialise D=0
    % It's a lot of effort, originally I used the first point, but in 1
    % case it was noisy and caused issues in sorting ttu, so this is more
    % rubst.
    NoP=0; roots=[1 2 9];
    LOC = Labels{roots(root),3};
    LOC = str2num(LOC);
    ves = Labels{roots(root),2};
    ves = str2num(ves);
    if length(ves)>1
        vest = Labels{roots(root),3};
        vest = str2num(vest);
        if ~isempty(vest)
            ves = vest(1);
        else
            ves = ves(1);
            NoP=1;
        end
    end
    if length(LOC)>1
        temp=LOC;
        LOC=temp(2);
        ves=temp(1);
    end
        [idx1,~]=find(BranchList(:,4)==ves);
    if NoP==1
        for i=1:length(idx1)
            if Qual(idx1(i))>params.thresh
                LOC=i;
                break
            end
        end
    end
    Data=BranchList(idx1,:);
    [idx2,~]=find(Data(:,5)==LOC);
    VesLoc=Data(idx2,6);
    [VesLoc,~]=find(IDX==VesLoc);
    time3= [(time-time(end)) (time) (time+time(end))];
    tres=time(1);

    %% Set up first curve for correlation to the rest
    timeINT=[0:20/500:(20)].*tres; %Interpolate time (Based on Rivera et al 2018)
    timeINT=timeINT(1:(end-1));
    [defCurve]=interp1(time3,[F(VesLoc,:) F(VesLoc,:) F(VesLoc,:)],timeINT,'spline');
    D(VesLoc,:)=[]; %Clear the test wave from data
    Q(VesLoc,:)=[];
    F(VesLoc,:)=[];
    ttu=[];
    %ttu(1,1)=0;
    if tag==1
        [row,~]=find(Q<params.thresh); %Ignore low quality points
        D(row,:)=[];
        Q(row,:)=[];
        F(row,:)=[];
        Q=(Q-params.thresh)./(4-params.thresh);
        W=Q;
    else
        A(VesLoc,:)=[];
        W=A;
    end
    %% This is the Xcor for the 
    for csa = 1:length(D)
        [csaFlowINT]=interp1(time3,[F(csa,:) F(csa,:) F(csa,:)],timeINT,'spline');
        [rho]=slidingxCor(csaFlowINT,defCurve);
        [idx1,~]=find(rho==max(rho(:,1)));
        if abs(timeINT(idx1)-max(timeINT))<timeINT(idx1)
            ttu(csa,1)=timeINT(idx1)-max(timeINT);
            flag(csa)=1;
        else
            ttu(csa,1)=timeINT(idx1);
        end
    end

    %% Delete outliers (happens, noisy data etc)
    TF = isoutlier(ttu,'gesd');
    D2=D(TF);
    ttu2=ttu(TF);
    D(TF)=[];
    ttu(TF)=[];
    W(TF)=[];
    %% Fit PWV
    [mdl,~] = fit_linXYData(D,ttu,W);
    pwv = 1./table2array(mdl.Coefficients(2,1));
    SE = 1./table2array(mdl.Coefficients(2,2));
    if (pwv > 0) && (pwv < 30)
        PWV = pwv;
    else
        PWV = 0;
    end
    Slope=table2array(mdl.Coefficients(2,:));
    R2=mdl.Rsquared.Adjusted;
    if params.PltFlag==1
        subplot(1,3,root)
        scatter(D,ttu,'o','MarkerFaceColor','c','MarkerfaceAlpha',0.2,'MarkerEdgeAlpha',0.3,'MarkerEdgeColor','k')
        hold on
        scatter(D2,ttu2,'r*','MarkerEdgeAlpha',0.3)
        hold on
        plot([min(D) max(D)], table2array(mdl.Coefficients(2,1)).*[min(D) max(D)]+table2array(mdl.Coefficients(1,1)),'k-.','LineWidth',2);
        xlabel('d (m)')
        ylabel('XCor time (s)')
        text(0.1,0.9,strcat('R^2=',num2str(R2,'%0.2f'),',p<',num2str(Slope(4),'%1.3f')),'Units','normalized','FontSize',6)
        ylim([-0.5 0.5])
    end
end