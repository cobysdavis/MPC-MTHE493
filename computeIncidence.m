function [ Incidence ] = computeIncidence(G)
I=incidence(G);
length_I=nnz(I);
num_edges=numedges(G);
num_nodes = numnodes(G);
Incidence=zeros(num_nodes,num_edges);
[node_i,link_j,val] = find(I);
%Computing "Real" Incidence Matrix
for i=1:num_nodes
    for j=1:num_edges
        for k=1:length_I
            if i==node_i(k) && j==link_j(k)
                Incidence(i,j)=val(k);    
            end
        end
    end
end
end

