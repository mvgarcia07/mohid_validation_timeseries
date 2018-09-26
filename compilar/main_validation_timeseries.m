
%read information from MatlabTimeserie.dat
global plot_data plot_model statistic down_data property plot_level plot_png str1 ini_date end_datefi publish forecast1 vscale_int buoy_path1

% try
mfidi = fopen('error_timeseries.dat','w');
fclose(mfidi);
plot_png='0';
mfid = fopen('MatlabTimeserie.dat');
    while ~feof(mfid);
        line = fgets(mfid);
		work = strfind(line,'WORK_PATH');
		model = strfind(line,'MOHID_PATH');
		buoy = strfind(line,'DATA_PATH');
		plotpath = strfind(line,'BACKUP_PATH');
        publishpath = strfind(line,'PUBLISH_PATH');
        bapublish = strfind(line,'BACKUP_PUBLISH');
		forecast = strfind(line,'FORECAST');
        daysbefore = strfind(line,'DAYS_BEFORE');
        daysafter = strfind(line,'DAYS_AFTER');
        downdata = strfind(line,'DOWNLOAD_DATA');    
        plotdata=strfind(line,'PLOT_DATA');
		plotmodel=strfind(line,'PLOT_MODEL');
        plotlevel=strfind(line,'LEVEL');
        plottemp=strfind(line,'TEMP');
        plotsal=strfind(line,'SAL');
        plotvel=strfind(line,'VEL');
        statist=strfind(line,'STATISTIC');
	    int_ts=strfind(line,'INTERVAL_TS');
		found_ini_date = strfind(line,'START');
		found_end_date = strfind(line,'END ');
		if work
		   delim = strfind(line,':');
		   work_date= line(delim+1:end);
		   [work_folder, n_values] = strsplitMH(work_date);
           work_folder=char(work_folder);
        end
		if model
		   delim = strfind(line,':');
		   model_date= line(delim+1:end);
		   [model_folder, n_values] = strsplitMH(model_date);
           model_folder=char(model_folder);
        end
		if buoy
		   delim = strfind(line,':');
		   buoy_date= line(delim+1:end);
		   [buoy_path, n_values] = strsplitMH(buoy_date);
           buoy_path=char(buoy_path);
        end
		if plotpath
		   delim = strfind(line,':');
		   plot_path= line(delim+1:end);
		   [plot_folder, n_values] = strsplitMH(plot_path);
           plot_folder=char(plot_folder);
        end
        if publishpath
		   delim = strfind(line,':');
		   publish_path1= line(delim+1:end);
		   [publish, n_values] = strsplitMH(publish_path1);
           publish=char(publish);
        end
        if bapublish
		   delim = strfind(line,':');
		   bapublish= line(delim+1:end);
		   [bapublish_folder, n_values] = strsplitMH(bapublish);
           bapublish_folder=char(bapublish_folder);
        end
		if forecast
           delim = strfind(line,':');
		   fore= line(delim+1:end);
		   [forecast1, n_values] = strsplitMH(fore);
           forecast1=char(forecast1);
        end 
        if daysbefore
           delim = strfind(line,':');
		   days_before= line(delim+1:end);
		   [date_vec, n_values] = strsplitMH(days_before);
           days_before=str2num(char(date_vec(1)));
        end 
        if daysafter
           delim = strfind(line,':');
		   days_after= line(delim+1:end);
		   [date_vec, n_values] = strsplitMH(days_after);
           days_after=str2num(char(date_vec(1)));
        end 
        if downdata
           delim = strfind(line,':');
		   down= line(delim+1:end);
		   [down_data, n_values] = strsplitMH(down);
           down_data=char(down_data);
        end
       
        if plotlevel
           delim = strfind(line,':');
		   plotle= line(delim+1:end);
		   [plot_level, n_values] = strsplitMH(plotle);
           plot_level=char(plot_level);
        end
        if plottemp
           delim = strfind(line,':');
		   plotte= line(delim+1:end);
		   [plot_temp, n_values] = strsplitMH(plotte);
           plot_temp=char(plot_temp);
        end
        if plotsal
           delim = strfind(line,':');
		   plotsa= line(delim+1:end);
		   [plot_sal, n_values] = strsplitMH(plotsa);
           plot_sal=char(plot_sal);
        end
        if plotvel
           delim = strfind(line,':');
		   plotvel= line(delim+1:end);
		   [plot_vel, n_values] = strsplitMH(plotvel);
           plot_vel=char(plot_vel);
        end
        if plotdata
           delim = strfind(line,':');
		   graph= line(delim+1:end);
		   [plot_data, n_values] = strsplitMH(graph);
           plot_data=char(plot_data);
        end
		if plotmodel
           delim = strfind(line,':');
		   graphm= line(delim+1:end);
		   [plot_model, n_values] = strsplitMH(graphm);
           plot_model=char(plot_model);
        end
        if statist
           delim = strfind(line,':');
		   stat= line(delim+1:end);
		   [statistic, n_values] = strsplitMH(stat);
           statistic=char(statistic);
        end
		if int_ts
           delim = strfind(line,':');
		   intts= line(delim+1:end);
		   [vscale_int, n_values] = strsplitMH(intts);
           vscale_int=char(vscale_int);
		   vscale_int=str2num(vscale_int);
        end
        if found_ini_date
           delim = strfind(line,':');
           ini_date1 = line(delim+1:end);
           [date_vec, n_values] = strsplitMH(ini_date1);
           y_ini = str2num(char(date_vec(1)));
           m_ini = str2num(char(date_vec(2)));
           d_ini = str2num(char(date_vec(3)));
           h_ini = str2num(char(date_vec(4)));
           min_ini = str2num(char(date_vec(5)));
           s_ini = str2num(char(date_vec(6)));
           initialdate = datenum(y_ini, m_ini, d_ini, h_ini, min_ini, s_ini);
		   if m_ini<10;
              m_ini_str =['0',num2str(m_ini)];
           else
              m_ini_str =num2str(m_ini);
           end
		   if d_ini<10;
               d_ini_str =['0',num2str(d_ini)];
           else
               d_ini_str =num2str(d_ini);
           end
		   ini_datef=[num2str(y_ini),'-',m_ini_str, '-', d_ini_str];
           
    	   
         end
		 if found_end_date
            delim = strfind(line,':');
            end_date1 = line(delim+1:end);
            [date_vec_end, n_values] = strsplitMH(end_date1);
            y_end = str2num(char(date_vec_end(1)));
            m_end = str2num(char(date_vec_end(2)));
            d_end = str2num(char(date_vec_end(3)));
            h_end = str2num(char(date_vec_end(4)));
            min_end = str2num(char(date_vec_end(5)));
            s_end = str2num(char(date_vec_end(6)));
            enddate = datenum(y_end, m_end, d_end, h_end, min_end, s_end);
			if m_end<10;
              m_end_str =['0',num2str(m_end)];
           else
              m_end_str =num2str(m_end);
           end
		   if d_end<10;
               d_end_str =['0',num2str(d_end)];
           else
               d_end_str =num2str(d_end);
           end
			end_datefi=[num2str(y_end),'-',m_end_str, '-', d_end_str];
        end
    end
