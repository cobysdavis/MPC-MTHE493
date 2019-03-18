function [ ] = plotMovie(movie_flag,save_movie_plot,save_video_as_avi,movie_name,horizons,xhorizons,uhorizons,G,time_length,nodes,warehouse_nodes,retail_nodes,plant_nodes,u_max,x_max,start_nodes,end_nodes)
m=numedges(G);
n=numnodes(G);
if movie_flag==1
    M((time_length+1)*length(horizons)) = struct('cdata',[],'colormap',[]);
    f=figure;
    position=[80 80 1200 900];
    set(f, 'Position',position);
    red=[1 0 0];
    green=[0 1 0];
    magenta=[1 0 1];
    NodeColors=[];
    for i=1:length(nodes)
        if ismember(nodes(i),warehouse_nodes)
            NodeColors=[NodeColors;red];
        elseif ismember(nodes(i),plant_nodes)
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
        
        NodeColors
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
            v = VideoWriter(strcat('/Users/cobydavis/Desktop/',movie_name,'.avi'));
            v.FrameRate=4;
            open(v);
            writeVideo(v,M);
            close(v);
        end
    end
end
end

