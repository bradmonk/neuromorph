function varargout = neuromorph(varargin)
%% neuromorph.m - NEURON MORPHOLOGY TOOLBOX
%{
% 
% Syntax
% -----------------------------------------------------
%     neuromorph()
% 
% 
% Description
% -----------------------------------------------------
% 
%     neuromorph() is run with no arguments passed in. The user
%     will be prompted to select a directory which contains the image data
%     tif stack along with the corresponding xls file.
%     
% 
% Useage Definitions
% -----------------------------------------------------
% 
%     neuromorph()
%         launches a GUI to process image stack data from GRIN lens
%         experiments
%  
% 
% 
% Example
% -----------------------------------------------------
% 
%     TBD
% 
% 
% See Also
% -----------------------------------------------------
% >> web('http://bradleymonk.com/neuromorph')
% >> web('http://imagej.net/Miji')
% >> web('http://bigwww.epfl.ch/sage/soft/mij/')
% 
% 
% Attribution
% -----------------------------------------------------
% % Created by: Bradley Monk
% % email: brad.monk@gmail.com
% % website: bradleymonk.com
% % 2016.07.04
%}
%----------------------------------------------------

%% ESTABLISH STARTING PATHS
clc; close all; clear all; clear java;
% clearvars -except varargin
disp('WELCOME TO NEUROMORPH - A NEURON MORPHOLOGY TOOLBOX')
% set(0,'HideUndocumented','off')

global thisfilepath
thisfile = 'neuromorph.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath);

fprintf('\n\n Current working path set to: \n % s \n', thisfilepath)

% global isbrad
% upath = userpath;
% isbrad = strcmp('/Users/bradleymonk',upath(1:18));
    
    pathdir0 = thisfilepath;
    pathdir1 = [thisfilepath '/neuromorphdata'];
    
    gpath = [pathdir0 ':' pathdir1];
    
    addpath(gpath)

fprintf('\n\n Added folders to path: \n % s \n % s \n % s \n % s \n\n',...
        pathdir0,pathdir1)




%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED

global datadir datafile datadate
datadir = '';
datafile = '';
datadate = '';

datadir = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/neuromorph/neuromorphdata/organotypic/DIV11/2016_08_30/';
% datafile = 'Intensity Image of slice3-n5z6.bmp';
datadate = '20160902';

global imgpath
imgpath = '';

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

imgpath = [datadir datafile];


%% ESTABLISH GLOBALS AND SET STARTING VALUES

global IMG DENDRITE SPINE SPINEHN
IMG = [];

global haxPRE






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


global flimdats ccmap cmmap phCCD
flimdats = {};
ccmap = [];
cmmap = [];



global boxtype
boxtype = 'freehand'; % freehand:1  rectangle:2  elipse:3



%########################################################################
%%              MAIN ANALYSIS GUI WINDOW SETUP 
%########################################################################


% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.1 .1 .8 .8], 'BusyAction',...
    'cancel', 'Name', 'Lifetime image', 'Tag', 'lifetime image','Visible', 'Off', ...
    'KeyPressFcn', {@keypresszoom,1});

haxCCD = axes('Parent', mainguih, 'NextPlot', 'Add',...
    'Position', [0.01 0.01 0.60 0.95], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none'); 




cmapsliderH = uicontrol('Parent', mainguih, 'Units', 'normalized','Style','slider',...
	'Max',50,'Min',1,'Value',10,'SliderStep',[.1 .2],...
	'Position', [0.01 0.96 0.60 0.03], 'Callback', @cmapslider);



haxPRE = axes('Parent', mainguih, 'NextPlot', 'replacechildren',...
    'Position', [0.63 0.03 0.3 0.25], ...
    'XColor','none','YColor','none'); 

axes(haxCCD)



%----------------------------------------------------
%           IMAGE PROCESSING PANEL
%----------------------------------------------------
IPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.62 0.65 0.30 0.30]); % 'Visible', 'Off',


