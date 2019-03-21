function [shipped,inventory_at_end,made,shipped_per_day] = compareBase(million_times,xhorizons,uhorizons,rhorizons,warehouse_nodes,n)
m=cell2mat(million_times);
shipped=[];
made=[];
shipped_per_day={};
for i=1:length(m)
    u=cell2mat(uhorizons(i));
    shipped=[shipped,sum(sum(u(:,1:m(i))))];
    s=[];
    for j=1:m(i)
        s=[s,sum(u(:,j))];
    end
    shipped_per_day{end+1}=s;
end


for i=1:length(m)
    r=cell2mat(rhorizons(i));
    made=[made,sum(sum(r(:,1:m(i))))];
end    
inventory_at_end=[];
w=max(warehouse_nodes);
warehouses=[ones(1,w) zeros(1,n-w)]
size(warehouses)
for i=1:length(m)
    x=cell2mat(xhorizons(i));
    x=x(:,end)
    inventory_at_end=[inventory_at_end,sum(x(1:w))];
end




end

