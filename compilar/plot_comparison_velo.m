function plot_comparison_velo(station,initialdate,enddate,days_after,model_folder,buoy_folder,buoy_folder1,extension,label_station,cprop,cprop1,lat,lon);

global astro_tide plot_data statistic down_data property plot_model plot_datan ini_date end_datefi publish
initial = initialdate;
NumDays=enddate+days_after-initialdate;
NumDays1=enddate-initialdate;

if strcmp(plot_data,'1') & strcmp(plot_model,'0') & strcmp(plot_datan,'1')
 forec_index='0';
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
        model_file =[model_folder, run_folder, station, extension]; %AQUI
        [model_prop1, model_time1, model_index1] = getmodelprop(model_file,initial,initial+1,cprop);
        [model_prop2, model_time2, model_index2] = getmodelprop(model_file,initial,initial+1,cprop1);
        
        if i==1
            model_prop=model_prop1;
            model_time=model_time1;
            model_propa=model_prop2;
            model_timea=model_time2;
        else
            model_prop=cat(1,model_prop,model_prop1);
            model_time=cat(2,model_time,model_time1);
            model_propa=cat(1,model_propa,model_prop2);
            model_timea=cat(2,model_timea,model_time2);
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

%velocity from m/s to cm/s
 model_mod=model_prop*100;

%direction from º to rad and rotate axis for matlab feather
% from deg to rad
 rdir = model_propa * pi/180;
 umodela=model_mod.*sin(rdir);
 vmodela=model_mod.*cos(rdir);
end


f=figure;
set(f,'Position',[200 200 800 500]);

if strcmp(plot_data,'1') & strcmp(plot_datan,'1')
    [buoy_prop,buoy_time,data_index1] = getmodelprop(buoy_folder,initialdate,enddate,8);
    [buoy_prop1,buoy_time1,data_index2] = getmodelprop(buoy_folder1,initialdate,enddate,8);
   if (data_index1==0 &  data_index2==0)
	 buoy_prop=buoy_prop*100;

	%%direction from º to rad and rotate axis for matlab feather
     rdir1 = buoy_prop1 * pi/180;
     udata=buoy_prop.*sin(rdir1);
     vdata=buoy_prop.*cos(rdir1);
     maxdat = max(buoy_prop.*sign(vdata));
     mindat = min(buoy_prop.*sign(vdata));
   
     	
	 subplot(2,1,1)
     hi=myfeather(udata,vdata);
	 set(hi,'color',[1 .5 0],'LineWidth',1);
	  
	 if strcmp(plot_model,'0') 
    	max_graph=max(1,maxdat);
	    min_graph=min(-1,mindat);
 	 
	 elseif strcmp(plot_model,'1')

	 %find the model results that correspond to the data 
        num1=0;
	    for i = 1:length(buoy_time)
          num1=num1+1;
          position = find(model_time==buoy_time(i),1,'last');
          umodel(num1)=umodela(position);
	      vmodel(num1)=vmodela(position);
        end
	    int=sqrt((umodel.*umodel)+(vmodel.*vmodel));
	    maxmod = max(int.*sign(vmodel));
	    minmod = min(int.*sign(vmodel));
	    max_graph=max(maxdat,maxmod);
	    min_graph=min(mindat,minmod);
	 end
     box on
	 axis([[-15] [length(udata)+15] [min_graph-5] [max_graph+5] ]);
     set(gca,'FontSize',12);
     set(gca,'LineWidth',1);
     h_xlabel = get(gca,'XLabel');
     h_ylabel = get(gca,'YLabel');
     h_yticklabel=get(gca,'YTickLabel');
	 set(gca,'XMinorTick','off')
     set(gca, 'Layer','top');
	 StartDate=initialdate;
     EndDate=enddate+days_after;
	 TotalDate=24;
	 %TotalDate=(NumDays/3)*24;
     xData1 = linspace(StartDate,EndDate,NumDays+1);
     set(gca,'XTick',[1:TotalDate:NumDays*TotalDate+1]);
     xdata_label=datestr(xData1,'ddmmm');
     set(gca,'XTickLabel',xdata_label);
     ylabel('Current (cm/s)','FontSize',14);
     title([ label_station, ' - ',property],'fontsize',14,'fontweight','bold');
     ylim2=get(gca,'YLim');
     xlim2=get(gca,'XLim');
     text(xlim2(2)-10,ylim2(2),'Observation',...
        'VerticalAlignment','bottom',...
        'HorizontalAlignment','left','color',[1 .5 0],'FontSize',12,'fontweight','bold');
   end
elseif (strcmp(plot_data,'0') | strcmp(plot_datan,'0')) & strcmp(plot_model,'1')
     umodel=umodela;
	 vmodel=vmodela;
	 maxmod = max(vmodel);
	 minmod = min(vmodel);
	 max_graph=max(1,maxmod);
	 min_graph=min(-1,minmod);
end


