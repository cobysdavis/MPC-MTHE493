function [] = plot_state_over_horizons(node_num,horizons,xhorizons,time_length,x_legend)
    figure
    time=1:time_length+1;
    for j=1:length(horizons)
        x=cell2mat(xhorizons(j));
        stairs(time,x(node_num,:));
        hold on
    end
    legend(x_legend)
    xlabel('Time')
    ylabel('State Value')
end

