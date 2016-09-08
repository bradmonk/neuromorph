function varargout = neuromorph(varargin)

%% ESTABLISH STARTING PATHS

clc; close all; clearvars -except datadir
disp('clearing matlab workspace');

thisfile = mfilename;
thisfilepath = fileparts(which(thisfile));


global datadir datafile datadate
datadir = '';
datafile = '';
datadate = '';


%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED


datadir = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/FRET_FLIM/FRETdata/Organotypic/DIV15/';
% datafile = 'Intensity Image of slice3-n5z6.bmp';
datadate = '20160902';



%% CD TO DATA DIRECTORY

if numel(datadir) < 1
    datadir = uigetdir;
end


cd(datadir);
home = cd;

disp(['HOME PATH: ' datadir])

if numel(datafile) < 1
    datafile = uigetfile('*.bmp');
end


%% ESTABLISH GLOBALS AND SET STARTING VALUES

global LifeImageFile FLIMcmap
global intenseThreshMIN intenseThreshMAX intenseThreshPMIN intenseThreshPMAX
global lifeThreshMIN lifeThreshMAX chiThreshMIN chiThreshMAX magnification maglevel
global flimdata flimdat flimtab flimd ROInames Datafilename 
global hROI ROImask ROIpos ROIarea dendritesize dpos
global ChiGood IntensityGood LifeGood AllGood
global ROI_LIFETIME ROI_INTENSITY ROI_CHI
global ROI_LIFETIME_MEAN ROI_INTENSITY_MEAN ROI_CHI_MEAN sROIarea
global imXlim imYlim VxD dVOL

LifeImageFile = 0;
FLIMcmap = FLIMcolormap;
intenseThreshMIN = 85.000;
intenseThreshMAX = 99.999;
intenseThreshPMIN = 2;
intenseThreshPMAX = 10;
lifeThreshMIN = 1000;
lifeThreshMAX = 2900;
chiThreshMIN = 0.7;
chiThreshMAX = 2.0;
magnification = 6;
maglevel = 6;
dendritesize = maglevel*5;
dpos = [];
flimdata = {};
flimdat = [];
flimtab = [];
flimd = [];
ROInames = '';
Datafilename = '';
hROI = [];
ROImask = [];
ROIpos = [];
ROIarea = [];
ChiGood = [];
IntensityGood = [];
LifeGood = [];
AllGood = [];
ROI_LIFETIME = [];
ROI_INTENSITY = [];
ROI_CHI = [];
ROI_LIFETIME_MEAN = [];
ROI_INTENSITY_MEAN = [];
ROI_CHI_MEAN = [];
sROIarea = [];
VxD = 1;
dVOL = 1;
% imXlim  = [];
% imYlim = [];


global flimdats ccmap cmmap imgC phCCD
flimdats = {};
ccmap = [];
cmmap = [];
imgC = [];


global boxtype
boxtype = 'freehand'; % freehand:1  rectangle:2  elipse:3








%% INITIATE GUI HANDLES AND CREATE GUI FIGURE

%Initialization code. Function creates a datastack variable for storing the
%files. It then displays the initial menu options - to compile a file or to
%load a file. Also sets up lifetime image and intensity image windows -
%these are set to invisible unless the 'load file' button is selected.


% ----- INITIAL SUBMENU GUI SETUP (LOAD DATA ~ COMPILE DATA) -----



% ----- MAIN FLIM ANALYSIS GUI WINDOW SETUP -----

% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.1 .1 .8 .8], 'BusyAction',...
    'cancel', 'Name', 'Lifetime image', 'Tag', 'lifetime image','Visible', 'Off', ...
    'KeyPressFcn', {@keypresszoom,1});

haxCCD = axes('Parent', mainguih, 'NextPlot', 'Add',...
    'Position', [0.05 0.15 0.7 0.7], 'OuterPosition', [-.08 0 .8 1],...
    'PlotBoxAspectRatio', [1024/768 1 1],'XColor','none','YColor','none'); 

% ----- FLIM ANALYSIS GUI PARAMETER BOXES -----

boxidh = uicontrol('Parent', mainguih, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.88 0.92 0.06 0.04], 'FontSize', 11); 
boxidselecth = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.92 0.12 0.04], 'FontSize', 11, 'String', 'ROI ID',...
    'Callback', @getROI); 



