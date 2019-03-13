function [actual_cost,state,controls] =  cvx_model_fixed_production_rate_with_rand(production_rate,time_length,T,u_max,u_min,x_max,x_min,x_0,rand_rate,n,m,Incidence,warehouse_path_selector,retail_path_selector,plant_path_selector,warehouse_selector,plant_selector);
% CVX Setup
% max constraints, initial condition
u_max_vector = u_max*ones(m,T);
u_min_vector=u_min*ones(m,T);
x_max_vector = x_max*ones(n,T);
x_min_vector=x_min*ones(n,T);
actual_cost=0;
state=[x_0]; % trajectory system actually takes num_nodes*time_length matrix
controls=[]; % control actions system actually takes num_paths*time_length matrix
xs=[]; % all state values that were computed along the way
us=[];  % all control values that were computed along the way
for i=1:time_length
    cvx_begin quiet
    disp(strcat(strcat('calculating optimal control: ',num2str(i)),strcat(' for horizon T=',num2str(T))))
    variables x(n,T) u(m,T);
    minimize(sum(sum(warehouse_path_selector*u+plant_path_selector*u-retail_path_selector*u))+sum(sum(warehouse_selector*x+plant_selector*x)));
    subject to
    %system dynamics:
    %with fixed production rate
    x(:,1:end)==[state(:,end) x(:,1:end-1)]+Incidence*u(:,1:end)+repmat(production_rate*transpose(plant_selector),1,T);
    %shipping constraints
    x <= x_max_vector;
    x >= x_min_vector;
    %storage constraints
    u <= u_max_vector;
    u >= u_min_vector;
    cvx_end
    cost_at_moment=warehouse_path_selector*u(:,1)+plant_path_selector*u(:,1)-retail_path_selector*u(:,1)+warehouse_selector*x(:,1)+plant_selector*x(:,1);
    actual_cost=actual_cost+cost_at_moment;
    state=[state,x(:,1)];
    %randomness factor
    r=-rand_rate+(rand_rate)*rand(n,1);
    %with random error
    state(:,end)=max(state(:,end)+state(:,end).*r,0);
    controls=[controls,u(:,1)];
    xs=[xs x];
    us=[us u];
end
end