boxidh = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.55 0.80 0.40 0.15], 'FontSize', 11); 
boxidselecth = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.80 0.40 0.15], 'FontSize', 11, 'String', 'SPINE ID',...
    'Callback', @getROI); 



boxtypeh = uibuttongroup('Parent', IPpanelH, 'Visible','off',...
                  'Units', 'normalized',...
                  'Position',[0.05 0.55 0.90 0.20],...
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


resetROISh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.10 0.40 0.15], 'String', 'Reset all ROIs', 'FontSize', 11,...
    'Callback', @resetROIS);



dendszh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.55 0.10 0.40 0.15], 'String', 'Get Dendrite Size', 'FontSize', 11,...
    'Callback', @getdendsize);





%----------------------------------------------------
%           DATA I/O PANEL
%----------------------------------------------------
IOpanelH = uipanel('Title','Data I/O ','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.62 0.35 0.30 0.30]); % 'Visible', 'Off',

lifetimeviewerh = uicontrol('Parent', IOpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.80 0.40 0.15], 'String', 'Explore Image', 'FontSize', 11,...
    'Callback', @lifetimeviewer);


closeimagesh = uicontrol('Parent', IOpanelH, 'Units', 'normalized', ...
    'Position', [0.55 0.80 0.40 0.15], 'FontSize', 11, 'String', 'Close Windows',...
    'Callback', @closelftintenw);


savefileh = uicontrol('Parent', IOpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.50 0.90 0.25], 'String', 'Save File', 'FontSize', 11,...
    'Callback', @saveFile);





%----------------------------------------------------
%     IMPORT IMAGE & LOAD DEFAULT TOOLBOX PARAMETERS
%----------------------------------------------------

loadfile()





%{
% setintenh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
%     'Position', [0.70 0.72 0.12 0.04], 'FontSize', 11, 'String', 'Set intensity',...
%     'Callback', @setinten);
% 
% 
% dftintenh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
%     'Position', [0.85 0.72 0.12 0.04], 'FontSize', 11,...
%     'String', 'Default intensities','Callback', @defaultinten);
% 
% 
% intThreshMinh = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
%     'Position', [0.70 0.668 0.12 0.04], 'FontSize', 11, 'String', 'Min Intensity');
% intThreshMin = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
%     'Position', [0.70 0.64 0.12 0.04]);
% 
% intThreshMaxh = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
%     'Position', [0.85 0.668 0.12 0.04], 'FontSize', 11, 'String', 'Max Intensity');
% intThreshMax = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
%     'Position', [0.85 0.64 0.12 0.04]);
% 
% 
% lifetimethresholdh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
%     'Position', [0.70 0.49 0.12 0.04], 'FontSize', 11, 'String', 'Lifetime Min');
% lftthresholdMINh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized',...
%     'Position', [0.70 0.46 0.12 0.04], 'FontSize', 11);
% 
% 
% lifetimethreshMAXh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
%     'Position', [0.85 0.49 0.12 0.04], 'FontSize', 11, 'String', 'Lifetime Max');
% lftthresholdMAXh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized',...
%     'Position', [0.85 0.46 0.12 0.04], 'FontSize', 11);
% 
% 
% 
% chithresholdminh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
%     'Position', [0.70 0.33 0.12 0.04], 'FontSize', 11, 'String', 'Chi Min');
% chiminh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
%     'Position', [0.70 0.30 0.12 0.04], 'FontSize', 11);
% 
% 
% chithresholdmaxh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized', ...
%     'Position', [0.85 0.33 0.12 0.04], 'FontSize', 11, 'String', 'Chi Max');
% chimaxh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
%     'Position', [0.85 0.30 0.12 0.04], 'FontSize', 11);
% 
% 
% magnifh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized', ...
%     'Position', [0.70 0.58 0.12 0.04], 'FontSize', 11, 'String', 'Magnification');
% magh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
%     'Position', [0.70 0.555 0.12 0.04], 'FontSize', 11);





