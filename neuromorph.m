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
    datafile = uigetfile('*.tif*; *.bmp');
end

imgpath = [datadir '/' datafile];


%% ESTABLISH GLOBALS AND SET STARTING VALUES

global IMG DENDRITE SPINE SPINEHN ROISAVES ROInum
IMG = [];
ROISAVES = [];

ROISAVES.SpineMask = [];
ROISAVES.SpinePos = [];

ROISAVES.SpineExtentPos = [0 0];
ROISAVES.SpineExtentCenter = [];
ROISAVES.SpineExtentX = [];
ROISAVES.SpineExtentY = [];
    
ROISAVES.SpineHeadPos = [0 0];
ROISAVES.SpineHeadCenter = [];
ROISAVES.SpineHeadX = [];
ROISAVES.SpineHeadY = [];    

ROISAVES.SpineNeckPos = [0 0];
ROISAVES.SpineNeckCenter = [];
ROISAVES.SpineNeckX = [];
ROISAVES.SpineNeckY = [];

ROISAVES.DendritePos = [0 0];
ROISAVES.DendriteCenter = [];
ROISAVES.DendriteX = [];
ROISAVES.DendriteY = [];

ROISAVES.SpineNearPos = [0 0];
ROISAVES.SpineNearCenter = [];
ROISAVES.SpineNearX = [];
ROISAVES.SpineNearY = [];



SPINE.intensity = [];
SPINE.area = [];
SPINEHN.spineextent = [];
SPINEHN.spineextentintensity = [];
SPINEHN.spineextentintensityprofile = [];
SPINEHN.spineextentcenter = [];
SPINEHN.headwidth = [];
SPINEHN.headintensity = [];
SPINEHN.headintensityprofile = [];
SPINEHN.headcenter = [];
SPINEHN.necklength = [];
SPINEHN.neckintensity = [];
SPINEHN.neckintensityprofile = [];
SPINEHN.neckcenter = [];
DENDRITE.size = [];
DENDRITE.intensity = [];
DENDRITE.intensityprofile = [];
DENDRITE.center = [];
DENDRITE.nearestspine = [];
DENDRITE.nearestspineint = [];
DENDRITE.nearestspineprofile = [];
DENDRITE.nearestspinecenter = [];


SPINE.area = 0;
SPINE.intensity = 0;
SPINEHN.spineextent = 0;
SPINEHN.spineextentintensity = 0;
SPINEHN.headwidth = 0;
SPINEHN.headintensity = 0;
SPINEHN.necklength = 0;
SPINEHN.neckintensity = 0;
DENDRITE.size = 0;
DENDRITE.intensity = 0;
DENDRITE.nearestspine = 0;
DENDRITE.nearestspineint = 0;




global haxPRE memos memoboxH
global dotsz cdotsz
dotsz = 30;
cdotsz = 150;


global magnification maglevel
global MORPHdata MORPHdat MORPHtab MORPHd ROInames Datafilename 
global hROI ROImask ROIpos dendritesize dpos
global imXlim imYlim VxD dVOL

magnification = 6;
maglevel = 6;
dendritesize = maglevel*5;
dpos = [];
MORPHdata = {};
MORPHdat = [];
MORPHtab = [];
MORPHd = [];
ROInames = '';
Datafilename = '';
hROI = [];
ROImask = [];
ROIpos = [];
ROIarea = [];
ROI_INTENSITY = [];
ROI_INTENSITY_MEAN = [];
VxD = 1;
dVOL = 1;


global MORPHdats ccmap cmmap phCCD
MORPHdats = {};
ccmap = [];
cmmap = [];

% global ROI_INTENSITY ROI_INTENSITY_MEAN ROIarea


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
    'Position', [0.63 0.03 0.3 0.25]); 

axes(haxCCD)



%----------------------------------------------------
%           IMAGE PROCESSING PANEL
%----------------------------------------------------
IPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.62 0.60 0.30 0.39]); % 'Visible', 'Off',


getROIH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.80 0.45 0.15], 'FontSize', 11, 'String', 'MEASURE ROI',...
    'Callback', @getROI); 

uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.68 0.90 0.25 0.10], 'FontSize', 11,'String', 'ROI ID');
ROIIDh = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.68 0.81 0.25 0.10], 'FontSize', 11); 


              
measureButtonsH = uipanel('Parent', IPpanelH,'Title','Analyses','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.05 0.15 0.90 0.60]); % 'Visible', 'Off',              

yp = 1 - ((1/6.2) .* (1:6));              
bpos1 = [0.05 yp(1) 0.95 0.14];
bpos2 = [0.05 yp(2) 0.95 0.14];
bpos3 = [0.05 yp(3) 0.95 0.14];
bpos4 = [0.05 yp(4) 0.95 0.14];
bpos5 = [0.05 yp(5) 0.95 0.14];
bpos6 = [0.05 yp(6) 0.95 0.14];

checkbox1H = uicontrol('Parent', measureButtonsH,'Style','checkbox','Units','normalized',...
    'Position', bpos1 ,'String','Spine Area', 'Value',1);
checkbox2H = uicontrol('Parent', measureButtonsH,'Style','checkbox','Units','normalized',...
    'Position', bpos2 ,'String','Spine Total Length', 'Value',1);
checkbox3H = uicontrol('Parent', measureButtonsH,'Style','checkbox','Units','normalized',...
    'Position', bpos3 ,'String','Spine Head Diameter', 'Value',1);
checkbox4H = uicontrol('Parent', measureButtonsH,'Style','checkbox','Units','normalized',...
    'Position', bpos4 ,'String','Spine Neck Length', 'Value',1);
checkbox5H = uicontrol('Parent', measureButtonsH,'Style','checkbox','Units','normalized',...
    'Position', bpos5 ,'String','Dendritic Shaft Diameter', 'Value',1);
checkbox6H = uicontrol('Parent', measureButtonsH,'Style','checkbox','Units','normalized',...
    'Position', bpos6 ,'String','Nearest Neighbor Spine', 'Value',1);




savefileh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.02 0.65 0.10], 'String', 'Save File', 'FontSize', 11,...
    'Callback', @saveFile);

loadROIh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.70 0.02 0.25 0.10], 'String', 'Load ROIs', 'FontSize', 11,...
    'Callback', @loadROI);



%----------------------------------------------------
%           MEMO CONSOLE GUI WINDOW
%----------------------------------------------------

memopanelH = uipanel('Parent', mainguih,'Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.62 0.30 0.30 0.29]); % 'Visible', 'Off',


memos = {' Welcome to Neuromorph', ' ',...
         ' Press MEASURE ROI to start', ' ', ...
         ' ', ' ', ...
         ' ', ' ', ...
         ' ', ' '};

memoboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',10,'Min',0,'Value',[],'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memos,'FontWeight', 'bold',...
        'Position',[.05 .05 .90 .90]);  






%%
%----------------------------------------------------
%     IMPORT IMAGE & LOAD DEFAULT TOOLBOX PARAMETERS
%----------------------------------------------------

loadfile()

axes(haxCCD)

% -----------------------------------------------------------------------------
%%                     GUI TOOLBOX FUNCTIONS
% -----------------------------------------------------------------------------





