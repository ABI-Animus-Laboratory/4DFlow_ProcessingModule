function [stats] = plot_BlandAltman(X1,X2,Type,XLims,YLims,lgnd,XTitle,YTitle,Title,Col,Shp)
    if Type == 1 
        [mdl,~] = fit_linXYData(X1,X2,[]);
        MaxY=max(X2);MinX=min(X1);MaxX=max(X1);MinY=min(X2);
        XFit=[MinX MaxX];
        Slope=table2array(mdl.Coefficients(2,:));
        R2=mdl.Rsquared.Adjusted;
        
        scatter(X1,X2,20,Shp,'MarkerFaceColor',Col,'MarkerFaceAlpha',0.2,'MarkerEdgeColor','k','MarkerEdgeAlpha',0.2)
        hold on
        plot(XLims,XLims,'k')
        plot(XFit,Slope(1).*XFit+table2array(mdl.Coefficients(1,1)),'k-.','LineWidth',2)
        
        %text(0.55,0.5,strcat('R^2=',num2str(R2,'%0.2f'),',p<',num2str(Slope(4),'%1.3f')),'Units','normalized','FontSize',6)
        
        text(0.6,0.5,strcat('R^2=',num2str(R2,'%0.2f')),'Units','normalized','FontSize',6)
        text(0.6,0.40,strcat('p<',num2str(Slope(4),'%1.3f')),'Units','normalized','FontSize',6)
        hold on
        %plot(-100,-100,'rx')
        if lgnd==1
            a=legend('Raw Data','Unity','Fit');%'Failure');
            set(a,'Location','NorthWest','FontSize',6,'color','white','box','on','AutoUpdate','off');
        end
        xlabel(XTitle,'FontSize',10);%,'FontWeight','Bold')
        ylabel(YTitle,'FontSize',10);%,'FontWeight','Bold')
        title(Title,'FontSize',10);%,'FontWeight','Bold')
        xlim(XLims);
        ylim(XLims)

        stats=[R2 Slope(4)];
        grid on
        %box on
    else
        X2p=X2-X1;
        Dev=std(X2p);
        X1p=mean([X1';X2'])';
        MaxY=max(abs(X2p));MinX=min(X1p);MaxX=max(X1p);MinY=min(X2p);
        XFit=[MinX MaxX];
        [mdl,~] = fit_linXYData(X1p,X2p,[]);
        Slope=table2array(mdl.Coefficients(2,:));
        R2=mdl.Rsquared.Ordinary;
        
        scatter(X1p,X2p,Shp,'MarkerFaceColor',Col,'MarkerFaceAlpha',0.2,'MarkerEdgeColor','k','MarkerEdgeAlpha',0.2)
        hold on
        plot(XLims,[mean(X2p) mean(X2p)],'k-')
        plot(XLims,[(mean(X2p)+Dev) (mean(X2p)+Dev)],'k--')
        plot(XFit,Slope(1).*XFit+table2array(mdl.Coefficients(1,1)),'k-.','LineWidth',2)
        plot(XLims,[(mean(X2p)-Dev) (mean(X2p)-Dev)],'k--')


        text(0.25,0.08,strcat('R^2=',num2str(R2,'%0.2f'),{'    '},'p<',num2str(Slope(4),'%1.3f')),'Units','normalized','FontSize',6)
        if lgnd==1
            a=legend('Raw Data',...
                strcat('mean=',num2str(mean(X2p),'%1.2f')),...
                strcat('2\sigma=',num2str(Dev,'%1.2f')),...
                'Fit');
            set(a,'Location','NorthWest','FontSize',6)
        end
        xlabel(XTitle,'FontSize',10);%,'FontWeight','Bold')
        ylabel(YTitle,'FontSize',10);%,'FontWeight','Bold')
        ylim([(MinY-0.3*MaxY) (MaxY+0.3*MaxY)])
        if isempty(YLims)
            ylim([(-MaxY-0.3*MaxY) (MaxY+0.3*MaxY)])
        else
            ylim(YLims)
        end
        
        xlim(XLims);
        stats=[mean(X2p) Dev];
        grid on
        %box on
    end
end