boxtypeh = uibuttongroup('Parent', mainguih, 'Visible','off',...
                  'Units', 'normalized',...
                  'Position',[0.70 0.85 0.25 0.05],...
                  'SelectionChangedFcn',@boxselection);
              
% Create three radio buttons in the button group.
boxtypeh1 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','freehand',...
                  'Units', 'normalized',...
                  'Position',[0.05 0.05 0.3 0.9],...
                  'HandleVisibility','off');
              
boxtypeh2 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','rectangle',...
                  'Units', 'normalized',...
                  'Position',[0.35 0.05 0.3 0.9],...
                  'HandleVisibility','off');

boxtypeh3 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','elipse',...
                  'Units', 'normalized',...
                  'Position',[0.65 0.05 0.3 0.9],...
                  'HandleVisibility','off');
boxtypeh.Visible = 'on';


resetROISh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.79 0.12 0.04], 'String', 'Reset all ROIs', 'FontSize', 11,...
    'Callback', @resetROIS);



setintenh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.72 0.12 0.04], 'FontSize', 11, 'String', 'Set intensity',...
    'Callback', @setinten);


dftintenh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.85 0.72 0.12 0.04], 'FontSize', 11,...
    'String', 'Default intensities','Callback', @defaultinten);


intThreshMinh = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
    'Position', [0.70 0.668 0.12 0.04], 'FontSize', 11, 'String', 'Min Intensity');
intThreshMin = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
    'Position', [0.70 0.64 0.12 0.04]);

intThreshMaxh = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
    'Position', [0.85 0.668 0.12 0.04], 'FontSize', 11, 'String', 'Max Intensity');
intThreshMax = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
    'Position', [0.85 0.64 0.12 0.04]);


lifetimethresholdh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
    'Position', [0.70 0.49 0.12 0.04], 'FontSize', 11, 'String', 'Lifetime Min');
lftthresholdMINh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized',...
    'Position', [0.70 0.46 0.12 0.04], 'FontSize', 11);


lifetimethreshMAXh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
    'Position', [0.85 0.49 0.12 0.04], 'FontSize', 11, 'String', 'Lifetime Max');
lftthresholdMAXh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized',...
    'Position', [0.85 0.46 0.12 0.04], 'FontSize', 11);



chithresholdminh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
    'Position', [0.70 0.33 0.12 0.04], 'FontSize', 11, 'String', 'Chi Min');
chiminh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
    'Position', [0.70 0.30 0.12 0.04], 'FontSize', 11);


chithresholdmaxh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized', ...
    'Position', [0.85 0.33 0.12 0.04], 'FontSize', 11, 'String', 'Chi Max');
chimaxh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
    'Position', [0.85 0.30 0.12 0.04], 'FontSize', 11);


magnifh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized', ...
    'Position', [0.70 0.58 0.12 0.04], 'FontSize', 11, 'String', 'Magnification');
magh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
    'Position', [0.70 0.555 0.12 0.04], 'FontSize', 11);


dendszh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.85 0.56 0.12 0.04], 'String', 'Get Dendrite Size', 'FontSize', 11,...
    'Callback', @getdendsize);



lifetimeviewerh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.20 0.24 0.04], 'String', 'Explore Image', 'FontSize', 11,...
    'Callback', @lifetimeviewer);


closeimagesh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.13 0.24 0.04], 'FontSize', 11, 'String', 'Close Windows',...
    'Callback', @closelftintenw);


savefileh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.06 0.24 0.04], 'String', 'Save File', 'FontSize', 11,...
    'Callback', @saveFile);

loadfile()




% -----------------------------------------------------------------
%% GUI TOOLBOX FUNCTIONS

function getROI(boxidselecth, eventdata)

    ROInum = str2num(boxidh.String);

    if strcmp(boxtype,'rectangle')
        
        hROI = imrect(haxCCD);
        
    elseif strcmp(boxtype,'elipse')
        
        hROI = imellipse(haxCCD);
        
    else % strcmp(boxtype,'freehand')
        
        hROI = imfreehand(haxCCD);
        
    end
    
    
    % imgC 	image variable name
    % phCCD imagesc plot handle
    
    
    ROImask = hROI.createMask(phCCD);
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));

    ROI_INTENSITY = imgC .* ROImask;
    
    ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));
    
    
    flimdata{ROInum} = {ROI_INTENSITY_MEAN, ROIarea};
                    
                    
                    
    fprintf('\n INTENSITY: % 5.5g \n AREA: % 5.5g \n\n',...
                ROI_INTENSITY_MEAN,ROIarea)

            

    doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
    switch doagainROI
       case 'Yes'
            set(boxidh,'String',num2str((str2num(boxidh.String)+1)) );
            getROI
       case 'No'
           set(boxidh,'String',num2str((str2num(boxidh.String)+1)) );
           % keyboard
    end

    set(gcf,'Pointer','arrow')

