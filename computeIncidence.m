function [ Incidence,Ain,Aout ] = computeIncidence(G)
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
Ain=Incidence;
Aout=Incidence;
s=size(Incidence);
n=s(1);
m=s(2);
for i=1:n
    for j=1:m
        if Incidence(i,j)<0
            Ain(i,j)=0;
            Aout(i,j)=-Incidence(i,j);
        end
        if Incidence(i,j)>0
            Aout(i,j)=0;
        end
    end
end
end

