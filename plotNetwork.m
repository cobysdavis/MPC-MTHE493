function p = plotNetwork(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end)
    %lat=[3.93,3.53,3.76,4.01,7.12,8.12,8.14,4.51,5.80, 6.26, 6.42];
    %long=[6.41,7.12,8.71,8.53,4.93,5.18,4.57,0.58, 1.02, 1.19, 2.07];
    %1.city	2.state_name	3.lat	4.lng	5.population	6.id
    num_edges=numedges(G);
    filename = 'uscities.xlsx';
    [num,txt,data]= xlsread(filename);
    n=numnodes(G);
    cities=(data(2:n+1,1))
    y=cell2mat(data(2:n+1,3))/-2.8+18.5;
    x=cell2mat(data(2:n+1,4))/5.9+21.3;
    num_nodes =numnodes(G);
    edge_labels = {};
    for i=1:num_edges
        edge_labels{end+1}=num2str(i);
    end
    img=imread('US MAP.png');
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
    highlight(p,warehouse_nodes,'NodeColor','r')
    highlight(p,retail_nodes,'NodeColor','g')
    highlight(p,plant_nodes,'NodeColor','m')
    hold on
    for i=1:num_edges
        if ismember(start_nodes(i),warehouse_nodes) && ismember(end_nodes(i),warehouse_nodes)
            highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','r')
        elseif ismember(start_nodes(i),plant_nodes) && ismember(end_nodes(i),warehouse_nodes)
            highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','m')
        else
            highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','g')
        end
    end
    
    figure
    p=plot(G);
    hold on
    labeledge(p,edge_start,edge_end,edge_labels);
    %Colour reatil nodes green, warehouse red
    highlight(p,warehouse_nodes,'NodeColor','r')
    highlight(p,retail_nodes,'NodeColor','g')
    highlight(p,plant_nodes,'NodeColor','m')
    hold on
    for i=1:num_edges
        if ismember(start_nodes(i),warehouse_nodes) && ismember(end_nodes(i),warehouse_nodes)
            highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','r')
        elseif ismember(start_nodes(i),plant_nodes) && ismember(end_nodes(i),warehouse_nodes)
            highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','m')
        else
            highlight(p,[start_nodes(i) end_nodes(i)],'EdgeColor','g')
        end
    end
    
end

