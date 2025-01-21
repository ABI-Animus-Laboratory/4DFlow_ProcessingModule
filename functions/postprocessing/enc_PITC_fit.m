function [PITC,globalPI] = enc_PITC_fit(PI_scat,path2data,params)
    %% Load Processed data
    [~,~,rootNum]=size(PI_scat);
    %===========================================
    % Crop Data by Quality>Thresh as a Baseline
    %===========================================
    ResCell=cell([1 3]); %This is what we store thresholded values into
    thresh=params.thresh; %Quality Threshold
    for i=1:rootNum %three roots
        [idx,~]=find(PI_scat(:,4,i)>thresh); %Find all > Q vals
        Vals=squeeze(PI_scat(idx,:,i)); %dimm reduction
        ResCell(i)={abs(Vals)}; %Save (note, absolute value in case flow direction was incorrectly assigned (happens ~0.5% of time)
        [idx2,~]=find(PI_scat(:,4,i)<=thresh); %Find all < Q vals
        ExVals=squeeze(PI_scat(idx2,:,i));
        ExCell(i)={abs(ExVals)};
    end
    %===========================================
    % Fit model to pi data and distance
    %===========================================
    ResSlope=cell([1 3]);
    STORE=[];
    for i=1:rootNum
        Vals=ResCell{i};
        posx=Vals(:,1);
        posy=Vals(:,2);
        if ~isempty(posx)
            W=(Vals(:,4)-thresh)./(4-thresh);
            meanPI=sum(W.*Vals(:,2))./sum(W);
            STORE=[STORE;W Vals(:,2)];
            PIs(1,i)=sum(W.*Vals(:,2))./sum(W);
            f=fit(posx,posy,'poly1','Weights',W);
            ci = confint(f,0.68);
            C = coeffvalues(f); % Get the coefficient values
            yCalc=f(posx);
            Rsq1 = 1 - sum((posy - yCalc).^2)/sum((posy - mean(posy)).^2);
            ResSlope(i)={[C(1) C(2) Rsq1 ci(1,1) ci(2,1) meanPI]};
        else
            PIs(1,i)=nan;
            ResSlope(i)={[nan nan nan nan nan nan]};
        end
    end
    globalPI=sum(STORE(:,1).*STORE(:,2))./sum(STORE(:,1));
    %===========================================
    % Fit model to pi data and distance
    %===========================================
    if params.PltFlag==1
        if isfile(fullfile(path2data,'DFdata.mat'))
            load(fullfile(path2data,'DFdata.mat'));
            DF(1:3,1:2)=StartPI(:,1:2);
            for i=1:3
                EPI=EndPI([(1+2*(i-1)) (2+2*(i-1))],1:2);
                idx=find(EPI(:,1)==-1);
                if ~isempty(idx)
                    EPI(idx,:)=[];
                end
                if length(EPI(:,1))==2
                    EndPIPlot(i,:)=mean(EPI);
                elseif length(EPI(:,1))==1
                    EndPIPlot(i,:)=EPI;
                else
                    EndPIPlot(i,:)=[nan nan];
                end
            end
            DF(1:3,3)=[EndPIPlot(1,1);EndPIPlot(2,1);EndPIPlot(3,1)];
            DF(1:3,4)=[EndPIPlot(1,2);EndPIPlot(2,2);EndPIPlot(3,2)];
            plot_SubjectQualityAndPI(ResCell,ExCell,thresh,ResSlope,PIs,DF)
        else
            plot_SubjectQualityAndPI(ResCell,ExCell,thresh,ResSlope,PIs)
        end
    end
    PITC=[ResSlope{1}' ResSlope{2}' ResSlope{3}'];
    if params.SaveData==1
        if params.PltFlag==1
            saveas(gcf,fullfile(path2data,'PITC_plot.jpg'))
            fprintf('\n saved data')
            close
        end
        save(fullfile(path2data,'PITCprocessed.mat'),'PITC')
    end
end