% hSP = imscrollpanel(mainguih,phCCD);
% set(hSP,'Units','normalized','Position',[0 .1 1 .9])
% 
% hMagBox = immagbox(mainguih,phCCD);
% pos = get(hMagBox,'Position');
% set(hMagBox,'Position',[0 0 pos(3) pos(4)])
% imoverview(phCCD)
%}







% -----------------------------------------------------------------------------
%%                     GUI TOOLBOX FUNCTIONS
% -----------------------------------------------------------------------------


function getROI(boxidselecth, eventdata)

    ROInum = str2num(boxidh.String);

    if strcmp(boxtype,'rectangle')
        
        hROI = imrect(haxCCD);
        
    elseif strcmp(boxtype,'elipse')
        
        hROI = imellipse(haxCCD);
        
    else % strcmp(boxtype,'freehand')
        
        hROI = imfreehand(haxCCD);
        
    end
    
    
    % IMG 	image variable name
    % phCCD imagesc plot handle
    
    % ---------------------------------------
    % GET SPINE MORPHOLOGY STATISTICS
    % ---------------------------------------
    
    ROImask = hROI.createMask(phCCD);
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));

    ROI_INTENSITY = IMG .* ROImask;
    
    ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));
    
    
    % flimdata{ROInum} = {ROI_INTENSITY_MEAN, ROIarea};
                    
    SPINE.area = ROIarea;
    SPINE.intensity = ROI_INTENSITY_MEAN;
    

    fprintf('\n TOTAL SPINE INTENSITY: % 5.5g \n TOTAL SPINE AREA: % 5.5g \n\n',...
                ROI_INTENSITY_MEAN,ROIarea)
            
            
    % ---------------------------------------
    % GET SPINE-HEAD:NECK MORPHOLOGY STATISTICS
    % ---------------------------------------
      % row 1 of dpos is the x,y pos of the line origin
      % test this using scatter(dpos(1,1),dpos(1,2),'r')
      
    disp('Draw line across spine-head parallel to dendritic shaft')

	hline = imline(haxCCD);
	dpos = hline.getPosition(); 

	spineheadwidth = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    spineheadcenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(spineheadcenter(1),spineheadcenter(2),'r')

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(spineheadwidth));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy,'.r')
    
    SPINEHN.headwidth = spineheadwidth;
    SPINEHN.headintensity = mean(c);
    SPINEHN.headintensityprofile = c;
    SPINEHN.headcenter = spineheadcenter;
    
    
    disp('Draw line along length of spine neck')

	hline = imline(haxCCD);
	dpos = hline.getPosition(); 

	spinenecklength = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    spineneckcenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(spineneckcenter(1),spineneckcenter(2),'r')

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(spinenecklength));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy,'.r')
    
    SPINEHN.necklength = spinenecklength;
    SPINEHN.neckintensity = mean(c);
    SPINEHN.neckintensityprofile = c;
    SPINEHN.neckcenter = spineneckcenter;
    
    
    
    disp(['SPINE HEAD WIDTH:' num2str(SPINEHN.headwidth)])
    disp(['SPINE NECK LENGTH:' num2str(SPINEHN.necklength)])

    % ---------------------------------------
    % GET DENDRITE MORPHOLOGY STATISTICS
    % ---------------------------------------

    disp('Draw line across dendrite region adjacent to spine')

	hline = imline(haxCCD);
	dpos = hline.getPosition(); 
      % row 1 of dpos is the x,y pos of the line origin
      % test this using scatter(dpos(1,1),dpos(1,2),'r')
    
	dendritesize = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    dendritecenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(dendritecenter(1),dendritecenter(2),'r')

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(dendritesize));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy,'.r')
    
    DENDRITE.size = dendritesize;
    DENDRITE.intensity = mean(c);
    DENDRITE.intensityprofile = c;
    DENDRITE.center = dendritecenter;
    
    disp(['DENDRITE SIZE:' num2str(dendritesize)])
    
    
    
    plot(c)
    
    
    % ---------------------------------------
    % SAVE MORPHOLOGY STATISTICS FOR THIS SPINE:DENDRITE PAIR
    % ---------------------------------------
    
    fprintf(['\n TOTAL SPINE INTENSITY: % 5.3f '...
         '\n TOTAL SPINE AREA:      % 5.1f '...
         '\n SPINE HEAD WIDTH:      % 5.1f '...
         '\n SPINE NECK LENGTH:     % 5.1f '...
         '\n DENDRITE DIAMETER:     % 5.1f '...
         '\n DENDRITE INTENSITY:    % 5.3f \n\n'],...
            ROI_INTENSITY_MEAN,ROIarea,...
            SPINEHN.headwidth,SPINEHN.necklength,...
            DENDRITE.size, DENDRITE.intensity)
    
    flimdata{ROInum} = {ROI_INTENSITY_MEAN, ROIarea, SPINE, SPINEHN, DENDRITE};
    
    
    
    
    
    % ---------------------------------------
    % QUESTION DIALOGUE TO KEEP DRAWING OR END
    % ---------------------------------------
            
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

    
    iminfo = imfinfo(imgpath);
    [im, map] = imread(imgpath);


    im_size = size(im);
    im_nmap = numel(map);
    im_ctype = iminfo.ColorType;


    if strcmp(im_ctype, 'truecolor') || numel(im_size) > 2

        IMG = rgb2gray(im);
        IMG = im2double(IMG);

    elseif strcmp(im_ctype, 'indexed')

        IMG = ind2gray(im,map);
        IMG = im2double(IMG);

    elseif strcmp(im_ctype, 'grayscale')

        IMG = im2double(im);

    else

        IMG = im;

    end
    
    
    
    

    set(mainguih, 'Visible', 'On');

    
    axes(haxCCD)
    colormap(haxCCD,bone); % parula
    phCCD = imagesc(IMG , 'Parent', haxCCD);
              pause(1)
              
    ccmap = bone;
    cmmap = [zeros(10,3); ccmap(end-40:end,:)];
    colormap(haxCCD,cmmap)
    mainguih.Colormap = cmmap;
    
    
    
    pause(.2)
    imXlim = haxCCD.XLim;
    imYlim = haxCCD.YLim;

    
    xdim = size(IMG,2); 
    ydim = size(IMG,1);

    
    
    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
