function [ ] = plotConnectedness( warehouse_nodes,retail_nodes,plant_nodes,initial_warehouse_distribution,initial_plant_distribution,G )
nodes=[warehouse_nodes,retail_nodes,plant_nodes];

%[retail_nodes,plant_nodes]=cleanUp(start_nodes,end_nodes,warehouse_nodes,retail_nodes,plant_nodes);

%defining the digraph based on start,end
m=numedges(G);
n=numnodes(G);
[s,t] = findedge(G);

hub_ranks = centrality(G,'hubs')
pg_ranks = centrality(G,'pagerank')
auth_ranks = centrality(G,'authorities');
G.Nodes.Hubs = hub_ranks;
G.Nodes.Authorities = auth_ranks;
G.Nodes.PageRank = pg_ranks;

G.Nodes.XCoord=rand(n,1);
G.Nodes.YCoord=rand(n,1);
xy = [G.Nodes.XCoord G.Nodes.YCoord];
[s,t] = findedge(G);
G.Edges.Weight = hypot(xy(s,1)-xy(t,1), xy(s,2)-xy(t,2));
Alpha=0.20;

figure
inc = centrality(G,'incloseness')
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);
p.NodeCData = inc;
colormap jet
colorbar
caxis([0 .025])
title('Incloseness Centrality Scores')

figure
outc=centrality(G,'outcloseness')
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);
p.NodeCData = outc;
colormap jet
colorbar
caxis([0 .025])
title('Outcloseness Centrality Scores')

figure
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);
btwn = centrality(G,'betweenness','Cost',G.Edges.Weight)
n = numnodes(G);
p.NodeCData = 2*btwn./((n-2)*(n-1));
% colormap(flip(autumn,1));
% colorbar

colormap jet
colorbar
caxis([0 .09])
title('Betweenness Centrality Scores')
end

