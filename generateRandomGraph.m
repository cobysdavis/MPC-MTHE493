function [start_nodes,end_nodes] = generateRandomGraph(warehouse_nodes,retail_nodes,plant_nodes,percent_warehouse_connect,percent_retail_connect,percent_plant_connect)
start_nodes=[];
end_nodes=[];
for i=warehouse_nodes
    for j=warehouse_nodes
        if rand()>=1-percent_warehouse_connect && i~=j
          start_nodes=[start_nodes,i];
          end_nodes=[end_nodes,j];
        end
        
    end
    for k=retail_nodes
        if rand()>=1-percent_retail_connect && i~=k
          start_nodes=[start_nodes,i];
          end_nodes=[end_nodes,k];
        end
    end
    for l=plant_nodes
        if rand()>=1-percent_plant_connect && i~=l
          start_nodes=[start_nodes,l];
          end_nodes=[end_nodes,i];
        end
    end
end

% end_retail=[];
% end_warehouse=[];
% for i=end_nodes
%     if ismember(i,retail_nodes)
%         end_retail=[end_retail,i];
%     else
%         end_warehouse=[end_warehouse,i];
%     end
% end
% end_retail=unique(end_retail);
% end_warehouse=unique(end_warehouse);
% retail_diff=length(retail_nodes)-length(end_retail)
% warehouse_diff=length(warehouse_nodes)-length(end_warehouse)
% for i=1:length(end_nodes)
%     if ismember(end_nodes(i),retail_nodes) && end_nodes(i)-retail_diff -length(retail_nodes)>0
%         end_nodes(i)=end_nodes(i)-retail_diff;
%     elseif ismember(end_nodes(i),warehouse_nodes) && end_nodes(i)-warehouse_diff-length(warehouse_nodes)>=0
%         end_nodes(i)=end_nodes(i)-warehouse_diff;
%     end
% end

end

