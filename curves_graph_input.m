

function curves_graph_input(time, Cv, Cb)
% When testing, plot the Cv and Cb curves on same time axis, with different y-axes...

    if nargin > 2

        [AX,H1,H2] = plotyy(time, Cb, time, Cv); %#ok<PLOTYY>
        xlabel('Time (s)'); 
        set(H1,'LineStyle','-','Color','g','Marker','.');
        set(H2,'LineStyle','-','Color','b','Marker','.');
        ylim(AX(1),'auto');
        ylim(AX(2),'auto');
        y1 = ylim(AX(1)); 
        y2 = ylim(AX(2));
        set(AX(1),'YLim',[0 y1(2)],'YTick',0:y1(2)/5:y1(2));
        set(AX(2),'YLim',[0 y2(2)],'YTick',0:y2(2)/5:y2(2));
        set(AX(1),'YColor','k'); 
        set(AX(2),'YColor','b');
        ylabel(AX(1),'ROI [Gd] (mmol l^{-1})');
        ylabel(AX(2),'AIF Blood [Gd] (mmol l^{-1})');
        title('AIF [Gd] (blood) and measured [Gd]','FontSize',12,'FontWeight','bold');
        legend([H1 H2],'C_{v}(t)','AIF: C_{b}(t)','Location','SouthEast');
        drawnow

    else
        
        H1 = plot(time, Cv); 
        xlabel('Time (s)'); 
        set(H1,'LineStyle','-','Color','g','Marker','.');
        ylim('auto');
        y1 = ylim;
        set(gca, 'YLim', [0, y1(2)]);
        ylabel('ROI Signal Intensity (a.u.)');
        title('MR signal vs. time','FontSize',12,'FontWeight','bold');
        legend('SI(t)','Location','SouthEast');
        drawnow
    
    end
        
end