%----------------------------------------------------
%        QUANTIFY SPINE ROI
%----------------------------------------------------
function getROI(boxidselecth, eventdata)

    ROInum = str2num(ROIIDh.String);


    if checkbox1H.Value
        MORPHOa(ROInum)
    end
    
    if checkbox2H.Value
        MORPHOb(ROInum)
    end
    
    if checkbox3H.Value
        MORPHOc(ROInum)
    end

    if checkbox4H.Value
        MORPHOd(ROInum)
    end

    if checkbox5H.Value
        MORPHOe(ROInum)
    end

    if checkbox6H.Value
        MORPHOf(ROInum)
    end

    
    spf1 = sprintf(['\n TOTAL SPINE INTENSITY: % 5.3f '...
     '\n TOTAL SPINE AREA:      % 5.1f '...
     '\n SPINE HEAD WIDTH:      % 5.1f '...
     '\n SPINE NECK LENGTH:     % 5.1f '...
     '\n NEAREST SPINE DIST:    % 5.1f '...
     '\n DENDRITE DIAMETER:     % 5.1f '...
     '\n DENDRITE INTENSITY:    % 5.3f \n\n'],...
     SPINE.intensity,SPINE.area,...
     SPINEHN.headwidth,SPINEHN.necklength,...
     DENDRITE.nearestspine,...
     DENDRITE.size, DENDRITE.intensity);
    disp(spf1)
    
    % ------
    memos(1:end-1) = memos(2:end);     
    memos{3} = ['TOTAL SPINE INTENSITY: ' num2str(SPINE.intensity)];
    memos{4} = ['TOTAL SPINE AREA: '      num2str(SPINE.area)];
    memos{5} = ['SPINE HEAD WIDTH: '      num2str(SPINEHN.headwidth)];
    memos{6} = ['SPINE NECK LENGTH: '     num2str(SPINEHN.necklength)];
    memos{7} = ['DENDRITE DIAMETER: '     num2str(DENDRITE.size)];
    memos{8} = ['DENDRITE INTENSITY: '    num2str(DENDRITE.intensity)];
    memos{9} = ['NEAREST SPINE DIST: '    num2str(DENDRITE.nearestspine)];
    memos{end} = ' ';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
    
    % ---------------------------------------
    % SAVE MORPHOLOGY STATISTICS FOR THIS SPINE:DENDRITE PAIR
    % ---------------------------------------
    
    % ROISAVES : saved inside individual MORPHO() functions
    
    MORPHdata{ROInum} = {SPINE, SPINEHN, DENDRITE};
    
    
    % ---------------------------------------
    % QUESTION DIALOGUE TO KEEP DRAWING OR END
    % ---------------------------------------
            
    doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
    switch doagainROI
       case 'Yes'
            set(ROIIDh,'String',num2str((str2num(ROIIDh.String)+1)) );
            getROI
       case 'No'
           set(ROIIDh,'String',num2str((str2num(ROIIDh.String)+1)) );
           % keyboard
    end

    set(gcf,'Pointer','arrow')

end






%----------------------------------------------------
%        QUANTIFY Spine Total Area
%----------------------------------------------------
function MORPHOa(ROInum)


    % ------  
    disp('Draw outline around entire spine')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'Draw outline around entire spine';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
    
    hROI = imfreehand(haxCCD);

    ROImask = hROI.createMask(phCCD);
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));

    ROI_INTENSITY = IMG .* ROImask;

    ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));

    SPINE.area = ROIarea;
    SPINE.intensity = ROI_INTENSITY_MEAN;


    fprintf('\n TOTAL SPINE INTENSITY: % 5.5g \n TOTAL SPINE AREA: % 5.5g \n\n',...
                ROI_INTENSITY_MEAN,ROIarea)

    ROISAVES(ROInum).SpineMask = ROImask;
    ROISAVES(ROInum).SpinePos = ROIpos;


end





%----------------------------------------------------
%        QUANTIFY Spine Total Length
%----------------------------------------------------
function MORPHOb(ROInum)

    % ------  
    disp('Draw line from dendritic shaft to spine tip (longest extent of spine)')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'Draw line from spine head tip to dendrite';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
	hline = imline(haxCCD);
	dpos = hline.getPosition(); 

	spineextent = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    spineextentcenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(spineextentcenter(1),spineextentcenter(2), cdotsz,...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [1 0 0], 'LineWidth', 3)

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(spineextent));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy, dotsz,'MarkerFaceColor', [1 0 0])
    
    SPINEHN.spineextent = spineextent;
    SPINEHN.spineextentintensity = mean(c);
    SPINEHN.spineextentintensityprofile = c;
    SPINEHN.spineextentcenter = spineextentcenter;
    
    ROISAVES(ROInum).SpineExtentPos = dpos;
    ROISAVES(ROInum).SpineExtentCenter = spineextentcenter;
    ROISAVES(ROInum).SpineExtentX = cx;
    ROISAVES(ROInum).SpineExtentY = cy;

    
    % ------ Plot F Profile ----
    plot(haxPRE, c)
    axes(haxCCD)
    % --------------------------

end





