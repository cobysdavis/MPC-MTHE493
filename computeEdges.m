function [edge_start,edge_end] = computeEdges(Incidence,G) 
    num_edges=numedges(G);
    num_nodes = numnodes(G);
    edge_start=[];
    edge_end=[];
    for i=1:num_edges
        for j=1:num_nodes
            if Incidence(j,i)==1
                edge_end=[edge_end,j];
            end
            if Incidence(j,i)==-1
                edge_start=[edge_start,j];
            end
        end
    end

end

