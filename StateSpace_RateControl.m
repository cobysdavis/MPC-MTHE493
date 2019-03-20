close all
clc
clear all
%% Choose what this code saves/outputs:
network_plot=1;
run_cvx=1;
state_control_graphs=0;
movie_flag=1;
save_movie_plot=0;
save_video_as_avi=0;
%% Create Graph
% choose retail and warehouse nodes. choose warehouse to be 1:n1, and retail
% to be n1:n2

warehouse_nodes=1:6;
retail_nodes=7:9;
plant_nodes=10;
nodes=[warehouse_nodes,retail_nodes,plant_nodes];
% initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
initial_warehouse_distribution=0*ones(1,length(warehouse_nodes));
initial_plant_distribution=0*ones(1,length(plant_nodes));
% initial_warehouse_distribution=10*[40;17;58;61];
%start nodes
start_nodes = [10 10 2 2 1 3 4 5 6];
%end nodes
end_nodes =   [1 2 7 8 3 4 5 6 9];

%automatic graph generation
% warehouse_nodes=1:6;
% retail_nodes=7:9;
% plant_nodes=10:14;
% nodes=[warehouse_nodes,retail_nodes,plant_nodes];
% initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
% initial_plant_distribution=800*ones(1,length(plant_nodes));
% pw=0.2;
% pr=0.2;
% pp=0.2;
% [start_nodes,end_nodes]=generateRandomGraph(warehouse_nodes,retail_nodes,plant_nodes,pw,pr,pp);
% [retail_nodes,plant_nodes]=cleanUp(start_nodes,end_nodes,warehouse_nodes,retail_nodes,plant_nodes);



%defining the digraph based on start,end
G=digraph(start_nodes,end_nodes);
m=numedges(G);
n=numnodes(G);
%% Incidence Matrix
Incidence=computeIncidence(G);
%% Plotting edge labels and colours and order
[nonretail_paths,retail_paths]=computeRetailPaths(G,warehouse_nodes,retail_nodes,start_nodes,end_nodes);
[edge_start,edge_end]=computeEdges(Incidence,G);
figure
if network_plot==1
    p=plotNetwork(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end);
end

%Cost function matrices
[warehouse_path_selector,retail_path_selector,warehouse_selector,plant_selector,plant_path_selector,plant_selector_constraint] = configureCostFunctionMatrices(warehouse_nodes,retail_nodes,plant_nodes,edge_start,edge_end,n,m)%% CVX Implementation
retail_path_selector(7)=1000
controls=[];
cost=[];
rate=[];
time_length=10;%overall lengthg of time which program runs for
horizons=[1];% list of T values (look ahead times)
xhorizons={};
uhorizons={};
rhorizons={};
if run_cvx==1
    for j=1:length(horizons)
        T=horizons(j);
        %% CVX Setup
        % max constraints, initial condition
        u_max=100;
        u_min=0;
        x_max=100000;
        x_min=0;
        rate_max=50;
        rate_min=0;
        u_max_vector = u_max*ones(m,T);
        u_min_vector=u_min*ones(m,T);
        x_max_vector = x_max*ones(n,T);
        x_min_vector=x_min*ones(n,T);
        rate_max_vector=rate_max*repmat(transpose(plant_selector),1,T);
        rate_min_vector=rate_min*repmat(transpose(plant_selector),1,T);
        x_0=setUpx_0(n,retail_nodes,warehouse_nodes,plant_nodes,initial_warehouse_distribution,initial_plant_distribution,nodes);
        actual_cost=0;
        state=[x_0]; % trajectory system actually takes num_nodes*time_length matrix
        controls=[]; % control actions system actually takes num_paths*time_length matrix
        xs=[]; % all state values that were computed along the way
        us=[];  % all control values that were computed along the way
        rs=[];  % all rate control values that were computed along the way
        for i=1:time_length
            cvx_begin quiet
            disp(strcat(strcat('calculating optimal control: ',num2str(i)),strcat(' for horizon T=',num2str(T))))
            variables x(n,T) u(m,T) rate(n,T)
%             minimize(sum(sum(warehouse_path_selector*u+plant_path_selector*u-retail_path_selector*u))+sum(sum(rate))+sum(sum(warehouse_selector*x+plant_selector*x)));
            minimize(sum(sum(warehouse_path_selector*u+plant_path_selector*u-retail_path_selector*u)))

            subject to
            %system dynamics:
            %with production rate
            x(:,1:end)==[state(:,end) x(:,1:end-1)]+Incidence*u(:,1:end)+rate(:,1:end);
            %without production rate
            %x(:,1:end)==[state(:,end) x(:,1:end-1)]+Incidence*u(:,1:end);
            %shipping constraints
            x <= x_max_vector;
            x >= x_min_vector;
            %storage constraints
            u <= u_max_vector;
            u >= u_min_vector;
            %rate constraints
            rate <= rate_max_vector;
            rate >= rate_min_vector;
            
            cvx_end
            
            %manual cost calculation
            cost_at_moment=warehouse_path_selector*u(:,1)+plant_path_selector*u(:,1)-retail_path_selector*u(:,1)+warehouse_selector*x(:,1)+plant_selector*x(:,1);
            actual_cost=actual_cost+cost_at_moment;
            state=[state,x(:,1)];
            rate=[rate,rate(:,1)];
            %randomness and production rate
            %-5 + (5+5)*rand(10,1)
            rand_rate=0;
            r=-rand_rate+(rand_rate)*rand(n,1);
            %with random error
                %state(:,end)=transpose(production_rate*plant_selector)+max(state(:,end)+state(:,end).*r,0);
            controls=[controls,u(:,1)];
            %saving all possible controls thrhoughout time for one single horizon
            xs=[xs x];
            us=[us u];
            rs=[rs rate];
        end
        %saving all actual costs
        cost=[cost,actual_cost];
        %storing all state in cell data structure from all horizons
        xhorizons{end+1}=state;
        uhorizons{end+1}=controls;
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
    plot(horizons,cost/abs(min(cost)))
    xlabel('Horizon Length')
    ylabel('Cost')
    x_legend={};
    for i=1:length(horizons)
        x_legend{end+1}=strcat('Horizon Length:' ,num2str(i));
    end
    
    figure
    time=1:time_length+1;
    for j=1:length(horizons)
        x=cell2mat(xhorizons(j))
        stairs(time,x(5,:));
        hold on
    end
    legend(x_legend)
    xlabel('Time')
    ylabel('State Value') 
end

%% Movie
movie_name='production_control';
plotMovie(movie_flag,save_movie_plot,save_video_as_avi,movie_name,horizons,xhorizons,uhorizons,G,time_length,nodes,warehouse_nodes,retail_nodes,plant_nodes,u_max,x_max,start_nodes,end_nodes)