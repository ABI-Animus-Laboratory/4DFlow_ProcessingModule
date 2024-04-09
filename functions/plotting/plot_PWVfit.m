function [] = plot_PWVfit(Raw)
%load('tester.mat')
figure('Units','centimeters','Position',[1 1 17 17])
Titles={'LICA','RICA','BA'};
for i=1:3
    Raw1=Raw{1,i};
    Raw2=Raw{2,i};
    Raw3=Raw{3,i};
    Raw4=Raw{4,i};

    D1=Raw1(:,1).*1000;
    ttu1=Raw1(:,2);
    W1=Raw1(:,3);
    [mdl1,~] = fit_linXYData(D1,ttu1,W1);
    Slope1=table2array(mdl1.Coefficients(2,1));

    D3=Raw3(:,1).*1000;
    ttu3=Raw3(:,2);
    W3=Raw3(:,3);
    [mdl3,~] = fit_linXYData(D3,ttu3,W3);
    Slope3=table2array(mdl3.Coefficients(2,1));
    %PLOTTING
    subplot(3,3,i)
    scatter(D1,ttu1,20,'o','MarkerFaceColor',0.7*[1 0 1],'MarkerfaceAlpha',0.3,'MarkerEdgeAlpha',0.3,'MarkerEdgeColor','k')
    hold on
    plot([min(D1) max(D1)], table2array(mdl1.Coefficients(2,1)).*[min(D1) max(D1)] + table2array(mdl1.Coefficients(1,1)),'k-.','LineWidth',2);
    plot([min(D3) max(D3)], table2array(mdl3.Coefficients(2,1)).*[min(D3) max(D3)] + table2array(mdl3.Coefficients(1,1)),'k--','LineWidth',2);
    ylabel('maximised XCor time (s)','FontSize',8,'FontWeight','Bold')
    title(Titles{i},'FontSize',8,'FontWeight','Bold')
    ylim([-0.3 0.5])
    a=legend('raw data',strcat('W_1;=',num2str((Slope1.^-1)./1000,'%1.1f'),'m/s'),strcat('W_2;',num2str((Slope3.^-1)./1000,'%1.1f'),'m/s'));
    set(a,'box','off','location','NorthWest','FontSize',6)
    
    
    D2=Raw2(:,1).*1000;
    ttu2=Raw2(:,2);
    W2=Raw2(:,3);
    [mdl2,~] = fit_linXYData(D2,ttu2,W2);
    Slope2=table2array(mdl2.Coefficients(2,1));
    D4=Raw4(:,1).*1000;
    ttu4=Raw4(:,2);
    W4=Raw4(:,3);
    [mdl4,~] = fit_linXYData(D4,ttu4,W4);
    Slope4=table2array(mdl4.Coefficients(2,1));
    %PLOTTING
    subplot(3,3,i+3)
    scatter(D2,ttu2,20,'o','MarkerFaceColor',0.7*[0 1 1],'MarkerfaceAlpha',0.3,'MarkerEdgeAlpha',0.3,'MarkerEdgeColor','k')
    hold on
    plot([min(D2) max(D2)], table2array(mdl2.Coefficients(2,1)).*[min(D2) max(D2)]+table2array(mdl2.Coefficients(1,1)),'k-.','LineWidth',2);
    plot([min(D4) max(D4)], table2array(mdl4.Coefficients(2,1)).*[min(D4) max(D4)]+table2array(mdl4.Coefficients(1,1)),'k--','LineWidth',2);
    ylabel('time-to-upstroke (s)','FontSize',8,'FontWeight','Bold')
    ylim([-0.3 0.5])
    a=legend('raw data',strcat('W_1;=',num2str((Slope2.^-1)./1000,'%1.1f'),'m/s'),strcat('W_2;',num2str((Slope4.^-1)./1000,'%1.1f'),'m/s'));
    set(a,'box','off','location','NorthWest','FontSize',6)
    


    subplot(3,3,i+6)
    D2=Raw3(:,1).*1000;
    W2=Raw3(:,3);
    scatter(D1,W1,20,'o','MarkerFaceColor',1*[0 1 0],'MarkerfaceAlpha',0.3,'MarkerEdgeAlpha',0.3,'MarkerEdgeColor','k')
    hold on
    scatter(D2,W2,20,'o','MarkerFaceColor',1*[0 0 1],'MarkerfaceAlpha',0.3,'MarkerEdgeAlpha',0.3,'MarkerEdgeColor','k')
    ylabel('Weight','FontSize',8,'FontWeight','Bold')
    a=legend('W_1','W_2');
    set(a,'box','off','FontSize',8)
    xlabel('d (mm)','FontSize',8,'FontWeight','Bold')
    ylim([0 1.3])
end
