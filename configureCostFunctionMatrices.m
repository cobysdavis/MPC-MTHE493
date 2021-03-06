function [warehouse_path_selector,retail_path_selector,warehouse_selector,plant_selector,plant_path_selector,plant_selector_constraint] = configureCostFunctionMatrices(warehouse_nodes,retail_nodes,plant_nodes,edge_start,edge_end,n,m)
rng(1,'twister');
a = rng;

warehouse_selector=zeros(1,n);
for i=1:n
    if ismember(i,warehouse_nodes)
        warehouse_selector(i)=randi(10,1,1);
    end
end
plant_selector_constraint=zeros(1,n);
plant_selector=zeros(1,n);
for i=1:n
    if ismember(i,plant_nodes)
        plant_selector(i)=randi(10,1,1)+10;
        plant_selector_constraint(i)=1;
    end
end


retail_path_selector=zeros(1,m);
for i=1:m
    if ismember(edge_end(i),retail_nodes) && ismember(edge_start(i),warehouse_nodes)
        retail_path_selector(i)=randi(50,1,1)+100; 
    end
end

warehouse_path_selector=zeros(1,m);
for i=1:m
    if ismember(edge_end(i),warehouse_nodes) && ismember(edge_start(i),warehouse_nodes)
        warehouse_path_selector(i)=randi(10,1,1)+30;
    end
end


plant_path_selector=zeros(1,m);
for i=1:m
    if ismember(edge_end(i),warehouse_nodes) && ismember(edge_start(i),plant_nodes)
        plant_path_selector(i)=randi(10,1,1)+30;
    end
end


end

