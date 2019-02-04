warehouse_nodes=1:10;
retail_nodes=11:16;
initial_warehouse_distribution=round(1000*rand(1,length(warehouse_nodes)))
pw=0.7;
pr=0.35;
[start_nodes,end_nodes]=generateRandomGraph(warehouse_nodes,retail_nodes,pw,pr);
retail_nodes=cleanUpNodes(retail_nodes,end_nodes);
nodes=[warehouse_nodes,retail_nodes];
G=digraph(start_nodes,end_nodes);
xy = [G.Nodes.q G.Nodes.YCoord];
[s,t] = findedge(G);
G.Edges.Weight = hypot(xy(s,1)-xy(t,1), xy(s,2)-xy(t,2));
p = plot(G,'XData',xy(:,1),'YData',xy(:,2),'MarkerSize',5);
title('Minnesota Road Network')
% deg_ranks = centrality(G,'degree','Importance',G.Edges.Weight);
% edges = linspace(min(deg_ranks),max(deg_ranks),7);
% bins = discretize(deg_ranks,edges);
% p.MarkerSize = bins;

% ucc = centrality(G,'closeness');
% p.NodeCData = ucc;
% colormap jet
% colorbar
% title('Closeness Centrality Scores - Unweighted')


% wcc = centrality(G,'closeness','Cost',G.Edges.Weight);
% p.NodeCData = wcc;
% title('Closeness Centrality Scores - Weighted')

% wbc = centrality(G,'betweenness','Cost',G.Edges.Weight);
% n = numnodes(G);
% p.NodeCData = 2*wbc./((n-2)*(n-1));
% colormap(flip(autumn,1));
% title('Betweenness Centrality Scores - Weighted')
