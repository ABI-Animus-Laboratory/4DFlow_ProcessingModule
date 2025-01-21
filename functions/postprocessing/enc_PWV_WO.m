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
    %%
    % Start by set up our optimisation problem using
    %fmincon. Reason for fmincon is to avoid nonphysiological velocities,
    %so we'll constrain the search a bit. 
    InitialGuess=[mean(F) 10]; %mean flow trace and 10m/s pwv, per paper
    lb=[(InitialGuess(1:end-1)-2) -10]; %Just constraint, no way global waveform is outside 2 after normalisation
    ub=[(InitialGuess(1:end-1)+2) 500] ;
    options = optimoptions("fmincon",'Display','off','TolCon', 1e-7, 'TolX', 1e-7, 'TolFun', 1e-7,'DiffMinChange', 1e-3);
    [Results]=fmincon(@(x)cost_WO(x,F,D,W,time),InitialGuess,[],[],[],[],lb,ub,[],options);
    
    % tres=time(1);
    % fun1=@(inParams)PWVest3_share(inParams,D,F,tres,W); 
    % pwv0 = 10; %initial guess of pwv
    % mean_flow = mean(F); %initial guess of waveform
    % initialGuess=[mean_flow, pwv0]; 
    % %This is the function below for cost function, check here
    % options = optimset('Display','off', 'TolCon', 1e-7, 'TolX', 1e-7, 'TolFun', 1e-7,'DiffMinChange', 1e-3);
    % [Results] = fminunc(fun1,initialGuess, options);%,options1);
    PWV = Results(end);
end