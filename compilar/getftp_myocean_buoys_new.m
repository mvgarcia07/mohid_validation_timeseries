function [gfile,nodata]=getftp_myocean_buoys_new(varargin)


global plot_data stareg flag_srw buoy_path1 station
%function getftp-myocean-buoys(buoy,date)
%
% > getftp_myocean_buoys('MYO_IR_Vigo_tg'); %Gets latest month
% > getftp_myocean_buoys('MYO_IR_Vigo_tg','201006'); %Gets whole month
% > getftp_myocean_buoys('MYO_IR_Vigo_tg','20110715'); %idem
% > getftp_myocean_buoys('MYO_IR_Vigo_tg','201006','201107'); %Gets whole months
%between start and end date. one file per month.
% > getftp_myocean_buoys('MYO_IR_Vigo_tg','20100604','20110723'); %Gets whole 
%months between start and end date. One file per month.
% > getftp_myocean_buoys; % Gets latest month from default 'Vigo_tg' buoy
%
% IR - IBI-ROOS South west shelf region
% TS - Timeserie
% MO - Fixed buoys or mooring time series
% MYO_IR_Aberdeen - MyOcean Trigram / Region / product
%
% LIST OF AVAILABLE BUOYS ( SLEV - nivel )
% IR_201106_TS_MO_MYO_IR_Aberdeen.nc
% IR_201106_TS_MO_MYO_IR_Alcudia_tg.nc
% IR_201106_TS_MO_MYO_IR_Algeciras_tg.nc
% IR_201106_TS_MO_MYO_IR_Almeria_tg.nc
% IR_201106_TS_MO_MYO_IR_Aranmore.nc
% IR_201106_TS_MO_MYO_IR_Arrecife_tg.nc
% IR_201106_TS_MO_MYO_IR_Barcelona_tg.nc
% IR_201106_TS_MO_MYO_IR_Barmouth.nc
% IR_201106_TS_MO_MYO_IR_Bilbao_tg.nc
% IR_201106_TS_MO_MYO_IR_Bonanza_tg.nc
% IR_201106_TS_MO_MYO_IR_Bournemouth.nc
% IR_201106_TS_MO_MYO_IR_BrestPort.nc
% IR_201106_TS_MO_MYO_IR_Castletownbere.nc
% IR_201106_TS_MO_MYO_IR_Cherbourg.nc
% IR_201106_TS_MO_MYO_IR_Coruna_tg.nc
% IR_201106_TS_MO_MYO_IR_Cromer.nc
% IR_201106_TS_MO_MYO_IR_Donostia_buoy.nc
% IR_201106_TS_MO_MYO_IR_Dover.nc
% IR_201106_TS_MO_MYO_IR_Dublin_Port.nc
% IR_201106_TS_MO_MYO_IR_Dundalk.nc
% IR_201106_TS_MO_MYO_IR_ElHierro_tg.nc
% IR_201106_TS_MO_MYO_IR_Ferrol_tg.nc
% IR_201106_TS_MO_MYO_IR_Fishguard.nc
% IR_201106_TS_MO_MYO_IR_Formentera_tg.nc
% IR_201106_TS_MO_MYO_IR_Fuerteventura_tg.nc
% IR_201106_TS_MO_MYO_IR_Galway_Port.nc
% IR_201106_TS_MO_MYO_IR_Gandia_tg.nc
% IR_201106_TS_MO_MYO_IR_Gijon_tg.nc
% IR_201106_TS_MO_MYO_IR_Gomera_tg.nc
% IR_201106_TS_MO_MYO_IR_Heysham.nc
% IR_201106_TS_MO_MYO_IR_Holyhead.nc
% IR_201106_TS_MO_MYO_IR_Howth.nc
% IR_201106_TS_MO_MYO_IR_Huelva_tg.nc
% IR_201106_TS_MO_MYO_IR_Ibiza_tg.nc
% IR_201106_TS_MO_MYO_IR_Ilfracombe.nc
% IR_201106_TS_MO_MYO_IR_Immingham.nc
% IR_201106_TS_MO_MYO_IR_Killybegs.nc
% IR_201106_TS_MO_MYO_IR_LaPalma_tg.nc
% IR_201106_TS_MO_MYO_IR_LasPalmas_tg.nc
% IR_201106_TS_MO_MYO_IR_Le_Conquet.nc
% IR_201106_TS_MO_MYO_IR_Le_Havre.nc
% IR_201106_TS_MO_MYO_IR_Liverpool.nc
% IR_201106_TS_MO_MYO_IR_Lowestoft.nc
% IR_201106_TS_MO_MYO_IR_Mahon_tg.nc
% IR_201106_TS_MO_MYO_IR_Malaga_tg.nc
% IR_201106_TS_MO_MYO_IR_Malin_Head.nc
% IR_201106_TS_MO_MYO_IR_Matxitxako_buoy.nc
% IR_201106_TS_MO_MYO_IR_Melilla_tg.nc
% IR_201106_TS_MO_MYO_IR_Monican01.nc
% IR_201106_TS_MO_MYO_IR_Monican02.nc
% IR_201106_TS_MO_MYO_IR_Motril_tg.nc
% IR_201106_TS_MO_MYO_IR_Newhaven.nc
% IR_201106_TS_MO_MYO_IR_Newlyn.nc
% IR_201106_TS_MO_MYO_IR_NorthShields.nc
% IR_201106_TS_MO_MYO_IR_PalmadeMallorca_tg.nc
% IR_201106_TS_MO_MYO_IR_Plymouth.nc
% IR_201106_TS_MO_MYO_IR_Sagunto_tg.nc
% IR_201106_TS_MO_MYO_IR_Santander_tg.nc
% IR_201106_TS_MO_MYO_IR_Sheerness.nc
% IR_201106_TS_MO_MYO_IR_Sligo.nc
% IR_201106_TS_MO_MYO_IR_Stornoway.nc
% IR_201106_TS_MO_MYO_IR_Tarifa_tg.nc
% IR_201106_TS_MO_MYO_IR_Tenerife_tg.nc
% IR_201106_TS_MO_MYO_IR_Valencia_tg.nc
% IR_201106_TS_MO_MYO_IR_Vigo_tg.nc
% IR_201106_TS_MO_MYO_IR_Villagarcia_tg.nc
% IR_201106_TS_MO_MYO_IR_Wexford.nc
% IR_201106_TS_MO_MYO_IR_Whitby.nc
% IR_201106_TS_MO_MYO_IR_Wick.nc
% IR_201106_TS_MO_MYO_IR_Workington.nc
% IR_201106_TS_MO_62025.nc CabodePenhas
% IR_201106_TS_MO_62082.nc EstacadeBares
% IR_201106_TS_MO_62083.nc Villano_Sisargas
% IR_201106_TS_MO_62084.nc Silleiro
% IR_201106_TS_MO_62085.nc Cadiz
% IR_201106_TS_MO_6201038.nc Cortegada
% IR_201106_TS_MO_6201039.nc Rande
% IR_201106_TS_MO_6201040.nc Illas Cies
% IR_201106_TS_MO_MYO_IR_Monican01.nc
% IR_201106_TS_MO_MYO_IR_Monican02.nc
% IR_201106_TS_MO_MYO_IR_Raia01.nc
%


     
     myoPartners = struct( ...
             'ftp',{ 'vftp1.ifremer.fr', ...
			         'clima.puertos.es', ...
                     'eftp.ifremer.fr', ...
                     'ftp.bsh.de'}, ...
             'ftpuser',{ 'fcampuzano', ...
			             'fcampuzano', ...
                         'c1e95c', ...
                         'rcbono'}, ...
             'ftppass',{ 'RAkopeci', ...
			             'RAkopeci', ...
                         'wnPFGPFE', ...
                         'ocean4u'}, ...
             'path',{  '/Core/INSITU_GLO_NRT_OBSERVATIONS_013_030',...
			           '/ibi_instac',...
                       '/user25276/data', ...
                       '/outgoing/rcbono/myocean'}, ...            
             'ftpHandle', { 1, 1, 1, 1} ...
            );
     
    %reference time is today
    today = datestr(date,'yyyymmdd');

    %default input values    
    %buoy = 'Vigo_tg';

    fstartdate = today;

    fenddate = today;
    
    
    %override default input values
    optargin = size(varargin,2);

    if optargin >= 1

        buoy = varargin{1};
        
        %myoProduct(1).code = ['MYO_IR_', buoy];
        myoProduct(1).code = buoy;
    end

    if optargin >= 2

        fstartdate = varargin{2};
        fenddate = varargin{2};     
    end

    if optargin >= 3

        fenddate = varargin{3};
	

    end
    
    %myoProduct = struct( ...
     %                   'region', { 'IR'}, ...
     %                   'ts', { 'TS'}, ...
     %                   'datatype', { 'MO'}, ...
     %                   'code', {buoy}...
     %               )
    myoProduct = struct( ...
                        'region', { char(stareg(1))}, ...
                        'ts', { char(stareg(2))}, ...
                        'datatype', { char(stareg(3))}, ...
                        'code', {buoy}...
                    );
                
                
    %correct input values
    if str2double(today(1:6)) - str2double(fstartdate(1:6)) < 0 

        fstartdate = today;        

    end    

    if str2double(today(1:6)) - str2double(fenddate(1:6)) < 0 

        fenddate = today;       

    end
    
    %Filename
    if str2double(fenddate(1:6)) - str2double(fstartdate(1:6)) ~= 0

        gfile = constructMonthlyFile( myoProduct(1), ...
                        [fstartdate(1:6),'_',fenddate(1:6)] ...
                    )

    end

    %Open ftp link
	try
      partnerId = 1;
      myoPartners(partnerId).ftpHandle = ftp(   myoPartners(partnerId).ftp, ...
                        myoPartners(partnerId).ftpuser, ...
                        myoPartners(partnerId).ftppass ...
                    )
	catch
	  disp('an error occoured in the ftp connection partnerID = 1')
	  mfidi = fopen('error_timeseries.dat','a');
      fprintf (mfidi,'%s\n','an error occoured ftp connection partnerID = 1');
      fclose(mfidi);
	  try
         partnerId = 2;
         myoPartners(partnerId).ftpHandle = ftp(   myoPartners(partnerId).ftp, ...
                        myoPartners(partnerId).ftpuser, ...
                        myoPartners(partnerId).ftppass ...
                    );
	  catch
	    disp('an error occoured in the ftp connection partnerID = 2')
	    mfidi = fopen('error_timeseries.dat','a');
        fprintf (mfidi,'%s\n','an error occoured ftp connection partnerID = 2');
        fclose(mfidi);
	  end
	end
 %   if optargin <= 2
    if optargin <= 3
    %Initialize while cycle
    fdate = fstartdate(1:6);
    nodata=0;
	nodataf=0;
	i=1;
    %Get one file per month between start and end date
   
    while str2double(fenddate(1:6)) - str2double(fdate) >= 0        
        %Are we in the latest month?
        if str2double(fdate) - str2double(today(1:6)) == 0
           [file,nodata] = getFtpMyOceanLatestMonth(myoPartners(partnerId), myoProduct(1), today);
		   if (nodata == 1)
		      if i==1
			   notataf=1;
			  end 
		   else
		      [file_out,Mstr,Nstr]=convertMyOceanBuoysToMOHIDTimeSerie_all(file);
              
			  buoy_folder=[buoy_path1,fdate(1:4),'-',fdate(5:6),'\'];
			  if ((Mstr==1) && (Nstr>1))
			       %allfile1=[station,'.srw'];
                   allfile1=[station,'.ets'];
				   allfile=[station,'.nc'];
			       copyfile(file_out,allfile1,'f')
			   %    copyfile(file,gfile,'f');
				   copyfile(file,allfile,'f')
				   delete(file);
				   delete(file_out);
				   %copyfile('*.srw',buoy_folder,'f');
                   copyfile('*.ets',buoy_folder,'f');
				   copyfile('*.nc',buoy_folder,'f');
			       delete('*.ets');
				   delete('*.nc');
				   
			  elseif ((Mstr~=1) || (Nstr==1))
			      % copyfile(file,gfile,'f');
				   allfile=[station,'.nc'];
				   copyfile(file,allfile,'f');
				   delete(file);
				   copyfile('*.nc',buoy_folder,'f');
				   delete('*.nc');
			  end
		   end

        else
           [file,nodata] = getFtpMyOceanMonth(myoPartners(partnerId), myoProduct(1), fdate);
		   if (nodata == 1)
		      if i==1
			   notataf=1;
			  end 
			else  
		      [file_out,Mstr,Nstr]=convertMyOceanBuoysToMOHIDTimeSerie_all(file);
			  buoy_folder=[buoy_path1,fdate(1:4),'-',fdate(5:6),'\'];
			  if ((Mstr==1) & (Nstr>1)) 
				   %allfile1=[station,'.srw'];
                   allfile1=[station,'.ets'];
				   allfile=[station,'.nc'];
			       copyfile(file_out,allfile1,'f');
			   %    copyfile(file,gfile,'f');
				   copyfile(file,allfile,'f')
				   delete(file);
				   delete(file_out);
				  % copyfile('*.srw',buoy_folder,'f');
                   copyfile('*.ets',buoy_folder,'f');
				   copyfile('*.nc',buoy_folder,'f');
			       delete('*.ets');
				   delete('*.nc');
				   
			  elseif ((Mstr~=1) | (Nstr==1))
			      % copyfile(file,gfile,'f');
				   allfile=[station,'.nc'];
				   copyfile(file,allfile,'f');
				   delete(file);
				   copyfile('*.nc',buoy_folder,'f');
				   delete('*.nc');
			  end
			  
		    end
        end

        disp(['Downloaded MyOcean ', fdate, ' ', ...
                myoProduct(1).code, ' buoy ...']);
        %Do we have several months to glue?
        if str2double(fenddate(1:6)) - str2double(fstartdate(1:6)) ~= 0
		    if strcmp(plot_data,'1')
            if str2double(fdate) == str2double(fstartdate(1:6))
                if (nodata == 1)
			      if i==1   
			 	    nodataf=1;
			      end 
			    else
                  copyfile(file,gfile,'f');
                end
            else
                if (nodata == 1)
                   return
                end
                try
				  
				    nc_cat(gfile,file);
				  
				catch
				  disp('an error occoured in the nc file')
				  mfidi = fopen('error_timeseries.dat','a');
                  fprintf (mfidi,'%s\n','an error occoured in the file cat');
              	  fclose(mfidi);
                end
            end
            end
        else
            
            gfile = file;
            
        end

        fdate = nextmonth(fdate);
    end
	if strcmp(plot_data,'1')
    ogfile=gfile;
    gfile=[buoy,'_all.nc'];
	 
	 if exist(ogfile,'file')
	  try
        copyfile(ogfile,gfile,'f');
      end
     end
    end
    else %optargin>=4 latest
	
      fdate=fstartdate;
	  
	  i=1;
	  gfile=[buoy,'_all.nc'];
      nodata=0;
      nodataf=0;
      while str2double(fenddate) - str2double(fdate) >= 0        
        %Are we in the latest day?
        if str2double(fenddate) - str2double(fdate) == 0
		    
            [file,nodata] = getFtpMyOceanLatestDay(myoPartners(partnerId), myoProduct(1),fenddate);
			if (nodata == 1)
			  if i==1   
			 	nodataf=1;
				return
			  else
			    return
			  end 
			else
			  [file_out,Mstr,Nstr]=convertMyOceanBuoysToMOHIDTimeSerie_all(file);

			  ffdate=datenum(fenddate,'yyyymmdd')+1;
			  fffdate=datestr(ffdate,'yyyymmdd');
			  buoy_folder=[buoy_path1,fenddate(1:4),'-',fenddate(5:6),'-',fenddate(7:8),'_',fffdate(1:4),'-',fffdate(5:6),'-',fffdate(7:8),'\'];
			  allfile=[station,'.nc'];
			  if ((Mstr==1) & (Nstr>1))
			    %allfile1=[station,'.srw'];
				allfile1=[station,'.ets'];
			    copyfile(file_out,allfile1,'f')
			    copyfile(file,allfile,'f');
			    delete(file);
				delete(file_out);
				%copyfile('*.srw',buoy_folder,'f');
				copyfile('*.ets',buoy_folder,'f');
				copyfile('*.nc',buoy_folder,'f');
			    delete('*.ets');
				delete('*.nc');
			  elseif ((Mstr~=1) | (Nstr==1))
			    copyfile(file,allfile,'f');
				delete(file);
				copyfile('*.nc',buoy_folder,'f');
				delete('*.nc');
			  end
            end
        else
            [file,nodata] = getFtpMyOceanLatestDay(myoPartners(partnerId), myoProduct(1), fdate);
			if (nodata == 1) 
                if i==1   
			 	  nodataf=1;
				  return
		        else
				  return
			    end
		    else
			    [file_out,Mstr,Nstr]=convertMyOceanBuoysToMOHIDTimeSerie_all(file);

				ffdate=datenum(fdate,'yyyymmdd')+1;
			    fffdate=datestr(ffdate,'yyyymmdd');
				buoy_folder=[buoy_path1,fdate(1:4),'-',fdate(5:6),'-',fdate(7:8),'_',fffdate(1:4),'-',fffdate(5:6),'-',fffdate(7:8),'\'];
				allfile=[station,'.nc'];
			
				if ((Mstr==1) & (Nstr>1))
				  %allfile1=[station,'.srw'];
				  allfile1=[station,'.ets'];
			      copyfile(file_out,allfile1,'f')
			      copyfile(file,allfile,'f');
			      delete(file);
				  delete(file_out);
				  %copyfile('*.srw',buoy_folder,'f');
				  copyfile('*.ets',buoy_folder,'f');
				  copyfile('*.nc',buoy_folder,'f');
			      delete('*.ets');
				
			    elseif ((Mstr~=1) | (Nstr==1))
			      copyfile(file,allfile,'f');
				  delete(file);
				  copyfile('*.nc',buoy_folder,'f');
				  delete('*.nc');
			  end
		    end    
        end
        
        disp(['Downloaded MyOcean ', fdate, ' ', ...
                myoProduct(1).code, ' buoy ...'])
        

        if exist(allfile,'file')
		    disp([allfile, ' exist and plot_data=',plot_data])
		    
			if strcmp(plot_data,'1')
              if (i==1 | (nodataf==1) & (nodata == 0))	
                copyfile(allfile,gfile,'f');
				nodataf=0;
		      else
			    if (nodata == 1)
                   return
                end
                try
				  nc_cat(gfile,allfile,'f');
				catch
				  disp('an error occoured in the nc file')
				  mfidi = fopen('error_timeseries.dat','a');
                  fprintf (mfidi,'%s\n','an error occoured in files cat');
              	  fclose(mfidi);
                end
              end
		    end
        end
			
		i=i+1;
		
		
        if str2double(fdate(7:8))+1 > eomday(str2double(fdate(1:4)),str2double(fdate(5:6)))
        
            ndate = nextmonth(fdate);
            fdate=[ndate,'01'];
        else
            fdate =num2str(str2double(fdate)+1);
        end
         
      
      end
	  
      delete(['*_LATEST*.nc']);
	  
    end
        
    % Close ftp link
    close(myoPartners(1).ftpHandle);
    
    disp('Done getftp myocean')

function [file,nodata] = getFtpMyOceanLatestDay(myoFtp, myo, gfile)
%unused function, yet.

    today = datestr(date,'yyyymmdd');
    
    file = constructLatestFile(myo,gfile);

    fpath = constructLatestPath(myoFtp,gfile);
    
    if (~isempty(dir(myoFtp.ftpHandle, [fpath,'/',file])) ~= 0)
        cd (myoFtp.ftpHandle, fpath);
		mget (myoFtp.ftpHandle, file);
		nodata=0;
    else
        disp(['No data for ', fpath, file])
		mfidi = fopen('error_timeseries.dat','a');
		fprintf (mfidi,'%s\n',['No data for ', fpath, file]);
		fclose(mfidi);
		nodata=1;
		
    end
    
function [file,nodata] = getFtpMyOceanLatestMonth(myoFtp, myo, today)

global plot_data

    days = struct('day',{'01','02','03','04','05','06','07','08','09', ...
                '10','11','12','13','14','15','16','17','18','19', ...
                '20','21','22','23','24','25','26','27','28','29', ...
                '30','31'});

    fdate = today(1:6);

    file = constructMonthlyFile(myo, fdate);

    lastday = str2double(today(7:8));

    for i = 1:lastday

        fdatet = [fdate,days(i).day];

        fpath = constructLatestPath(myoFtp, fdatet);

        filet = constructLatestFile(myo, fdatet);

        cd (myoFtp.ftpHandle, fpath);
        if (~isempty(dir(myoFtp.ftpHandle, [fpath,'/',filet])) ~= 0)
              mget (myoFtp.ftpHandle, filet);
        else
             disp(['No data for', filet])
			 mfidi = fopen('error_timeseries.dat','a');
			 fprintf (mfidi,'%s/r/n',['No data for ', filet]);
			 fclose(mfidi);
			 
			 nodata=1;
		     
        end

        if strcmp(plot_data,'1')
         if exist(filet,'file')
           if i == 1
            copyfile(filet,file,'f');
           else         
             nc_cat(file,filet);
           end
         end
        end
    end

    delete([myo.region,'_LATEST*.nc']);

function [file,nodata] = getFtpMyOceanMonth(myoFtp, myo, fdate)
    fpath = constructMonthlyPath(myoFtp,myo,fdate);
    file = constructMonthlyFile(myo,fdate);
    myoFtp.ftpHandle
    fpath
    cd(myoFtp.ftpHandle,fpath);
	if (~isempty(dir(myoFtp.ftpHandle, [fpath,'/',file])) ~= 0)
        mget (myoFtp.ftpHandle, file);
		nodata=0;
		
    else
        disp(['No data for ', file])
		mfidi = fopen('error_timeseries.dat','a');
		fprintf (mfidi,'%s\n',['No data for ', file]);
		fclose(mfidi);
		nodata=1;
    end
     
	
      
    %adaptMonthToLatestFormat(file);

%This function is required because the netcdf in the latest
%format contain one extra variable SLEV_DM that is absent
%from the monthly format. This difference doesn't allow
%the concatenation of monthly files with latest.
%This function adds the missing variable to all the monthly formatted
%netcdf files.
function adaptMonthToLatestFormat(file)

    v.Name = 'SLEV_DM';
    v.Datatype = 'char';
    v.Dimension = { 'DEPTH', 'TIME'};

    v.Attribute.Name = 'long_name';
    v.Attribute.Value = 'method of data processing';

    v.Attribute.Name = 'conventions';
    v.Attribute.Value = 'OceanSITES reference table 5';

    v.Attribute.Name = 'flag_values';
    v.Attribute.Value = 'R, P, D, M';

    v.Attribute.Name = 'flag_meanings';
    v.Attribute.Value = 'realtime post-recovery delayed-mode mixed';

    v.Attribute.Name = '_FillValue';
    v.Attribute.Value = ' ';

    nc_addvar(file,v);

function ndate = nextmonth(fdate)

    months = struct('month',{'01','02','03','04','05','06','07','08', ...
        '09','10','11','12'});

    fdate = fdate(1:6);

    fyear = str2double(fdate(1:4));

    fmonth = str2double(fdate(5:6));

    %increment month
    fmonth = fmonth + 1;

    if fmonth == 13

        fyear = fyear + 1;

        fmonth = 1;

    end

    ndate = [num2str(fyear),months(fmonth).month];

function file = constructLatestFile(myo, fdate)
    file = [myo.region,'_LATEST_',myo.ts,'_', ...
            myo.datatype,'_',myo.code,'_',fdate,'.nc'];
        
function file = constructMonthlyFile(myo, fdate)
    	 
    file = [myo.region,'_',fdate,'_',myo.ts,'_', ...
            myo.datatype,'_',myo.code,'.nc'];

function fpath = constructLatestPath(myoFtp, fdate)
    fpath = [myoFtp.path,'/latest/',fdate];
        
function fpath = constructMonthlyPath(myoFtp, myo, fdate)
    switch myo.datatype
        case 'MO'
            fpath = [myoFtp.path,'/monthly/mooring/',fdate];
            if strcmp(myoFtp.ftp, 'ftp.bsh.de')
                fpath = [myoFtp.path,'/monthly/moorings/',fdate];
            end    
        otherwise
            fpath = [myoFtp.path,'/monthly/mooring/',fdate];
    end
        