function [PWV,SE,Raw,Ex]=enc_PWV_TTU(Vals,data_struct,time,tag,A,params)
    Flows=data_struct.flowPulsatile_val;
    D=Vals(:,1)./1000; %Distance (m)
    F=Flows(Vals(:,2),:); %Flow Traces
    Q=Vals(:,3); %Quality
    time3= [(time-time(end)) (time) (time+time(end))];
    tres=time(1);
    %% Set up first curve for correlation to the rest
    timeINT=[0:20/500:(20)].*tres; %Interpolate time (Based on Rivera et al 2018)
    timeINT=timeINT(1:(end-1));
    ttu=[];
    if tag==1
        [row,~]=find(Q<params.thresh); %Ignore low quality points
        D(row,:)=[];
        Q(row,:)=[];
        F(row,:)=[];
        Q=(Q-params.thresh)./(4-params.thresh);
        W=Q;
    else
        W=A;
    end
    %% This is the TTU
    for csa = 1:length(D)
        [csaFlowINT]=interp1(time3,[F(csa,:) F(csa,:) F(csa,:)],timeINT,'spline');
        accel=diff(csaFlowINT);
        [~,dt]=max(accel);
        if abs(timeINT(dt)-max(timeINT))<timeINT(dt)
            ttu(csa,1)=timeINT(dt)-max(timeINT);
            flag(csa)=1;
        else
            ttu(csa,1)=timeINT(dt);
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
    if (pwv > 0) % && (pwv < 30)
        PWV = pwv;
    else
        PWV = -1;
    end
end