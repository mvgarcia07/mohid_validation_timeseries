function getplot(initialdate,enddate,days_before,days_after,model_folder,work_folder,folder,nodata)
global property plot_data down_data plot_model plot_png astro_tide starefe str1 plot_datan data_path stareg


count1=0;
buoy_path=buoy_path1;
if strcmp(property,'temperature') | strcmp(property,'salinity') | strcmp(property,'velocity')
   mfid1 = fopen('station_id.dat');
elseif strcmp(property,'level')
   mfid1 = fopen('Tide_station_id.dat');
end
if (mfid1 < 0)
    mfidi = fopen('error_timeseries.dat','a');
    fprintf (mfidi,'%s\n','station_id.dat is missing');
    fclose(mfidi);
    error('Tide_station_id.dat is missing')
end		 
if strcmp(property,'level')
   extension = '.srh';  
   cprop=13;
elseif strcmp(property,'temperature')
    extension = '.srw';    
    cprop=9;
elseif strcmp(property,'salinity')
    extension = '.srw';    
    cprop=8;
elseif strcmp(property,'velocity')
    extension = '.srh';   
    cprop=11;
    cprop1=12;
end  

%get stations to plot

 while ~feof(mfid1);
       line = fgets(mfid1);
       stationname= strfind(line,'STATION_NAME');
       plotlabel=strfind(line,'PLOT_LABEL');
       stationorigin = strfind(line,'ORIGIN');
       stationregion = strfind(line,'REGION');
       downstaname = strfind(line,'DOWNSTA_NAME');
	   lat= strfind(line,'LATITUDE');
	   lon= strfind(line,'LONGITUDE');
	   staref=strfind(line,'LEVEL_REF');
	   astrotide= strfind(line,'ASTRO_TIDE');
       block = strfind(line,'<EndStation>');
       if stationname
                   delim = strfind(line,':');
		           station_name= line(delim+1:end);
		           [station, n_values] = strsplit(station_name);
                   if (n_values == 2) 
                       station=strcat(station(1),{' '},station(2));
                   elseif (n_values == 3)
                       station=strcat(station(1),{' '},station(2),{' '},station(3));
				   elseif (n_values == 4)
				       station=strcat(station(1),{' '},station(2),{' '},station(3),{' '},station(4));
                   elseif (n_values > 4)
				       station=strcat(station(1),{' '},station(2),{' '},station(3),{' '},station(4))
                       mfidi = fopen('error_timeseries.dat','a');
                       fprintf (mfidi,'%s\n','STATION_NAME to big max 4 words');
                   	   fclose(mfidi)
                       error('STATION_NAME to big max 4 words')		
				   end
                   station=char(station);
       end
       if plotlabel
                   delim = strfind(line,':');
		           plot_label= line(delim+1:end);
		           [plotlabel, n_values] = strsplit(plot_label);
                   if (n_values == 2) 
                       plotlabel=strcat(plotlabel(1),{' '},plotlabel(2));
                   elseif (n_values ==3)
                       plotlabel=strcat(plotlabel(1),{' '},plotlabel(2),{' '},plotlabel(3));
				   elseif (n_values == 4)
				       plotlabel=strcat(plotlabel(1),{' '},plotlabel(2),{' '},plotlabel(3),{' '},plotlabel(4));
                   elseif (n_values > 4)
				       plotlabel=strcat(plotlabel(1),{' '},plotlabel(2),{' '},plotlabel(3),{' '},plotlabel(4));
                       mfidi = fopen('error_timeseries.dat','a');
                       fprintf (mfidi,'%s\n','PLOT_LABEL to big max 4 words');
                   	   fclose(mfidi);
					   error('PLOT_LABEL to big max 4 words')
                   end
                   plotlabel=char(plotlabel);
                   label=plotlabel;
       end
       if stationorigin
           delim = strfind(line,':');
		   station_origin= line(delim+1:end);
		   [staorigin, n_values] = strsplit(station_origin);
           staorigin=char(staorigin);
       end
       if stationregion
                   delim = strfind(line,':');
		           station_reg= line(delim+1:end);
		           [stareg, n_values] = strsplit(station_reg);
                 
				   if (n_values > 3)
				       mfidi = fopen('error_timeseries.dat','a');
					   fprintf (mfidi,'%s\n',stareg);
                       fprintf (mfidi,'%s\n','Wrong REGION need 3 items region stationtype datatype');
					   fclose(mfidi);
					   error('Wrong REGION need 3 items region stationtype datatype')
                   end
       else
                   stareg={'IR';'TS';'MO'};
                   
       end
        if downstaname
           delim = strfind(line,':');
		   down_sta= line(delim+1:end);
		   [downsta, n_values] = strsplit(down_sta);
           downsta=char(downsta);
       end
	    if lat
            delim = strfind(line,':');
		    lat_ref= line(delim+1:end);
		    [lati, n_values] = strsplit(lat_ref);
            latitude=str2num(char(lati));
       end
	   if lon
            delim = strfind(line,':');
		    lon_ref= line(delim+1:end);
		    [long, n_values] = strsplit(lon_ref);
            longitude=str2num(char(long));
       end
	   if staref
           delim = strfind(line,':');
		   sta_ref= line(delim+1:end);
		   [starefe, n_values] = strsplit(sta_ref);
           starefe=str2num(char(starefe));
       end
       if astrotide
           delim = strfind(line,':');
		   astro= line(delim+1:end);
		   [astro_tide, n_values] = strsplit(astro);
           astro_tide=char(astro_tide);
       end
      

       if block
          if strcmp(plot_data,'1')
		       plot_png='1';
              if strcmp(staorigin,'MyOcean')
                if strcmp(property,'level')
                   prop='SLEV'
                elseif strcmp(property,'temperature')
                   prop='TEMP'
                elseif strcmp(property,'salinity')
                   prop='PSAL';
                elseif strcmp(property,'velocity')
                   prop='HCSP'; %velocity intensity
                   prop1='HCDT'; %velocity direction
                elseif strcmp(property,'wind')
                   prop='WSPD'; %wind modulo
                   prop1='WDIR'; %wind direction
                elseif strcmp(property,'air_temperature')
                   prop='AIRT'; %air temperature
                elseif strcmp(property,'atmospheric')
                   prop='ATMP'; %atmospheric pressure
                elseif strcmp(property,'wave')
                   prop='VTDH'; %wave amplitude
                   prop1='VTZA'; %wave period
                   prop2='VDIR'; %wave direction
                end
				
                if strcmp(down_data,'1') | 	strcmp(down_data,'2')			
                  stan=downsta;
				  filenc=[downsta,'_all.nc'];
				  gfile=[buoy_path,station,'\',filenc];
				end
				if strcmp(down_data,'2') %get data from nc file
				  data_path=[buoy_path,station,'\',]
				  day_dif=now-initialdate;
				  
			      if (day_dif<=30)
                      [gfile]=cat_myocean_buoys(stan,datestr(initialdate-days_before,'yyyymmdd'),datestr(enddate-1,'yyyymmdd'),'latest');
                      
			      else 
			          [gfile]=cat_myocean_buoys(stan,datestr(initialdate-days_before,'yyyymmdd'),datestr(enddate-1,'yyyymmdd'));
				  end
				  
	            end  
			     
              end
			  
              if strcmp(property,'velocity')
			        convertMyOceanBuoysToMOHIDTimeSerie(gfile,prop);
					 if strcmp(str1,'bad')
                        buoy_folder=[];
                        buoy_folder1=[];
						plot_datan='0';
						if strcmp(plot_model,'0')
				            plot_png ='0';
				        end
                     else
					    file_nc=[buoy_path,station,'\*sr*'];
						file_all=[buoy_path,station,'\*all*'];
					    buoy_folder_srh=[work_folder,'\data\srh_format\',folder,'\current_intensity\'];
						if strcmp(down_data,'1')
                          copyfile(file_nc,buoy_folder_srh,'f');
                        elseif strcmp(down_data,'2')
                          copyfile('*srh',buoy_folder_srh,'f');
                        end						  
					    buoy_folder=[buoy_folder_srh,stan,'_all',extension];
						plot_datan='1';
				     end

					 convertMyOceanBuoysToMOHIDTimeSerie(gfile,prop1)
	    			 if strcmp(str1,'bad')
                        buoy_folder=[];
                        buoy_folder1=[];
     					plot_datan1='0';
						if strcmp(plot_model,'0')
				            plot_png ='0';
				        end
                     else
					    file_nc=[buoy_path,station,'\*sr*'];
						file_all=[buoy_path,station,'\*all*'];
					    buoy_folder_srh1=[work_folder,'\data\srh_format\',folder,'\current_direction\'];
						if strcmp(down_data,'1')
                          copyfile(file_nc,buoy_folder_srh1,'f');
						  delete(file_nc);
                        elseif strcmp(down_data,'2')
                          copyfile('*srh',buoy_folder_srh1,'f');
						  delete('*srh');
						  delete('*all.nc');
                        end					
					    buoy_folder1=[buoy_folder_srh1,stan,'_all',extension];
						plot_datan1='1';
						
				     end
     
	                 if (strcmp(plot_datan,'0') | strcmp(plot_datan1,'0'))
					    plot_datan='0';
					 end
              else
					convertMyOceanBuoysToMOHIDTimeSerie(gfile,prop);
					if strcmp(str1,'bad')
                        buoy_folder=[];
                        buoy_folder1=[];
						plot_datan='0';
						if strcmp(plot_model,'0')
				            plot_png ='0';
				        end
                     else
					    file_nc=[buoy_path,station,'\*sr*'];
					    buoy_folder_srh=[work_folder,'\data\srh_format\',folder,'\'];
						if strcmp(down_data,'1')
                          copyfile(file_nc,buoy_folder_srh,'f');
						  delete(file_nc);
                        elseif strcmp(down_data,'2')
						 if strcmp(property,'temperature') | strcmp(property,'salinity') 
                          copyfile('*srw',buoy_folder_srh,'f');
						  delete('*srw');
						  delete('*all.nc');
						 elseif strcmp(property,'level')
						  copyfile('*srh',buoy_folder_srh,'f');
						  delete('*srh');
						  delete('*all.nc');
						 end
                        end						  
					    buoy_folder=[buoy_folder_srh,stan,'_all',extension]
						plot_datan='1';
						
				     end
              end
              
   %       elseif strcmp(plot_data,'1') && strcmp(down_data,'0') %search for the data
   %           stan=downsta;
   %           if strcmp(property,'velocity')
   %                 buoy_folder = [buoy_path,'srh_format\',folder,'\current_intensity\',stan,extension];
   %                 buoy_folder1 = [buoy_path,'srh_format\',folder,'\current_direction\',stan,extension];
   %           else
   %                 buoy_folder = [buoy_path,'srh_format\',folder,'\',stan,extension];
   %           end
          elseif strcmp(plot_data,'0') 
              buoy_folder=[];
              buoy_folder1=[];
          end    
          
          if strcmp(plot_data,'1') | strcmp(plot_model,'1')
            if strcmp(property,'temperature') | strcmp(property,'salinity')
               plot_comparison(station,initialdate-days_before,enddate,days_after,model_folder,buoy_folder,extension,label,cprop,latitude,longitude);
            elseif strcmp(property,'level')
               plot_comparison_level(station,initialdate-days_before,enddate,days_after,model_folder,buoy_folder,buoy_path,extension,label,cprop,latitude,longitude);
			elseif strcmp(property,'velocity')
               plot_comparison_velo(station,initialdate-days_before,enddate,days_after,model_folder,buoy_folder,buoy_folder1,extension,label,cprop,cprop1,latitude,longitude);
            end
		  end
       end
    end 
fclose(mfid1);
