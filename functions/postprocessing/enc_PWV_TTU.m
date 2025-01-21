function [PWV,SE,Raw,Ex]=enc_PWV_TTU(Vals,data_struct,Labels,time,tag,A,params,root,pwvlim)
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
    %% This section just grabs the vessel initialise the search window
    % It's a lot of effort, originally I used the first point, but in 1
    % case it was noisy and caused issues in sorting ttu Xcor, so this is more
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
    %% Weights preprocessing
    if tag==0 %Equal weight
        W=ones(size(Q));
    elseif tag==1
        [row,~]=find(Q<params.thresh); %Ignore low quality points
        D(row,:)=[];
        Q(row,:)=[];
        F(row,:)=[];
        Q=(Q-params.thresh)./(4-params.thresh);
        W=Q;
    elseif tag==2 %Use Bjornfot weights
        A=A(:)./max(A); % Normalise Bjornfoot Weights
        W=A;
    else
        fprintf('\n Unknown weight function pointer\n')
    end
    %% Set up first curve for TTU search window
    timeINT=[0:20/500:(20)].*tres; %Interpolate time (Based on Rivera et al 2018), assumes 20 cardiac cycles
    timeINT=timeINT(1:(end-1)); %last point = first point, so remove last
    [initCurve]=interp1(time3,[F(VesLoc,:) F(VesLoc,:) F(VesLoc,:)],timeINT,'spline');
    initaccel=diff(initCurve); %acceleration
    [~,initdt]=max(initaccel); %index of maximum accel
    zerotime=timeINT(initdt);
    %maximum distance anticipated to travel
    maxD=max(D); %maximum depth;
    maxdt=maxD./pwvlim; %assuming minimum PWV (1), calc max shift in time;
    trange=round(maxdt./(timeINT(2)-timeINT(1))); %index range for search window
    maxidx=length(timeINT)-1; %minus 1 because acceleartion will loose that point
    twindow=[];
    %Stich the index seach window
    if (initdt-trange)<1
        p1=1:(initdt+trange);
        p2=(maxidx-(initdt-trange)):maxidx;
        twindow=[p1,p2];
    elseif (initdt+trange)>maxidx
        p1=(initdt-trange):maxidx;
        p2=1:((initdt+trange)-maxidx);
        twindow=[p1,p2];
    else
        twindow=(initdt-trange):(initdt+trange);
    end
    %% This is the TTU
    ttu=[];
    for csa = 1:length(D)
        [csaFlowINT]=interp1(time3,[F(csa,:) F(csa,:) F(csa,:)],timeINT,'spline');
        accel=diff(csaFlowINT);
        %Section to pick the closest max acceleration
        [~,locs] = findpeaks(accel,timeINT(1:(end-1)));
        locs2=[locs (locs+20.*tres)];
        [~,dtidx]=min(abs(locs2-zerotime));
        dt=locs2(dtidx);
        if abs(dt-max(timeINT))<dt
            ttu(csa,1)=dt-max(timeINT) +max(timeINT)-zerotime;
            flag(csa)=1;
        else
            ttu(csa,1)=dt+max(timeINT)-zerotime;%-zerotime;
        end
        % windowaccel=accel(twindow);
        % [~,wdt]=max(windowaccel);
        % dt=twindow(wdt);
        % if abs(timeINT(dt)-max(timeINT))<timeINT(dt)
        %     ttu(csa,1)=timeINT(dt)-max(timeINT) +max(timeINT)-zerotime;
        %     flag(csa)=1;
        % else
        %     ttu(csa,1)=timeINT(dt)+max(timeINT)-zerotime;%-zerotime;
        % end
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
    PWV = pwv;
end