fclose(mfid);
if strcmp(forecast1,'1')
  
   if ((now+days_after)>enddate+1)
      mfidi = fopen('error_timeseries.dat','a');
      fprintf (mfidi,'%s\n','error in main_validation_timeseries.m, today+daysafter>enddate+1');
	  fclose(mfidi);
      clear all
      quit
   else
	  enddate=enddate-days_after;
	  initialdate=initialdate-days_before;
	  [Y, M, D, H, MN, S] =datevec(initialdate);
      [Y1, M1, D1, H1, MN1, S1] = datevec(enddate);
	  if M<10;
        M_str =['0',num2str(M)];
      else
        M_str =num2str(M);
      end
      if D<10;
        D_str =['0',num2str(D)];
      else
        D_str =num2str(D);
      end
	  if M1<10;
        M1_str =['0',num2str(M1)];
      else
        M1_str =num2str(M1);
      end
      if D<10;
        D1_str =['0',num2str(D1)];
      else
        D1_str =num2str(D1);
      end
	  
	  ini_datef=[num2str(Y),'-',M_str, '-', D_str];
	  end_datef=[num2str(Y1),'-',M1_str, '-', D1_str];
   end
else
   days_before=0;
   days_after=0;
end

%get plot
if strcmp(plot_level,'1')
    property='level';
    folder='tidal_data';
    count1=0;
    buoy_path1=[buoy_path];
    if strcmp(down_data,'1')
      if (enddate>now)
	      enddate1=now;
      else 
          enddate1=enddate;
      end
	  [nodata]=getdata(initialdate,days_before,enddate1);
    else
       nodata=[];
    end
	
    %plot timeserie
	if (strcmp(plot_data,'1') | strcmp (plot_model,'1'))
	  getplot(initialdate,enddate,days_before,days_after,model_folder,work_folder,buoy_path1,folder,nodata);
    end 
