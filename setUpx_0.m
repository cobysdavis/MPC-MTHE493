function [x_0]=setUpx_0(retail_nodes,initial_warehouse_distribution,nodes)
x_0=[];
count=1;
for i=nodes
    if ismember(i,retail_nodes)
        x_0=[x_0;0];
    else
        x_0=[x_0;initial_warehouse_distribution(count)];
        count=count+1;
    end
end
end

