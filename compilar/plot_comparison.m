function plot_comparison(station,initialdate,enddate,days_after,model_folder,buoy_folder,extension,label_station,cprop,lat,lon);

global astro_tide plot_data plot_model statistic down_data property plot_datan ini_date end_datefi publish
initial = initialdate;
NumDays=enddate+days_after-initialdate;
NumDays1=enddate-initialdate;

if strcmp(plot_data,'1') & strcmp(plot_model,'0') & strcmp(plot_datan,'1')
 [Y, M, D, H, MN, S] =datevec(initialdate);
 [Y1, M1, D1, H1, MN1, S1] = datevec(enddate);
 D2=D1+1;
  
 if M<10;
    Mstr =['0',num2str(M)];
 else
    Mstr =num2str(M);
 end
 if M1<10;
    M1str =['0',num2str(M1)];
 else
    M1str =num2str(M1);
 end
 if D<10;
    Dstr =['0',num2str(D)];
 else
    Dstr =num2str(D);
 end
 if D1<10;
    D1str =['0',num2str(D1)];
 else
    D1str =num2str(D1);
 end
 ini_date=[num2str(Y),'-',Mstr, '-', Dstr];
 end_date=[num2str(Y1),'-',M1str, '-', D1str];
 
end

if strcmp(plot_model,'1')
 forec_index='0';
 for i=1:NumDays
        [Y, M, D, H, MN, S] = datevec(initial);
        [Y1, M1, D1, H1, MN1, S1] = datevec(initial+1); 
		if ((initial > now) | (initial+1  > now)) & strcmp(forec_index,'0') 
		   forec=length(model_prop);
		   forec_index='1';
		end
        if M<10;
            Mstr =['0',num2str(M)];
        else
            Mstr =num2str(M);
        end
        if M1<10;
            M1str =['0',num2str(M1)];
        else
            M1str =num2str(M1);
        end
        if D<10;
            Dstr =['0',num2str(D)];
        else
            Dstr =num2str(D);
        end
        if D1<10;
            D1str =['0',num2str(D1)];
        else
            D1str =num2str(D1);
        end
        run_folder= [num2str(Y),'-',Mstr, '-', Dstr,'_',num2str(Y1),'-',M1str, '-', D1str, '\'];
        model_file =[model_folder, run_folder,station, extension]; %aqui
        [model_prop1, model_time1] = getmodelprop(model_file,initial,initial+1,cprop);
        
        if i==1
            model_prop=model_prop1;
            model_time=model_time1;
        else
            model_prop=cat(1,model_prop,model_prop1);
            model_time=cat(2,model_time,model_time1);     
        end
		if i==1
		   ini_date=[num2str(Y),'-',Mstr, '-', Dstr];
		elseif (i==NumDays)
		   end_date=[num2str(Y),'-',Mstr, '-', Dstr];
		end
        initial=initial+1;
 end
 if (NumDays==1)
     end_date=[num2str(Y1),'-',M1str, '-', D1str];
 end
end


 f=figure;
   set(f,'Position',[200 200 800 500]);
   axes('position',[0.07,0.1,0.65,0.8]);

if strcmp(plot_data,'1') & strcmp(plot_datan,'1')
    [buoy_prop,buoy_time] = getmodelprop(buoy_folder,initialdate,enddate,8);
	if strcmp(property,'salinity')
	 for i=1:length(buoy_prop)
	 
	    if buoy_prop(i)<0.05
		   buoy_prop(i)=NaN;
		end
     end
	end
	max_data=max(buoy_prop);
    min_data=min(buoy_prop);
    hold on
    h_date=plot(buoy_time,buoy_prop, 'ro', 'LineWidth',0.1,'MarkerSize',2,'MarkerFaceColor',[1 .5 0]);
end

if strcmp(plot_model,'1')
 hold on
 max_model=max(model_prop);
 min_model=min(model_prop);
 plot(model_time, model_prop, 'bo-', 'LineWidth',2,'MarkerSize',2);


 if (days_after > 0) | strcmp(forec_index,'1')
      hold on
	  plot(model_time(forec:end),model_prop(forec:end),'go-','LineWidth',2,'MarkerSize',2)
 end
end

if  strcmp(plot_data,'1') && strcmp(plot_model,'1') & strcmp(plot_datan,'1') & (days_after == 0)
     h = legend('Observation','MOHID hindcast');
     uistack(h_date,'top');
elseif strcmp(plot_data,'1') && strcmp(plot_model,'1') & strcmp(plot_datan,'1') & (days_after > 0)
     h = legend('Observation','MOHID hindcast','MOHID forecast');
     uistack(h_date,'top');
elseif (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) && strcmp(plot_model,'1')& (days_after == 0)
     h = legend('MOHID hindcast');
elseif (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) && strcmp(plot_model,'1')& (days_after > 0)
     h = legend('MOHID hindcast','MOHID forecast');	 
elseif strcmp(plot_data,'1') && strcmp(plot_model,'0') & strcmp(plot_datan,'1')
     h = legend('Observation');
end
%set(h,'Visible', 'off') %Turn the box off
%set(allchild(h),'visible','on'); % Hides the legend's axes (legend border and background)
legend boxoff; % Hides the legend's axes (legend border and background)
grid on
StartDate=initialdate;

EndDate=enddate+days_after;
xData = linspace(StartDate,EndDate,9);
%xlabel('Time (hours, UTC+1)');
   
   if strcmp(property,'temperature')
         ylabel('Temperature(ºC)');
   elseif strcmp(property,'salinity')
          ylabel('Salinity');
   end
   title([ label_station, ' - ',property],'fontsize',14,'fontweight','bold');
   

   
   if strcmp(plot_data,'1') && strcmp(plot_model,'1') & strcmp(plot_datan,'1')
       max_graph=max(max_model,max_data)+4;
       min_graph=min(min_model,min_data)-4;
   elseif (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) && strcmp(plot_model,'1')
       max_graph=max_model+4;
       min_graph=min_model-4;
   elseif strcmp(plot_data,'1') && strcmp(plot_model,'0') & strcmp(plot_datan,'1')
       max_graph=max_data+4;
       min_graph=min_data-4;   
   end
   
   ylim([[min_graph] [max_graph]]);
   
   
   set(gca, 'XTick',xData);
   %datetick('x','ddmmm HH:MMPM','keepticks');
   dateNtick('x',19);
  
   box on
   set(gca,'FontSize',10);
   set(gca,'LineWidth',2);
   h_xlabel = get(gca,'XLabel');
   h_ylabel = get(gca,'YLabel');
   h_yticklabel=get(gca,'YTickLabel');
   set(h_xlabel,'FontSize',10);
   set(h_ylabel,'FontSize',10);
   set(gca, 'Layer','top');
  
  
   hold on
   do_localmap(lat,lon);

   filename = [property,'_',label_station,'.png'];
   filename2 = [ini_date,'_',end_datefi,'.png'];
   filename3 = ['latest.png'];
   path1=[publish,label_station,'\',property,'\PCOMS\'];
   
  %to check if the folder exist. If not create it.    
   if (exist(path1)<=0)
     mkdir (path1)
   end
   
   pathname2 = [path1,filename2];
   pathname3 = [path1,filename3];
   set(gcf,'PaperPositionMode','auto')
   
   saveas(gcf,filename,'png');
   
   copyfile(filename,pathname2,'f')
   copyfile(filename,pathname3,'f')


end