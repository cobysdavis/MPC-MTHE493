ans=[]
for i=1:length(horizons)
    ans=[ans,mean(cell2mat((solver_tolerance_horizons(i))))]
end