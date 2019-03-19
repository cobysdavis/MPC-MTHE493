function [p] = plotNetworkUSMap(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end)
figure
num_edges=numedges(G);
filename = 'uscities.xlsx';
[num,txt,data]= xlsread(filename);
n=numnodes(G);
cities=(data(2:n+1,1));
y=cell2mat(data(2:n+1,3))/-2.8+18.2;
x=cell2mat(data(2:n+1,4))/5.9+21.3;
num_nodes =numnodes(G);
edge_labels = {};
for i=1:num_edges
    edge_labels{end+1}=num2str(i);
end
set(gca,'FontSize', 18)
img=imread('usmap.jpeg');
min_x = 0;
max_x = 10;
min_y = 0;
max_y = 10;
imagesc([min_x max_x], [min_y max_y], img);
hold on
p=plot(G,'XData',x,'YData',y,'NodeLabel',cities);
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

