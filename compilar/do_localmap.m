 function do_localmap(latitude,longitude)
 

 axes('position',[0.68,0.35,0.4,0.45]);
 m_proj('miller','long',[-12.5 -5.0],'lat',[35.0 44.5]);
 %ha=m_plot(longitude,latitude,'or','MarkerSize',4, 'MarkerFaceColor',[1 .5 0]);
 m_usercoast('portuguese_coastline.mat');
 %m_usercoast('portuguese_coastline.mat','patch','y','FaceAlpha',0.2);
 hold on
 ha=m_plot(longitude,latitude,'or','MarkerSize',4, 'MarkerFaceColor',[1 .5 0]);
 m_grid('box','fancy','linestyle','none','fontsize',6);

 