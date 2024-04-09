function [] = plot_SubjectQualityAndPI(ResCell,ExCell,thresh,ResSlope,PIs,varargin)
    h1=figure();
    set(h1,'Position',[50 150 700 450])
    MrkrSz=7; %Plotting MarkerSize
    FSs=6; %small fontsise
    FSm=10; %medium fontsize
    FSl=12; %large fontsize
    TitleNames={'Left ICA';'Right ICA';'Basilar';};
    yNames={'Q (max 4)','p_{pi}'};
    maxX=0;
    for i=1:3
        Vals=ResCell{i};
        maxX=max([maxX max(Vals(:,1))]);
    end
    ID=0;
    for i=1:6
        subplot(2,3,i)
        if mod(i,4)==0
            ID=1;
        end
        if ID == 0
            ExVals=ExCell{i}; %Now Use Excluded Values
            ExVals(:,4)=((ExVals(:,4)-2.5)./1.5);
            scatter(ExVals(:,1),ExVals(:,4),MrkrSz,'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0)
            hold on
            Vals=ResCell{i}; %Now Use Thresholded Values
            Vals(:,4)=((Vals(:,4)-2.5)./1.5);
            scatter(Vals(:,1),Vals(:,4),MrkrSz,'MarkerFaceColor','b','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',0)
            lgnd=legend(strcat('Q<',num2str(thresh-thresh)),strcat('Q>',num2str(thresh-thresh)));
            set(lgnd,'Location','SouthWest','FontSize',FSs)
        else
            Vals=ResCell{i-3}; %Now Use Thresholded Values
            scatter(Vals(:,1),Vals(:,2),MrkrSz,'MarkerFaceColor','b','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',0)
            hold on
            Slopes=ResSlope{i-3};
            if ~isempty(Slopes)
                ypos=Slopes(1).*[0 maxX]+Slopes(2);
                plot([0 maxX],ypos,'k-')
            end
            plot([0 maxX],[PIs(i-3) PIs(i-3)],'r-')
            if i==4
            lgnd=legend('Data','p_{tf}(d)=p_{tc}d+\beta','\mu(p_{pi})');
            set(lgnd,'Location','NorthEast','FontSize',FSs)
            end
            if length(varargin)==1
                DF=varargin{1};
                scatter([DF(i-3,1) DF(i-3,3)],[DF(i-3,2) DF(i-3,4)],'MarkerFaceColor','g','MarkerFaceAlpha',0.8,'MarkerEdgeAlpha',0)
                if i==4
                    lgnd=legend('Data','p_{tf}(d)=p_{tc}d+\beta','\mu(p_{pi})','x_{p} and x_{d}');
                    set(lgnd,'Location','NorthEast','FontSize',FSs)
                end
            end
        end
        if i<4
            title(TitleNames{i},'FontSize',FSl,'FontWeight','Bold')
            ylim([-1 1]) %Quality y limits
            %ylim([0 4]) %Quality y limits
        else
            ylim([0 1.5]) %Pulsatility y limits
        end
        if i==1 || i==4
            ylabel(yNames{ID+1},'FontSize',FSm,'FontWeight','Bold')
        end
        xlabel('d (mm)','FontSize',FSm,'FontWeight','Bold')
        xticks(0:25:500)
        xlim([0 maxX])
        grid on
        box on
    end
end