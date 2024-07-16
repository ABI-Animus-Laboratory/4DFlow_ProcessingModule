function [PWV,SE,Raw,Ex]=enc_PWV_XCor(Vals,data_struct,Labels,time,tag,A,params,root)
    Flows=data_struct.flowPulsatile_val;
    BranchList=data_struct.branchList;
    Qual=data_struct.StdvFromMean;
    BranchList=[BranchList [1:length(BranchList(:,1))]'];
    D=Vals(:,1)./1000; %Distance (m)
    F=Flows(Vals(:,2),:); %Flow Traces
    Q=Vals(:,3); %Quality
    IDX=Vals(:,2); %Branchlist
    time3= [(time-time(end)) (time) (time+time(end))];
    tres=time(1);
    %% This section just grabs the ICA point to initialise D=0
    % It's a lot of effort, originally I used the first point, but in 1
    % case it was noisy and caused issues in sorting ttu, so this is more
    % rubst.
    NoP=0; roots=[1 2 9];
    [Locs]=get_SampleLocs(data_struct,Labels);
    if Locs(roots(root))>0
        [VesLoc,~]=find(IDX==Locs(roots(root)));
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
        W2=W(TF);
        D(TF)=[];
        ttu(TF)=[];
        W(TF)=[];
        %% Fit PWV
        Raw=[D,ttu,W];
        Ex=[D2,ttu2,W2];
        [mdl,~] = fit_linXYData(D,ttu,W);
        pwv = 1./table2array(mdl.Coefficients(2,1));
        SE = 1./table2array(mdl.Coefficients(2,2));
        if (pwv > 0)% && (pwv < 30)
            PWV = pwv;
        else
            PWV = -1;
        end
    else
        PWV=-1;SE=0;Raw=[0,0,0];Ex=[0,0,0];
    end
end