%----------------------------------------------------
%        QUANTIFY Spine Head Diameter
%----------------------------------------------------
function MORPHOc(ROInum)
    
    % ------  
    disp('Draw line across spine-head parallel to dendritic shaft')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'Draw line across spine-head width';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
	hline = imline(haxCCD);
	dpos = hline.getPosition(); 

	spineheadwidth = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    spineheadcenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(spineheadcenter(1),spineheadcenter(2), cdotsz,...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [1 0 1], 'LineWidth', 3)

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(spineheadwidth));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy, dotsz,'MarkerFaceColor', [1 0 1])
    
    SPINEHN.headwidth = spineheadwidth;
    SPINEHN.headintensity = mean(c);
    SPINEHN.headintensityprofile = c;
    SPINEHN.headcenter = spineheadcenter;
    
    ROISAVES(ROInum).SpineHeadPos = dpos;
    ROISAVES(ROInum).SpineHeadCenter = spineheadcenter;
    ROISAVES(ROInum).SpineHeadX = cx;
    ROISAVES(ROInum).SpineHeadY = cy;
    
    % ------ Plot F Profile ----
    plot(haxPRE, c)
    axes(haxCCD)
    % --------------------------

end




%----------------------------------------------------
%        QUANTIFY Spine Neck Length
%----------------------------------------------------
function MORPHOd(ROInum)
    
    % ------
    disp('Draw line along length of spine neck')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'Draw line along length of spine neck';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
	hline = imline(haxCCD);
	dpos = hline.getPosition(); 

	spinenecklength = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    spineneckcenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(spineneckcenter(1),spineneckcenter(2), cdotsz,...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 3)

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(spinenecklength));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy, dotsz,'MarkerFaceColor', [0 1 0])
    
    SPINEHN.necklength = spinenecklength;
    SPINEHN.neckintensity = mean(c);
    SPINEHN.neckintensityprofile = c;
    SPINEHN.neckcenter = spineneckcenter;
    
    ROISAVES(ROInum).SpineNeckPos = dpos;
    ROISAVES(ROInum).SpineNeckCenter = spineneckcenter;
    ROISAVES(ROInum).SpineNeckX = cx;
    ROISAVES(ROInum).SpineNeckY = cy;
    
    % ------ Plot F Profile ----
    plot(haxPRE, c)
    axes(haxCCD)
    % --------------------------

end




%----------------------------------------------------
%        QUANTIFY Dendritic Shaft Diameter
%----------------------------------------------------
function MORPHOe(ROInum)

    disp('Draw line across dendrite region adjacent to spine')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'Draw line across dendrite diameter connecting to spine';
    memoboxH.String = memos;
    pause(.02)
    % ------

	hline = imline(haxCCD);
	dpos = hline.getPosition(); 
      % row 1 of dpos is the x,y pos of the line origin
      % test this using scatter(dpos(1,1),dpos(1,2),'r')
    
	dendritesize = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    dendritecenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(dendritecenter(1),dendritecenter(2), cdotsz,...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0 0 1], 'LineWidth', 3)

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(dendritesize));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy, dotsz,'MarkerFaceColor', [0 0 1])
    
    DENDRITE.size = dendritesize;
    DENDRITE.intensity = mean(c);
    DENDRITE.intensityprofile = c;
    DENDRITE.center = dendritecenter;
    
    ROISAVES(ROInum).DendritePos = dpos;
    ROISAVES(ROInum).DendriteCenter = dendritecenter;
    ROISAVES(ROInum).DendriteX = cx;
    ROISAVES(ROInum).DendriteY = cy;
    
    
    % ------ Plot F Profile ----
    plot(haxPRE, c)
    axes(haxCCD)
    % --------------------------
    
end




%----------------------------------------------------
%        QUANTIFY Nearest Neighbor Spine
%----------------------------------------------------
function MORPHOf(ROInum)
    
    % ------
    disp('Connect line from this spine to nearest spine ')
    memos(1:end-1) = memos(2:end);
    memos{end} = ' Connect line from ROI spine to nearest spine';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
	hline = imline(haxCCD);
	dpos = hline.getPosition(); 

	nearestspine = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    nearestspinecenter = [mean(dpos(:,1)) mean(dpos(:,2))];
        scatter(nearestspinecenter(1),nearestspinecenter(2), cdotsz,...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', [0 1 0], 'LineWidth', 3)

    
    [cx,cy,c] = improfile(IMG, dpos(:,1), dpos(:,2), round(nearestspine));
    
        % sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2)
        scatter(cx,cy, dotsz,'MarkerFaceColor', [0 1 0])
    
    DENDRITE.nearestspine = nearestspine;
    DENDRITE.nearestspineint = mean(c);
    DENDRITE.nearestspineprofile = c;
    DENDRITE.nearestspinecenter = nearestspinecenter;
    
    ROISAVES(ROInum).SpineNearPos = dpos;
    ROISAVES(ROInum).SpineNearCenter = nearestspinecenter;
    ROISAVES(ROInum).SpineNearX = cx;
    ROISAVES(ROInum).SpineNearY = cy;
     
    
    % ------ Plot F Profile ----
    plot(haxPRE, c)
    axes(haxCCD)
    % --------------------------

