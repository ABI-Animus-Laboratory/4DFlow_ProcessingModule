function [PWV,A]=enc_PWV_WO(Flows,Vals,time,tag,params)
    D=Vals(:,1)./1000; %get distance into meters
    F=Flows(Vals(:,2),:);
    Q=Vals(:,3);
    A=Vals(:,4);
    for flow=1:length(F(:,1))
        Ftemp=F(flow,:)./(A(flow,1));
        Ftemp=Ftemp-mean(Ftemp); % remove mean.
        Scaling=1./std(Ftemp); 
        F(flow,:)=Ftemp.*Scaling;  % Normalise by standard deviation and update.
        A(flow,1)=A(flow,1)./(Scaling.^2); % Bjornfoot Weights
    end
    A=A(:)./max(A); % Normalise Bjornfoot Weights
    if tag==1
        [row,~]=find(Q<params.thresh); %Ignore low quality points
        D(row,:)=[];
        Q(row,:)=[];
        F(row,:)=[];
        Q=(Q-params.thresh)./(4-params.thresh); %Normalise weights, not needed, but expressed.
        W=Q;
    else
        W=A;
    end
    tres=time(1);
    fun1=@(inParams)PWVest3_share(inParams,D,F,tres,W); 
    pwv0 = 10; %initial guess of pwv
    mean_flow = mean(F); %initial guess of waveform
    initialGuess=[mean_flow, pwv0]; 
    %This is the function below for cost function, check here
    options = optimset('Display','off', 'TolCon', 1e-7, 'TolX', 1e-7, 'TolFun', 1e-7,'DiffMinChange', 1e-3);
    lb=[-5.*ones([1 20]) -200];
    ub=[5.*ones([1 20]) 200];
    %[Results] = fmincon(fun1,initialGuess,[],[],[],[],lb,ub,[],options);
    [Results] = fminunc(fun1,initialGuess, options);%,options1);
    if Results(end)<0
        PWV = -1;
    else
        PWV = Results(end);
    end
end