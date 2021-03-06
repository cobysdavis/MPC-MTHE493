function [ output_args ] = plotStatistics(horizons,cpu_time_horizons,opt_band_horizons,solver_iterations_horizons,solver_tolerance_horizons,shipping_cost_horizons,storage_cost_horizons,revenue_generated_horizons,production_cost_horizons)
cpu=cell2mat(cpu_time_horizons)
band=(cell2mat(opt_band_horizons))
its=cell2mat(solver_iterations_horizons)
avg_tol=[]
for i=1:length(solver_tolerance_horizons)
    avg_tol=[avg_tol,mean(cell2mat(solver_tolerance_horizons(i)))];
end
ship_cost=cell2mat(shipping_cost_horizons)
str_cost=cell2mat(storage_cost_horizons)
prod_cost=cell2mat(production_cost_horizons)
rev=cell2mat(revenue_generated_horizons)
data=[cpu;its;avg_tol;ship_cost;str_cost;prod_cost;rev]
% names={'cpu time';'number of iterations';'average tolerance';'shipping cost';'storage cost';'production cost';'revenue generated'}
filename = 'data.xlsx';
xlswrite(filename,data)

figure
plot(horizons,cpu)
ylabel('CPU time (s)');
xlabel('Horizon Length')
title('CPU time vs. Horizon Length')

figure
plot(horizons,its)
ylabel('Solver Iterations');
xlabel('Horizon Length')
title('Solver Iterations vs. Horizon Length')

figure
plot(horizons,avg_tol)
ylabel('Average Solver Tolerance');
xlabel('Horizon Length')
title('Average Solver Tolerance vs. Horizon Length')

figure
plot(horizons,ship_cost)
hold on
plot(horizons,str_cost)
hold on
plot(horizons,prod_cost)
hold on
plot(horizons,rev)
hold on
plot(horizons,rev-ship_cost-str_cost-prod_cost)
ylabel('Costs');
xlabel('Horizon Length')
title('Costs vs. Horizon Length')
legend('Shipping Cost','Storage Cost','Production Cost','Revenue Generated','Net Income')
end

