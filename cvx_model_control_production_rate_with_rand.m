function [actual_cost,state,controls,rate] =  cvx_model_control_production_rate_with_rand(time_length,T,rate_max,rate_min,u_max,u_min,x_max,x_min,x_0,rand_rate,n,m,Incidence,warehouse_path_selector,retail_path_selector,plant_path_selector,plant_selector_constraint,warehouse_selector,plant_selector);
%% CVX Setup
% max constraints, initial condition
u_max_vector = u_max*ones(m,T);
u_min_vector=u_min*ones(m,T);
x_max_vector = x_max*ones(n,T);
x_min_vector=x_min*ones(n,T);
rate_max_vector=rate_max*repmat(transpose(plant_selector_constraint),1,T);
rate_min_vector=rate_min*repmat(transpose(plant_selector_constraint),1,T);
actual_cost=0;
state=[x_0]; % trajectory system actually takes num_nodes*time_length matrix
controls=[]; % control actions system actually takes num_paths*time_length matrix
xs=[]; % all state values that were computed along the way
us=[];  % all control values that were computed along the way
rs=[];  % all rate control values that were computed along the way
for i=1:time_length
    cvx_begin quiet
    disp(strcat(strcat('calculating optimal control control production model: ',num2str(i)),strcat(' for horizon T=',num2str(T))))
    variables x(n,T) u(m,T) rate(n,T)
    minimize(sum(sum(warehouse_path_selector*u+plant_path_selector*u-retail_path_selector*u))+sum(sum(rate))+sum(sum(warehouse_selector*x+plant_selector*x)));
    subject to
    %system dynamics:
    %with production rate as a control
    x(:,1:end)==[state(:,end) x(:,1:end-1)]+Incidence*u(:,1:end)+rate(:,1:end);
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
    cost_at_moment=warehouse_path_selector*u(:,1)+plant_path_selector*u(:,1)-retail_path_selector*u(:,1)+warehouse_selector*x(:,1)+plant_selector*x(:,1)+plant_selector*rate(:,1);
    actual_cost=actual_cost+cost_at_moment;
    %randomness and production rate
    r=-rand_rate+(rand_rate)*rand(n,1);
    %with random error
    state(:,end)=max(state(:,end)+state(:,end).*r,0);
    
    state=[state,x(:,1)];
    controls=[controls,u(:,1)];
    rate=[rate,rate(:,1)];
    %saving all possible controls thrhoughout time for one single horizon
    xs=[xs x];
    us=[us u];
    rs=[rs rate];
end