end

if strcmp(plot_temp,'1') | strcmp(plot_sal,'1') | strcmp(plot_vel,'1')
    
	property='temperature';
    buoy_path1=[buoy_path];
    if strcmp(down_data,'1')
	  if (enddate>now)
	      enddate1=now;
      else 
          enddate1=enddate;
      end
      disp('entrou')	  
      [nodata]=getdata(initialdate,days_before,enddate1);
    else
       nodata=[];
    end
	
if strcmp(plot_temp,'1') %plot temperature 
    property='temperature';
    folder='temp_data';
      
    %plot timeserie
	if strcmp(plot_data,'1') | strcmp (plot_model,'1')
      getplot(initialdate,enddate,days_before,days_after,model_folder,work_folder,folder,nodata);
    end 
end  

if strcmp(plot_sal,'1') %plot salinity
   property='salinity';
   folder='salt_data';
   buoy_path1=[buoy_path]
      
   %plot timeserie
   if strcmp(plot_data,'1') | strcmp (plot_model,'1') 
      getplot(initialdate,enddate,days_before,days_after,model_folder,work_folder,folder,nodata);
   end

end

if strcmp(plot_vel,'1') %plot velocity
   property='velocity';
   folder='vel_data';
   
   %plot timeseries
   if strcmp(plot_data,'1') | strcmp (plot_model,'1') 
     getplot(initialdate,enddate,days_before,days_after,model_folder,work_folder,folder,nodata);
   end
end
end
if (strcmp(plot_data,'1') | strcmp (plot_model,'1'))
if (strcmp(plot_png,'1') )
  
   folder_date=[plot_folder,ini_date,'_',end_datefi,'\'];
   copyfile('*.png',folder_date,'f');
   folder_back=[bapublish_folder,ini_date,'_',end_datefi,'\'];
   copyfile('*.png',folder_back,'f');
   delete('*.png');

end
end
 
%  catch
%       disp('an error occoured in main_validation_timeseries.m')
%       mfidi = fopen('error_timeseries.dat','a');
%       fprintf (mfidi,'%s\n','error in main_validation_timeseries.m');
%  	 fprintf (mfidi,'%s\n','Matlab TimeSeries failed ');
%  	 fclose(mfidi);
% end
     mfidi = fopen('error_timeseries.dat','a');
	 fprintf (mfidi,'%s\n','Matlab TimeSeries successfully executed');
	 fclose(mfidi);
%copy error file to Log folder
new_error=['error_timeseries_',end_datefi,'.dat'];
copyfile('error_timeseries.dat',new_error,'f');
error_path=[work_folder,'Logs\'];
copyfile(new_error,error_path,'f');
delete('error_timeseries*');

%clear all
%quit;