end



function lifetimeviewer(lifetimeviewerh, eventData)

    set(mainguih, 'Visible', 'Off');
    set(initmenuh, 'Visible', 'Off');

    lftthresholdMIN = str2double(get(lftthresholdMINh, 'String'));
    lftthresholdMAX = str2double(get(lftthresholdMAXh, 'String'));
    
    intenthresholdMIN = str2double(get(intThreshMin, 'String'));
    intenthresholdMAX = str2double(get(intThreshMax, 'String'));
    
    intPminmax = prctile(intensity(:),[intenthresholdMIN intenthresholdMAX]);
    
    chimin = str2double(get(chiminh, 'String'));
    chimax = str2double(get(chimaxh, 'String'));


    ChiG = (chi >= chimin & chi <= chimax);
    IntG = (intensity >= intPminmax(1) & intensity <= intPminmax(2));
    LifG = (lifetime >= lftthresholdMIN & lifetime <= lftthresholdMAX);
    AllG = (ChiG .* IntG .* LifG) > 0;

        
    % close all
    fh3=figure('Units','normalized','OuterPosition',[.05 .27 .9 .7],'Color','w');
    ah1 = axes('Position',[.05 .55 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah2 = axes('Position',[.30 .55 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah3 = axes('Position',[.05 .05 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah4 = axes('Position',[.30 .05 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah5 = axes('Position',[.55 .15 .40 .7],'Color','none','XTick',[],'YTick',[]);
    
        axes(ah1)
    imagesc(ChiG); title('Pixels within CHI thresholds')
        axes(ah2)
    imagesc(IntG); title('Pixels within INTENSITY thresholds')
        axes(ah3)
    imagesc(LifG); title('Pixels within LIFETIME thresholds')
        axes(ah4)
    imagesc(AllG); title('Pixels within ALL thresholds')
        axes(ah5)
    imagesc(lifetime .* AllG); title('Fluorescent Lifetime of pixels above ALL thresholds')
        colormap(ah5,[0 0 0; flipud(jet(23))])
        caxis([lftthresholdMIN lftthresholdMAX])
        colorbar
        set(ah1,'YDir','normal')
        set(ah2,'YDir','normal')
        set(ah3,'YDir','normal')
        set(ah4,'YDir','normal')
        set(ah5,'YDir','normal')
        
    disp('Close figure to continue')
    uiwait(fh3)
    
    
    set(mainguih, 'Visible', 'On');

end



function setinten(hObject, eventdata)
    
       lowerinten = str2num(intThreshMin.String);
       upperinten = str2num(intThreshMax.String);
       
       lowerintenPCT = prctile(intensity(:),lowerinten);
       upperintenPCT = prctile(intensity(:),upperinten);
              
       set(haxCCD,'CLim',[lowerintenPCT upperintenPCT])

end



function defaultinten(hObject, eventdata)
        
       set(intThreshMin, 'String', num2str(intenseThreshMIN));
       set(intThreshMax, 'String', num2str(intenseThreshMAX));

end



function closelftintenw(hObject, eventdata)
%Closelftintenw sets both lifetime image and intensity image windows to
%invisible. The initial menu becomes visible again for further selection. 
    
       set(mainguih, 'Visible', 'Off');
       set(initmenuh, 'Visible', 'On');
       saveROI = zeros(200, 17);
       saveData = zeros(200, 9);
       datastack = zeros(1,1,3,'double');
       lifetime = zeros(1, 1);
       intensity = zeros(1, 1);
       chi = zeros(1, 1);
       lifetimeimage = zeros(1, 1);
       intensityimage = zeros(1, 1);
       xdim = 0;
       ydim = 0;
end



function keypresszoom(hObject, eventData, key)
    
    

    
        % --- ZOOM ---
        
        if strcmp(mainguih.CurrentCharacter,'=')
            
            % IN THE FUTURE USE MOUSE LOCATION TO ZOOM
            % INTO A SPECIFIC POINT. TO QUERY MOUSE LOCATION
            % USE THE METHOD: mainguih.CurrentPoint
            
            zoom(1.5)
        end
        
        if strcmp(mainguih.CurrentCharacter,'-')
            zoom(.5)
        end
                
        
        % --- PAN ---
        
        if strcmp(mainguih.CurrentCharacter,'p')

            pan('on')        
            % h = pan;
            % h.ActionPreCallback = @myprecallback;
            % h.ActionPostCallback = @mypostcallback;
            % h.Enable = 'on';
        end
        if strcmp(mainguih.CurrentCharacter,'o')
            pan('off')        
        end
        
        if strcmp(mainguih.CurrentCharacter,'f')
            haxCCD.XLim = haxCCD.XLim+20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'s')
            haxCCD.XLim = haxCCD.XLim-20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'e')
            haxCCD.YLim = haxCCD.YLim+20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'d')
            haxCCD.YLim = haxCCD.YLim-20;
        end
        
        
        % --- RESET ZOOM & PAN ---
        
        if strcmp(mainguih.CurrentCharacter,'0')
            zoom out
            zoom reset
            haxCCD.XLim = imXlim;
            haxCCD.YLim = imYlim;
        end
        
        
end



function resetROIS(deleteROIh, eventData)
    
    ROInum = str2double(get(boxidh, 'String'));
        
    % spf1 = sprintf('Delete ROI #%1.2g ?.',ROInum);
    yesno = questdlg('Reset all ROIs and start over?','Warning','Yes','No','Yes');
    
    
    if strcmp(yesno,'Yes')
    
        flimdata(:) = [];
        
        delete(haxCCD.Children(1:end-2))
        
        set(boxidh, 'String','1')
        
        msgbox('ROI data-container and image has been reset');
        
    else
        msgbox('Phew, nothing was deleted!');
    end
    
end



function boxselection(source,callbackdata)
    
    % callbackdata.OldValue.String
    boxtype = callbackdata.NewValue.String;

end



function getdendsize(boxidselecth, eventdata)


   hline = imline;
   dpos = hline.getPosition();
    
   dendritesize = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

   disp(['dendrite size:' num2str(dendritesize)])

end




function loadfile()
%Load file triggers uiresume; the initial menu is set to invisible. Prompts
%user for file to load, copies the datastack from the file; sets the image 
%windows to visible, and plots the images.


    imgC = ccdget([datadir datafile]);

    set(mainguih, 'Visible', 'On');

    
    set(mainguih, 'Colormap', hot);
    
    axes(haxCCD)
    colormap(haxCCD,hot)
    phCCD = imagesc(imgC , 'Parent', haxCCD);
              pause(1)
              
              
              
    ccmap = hot;
    cmmap = [0 0 0; ccmap(end-40:end,:)];    
    mainguih.Colormap = cmmap;
    
    pause(.2)
    imXlim = haxCCD.XLim;
    imYlim = haxCCD.YLim;

    
    xdim = size(imgC,2); 
    ydim = size(imgC,1);


    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
    set(intThreshMin, 'String', num2str(intenseThreshMIN));
    set(intThreshMax, 'String', num2str(intenseThreshMAX));

    set(intThreshMin, 'String', num2str(intenseThreshMIN));
    set(intThreshMax, 'String', num2str(intenseThreshMAX));

    set(lftthresholdMINh, 'String', num2str(lifeThreshMIN));
    set(lftthresholdMAXh, 'String', num2str(lifeThreshMAX));

    set(chiminh, 'String', num2str(chiThreshMIN));
    set(chimaxh, 'String', num2str(chiThreshMAX));

    set(magh, 'String', num2str(magnification));

    set(mainguih, 'Name', datafile);
    set(boxidh, 'String', int2str(1));
    set(haxCCD, 'XLim', [1 xdim]);
    set(haxCCD, 'YLim', [1 ydim]);
    %----------------------------------------------------
    
    
    
    
    
end




function prepForSave(savefileh, eventData)
    
    % ------
    
    lftthresholdMIN = str2double(lftthresholdMINh.String);
    lftthresholdMAX = str2double(lftthresholdMAXh.String);
        
    intPminmax = prctile(intensity(:),...
        [str2double(intThreshMin.String) str2double(intThreshMax.String)]);
    
    chimin = str2double(chiminh.String);
    chimax = str2double(chimaxh.String);
    
    ChiGood       = (chi >= chimin & chi <= chimax);
    IntensityGood = (intensity >= intPminmax(1) & intensity <= intPminmax(2));
    LifeGood      = (lifetime >= lftthresholdMIN & lifetime <= lftthresholdMAX);
    AllGood       = (ChiGood .* IntensityGood .* LifeGood) > 0;

    
    
    
    
    % ------
    sROI = findobj(haxCCD,'Type','patch');
    
    for nn = 1:length(sROI)
        
        sROIpos = sROI(nn).Vertices;
        sROIarea = polyarea(sROIpos(:,1),sROIpos(:,2));
        sROImask = poly2mask(sROIpos(:,1),sROIpos(:,2), ...
                             size(imgC,1), size(imgC,2));

        ROI_INTENSITY = imgC .* sROImask;
    
        ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));

        flimdats{nn} = {sROIarea,ROI_INTENSITY_MEAN};
    
    end
    % ------
        
end







function saveFile(savefileh, eventData)
    
    
    % prepForSave(savefileh, eventData)
    

    cd(datadir);

    saveDatafilename = inputdlg('Enter a filename to save data','file name',1,...
                                {datafile(1:end-4)});

    Datafilename = char(strcat(saveDatafilename));

    maglevel = str2double(magh.String);
    
    if numel(dpos) < 1; % If dendrite size was manually selected, numel(dpos) > 1
        dendritesize = maglevel*5;
    end

    %for nn = 1:size(flimdats,2)
    for nn = 1:size(flimdata,2)
        flimdat(nn,:) = [flimdata{1,nn}{1:2} maglevel dendritesize];        
        ROInames{nn} = num2str(nn);        
    end
    
    
    flimtab = array2table(flimdat);
    flimtab.Properties.VariableNames = {'INTENSITY' 'AREA' 'MAG' 'DSIZE'};
    flimtab.Properties.RowNames = ROInames;
    
    flimtab.FILE = repmat(datafile,size(flimdata,2),1);
    flimtab.DATE = repmat(datadate,size(flimdata,2),1);
    
    
    writetable(flimtab,[Datafilename '.csv'],'WriteRowNames',true)
    disp('Data saved successfully!')
    % msgbox('Data saved successfully');

    cd(home);


end







%{
function saveFile(savefileh, eventData)

        
    cd(datadir);

    saveDatafilename = inputdlg('Enter a filename to save data','file name',1,...
                                {datafile(1:end-4)});

    Datafilename = char(strcat(saveDatafilename));

    maglevel = str2double(magh.String);
    
    if numel(dpos) < 1; % If dendrite size was manually selected, numel(dpos) > 1
        dendritesize = maglevel*5;
    end
    
    
    for nn = 1:size(flimdata,2)
        
        VxD = flimdata{1,nn}{7} ./ (.5 .* dendritesize).^2;
        
        dVOL = VxD .* 0;
        
        flimdat(nn,:) = [flimdata{1,nn}{4:7} maglevel dendritesize VxD dVOL];        
        ROInames{nn} = num2str(nn);        
    end
    
    
    
    flimtab = array2table(flimdat);
    flimtab.Properties.VariableNames = {'LIFETIME' 'INTENSITY' 'CHISQR' 'VOLUME' ...
                                        'MAG' 'DSIZE' 'VxD' 'dVOL'};
    flimtab.Properties.RowNames = ROInames;
    
    
    writetable(flimtab,[Datafilename '.csv'],'WriteRowNames',true)
    disp('Data saved successfully!')
    % msgbox('Data saved successfully');


    OpenFLIMdataTool = questdlg('Open FLIMX plots?',...
                                'Open FLIMX plots?',...
                                'Yes', 'No', 'No');
                            
    switch OpenFLIMdataTool
       case 'Yes'
            assignin('base','FXdata',flimdata)
            assignin('base','FXdat',flimdat)
            assignin('base','FXcsv',flimtab)
            disp('Welcome to the FLIMXplots toolbox')
            %edit FLIMXplots.m
            FLIMXplots(flimdata,flimdat,flimtab,Datafilename)
            close all
       case 'No'
    end

    cd(home);


end
%}


end
%% EOF
