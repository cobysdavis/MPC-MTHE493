close all
clc
clear all
%% Choose what this code saves/outputs:
network_plot=1;
run_cvx=1;
state_control_graphs=0;
movie_plot=1;
save_movie_plot=0;
save_video_as_avi=0;
%% Create Graph
% choose retail and warehouse nodes. choose warehouse to be 1:n1, and retail
% to be n1:n2

%manual graph generation
warehouse_nodes=1:5;
retail_nodes=6:8;
plant_nodes=9:10;
nodes=[warehouse_nodes,retail_nodes,plant_nodes];
% initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
initial_warehouse_distribution=200*ones(1,length(warehouse_nodes)+length(plant_nodes));
% initial_warehouse_distribution=10*[40;17;58;61];
%start nodes
start_nodes = [1 1 1 2 2 3 3 3 4 4 4 5 5 5 9 9 9 9 10 10 10];
%end nodes
end_nodes =   [2 3 5 1 4 1 4 5 6 7 8 6 7 8 1 2 3 4 1 2 3];

%automatic graph generation
% warehouse_nodes=1:10;
% retail_nodes=11:14;
% initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)))
% pw=0.6;
% pr=0.3;
% [start_nodes,end_nodes]=generateRandomGraph(warehouse_nodes,retail_nodes,pw,pr);
% retail_nodes=cleanUpNodes(retail_nodes,end_nodes);
% nodes=[warehouse_nodes,plant_nodes,retail_nodes];
% 

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
end

%Cost function matrices
[warehouse_path_selector,retail_path_selector,warehouse_selector,plant_selector,plant_path_selector]=configureCostFunctionMatrices(warehouse_nodes,retail_nodes,plant_nodes,edge_start,edge_end,n,m);
%% CVX Implementation
controls=[];
cost=[];
production_rate=10;
time_length=30;%overall lengthg of time which program runs for
Horizons=[20];% list of T values (look ahead times)
if run_cvx==1
    for j=1:length(Horizons)
        T=Horizons(j);
        %% CVX Setup
        % max constraints, initial condition
        u_max=10;
        u_min=0;
        x_max=2000;
        x_min=0;
        u_max_vector = u_max*ones(m,T);
        u_min_vector=u_min*ones(m,T);
        x_max_vector = x_max*ones(n,T);
        x_min_vector=x_min*ones(n,T);
        x_0=setUpx_0(retail_nodes,initial_warehouse_distribution,nodes);
        actual_cost=0;
        state=[x_0];
        controls=[];
        for i=1:time_length
            cvx_begin quiet
            disp(strcat(strcat('calculating optimal control: ',num2str(i)),strcat(' for horizon T=',num2str(T))))
            variables x(n,T) u(m,T)
            minimize(sum(sum(warehouse_path_selector*u+plant_path_selector*u-retail_path_selector*u))+sum(sum(warehouse_selector*x+plant_selector*x)))
            subject to
            %system dynamics:
            x(:,1:end)==[state(:,end) x(:,1:end-1)]+Incidence*u(:,1:end)
            %shipping constraints
            x <= x_max_vector;
            x >= x_min_vector;
            %storage constraints
            u <= u_max_vector;
            u >= u_min_vector;
            cvx_end
            cost_at_moment=warehouse_path_selector*u(:,1)-retail_path_selector*u(:,1)+warehouse_selector*x(:,1);
            actual_cost=actual_cost+cost_at_moment;
            state=[state,x(:,1)];
            state(:,end)=transpose(production_rate*plant_selector)+state(:,end);
            controls=[controls,u(:,1)];
        end
        cost=[cost,actual_cost];
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
    %Plotting State and Inputs Over Time
    time=1:T;
    figure
    subplot(2,1,1);
    plot(time,x,'o');
    title('State')
    legend(state_legend)

    subplot(2,1,2);
    plot(time,u,'o');
    title('Input')
    legend(control_legend)

    figure
    plot(cost)
end 
%% Movie
if movie_plot==1
    f=figure;
    position=[80 80 1200 900];
    set(f, 'Position',position);
    %Modify state and controls so that they are visible for plotting (no
    %non-zero states or controls on plots for line width purposes)
    nonzero_rounded_controls=round(controls);
    for t=1:time_length
        for i=1:m
            if nonzero_rounded_controls(i,t)<=0.1
                nonzero_rounded_controls(i,t)=1;
            end
        end
    end
    
    rounded_state=round(state);
    nonzero_rounded_state=round(state);
    for t=1:time_length
        for i=1:n
            if nonzero_rounded_state(i,t)<=0.1
                nonzero_rounded_state(i,t)=1;
            end
        end
    end

    red=[1 0 0];
    green=[0 1 0];
    blue=[0 0 1];
    NodeColors=[];
    for i=nodes
        if ismember(i,warehouse_nodes)
            NodeColors=[NodeColors;red];
        elseif ismember(i,plant_nodes)
            NodeColors=[NodeColors;blue];
        else
            NodeColors=[NodeColors;green];

        end
    end
    M(time_length) = struct('cdata',[],'colormap',[]);
    count=1;
    for t=1:time_length
        LWidths = 3*nonzero_rounded_controls(:,t)/u_max;
        Names=cell(n,1);
        for k=1:n
           Names{k}=num2str(rounded_state(k,t));
        end
        h=plot(G,'EdgeLabel',round(controls(:,t)),'LineWidth',LWidths,'NodeLabel',Names,'ArrowSize',12,'NodeColor',NodeColors);
        for i=1:m
            if ismember(start_nodes(i),warehouse_nodes) && ismember(end_nodes(i),warehouse_nodes)
                highlight(h,[start_nodes(i) end_nodes(i)],'EdgeColor','r')
            elseif ismember(start_nodes(i),plant_nodes) && ismember(end_nodes(i),warehouse_nodes)
                highlight(h,[start_nodes(i) end_nodes(i)],'EdgeColor','b')
            else
                highlight(h,[start_nodes(i) end_nodes(i)],'EdgeColor','g')
            end
        end
        h.MarkerSize=25*sqrt(nonzero_rounded_state(:,t)/max(nonzero_rounded_state(:,t)));
        legend(strcat('t= ',num2str(t)));
        M(t) = getframe(gca);
    end
    if save_movie_plot==1
        fig = figure;
        set(fig, 'Position',position);
        movie(M,1,4);
        if save_video_as_avi==1
            v = VideoWriter('/Users/cobydavis/Desktop/supplychain.avi');
            v.FrameRate=4;
            open(v);
            writeVideo(v,M);
            close(v);
        end
    end
end