end






%----------------------------------------------------
%        KEYBOARD CALLBACKS (ZOOM + PAN)
%----------------------------------------------------
function keypresszoom(hObject, eventData, key)
    
    

    
        % --- ZOOM ---
        
        if strcmp(mainguih.CurrentCharacter,'=')
            
            % IN THE FUTURE USE MOUSE LOCATION TO ZOOM
            % INTO A SPECIFIC POINT. TO QUERY MOUSE LOCATION
            % USE THE METHOD: mainguih.CurrentPoint
            
            zoom(1.5)
            drawnow
        end
        
        if strcmp(mainguih.CurrentCharacter,'-')
            zoom(.5)
            drawnow
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
            drawnow
        end
        
        if strcmp(mainguih.CurrentCharacter,'s')
            haxCCD.XLim = haxCCD.XLim-20;
            drawnow
        end
        
        if strcmp(mainguih.CurrentCharacter,'e')
            haxCCD.YLim = haxCCD.YLim+20;
            drawnow
        end
        
        if strcmp(mainguih.CurrentCharacter,'d')
            haxCCD.YLim = haxCCD.YLim-20;
            drawnow
        end
        
        
        % --- RESET ZOOM & PAN ---
        
        if strcmp(mainguih.CurrentCharacter,'0')
            zoom out
            zoom reset
            haxCCD.XLim = imXlim;
            haxCCD.YLim = imYlim;
        end
        
        
end





%----------------------------------------------------
%        BOX SELECTION
%----------------------------------------------------
function boxselection(source,callbackdata)
    
    % callbackdata.OldValue.String
    boxtype = callbackdata.NewValue.String;

end





%----------------------------------------------------
%        LOAD FILE
%----------------------------------------------------
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
    set(mainguih, 'Name', datafile);
    set(ROIIDh, 'String', int2str(1));
    set(haxCCD, 'XLim', [1 xdim]);
    set(haxCCD, 'YLim', [1 ydim]);
    %----------------------------------------------------
    % axes(haxCCD)
    
    
end





%----------------------------------------------------
%        SAVE DATA AND ROI COORDINATES
%----------------------------------------------------
function saveFile(savefileh, eventData)
    
    
    % prepForSave(savefileh, eventData)
    

    cd(datadir);

    saveDatafilename = inputdlg('Enter a filename to save data','file name',1,...
                                {datafile(1:end-4)});

    Datafilename = char(strcat(saveDatafilename));
    
