function [] = plot_XYData(xData,yData,Col,MrkrSz,mdlPlot,yLIMS,xLIMS,xTitle,yTitle,Title,FS,LGND,Ticks)
    scatter(xData,yData,MrkrSz,'MarkerFaceColor',Col,'MarkerEdgeColor',Col,'MarkerFaceAlpha',0.4,'MarkerEdgeAlpha',.7)
    hold on
    plot(mdlPlot(:,1),mdlPlot(:,2),'k-')
    plot(mdlPlot(:,1),mdlPlot(:,3),'k--')
    plot(mdlPlot(:,1),mdlPlot(:,4),'k--')
    [mdl,~] = fit_linXYData(xData,yData,[]);
    Slope=table2array(mdl.Coefficients(2,:));
    R2=mdl.Rsquared.Adjusted;
    text(0.25,1.08,strcat('R^2=',num2str(R2,'%0.2f'),',p<',num2str(Slope(4),'%1.3f')),'Units','normalized','FontSize',6)

    if ~isempty(yLIMS) 
        minY=yLIMS(1);maxY=yLIMS(2);
        ylim([minY maxY])
    end
    if ~isempty(xLIMS)
        minX=xLIMS(1);maxX=xLIMS(2);
        xlim([minX maxX])
    end
    if ~isempty(LGND)
        lgn=legend(LGND);
        set(lgn,'Location','NorthWest','FontSize',FS(1),'AutoUpdate','off')
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