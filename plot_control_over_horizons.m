function [] = plot_control_over_horizons(path_num,horizons,uhorizons,time_length,x_legend)
    figure
    time=1:time_length;
    for j=1:length(horizons)
        u=cell2mat(uhorizons(j));
        stairs(time,u(path_num,:));
        hold on
    end
    legend(x_legend)
    xlabel('Time')
    ylabel('State Value')
    title(strcat('Path: ',' ',string(path_num),' Value Over Time'));
end

