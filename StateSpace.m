close all
clc
clear all
%% Choose what this code saves/outputs:
network_plot=1;
run_cvx=0;
state_control_graphs=0;
movie_flag=0;
save_movie_plot=0;
save_video_as_avi=0;
movie_name='production_rate_cost_over_varying_time_horizons';
%% Create Graph
% choose retail and warehouse nodes. choose warehouse to be 1:n1, and retail
% to be n1:n2

% %manual graph generation
% warehouse_nodes=1:4;
% retail_nodes=5:7;
% plant_nodes=8:10;
% nodes=[warehouse_nodes,retail_nodes,plant_nodes];
% % initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
% initial_warehouse_distribution=0*ones(1,length(warehouse_nodes));
% initial_plant_distribution=100*ones(1,length(plant_nodes));
% % initial_warehouse_distribution=10*[40;17;58;61];
% %start nodes
% start_nodes = [8 8 9 9 1 2 1 2 4 4 3 1 2 3 4 8 10];
% %end nodes
% end_nodes =   [1 2 1 2 3 4 4 5 5 6 7 2 3 4 1 4 3];

% automatic graph generation
warehouse_nodes=1:5;
retail_nodes=6:8;
plant_nodes=9:11;
rng(1,'twister');
a = rng;
nodes=[warehouse_nodes,retail_nodes,plant_nodes];
initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
initial_plant_distribution=800*ones(1,length(plant_nodes));
pw=0.7;
pr=0.6;
pp=0.5;
[start_nodes,end_nodes]=generateRandomGraph(warehouse_nodes,retail_nodes,plant_nodes,pw,pr,pp);
[retail_nodes,plant_nodes]=cleanUp(start_nodes,end_nodes,warehouse_nodes,retail_nodes,plant_nodes);

%defining the digraph based on start,end
G=digraph(start_nodes,end_nodes);
m=numedges(G);
n=numnodes(G);
%% Incidence Matrix
Incidence=computeIncidence(G);
%% Plotting edge labels and colours and order
[nonretail_paths,retail_paths]=computeRetailPaths(G,warehouse_nodes,retail_nodes,start_nodes,end_nodes);
[edge_start,edge_end]=computeEdges(Incidence,G);

if network_plot==1 
     p=plotNetwork(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end);
%      p2=plotNetworkUSMap(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end);
%      plotConnectedness(warehouse_nodes,retail_nodes,plant_nodes,initial_warehouse_distribution,initial_plant_distribution,G)
end

%Cost function matrices
[warehouse_path_selector,retail_path_selector,warehouse_selector,plant_selector,plant_path_selector,plant_selector_constraint]=configureCostFunctionMatrices(warehouse_nodes,retail_nodes,plant_nodes,edge_start,edge_end,n,m);
%% CVX Implementation

time_length=5;%overall lengthg of time which program runs for
% horizons=[1 5 10 20 30 40 45];% list of T values (look ahead times)
% rand_rates=[0 0 0 0 0 0 0];
horizons=[1];% list of T values (look ahead times)
rand_rates=[0];
xhorizons={};
uhorizons={};
rhorizons={};
cpu_time_horizons={};
opt_band_horizons={};
solver_iterations_horizons={};
solver_status_horizons={};
solver_tolerance_horizons={};
u_max=100;
u_min=0;
x_max=10000;
x_min=0;
x_0=setUpx_0(n,retail_nodes,warehouse_nodes,plant_nodes,initial_warehouse_distribution,initial_plant_distribution,nodes);
cost=[];     
if run_cvx==1
    for j=1:length(horizons)
        T=horizons(j);
        rand_rate=rand_rates(j);
        
        %fixed rate
        %production_rate=u_max;
        %[actual_cost,state,controls]=cvx_model_fixed_production_rate_with_rand(production_rate,time_length,T,u_max,u_min,x_max,x_min,x_0,rand_rate,n,m,Incidence,warehouse_path_selector,retail_path_selector,plant_path_selector,warehouse_selector,plant_selector);
        
        %rate as control
        rate_max=u_max-50;
        rate_min=0;
        
        [actual_cost,state,controls,rate,cpu_time,opt_band,solver_iterations,solver_status,solver_tolerance]=cvx_model_control_production_rate_with_rand(time_length,T,rate_max,rate_min,u_max,u_min,x_max,x_min,x_0,rand_rate,n,m,Incidence,warehouse_path_selector,retail_path_selector,plant_path_selector,plant_selector_constraint,warehouse_selector,plant_selector);
        cost=[cost,actual_cost];
        xhorizons{end+1}=state;
        uhorizons{end+1}=controls;
        rhorizons{end+1}=rate;
        cpu_time_horizons{end+1}=cpu_time;
        opt_band_horizons{end+1}=opt_band;
        solver_iterations_horizons{end+1}=solver_iterations;
        solver_status_horizons{end+1}=solver_status;
        solver_tolerance_horizons{end+1}=solver_tolerance;
        
    end
end


%% Plots
if state_control_graphs==1
    state_legend={};
    control_legend={};
    for i=1:m
        state_legend{end+1}=num2str(i);
    end
    for i=1:m
        control_legend{end+1}=num2str(i);
    end
%     %Plotting State and Inputs Over Time
%     time=1:T;
%     figure
%     subplot(2,1,1);
%     plot(time,x,'o');
%     title('State')
%     legend(state_legend)
%     
%     subplot(2,1,2);
%     plot(time,u,'o');
%     title('Input')
%     legend(control_legend)
    
    figure
    plot(horizons,cost)
    %     xlim([min(horizons) max(horizons)])
    %     ylim([0.9*abs(min(cost)) 1.1*abs(max(cost))])
    xlabel('Horizon Length')
    ylabel('Cost')
    x_legend={};
    for i=1:length(horizons)
        x_legend{end+1}=strcat('Horizon Length:' ,num2str(i));
    end
%     for node_num=1:n
%     plot_state_over_horizons(node_num,horizons,xhorizons,time_length,x_legend);
%     end
%     
%     for path_num=1:m
%     plot_control_over_horizons(path_num,horizons,uhorizons,time_length,x_legend);
%     end
%    
% figure
% plot(100*rand_rates,cost/cost(1)*100)
% xlabel('Error Rate (%)')
% ylabel('Efficiency Compared to Errorless System (%)')
% title('Error Rate vs. Cost')
    
end
%% Movie
plotMovie(movie_flag,save_movie_plot,save_video_as_avi,movie_name,horizons,xhorizons,uhorizons,G,time_length,nodes,warehouse_nodes,retail_nodes,plant_nodes,u_max,x_max,start_nodes,end_nodes)