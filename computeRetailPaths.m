function [nonretail_paths,retail_paths] = computeRetailPaths(G,warehouse_nodes,retail_nodes,start_nodes,end_nodes)
    num_edges=numedges(G);
    num_nodes =numnodes(G);
    nonretail_paths=[];
    retail_paths=[];
    for i=1:num_edges
        if ismember(start_nodes(i),warehouse_nodes) && ismember(end_nodes(i),warehouse_nodes)
            nonretail_paths=[nonretail_paths;[start_nodes(i) end_nodes(i)]];
        else
            retail_paths=[retail_paths;[start_nodes(i) end_nodes(i)]];
        end
    end
end

