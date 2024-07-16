for i=1:length(Edges)
    P1=[Nodes(Edges(i,1)+1,2) Nodes(Edges(i,1)+1,3) Nodes(Edges(i,1)+1,4)];
    P2=[Nodes(Edges(i,2)+1,2) Nodes(Edges(i,2)+1,3) Nodes(Edges(i,2)+1,4)];
    plot3([P1(1) P2(1)],[P1(2) P2(2)],[P1(3) P2(3)],'w-','LineWidth',3)
    hold on
end