%{    
% SPINE    % MORPHdata{1,1}
% area: 349.0402
% intensity: 0.5744                     


% SPINEHN  % MORPHdata{1,2}
% spineextent: 26.4981
% spineextentintensity: 0.6986
% spineextentintensityprofile: [26x1 double]
% spineextentcenter: [108.4859 119.9637]
% headwidth: 17.7264
% headintensity: 0.5338
% headintensityprofile: [18x1 double]
% headcenter: [108.0432 123.1734]
% necklength: 6.0418
% neckintensity: 0.7196
% neckintensityprofile: [6x1 double]
% neckcenter: [109.9247 109.5600]


% DENDRITE  % MORPHdata{1,3}
% size: 21.7887
% intensity: 0.8098
% intensityprofile: [22x1 double]
% center: [112.9130 97.0534]
% nearestspine: 36.8842
% nearestspineint: 0.9783
% nearestspineprofile: [37x1 double]
% nearestspinecenter: [129.0720 105.9076]    
%}
    
    
MORPHdata = MORPHdata(~cellfun(@isempty, MORPHdata));

    %for nn = 1:size(MORPHdats,2)
    for nn = 1:size(MORPHdata,2)
        MORPHdat(nn,:) = [MORPHdata{1,nn}{1}.area ...
                         MORPHdata{1,nn}{1}.intensity ...
                         MORPHdata{1,nn}{2}.spineextent ...
                         MORPHdata{1,nn}{2}.spineextentintensity ...
                         MORPHdata{1,nn}{2}.headwidth ...
                         MORPHdata{1,nn}{2}.headintensity ...
                         MORPHdata{1,nn}{2}.necklength ...
                         MORPHdata{1,nn}{2}.neckintensity ...
                         MORPHdata{1,nn}{3}.size ...
                         MORPHdata{1,nn}{3}.intensity ...
                         MORPHdata{1,nn}{3}.nearestspine ...
                         MORPHdata{1,nn}{3}.nearestspineint ...
                         ];        

        ROInames{nn} = num2str(nn);        
    end
    
    
    
    
    MORPHtab = array2table(MORPHdat);
    MORPHtab.Properties.VariableNames = {...
        'SPINE_AREA' 'SPINE_F' 'SPINE_LEN' 'SPINE_LEN_F' ...
        'HEAD_WIDTH' 'HEAD_F' 'NECK_LENGTH' 'NECK_F'...
        'DEND_DIAMETER' 'DEND_DIAMETER_F' 'NEARBY_SPINE_DIST' 'LENGTH_SHAFT_F'...
        };
    
    
    MORPHtab.Properties.RowNames = ROInames;
    
    
    
    MORPHtab.FILE = repmat(datafile,size(MORPHdata,2),1);
    % MORPHtab.DATE = repmat(datadate,size(MORPHdata,2),1);
    
    
    writetable(MORPHtab,[Datafilename '.csv'],'WriteRowNames',true)
    save([Datafilename '.mat'],'MORPHdata','ROISAVES')
    
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





%----------------------------------------------------
%        LOAD ROI DATA
%----------------------------------------------------
function loadROI(hObject, eventdata)

    % ------  
    disp('Select .mat file with ROI data')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'Select .mat file with ROI data';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
    
    [ROIFileName,ROIPathName,ROIFilterIndex] = uigetfile('*.mat');

    ROIloaded = load([ROIPathName ROIFileName],'MORPHdata','ROISAVES');
    

    MORPHdata = ROIloaded.MORPHdata;
    ROISAVES = ROIloaded.ROISAVES;
    
    
    % ------  
    disp('ROI data loaded into workspace!')
    memos(1:end-1) = memos(2:end);
    memos{end} = 'ROI data loaded into workspace!';
    memoboxH.String = memos;
    pause(.02)
    % ------
    
    
    
    lwd = 4;
    axes(haxCCD)
    for nn = 1:length(ROISAVES)
        
    line(ROISAVES(nn).SpinePos(:,1), ROISAVES(nn).SpinePos(:,2),'Color',[.95 .95 .10],'LineWidth',lwd)
    line(ROISAVES(nn).SpineExtentPos(:,1), ROISAVES(nn).SpineExtentPos(:,2),'Color',[.10 .95 .95],'LineWidth',lwd)
    line(ROISAVES(nn).SpineHeadPos(:,1), ROISAVES(nn).SpineHeadPos(:,2),'Color',[.95 .10 .95],'LineWidth',lwd)
    line(ROISAVES(nn).SpineNeckPos(:,1), ROISAVES(nn).SpineNeckPos(:,2),'Color',[.95 .10 .10],'LineWidth',lwd)
    line(ROISAVES(nn).DendritePos(:,1), ROISAVES(nn).DendritePos(:,2),'Color',[.10 .95 .10],'LineWidth',lwd)
    line(ROISAVES(nn).SpineNearPos(:,1), ROISAVES(nn).SpineNearPos(:,2),'Color',[.10 .10 .95],'LineWidth',lwd)
                
    end
    
%     ROISAVES.SpinePos
%     ROISAVES.SpineExtentPos
%     ROISAVES.SpineHeadPos
%     ROISAVES.SpineNeckPos
%     ROISAVES.DendritePos
%     ROISAVES.SpineNearPos



end





end
%% EOF