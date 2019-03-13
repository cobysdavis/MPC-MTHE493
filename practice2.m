R = 6371; % earth radius in km
latspacing = 10; 
lonspacing = 20; 
% lines of longitude: 
[lon1,lat1] = meshgrid(-180:lonspacing:180,linspace(-90,90,300)); 
[x1,y1,z1] = sph2cart(lon1*pi/180,lat1*pi/180,R); 
plot3(x1,y1,z1,'-','color',0.5*[1 1 1])
hold on
% lines of latitude: 
[lat2,lon2] = meshgrid(-90:latspacing:90,linspace(-180,180,300)); 
[x2,y2,z2] = sph2cart(lon2*pi/180,lat2*pi/180,R); 
plot3(x2,y2,z2,'-','color',0.5*[1 1 1])
axis equal tight off