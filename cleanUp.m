function [r_n,p_n] = cleanUp(start_nodes,end_nodes, w_n, r_n, p_n )
for r=r_n
    if ~ismember(r,end_nodes)
        r_n(find(r_n==r))=[];
    end
end



for p=p_n
    if ~ismember(p,start_nodes)
        p_n(find(p_n==p))=[];
    end
end
    
end

