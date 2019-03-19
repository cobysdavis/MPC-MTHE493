function p = plotNetwork(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end)
figure
num_edges=numedges(G);
num_nodes =numnodes(G);
edge_labels = {};
for i=1:num_edges
    edge_labels{end+1}=num2str(i);
end
p=plot(G);
hold on
labeledge(p,edge_start,edge_end,edge_labels);
%Colour reatil nodes green, warehouse red
highlight(p,warehouse_nodes,'NodeColor','b')
highlight(p,retail_nodes,'NodeColor','r')
highlight(p,plant_nodes,'NodeColor','g')
hold on
for i=1:num_edges
    if ismember(start_nodes(i),warehouse_nodes) && ismember(end_nodes(i),warehouse_nodes)
        highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','b')
    elseif ismember(start_nodes(i),plant_nodes) && ismember(end_nodes(i),warehouse_nodes)
        highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','g')
    else
        highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','r')
    end
end

end

