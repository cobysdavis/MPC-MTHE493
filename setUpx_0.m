function [x_0]=setUpx_0(retail_nodes,warehouse_nodes,plant_nodes,initial_warehouse_distribution,initial_plant_distribution,nodes)
x_0=[];
count_warehouse=1;
count_plant=1;
for i=nodes
    if ismember(i,retail_nodes)
        x_0=[x_0;0];
    elseif ismember (i,warehouse_nodes)
        x_0=[x_0;initial_warehouse_distribution(count_warehouse)];
        count_warehouse=count_warehouse+1;
    else
        x_0=[x_0;initial_plant_distribution(count_plant)];
        count_plant=count_plant+1;
    end
end
end

