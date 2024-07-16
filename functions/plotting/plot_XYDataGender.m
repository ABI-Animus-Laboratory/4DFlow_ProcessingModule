function [] = plot_XYDataGender(xData,yData,MrkrSz,mdlPlot,yLIMS,xLIMS,xTitle,yTitle,Title,FS,Flg,Ticks)
    if Flg==1
        scatter(-1000,-1000,20,'MarkerFaceColor',[0.7176    0.2745    1.0000],...
            'MarkerEdgeColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',.6);
        hold on
        scatter(-1000,-1000,20,'MarkerFaceColor',[0.3922    0.8314    0.0745],...
            'MarkerEdgeColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',.6);
        floatlgnd=legend('Male','Female');
        set(floatlgnd,'AutoUpdate','off','Location','NorthWest','FontSize',FS(1));
    end


    scatter(xData{1},yData{1},MrkrSz,'MarkerFaceColor',[0.7176    0.2745    1.0000],...
        'MarkerEdgeColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',.6)
    hold on
    scatter(xData{2},yData{2},MrkrSz,'MarkerFaceColor',[0.3922    0.8314    0.0745],...
        'MarkerEdgeColor','k','MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',.6)
    hold on
    if ~isempty(mdlPlot)
        mdlPlot1=mdlPlot{1};
        mdlPlot2=mdlPlot{2};
        plot(mdlPlot1(:,1),mdlPlot1(:,2),'-','Color',[0.7176    0.2745    1.0000])
        %plot(mdlPlot1(:,1),mdlPlot1(:,3),'--','Color',[0.7176    0.2745    1.0000])
        %plot(mdlPlot1(:,1),mdlPlot1(:,4),'--','Color',[0.7176    0.2745    1.0000])
        plot(mdlPlot2(:,1),mdlPlot2(:,2),'-','Color',[0.3922    0.8314    0.0745])
        %plot(mdlPlot2(:,1),mdlPlot2(:,3),'--','Color',[0.3922    0.8314    0.0745])
        %plot(mdlPlot2(:,1),mdlPlot2(:,4),'--','Color',[0.3922    0.8314    0.0745])
    end
    if ~isempty(yLIMS) 
        minY=yLIMS(1);maxY=yLIMS(2);
        ylim([minY maxY])
    end
    if ~isempty(xLIMS)
        minX=xLIMS(1);maxX=xLIMS(2);
        xlim([minX maxX])
    end
    if ~isempty(xTitle)
        xlabel(xTitle,'FontSize',FS(2),'FontWeight','Bold')
    end
    if ~isempty(yTitle)
        ylabel(yTitle,'FontSize',FS(2),'FontWeight','Bold')
    end
    if ~isempty(Title)
        title(Title,'FontSize',FS(3),'FontWeight','Bold')
    end
    if ~isempty(Ticks)
        xticks([minX:Ticks(1):maxX])
        yticks([minY:Ticks(2):maxY])
    end
    grid on
    box on
end