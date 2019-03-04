close all
clc
%% Choose what this code saves/outputs:
network_plot=0;
run_cvx=1;
state_control_graphs=0;
movie_plot=1;
save_movie_plot=0;
save_video_as_avi=0;
%% Create Graph
% choose retail and warehouse nodes. choose warehouse to be 1:n1, and retail
% to be n1:n2

%manual graph generation
warehouse_nodes=1:4;
retail_nodes=5:7;
plant_nodes=8:9;
nodes=[warehouse_nodes,retail_nodes,plant_nodes];
% initial_warehouse_distribution=round(100*rand(1,length(warehouse_nodes)));
initial_warehouse_distribution=0*ones(1,length(warehouse_nodes));
initial_plant_distribution=20*ones(1,length(plant_nodes));
% initial_warehouse_distribution=10*[40;17;58;61];
%start nodes
start_nodes = [8 8 9 9 1 2 1 2 4 4 3];
%end nodes
end_nodes =   [1 2 1 2 3 4 4 5 5 6 7];



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
figure
if network_plot==1
    p=plotNetwork(G,warehouse_nodes,retail_nodes,plant_nodes,start_nodes,end_nodes,edge_start,edge_end);
end

%Cost function matrices
[warehouse_path_selector,retail_path_selector,warehouse_selector,plant_selector,plant_selector_cost,plant_path_selector]=configureCostFunctionMatrices(warehouse_nodes,retail_nodes,plant_nodes,edge_start,edge_end,n,m);
%% CVX Implementation
controls=[];
cost=[];
rate=[];
time_length=30;%overall lengthg of time which program runs for
horizons=[10];% list of T values (look ahead times)
xhorizons={};
uhorizons={};
rhorizons={};
if run_cvx==1
    for j=1:length(horizons)
        T=horizons(j);
        %% CVX Setup
        % max constraints, initial condition
        u_max=10;
        u_min=0;
        x_max=100000;
        x_min=0;
        rate_max=55;
        rate_min=0;
        u_max_vector = u_max*ones(m,T);
        u_min_vector=u_min*ones(m,T);
        x_max_vector = x_max*ones(n,T);
        x_min_vector=x_min*ones(n,T);
        rate_max_vector=rate_max*repmat(transpose(plant_selector),1,T);
        rate_min_vector=rate_min*repmat(transpose(plant_selector),1,T);
        x_0=setUpx_0(retail_nodes,warehouse_nodes,plant_nodes,initial_warehouse_distribution,initial_plant_distribution,nodes);
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
            minimize(sum(sum(warehouse_path_selector*u+plant_path_selector*u-retail_path_selector*u))+sum(sum(rate))+sum(sum(warehouse_selector*x+plant_selector*x)));
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
if movie_plot==1
    M((time_length+1)*length(horizons)) = struct('cdata',[],'colormap',[]);
    f=figure;
    position=[80 80 1200 900];
    set(f, 'Position',position);
    red=[1 0 0];
    green=[0 1 0];
    magenta=[1 0 1];
    NodeColors=[];
    for i=nodes
        if ismember(i,warehouse_nodes)
            NodeColors=[NodeColors;red];
        elseif ismember(i,plant_nodes)
            NodeColors=[NodeColors;magenta];
        else
            NodeColors=[NodeColors;green];
            
        end
    end
    
    %Modify state and controls so that they are visible for plotting (no
    %non-zero states or controls on plots for line width purposes)
    for horizon=1:length(horizons)
        controls=[cell2mat(uhorizons(horizon)),zeros(m,1)];
        state=cell2mat(xhorizons(horizon));
        nonzero_rounded_controls=round(controls);
        for t=1:time_length+1
            for i=1:m
                if nonzero_rounded_controls(i,t)<=0.1
                    nonzero_rounded_controls(i,t)=1;
                end
            end
        end
        rounded_state=round(state);
        nonzero_rounded_state=round(state);
        for t=1:time_length+1
            for i=1:n
                if nonzero_rounded_state(i,t)<=0.001
                    nonzero_rounded_state(i,t)=1;
                end
            end
        end
        
        count=1;
        for t=1:time_length+1
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
                    highlight(h,[start_nodes(i) end_nodes(i)],'EdgeColor','m')
                else
                    highlight(h,[start_nodes(i) end_nodes(i)],'EdgeColor','g')
                end
            end
            h.MarkerSize=25*sqrt(nonzero_rounded_state(:,t)/max(nonzero_rounded_state(:,t)));
            legend(strcat('t= ',num2str(t)));
            title(strcat('Horizon Length= ',num2str(horizons(horizon))));
            M(t) = getframe(gca);
        end
    end
    
    if save_movie_plot==1
        fig = figure;
        set(fig, 'Position',position);
%movie(M,time to replay, fps)
        movie(M,1,5);
        if save_video_as_avi==1
            v = VideoWriter('/Users/cobydavis/Desktop/supplychain.avi');
            v.FrameRate=4;
            open(v);
            writeVideo(v,M);
            close(v);
        end
    end
end