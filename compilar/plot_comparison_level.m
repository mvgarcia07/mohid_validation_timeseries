function plot_comparison_level(station,initialdate,enddate,days_after,model_folder,buoy_folder,buoy_path,extension,plotlabel,cprop,lat,lon);

global astro_tide plot_data statistic down_data starefe plot_level plot_model plot_datan ini_date end_datefi publish forecast1

try
initial = initialdate;
NumDays=enddate+days_after-initialdate;
NumDays1=enddate-initialdate;

if strcmp(plot_data,'1') && strcmp(plot_model,'0') & strcmp(plot_datan,'1')

 [Y, M, D, H, MN, S] =datevec(initialdate);
 [Y1, M1, D1, H1, MN1, S1] = datevec(enddate);
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
%		if ((initial > now) | (initial+1  > now)) & strcmp(forec_index,'0')
       
        if ((initial > now) | (initial+1  > now)) & strcmp(forecast1,'1') & strcmp(forec_index,'0')	
		   forec=length(model_prop)
		   forec_index='1'
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
        run_folder = [num2str(Y),'-',Mstr, '-', Dstr,'_',num2str(Y1),'-',M1str, '-', D1str, '\'];
        model_file =[model_folder, run_folder, station, extension]; %AQUI plotlabel
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
%model_mean=mean(model_prop)
 model_prop=model_prop-mean(model_prop)+starefe;

if strcmp(statistic,'1')
%search for the model max and min
 [maxtab, mintab] = peakdet(model_prop,0.1); %0.05
 all_max_min=cat(1,maxtab,mintab);
 all_max_min=sortrows(all_max_min);

%check if the first value is a max or min
 if all_max_min(1,1)==1
    all_max_min=all_max_min(2:length(all_max_min),1);
   
 else
    
    all_max_min=all_max_min(:,1);
 end
 disc1=[];
 if model_prop(all_max_min(1))<model_prop(all_max_min(2))
    disc={'low tide'};
 else
    disc= {'high tide'};
 end 
 disc1=[disc1; disc];

 for i=2:length(all_max_min)
    if model_prop(all_max_min(i-1))>model_prop(all_max_min(i))
        disc= {'low tide'};
    else
        disc= {'high tide'};
    end 
    disc1=[disc1; disc];
 end
end
end

if strcmp(astro_tide,'1')
   prev_file= [buoy_path,'srh_format\Prev\',num2str(Y),'\prev_',station,extension];
   [prev_prop, prev_time,prev_index] = getmodelprop(prev_file,initialdate,enddate+days_after,8);
   prev_prop=prev_prop-mean(prev_prop)+starefe;
end

if strcmp(plot_data,'1') & strcmp(plot_datan,'1')
	[buoy_prop,buoy_time,buoy_index] = getmodelprop(buoy_folder,initialdate,enddate,8);
    buoy_mean=mean(buoy_prop);
    buoy_prop=buoy_prop-buoy_mean;
    buoy_prop( buoy_prop==-buoy_mean)=NaN; 
    buoy_prop=buoy_prop+starefe;
end

%if graph is on plot graphic with model results, data, astronomical tide


   f=figure;
   set(f,'Position',[200 200 800 500]);
   if strcmp(plot_level,'1') && strcmp(statistic,'1')
     set(gcf,'PaperPositionMode','auto')
;
  
     mt=datestr(model_time(all_max_min)','HH:MM');
     mp=single(model_prop(all_max_min));
 
     for i=1:length(mp)
        mp1= sprintf(' %0.2f', mp(i));
        mp2(i)={mp1};
	    md1=datestr(model_time(all_max_min(i))','yyyy-mm-dd ');
	    md2(i)={md1};
	    mt1=datestr(model_time(all_max_min(i))','HH:MM');
	    mt2(i)={mt1 };
     end

     mp2=mp2';
     mt2=mt2';
     md2=md2';
     mmp2=[md2,mt2,mp2,disc1];

     cnames = {'Tide(m)',[]};
     t = uitable('Parent',f,'Data',mmp2,... 
            'ColumnWidth',{5},'RowName',[],'Position',[640 340 242 110]);
     set(t,'ColumnName',{'<html><font size="3"><font face="Helvetica"><b>Date</b></font></font></html>','<html><font size="3"><font face="Helvetica"><b>Time</b></font></font></html>','<html><font size="3"><font face="Helvetica"><b>Tide (m)</b></font></font></html>',' '})      
     set(t,'ColumnWidth',{80,40,50,70},'FontSize',10,'FontWeight','bold');

   end
   

   axes('position',[0.07,0.1,0.65,0.8]);
   
   
   if strcmp(astro_tide,'1')
      hold on
      plot (prev_time,prev_prop, 'k-', 'LineWidth',2);
   end
   
   
   if strcmp(plot_data,'1') & strcmp(plot_datan,'1')
      hold on
      h_date=plot(buoy_time,buoy_prop, 'ro-', 'LineWidth',0.1,'MarkerSize',2,'MarkerFaceColor',[1 .5 0]);
 %       h_date=plot(buoy_time,buoy_prop, 'ro-', 'LineWidth',0.2,'MarkerSize',1.8,'MarkerColor',[1 .5 0]);
   end
   if strcmp(plot_model,'1')
      hold on
      h_model=plot (model_time, model_prop, 'b-', 'LineWidth',3,'MarkerSize',2);

	  
      if strcmp(statistic,'1')
	    hold on
        h_stat=plot(model_time(all_max_min), model_prop(all_max_min), 'c*')
	  end
   
      if (days_after > 0) | strcmp(forec_index,'1')
        hold on
	    ha_fore=plot(model_time(forec:end),model_prop(forec:end),'g-','LineWidth',3,'MarkerSize',2);
      end
   end  
   
   if (days_after > 0)
    if strcmp(astro_tide,'1') & strcmp(plot_data,'1') & strcmp(plot_model,'1') & strcmp(plot_datan,'1') & strcmp(statistic,'0')
          h = legend('Prediction','Observation','MOHID hindcast','MOHID forecast');
		  uistack(h_date,'top');
    elseif strcmp(astro_tide,'1') & (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) & strcmp(plot_model,'1') & strcmp(statistic,'0')
          h = legend('Prediction','MOHID hindcast','MOHID forecast'); 
    elseif strcmp(astro_tide,'1') & strcmp(plot_data,'1') & strcmp(plot_model,'0') & strcmp(plot_datan,'1')
           h = legend('Prediction','Observation');
    end
    if strcmp(astro_tide,'0') & strcmp(plot_data,'1') & strcmp(plot_model,'1') & strcmp(plot_datan,'1') & strcmp(statistic,'0')
          h = legend('Observation','MOHID hindcast','MOHID forecast');
		  uistack(h_date,'top');
    elseif strcmp(astro_tide,'0') & (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) & strcmp(plot_model,'1')
          h = legend('MOHID hindcast','MOHID forecast');
    elseif strcmp(astro_tide,'0') & strcmp(plot_data,'1') & strcmp(plot_model,'0') & strcmp(plot_datan,'1')
          h = legend('Observation');
    end
   else 
    if strcmp(astro_tide,'1') & strcmp(plot_data,'1') & strcmp(plot_model,'1') & strcmp(plot_datan,'1') & strcmp(statistic,'0')
          h = legend('Prediction','Observation','MOHID hindcast');
		  uistack(h_date,'top');
    elseif strcmp(astro_tide,'1') & (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) & strcmp(plot_model,'1') & strcmp(statistic,'0')
          h = legend('Prediction','MOHID hindcast'); 
    elseif strcmp(astro_tide,'1') & strcmp(plot_data,'1') & strcmp(plot_model,'0') & strcmp(plot_datan,'1')
           h = legend('Prediction','Observation');
    end
    if strcmp(astro_tide,'0') & strcmp(plot_data,'1') & strcmp(plot_model,'1') & strcmp(plot_datan,'1') & strcmp(statistic,'0')
          h = legend('Observation','MOHID hindcast');
		  uistack(h_date,'top');
    elseif strcmp(astro_tide,'0') & (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) & strcmp(plot_model,'1')
          h = legend('MOHID');
    elseif strcmp(astro_tide,'0') & strcmp(plot_data,'1') & strcmp(plot_model,'0') & strcmp(plot_datan,'1')
          h = legend('Observation');
    end
   end
   
   legend boxoff % Hides the legend's axes (legend border and background)
  
   StartDate=initialdate;
   EndDate=enddate+days_after;
  
   xData = linspace(StartDate,EndDate,9);
  
   grid on
   
   ylabel('Water level (m)');
   title([ plotlabel, ' - ','water level '],'fontsize',14,'fontweight','bold');
   
   if strcmp(plot_model,'1')
      max_graph=max(model_prop)+1;
      min_graph=max(0,min(model_prop)-1);
   else 
      max_graph=max(buoy_prop)+1;
      min_graph=max(0,min(buoy_prop)-1);
   end
   ylim([[min_graph] [max_graph]]);
   
   
  
 
   set(gca, 'XTick',xData);
   %datetick('x','ddmmm HH:MMPM','keepticks');
   dateNtick('x',19);
  
   box on
   set(gca,'FontSize',10);
   set(gca,'LineWidth',2);
%   h_xlabel = get(gca,'XLabel');
   h_ylabel = get(gca,'YLabel');
   h_yticklabel=get(gca,'YTickLabel');
 %  set(h_xlabel,'FontSize',14);
   set(h_ylabel,'FontSize',12);
   set(gca, 'Layer','top');
   
   hold on

   do_localmap(lat,lon);
   
 
   filename = ['level','_',plotlabel,'.png'];
   filename2 = [ini_date,'_',end_datefi,'.png'];
   filename3 = ['latest.png'];
   
   path1=[publish,plotlabel,'\level\PCOMS\'];
   
%to check if the folder exist. If not create it.   
   if (exist(path1)<=0)
     mkdir (path1)
   end
   
   pathname2 = [path1,filename2];
   pathname3 = [path1,filename3];
   set(gcf,'PaperPositionMode','auto')
  
   saveas(gcf,filename,'png');
   copyfile(filename,pathname2,'f');
   copyfile(filename,pathname3,'f')


%if statisc is on plot table with min, max and error

catch
  mfidi = fopen('error_timeseries.dat','a');
  fprintf (mfidi,'%s\n','an error occoured in plot_comparison_level.m');
  fclose(mfidi);
  disp('an error occoured in plot_comparison_level.m')
end

end