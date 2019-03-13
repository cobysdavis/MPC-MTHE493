close all
warehouse_nodes=1:20;
retail_nodes=21:30;
plant_nodes=31:40;
nodes=[warehouse_nodes,retail_nodes,plant_nodes];
initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
initial_plant_distribution=800*ones(1,length(plant_nodes));
pw=0.6;
pr=0.6;
pp=0.6;
[start_nodes,end_nodes]=generateRandomGraph(warehouse_nodes,retail_nodes,plant_nodes,pw,pr,pp);
[retail_nodes,plant_nodes]=cleanUp(start_nodes,end_nodes,warehouse_nodes,retail_nodes,plant_nodes);

%defining the digraph based on start,end
G=digraph(start_nodes,end_nodes);
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
Alpha=0.25
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);


inc = centrality(G,'incloseness');
figure
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);
p.NodeCData = inc;
colormap jet
colorbar
title('Incloseness Centrality Scores - Unweighted')

figure
outc=centrality(G,'outcloseness');
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);
p.NodeCData = outc;
colormap jet
colorbar
title('Outcloseness Centrality Scores - Unweighted')

figure
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',10,'EdgeAlpha',Alpha,'ArrowSize',7);
btwn = centrality(G,'betweenness','Cost',G.Edges.Weight);
n = numnodes(G);
p.NodeCData = 2*btwn./((n-2)*(n-1));
colormap(flip(autumn,1));
colorbar
title('Betweenness Centrality Scores - Weighted')