%     set(intThreshMin, 'String', num2str(intenseThreshMIN));
%     set(intThreshMax, 'String', num2str(intenseThreshMAX));
% 
%     set(intThreshMin, 'String', num2str(intenseThreshMIN));
%     set(intThreshMax, 'String', num2str(intenseThreshMAX));
% 
%     set(lftthresholdMINh, 'String', num2str(lifeThreshMIN));
%     set(lftthresholdMAXh, 'String', num2str(lifeThreshMAX));
% 
%     set(chiminh, 'String', num2str(chiThreshMIN));
%     set(chimaxh, 'String', num2str(chiThreshMAX));
% 
%     set(magh, 'String', num2str(magnification));

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
                             size(IMG,1), size(IMG,2));

        ROI_INTENSITY = IMG .* sROImask;
    
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


%----------------------------------------------------
%        IMAGE SIDER CALLBACK
%----------------------------------------------------
function cmapslider(hObject, eventdata)

    % Hints: hObject.Value returns position of slider
    %        hObject.Min and hObject.Max determine range of slider
    % sunel = get(handles.sunelslider,'value'); % Get current light elev.
    % sunaz = get(hObject,'value');   % Varies from -180 -> 0 deg

    
    
    
    slideVal = ceil(cmapsliderH.Value);

              
    % cmap = colormap(haxCCD);

    ccmap = bone; % parula
    
    % cmmap = [zeros(slideVal,3); ccmap(end-40:end,:)];
    cmmap = [zeros(slideVal,3); ccmap(slideVal:end,:)];
    
    
    colormap(haxCCD,cmmap)

    
    pause(.05)

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