if strcmp(plot_model,'1') & (model_index1==0 & model_index2==0) 
  if strcmp(plot_data,'1') & strcmp(plot_datan,'1')
    subplot(2,1,2)
    hj=myfeather(umodel,vmodel,'b');
	set(hj,'color','b','LineWidth',1);
	axis([[-15] [length(umodel)+15] [min_graph-5] [max_graph+5] ]);
	
  elseif (strcmp(plot_data,'0') | strcmp(plot_datan,'0'))
	subplot(2,1,1)
    hj=myfeather(umodel(1:6:end),vmodel(1:6:end),'b');
	set(hj,'color','b','LineWidth',1);
	axis([[-15] [length(umodel)/6+15] [min_graph-5] [max_graph+5] ]);
	title([ label_station, ' - ',property],'fontsize',14,'fontweight','bold');
  end
    box on
    
    set(gca,'FontSize',12);
    set(gca,'LineWidth',1);
    h_xlabel = get(gca,'XLabel');
    h_ylabel = get(gca,'YLabel');
    h_yticklabel=get(gca,'YTickLabel');
    set(gca,'XMinorTick','off');
    set(gca, 'Layer','top');

    StartDate=initialdate;
    EndDate=enddate+days_after;
	TotalDate=24;
	xData1 = linspace(StartDate,EndDate,NumDays+1);
    set(gca,'XTick',[1:TotalDate:NumDays*TotalDate+1]);
    xdata_label=datestr(xData1,'ddmmm');
    set(gca,'XTickLabel',xdata_label);
    ylabel('Current (cm/s)','FontSize',14);
%	xlabel('Time (hours, UTC+1)','FontSize',14);
    
    ylim1=get(gca,'YLim');
    xlim1=get(gca,'XLim');
	 
	text(xlim1(2)-10,ylim1(2),'Model',...
   'VerticalAlignment','bottom',...
   'HorizontalAlignment','left','FontSize',12,'color','b','fontweight','bold')

%   for i =1:length(hj)-1 %the last line on the axes
%       xDataa = get(hj(i),'XData');
%       yDataa = get(hj(i),'YData');
%       set(hj(i),'XData',xDataa(1:2),'YData',yDataa(1:2))
%   end 
end
   
filename = [property,'_',label_station,'uv.png'];
filename2 = [ini_date,'_',end_datefi,'.png'];
filename3 = ['latest.png'];
path1=[publish,label_station,'\',property,' vectors\PCOMS\'];

%to check if the folder exist. If not create it.   
if (exist(path1)<=0)
     mkdir (path1)
end
   
pathname2 = [path1,filename2];
pathname3 = [path1,filename3];
   
saveas(gcf,filename,'png');   
copyfile(filename,pathname2,'f')
copyfile(filename,pathname3,'f')

g=figure

set(g,'Position',[200 200 800 500]);
axes('position',[0.07,0.1,0.65,0.8]);

if strcmp(plot_model,'1') 
    plot(model_time,model_mod/100,'b-', 'LineWidth',2);
	max_model1=max(model_mod/100);
	min_model1=min(model_mod/100);
	if (days_after > 0) | strcmp(forec_index,'1')
      hold on
	  plot(model_time(forec:end),model_prop(forec:end),'g-','LineWidth',2);
    end
	if strcmp(plot_data,'1') & strcmp(plot_datan,'1')
      hold on
      h_data=plot(buoy_time,buoy_prop/100, 'ro', 'LineWidth',0.1,'MarkerSize',2,'MarkerFaceColor',[1 .5 0]);
	  
	  if (days_after > 0) | strcmp(forec_index,'1')
	      h = legend('MOHID hindcast','MOHID forecast','Observation');
      else
          h = legend('MOHID hindcast','Observation');
	  end
	  legend boxoff % Hides the legend's axes (legend border and background)
	  max_data1=max(buoy_prop/100);
	  min_data1=min(buoy_prop/100);
	  max_graph1=max(max_model1,max_data1)+0.2;
	  min_graph1=max(0,min(min_model1,min_data1)-0.2);
   %  uistack(h_data,'top');
	elseif (strcmp(plot_data,'0') | strcmp(plot_datan,'0'))
	  if (days_after > 0) | strcmp(forec_index,'1')
	     h = legend('MOHID hindcast','MOHID forecast');
        else
         h = legend('MOHID hindcast');
	  end
%	  set(h,'Visible', 'off') %Turn the box off
%	  set(allchild(h),'visible','on'); % Hides the legend's axes (legend border and background)
      legend boxoff % Hides the legend's axes (legend border and background)
	  max_graph1=max_model1+0.2;
	  min_graph1=max(0,min_model1-0.2);
	end
	grid on
	StartDate=initialdate;
    EndDate=enddate+days_after;
    xData = linspace(StartDate,EndDate,9);
    %xlabel('Time (hours, UTC+1)','FontSize',14);
	ylabel('Intensity (m/s)','FontSize',14);
	ylim([[min_graph1] [max_graph1]]);
	set(gca, 'XTick',xData);
	
    %datetick('x','ddmmm HH:MMPM','keepticks');
	dateNtick('x',19);
	title([ label_station, ' - ',property],'fontsize',14,'fontweight','bold');
end

hold on

do_localmap(lat,lon)

filename1 = [property,'_',label_station,'int.png'];
filename2 = [ini_date,'_',end_datefi,'.png'];
filename3 = ['latest.png'];
path1=[publish,label_station,'\',property,' magnitude\PCOMS\'];
   
%to check if the folder exist. If not create it.   
if (exist(path1)<=0)
     mkdir (path1)
end
   
pathname2 = [path1,filename2];
pathname3 = [path1,filename3];
set(gcf,'PaperPositionMode','auto')

saveas(gcf, filename1, 'png');
copyfile(filename1,pathname2,'f')
copyfile(filename1,pathname3,'f')

%saveas(gcf, filename1, 'png');
%filename2=['\',station,'\',property,'\PCOMS\']

%end