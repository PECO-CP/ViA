classdef channel < handle
%CHANNEL Secondary MATLAB tool; child of image_analysis parent class
%      CHANNEL creates a new CHANNEL class object instance within the parent 
%      class or creates a nonfunctional GUI representation.
%
%      H = CHANNEL returns the handle to a new CHANNEL tool, displaying GUI
%      interfaces and holding data values relevant to controlling image
%      channels.
% 
%      This class was constructed to operate solely with the properties and 
%      objects of parent class image_analysis and sub classes select_channel
%      and analyze in package Interfaces. This may change in future releases.
% 
%      This class can be run on its own; in that case, it is a
%      nonfunctional representation of the graphic objects inherent in this
%      class. This is primarily used for troubleshooting and preview
%      purposes.

% Last Modified by JONATHAN HOOD v3.0 Sep-2022
 
% ViA Interfaces package holding all created interfaces of the ViA class,
% including the primary interface image_analysis.m.
%     Copyright (C) 2022 California Polytechnic State University San Luis
%     Obispo:
%     -Jonathan Hood
%     -Alexis Pasulka
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%     
%     With questions regarding this program, please contact Dr. Alexis
%     Pasulka electronically at apasulka@calpoly.edu or send a letter to:
%           Cal Poly San Luis Obispo
%           1 Grande Ave.
%           Biological Sciences Department
%           San Luis Obispo, CA 93407

   properties(Access = public)
       % Parent class objects
       parent_panel = [];              % parent panel handle
       parent = [];                    % parent tab group handle
       jparent = [];                   % handle to tab java objects
       
       % Raw Image tab properties
       raw_image_sub_tab = [];             % raw image tab handle
       raw_image_panel = [];               % raw image panel handle
       raw_image_prop_image = [];          % handle to image property image axes
       raw_image_type_txt = [];            % handle to image type text
       raw_image_filepath_txt = [];        % handle to image location text
       raw_image_bit_depth = [];           % handle to image bit depth text
       raw_image_dimensions = [];          % handle to image dimensions text
       raw_image_file_size = [];           % handle to image file size text
       raw_image_name = [];                % handle to image name textbox
       raw_image_prop_image_dir = [];      % handle to image logo directory
       
       % Background Subtraction tab properties
       bckgrnd_sub_tab = [];            % background subtraction tab handle
       bckgrnd_panel_labeled = [];      % background subtraction labeled panel handle
       bckgrnd_panel_labeled_edit = []; % background subtraction labeled panel edit box
       bckgrnd_panel_labeled_slid = []; % background subtraction labeled panel slider
       bckgrnd_panel_dna = [];          % background subtraction DNA panel handle
       bckgrnd_panel_dna_edit = [];     % background subtraction DNA panel edit box
       bckgrnd_panel_dna_slid = [];     % background subtraction DNA panel slider
       bck_def_val = 10;                % background subtraction default value
       
       % Threshold virus tab properties
       thresh_vir_tab = [];             % threshold viruses tab handle
       thresh_panel_labeled = [];       % threshold viruses labeled panel handle
       thresh_panel_labeled_edit = [];  % threshold viruses labeled panel edit box
       thresh_panel_labeled_slid = [];  % threshold viruses labeled panel slider
       thresh_panel_dna = [];           % threshold viruses DNA panel handle
       thresh_panel_dna_edit = [];      % threshold viruses DNA panel edit box
       thresh_panel_dna_slid = [];      % threshold viruses DNA panel slider
       thresh_def_val = 0;              % threshold default value 
       
       % Image alignment tab properties
       align_im_tab = [];              % align images tab handle
       align_panel = [];               % align images panel handle
       align_def_val = 0.0625;         % alignment default value
       align_panel_edit = [];          % alignment tab edit handle
       align_panel_x = [];             % alignment shift in the x 
       align_panel_y = [];             % alignment shift in the y 
       
       % Pixel artifact removal tab properties
       rmv_size_tab = [];              % remove pixel artifacts tab handle
       rmv_panel_um = [];              % remove pixel artifacts um stats panel handle
       rmv_panel_stats = [];           % remove artifacts pixel stats panel handle
       rmv_panel_min_max = [];         % remove artifacts min/max panel handle
       max_pixel_edit_dna = [];        % remove artifacts Max Pixel DNA edit box handle
       max_pixel_edit_labeled = [];    % remove artifacts Max Pixel labeled edit box handle
       min_pixel_edit_dna = [];        % remove artifacts Min Pixel DNA edit box handle
       min_pixel_edit_labeled = [];    % remove artifacts Min Pixel labeled edit box handle
       cell_dna = [];                  % remove artifacts DNA ROI cell count textbox handle
       cell_labeled = [];              % remove artifacts labeled ROI cell count textbox handle
       median_pixel_dna = [];          % remove artifacts Median Pixel DNA textbox handle
       median_pixel_labeled = [];      % remove artifacts Median Pixel labeled textbox handle
       mean_pixel_dna = [];            % remove artifacts Mean Pixel DNA textbox handle
       mean_pixel_labeled = [];        % remove artifacts Mean Pixel labeled textbox handle
       max_pixel_dna = [];             % remove artifacts Max Pixel DNA textbox handle
       max_pixel_labeled = [];         % remove artifacts Max Pixel labeled textbox handle
       min_pixel_dna = [];             % remove artifacts Min Pixel DNA textbox handle
       min_pixel_labeled = [];         % remove artifacts Min Pixel labeled textbox handle
       
       conv_factor = [];               % remove artifacts um/pixel conv factor editbox handle
       
       median_um_dna = [];             % remove artifacts Median um DNA textbox handle
       median_um_labeled = [];         % remove artifacts Median um labeled textbox handle
       mean_um_dna = [];               % remove artifacts Mean um DNA textbox handle
       mean_um_labeled = [];           % remove artifacts Mean um labeled textbox handle
       max_um_dna = [];                % remove artifacts Max um DNA textbox handle
       max_um_labeled = [];            % remove artifacts Max um labeled textbox handle
       min_um_dna = [];                % remove artifacts Min um DNA textbox handle
       min_um_labeled = [];            % remove artifacts Min um labeled textbox handle
       
       % Data display tab properties
       data_disp_tab = [];             % data display tab handle
       data_disp_panel = [];           % data display panel handle
       lab_dna_hist = [];              % labeled/dna ratio raw histogram axes
       lab_dna_bs_hist = [];           % labeled/dna background subtracted ratio histogram axes
       sz_distr_hist = [];             % size distribution histogram axes
       lab_dna_histogram = [];         % labeled/dna ratio raw histogram axes
       lab_dna_bs_histogram = [];      % labeled/dna background subtracted ratio histogram axes
       sz_distr_histogram = [];        % size distribution histogram axes
       save_hist_btn = [];             % save histograms button  
       
       lab_dna_ratio_max_edit = [];    % labeled:DNA ratio axes max X-Lim
       lab_dna_ratio_min_edit = [];    % labeled:DNA ratio axes min X-Lim
       lab_dna_ratio_median = [];      % labeled:DNA ratio median display
       lab_dna_ratio_mean = [];        % labeled:DNA ratio mean display
       lab_dna_ratio_bin_edit = [];    % labeled:DNA ratio histgoram edit box
       
       lab_dna_bs_ratio_max_edit = []; % labeled:DNA BS ratio axes max X-Lim
       lab_dna_bs_ratio_min_edit = []; % labeled:DNA BS ratio axes min X-Lim
       lab_dna_bs_ratio_median = [];   % labeled:DNA BS ratio median display
       lab_dna_bs_ratio_mean = [];     % labeled:DNA BS ratio mean display
       lab_dna_bs_ratio_bin_edit = []; % labeled:DNA BS ratio histgoram edit box
       
       size_max_edit = [];             % Size axes max X-Lim
       size_min_edit = [];             % Size axes min X-Lim
       size_median = [];               % Size median display
       size_mean = [];                 % Size mean display
       size_bin_edit = [];             % Size histgoram edit box
       unit_disp = [];                 % Size histogram units selection
       
       bin_def_val = 20;               % Bin default value
       
       % Other graphic objects
       next_btn = [];                  % handle to 'Next' button object
       prev_btn = [];                  % handle to 'Previous' button object
       analysis_tool = [];             % handle to partner analyze class object
       dual_zoom_tog = [];             % handle to dual zoom toggle checkbox
       
       tab_enabled = [1 0 0 0 0 1];    % logical array indicating if a tab has been fully enabled or not
       UserData = 'Default';           % handle to user-specified data; changes callback to callback
       Tag = 'ChannelTool';            % class tag
   end
   
   events
      Status_Update     % Status_Update event, indicating an event has occurred significant enough to display to the user
      SelectionMade     % SelectionMade event, indicating an image(s) has been selected (not used in this class directly; acts as a carrier)
      ChannelsSelected  % ChannelsSelected event, indicating the user has finished selecting the color channels for a CZI or grayscale image.
      AreaFilter        % AreaFilter event, indicating the user has changed the min/max ROI area
      ThresholdChanged  % ThresholdChanged event, indicating the user has changed DNA/labeled thresholding values
      RawImage
      BackgroundSubtraction
      ThresholdViruses
      AlignImages
      RemovePixelArtifacts
      SaveHistograms
   end
   
   methods
       function obj = channel(parent)
        %CHANNEL Creates a new 'Channel' object.
        % This function can be called with one or no arguments. If it is
        % called with no arguments, the function creates a nonfunctional
        % GUI representation. Otherwise, the function expects a parent
        % object of class image_analysis.
        
           % Check number of input arguments
           if nargin == 0
            obj.parent_panel = Figure.blank_figure().fig_handle;
            obj.parent = uitabgroup(obj.parent_panel,'Units','normalized',...
                'Position',[0 0 1 0.9],'TabLocation','left');
            uitab(obj.parent,'Title','Raw Image Properties');
            uitab(obj.parent,'Title','Background Subtraction');
            uitab(obj.parent,'Title','Threshold Viruses');
            uitab(obj.parent,'Title','Align Images');
            uitab(obj.parent,'Title','Remove Pixel Artifacts');
            uitab(obj.parent,'Title','Data Display');
           else
              obj.parent_panel = parent.Parent;
              obj.parent = parent; 
           end
           
           % Run GUI build function
           obj.buildFnc(obj.parent);
       end
       
       function obj = buildFnc(obj,parent)
       %CHANNEL Builds the graphical components of the 'Channel' panel.
       % This function builds the graphical components of the 'Channel'
       % panel into the input argument 'parent'. The purpose of these
       % graphical components is to control image color channel contrast
       % levels for the class image_analysis.
           
           X = 0.02;    
           Y = 0.02;
           btnHeight = 0.05;
           btnWidth = 0.3;
           btn_fontsize = 0.4;
           
           % Set selection callback
           parent.SelectionChangedFcn = @(src,~)obj.iterate_step(src);
           
           % Grab tabs
           obj.raw_image_sub_tab = parent.Children(1);
           obj.bckgrnd_sub_tab = parent.Children(2);
           obj.thresh_vir_tab = parent.Children(3);
           obj.align_im_tab = parent.Children(4);
           obj.rmv_size_tab = parent.Children(5);
           obj.data_disp_tab = parent.Children(6);
           
           % Add listeners
           addlistener(obj,'RawImage',@(~,~)obj.rawImage())
           addlistener(obj,'BackgroundSubtraction',@(src,~)obj.bckgrndSubtraction(src))
           addlistener(obj,'ThresholdViruses',@(src,~)obj.manualThreshold(src))
           addlistener(obj,'AlignImages',@(src,~)obj.alignment())
           addlistener(obj,'RemovePixelArtifacts',@(src,~)obj.min_max_changed(src))
           
           obj.jparent = Interfaces.Functions.findjobj(parent);
           temp = findobj(obj.jparent,'-isa','javahandle_withcallbacks.com.mathworks.mwswing.MJTabbedPane');
           
           confirm = 0;
           if isa('temp','matlab.graphics.GraphicsPlaceholder')
               % Finally caught it; run through the steps below. If the
               % program pauses after this first step, then we've found the
               % way to patch the issue. Otherwise, none of them worked and
               % we need to try something else. If the program never
               % paused, then the issue didn't occur on this run through.
               keyboard % Hit run on the taskbar above or type 'dbcont' in the command window to continue program
               
               % Debug attempt 1: use 'drawnow' to try to force MATLAB to
               % render graphics
               drawnow
               temp = findobj(obj.jparent,'-isa','javahandle_withcallbacks.com.mathworks.mwswing.MJTabbedPane');
               if ~isa('temp','matlab.graphics.GraphicsPlaceholder')
                  % Success!
                  confirm = 1;
                  keyboard % Hit run on the taskbar above or type 'dbcont' in the command window to continue program
               
               else
                   % Debug attempt 2: just try again
                   temp = findobj(obj.jparent,'-isa','javahandle_withcallbacks.com.mathworks.mwswing.MJTabbedPane');
                   if ~isa('temp','matlab.graphics.GraphicsPlaceholder')
                      % Success!
                      confirm = 2;
                      keyboard % Hit run on the taskbar above or type 'dbcont' in the command window to continue program
               
                   else
                       % Failure!
                       % Debug attempt 2: try again at 2 second intervals for
                       % 60 seconds
                       for i = 1:30
                           drawnow
                           temp = findobj(obj.jparent,'-isa','javahandle_withcallbacks.com.mathworks.mwswing.MJTabbedPane');
                           if ~isa('temp','matlab.graphics.GraphicsPlaceholder')
                               confirm = 3;
                               keyboard % Hit run on the taskbar above or type 'dbcont' in the command window to continue program
               
                               break;
                           end
                           pause(2);
                       end
                   end
               end
           end
           fprintf(['\n================ ', ...
                    '\n= CONFIRM == %d =',...
                    '\n================\n'],confirm)

           obj.jparent = temp;
           % Disable tabs
           obj.jparent.setEnabledAt(1,0);
           obj.jparent.setEnabledAt(2,0);
           obj.jparent.setEnabledAt(3,0);
           obj.jparent.setEnabledAt(4,0);
           obj.jparent.setEnabledAt(5,1);
           
           % Task iteration buttons and uitabgroup height adjustment
           % Create 'Previous ROI' button
            obj.prev_btn = uicontrol(obj.parent_panel,'Style',...
                'pushbutton','String','<< Previous Step','FontUnits','normalized',...
                'FontSize',btn_fontsize,'Units','normalized',...
                'Position',[X Y btnWidth btnHeight],'Callback',...
                @(src,~)obj.iterate_step(src),'Enable','off','Tag','Previous Step');
            
            % Create 'Next ROI' button
            newX = 1-btnWidth-X;
            obj.next_btn = uicontrol(obj.parent_panel,'Style',...
                'pushbutton','String','Next Step >>','FontUnits','normalized',...
                'FontSize',btn_fontsize,'Units','normalized',...
                'Position',[newX Y btnWidth btnHeight],'Callback',...
                @(src,~)obj.iterate_step(src),'Tag','Next Step','Enable','on');
            
           % Adjust tab group Y position
           obj.parent.Position(2) = btnHeight + 2*Y;
           
           % Initialize four uipanels, one for each tab channel
           rmv_panel_min_max_height = 0.2;
           obj.raw_image_panel = uipanel(obj.raw_image_sub_tab,'Units','normalized','Position',...
               [0 0 1 1],'Title','Raw Image Properties');
           
           obj.bckgrnd_panel_labeled = uipanel(obj.bckgrnd_sub_tab,'Units','normalized','Position',...
               [0 0 1 0.5],'Title','Select LABELED Disc Size (pixels)');
           newY = obj.bckgrnd_panel_labeled.Position(2) + obj.bckgrnd_panel_labeled.Position(4);
           obj.bckgrnd_panel_dna = uipanel(obj.bckgrnd_sub_tab,'Units','normalized','Position',...
               [0 newY 1 1-newY],'Title','Select DNA Disc Size (pixels)');
           
           obj.thresh_panel_labeled = uipanel(obj.thresh_vir_tab,'Units','normalized','Position',...
               [0 0 1 0.5],'Title','Select LABELED Threshold Level');
           obj.thresh_panel_dna = uipanel(obj.thresh_vir_tab,'Units','normalized','Position',...
               [0 newY 1 1-newY],'Title','Select DNA Threshold Level');
           
           obj.align_panel = uipanel(obj.align_im_tab,'Units','normalized','Position',...
               [0 0 1 1]);
           
           obj.rmv_panel_um = uipanel(obj.rmv_size_tab,'Units','normalized','Position',...
               [0 0 1 (1-rmv_panel_min_max_height)/2],'Title','Micrometer (um) Statistics (Major Axis Length)');
           
           obj.rmv_panel_min_max = uipanel(obj.rmv_size_tab,'Units','normalized','Position',...
               [0 (1-rmv_panel_min_max_height)/2 1 rmv_panel_min_max_height]);
           
           obj.rmv_panel_stats = uipanel(obj.rmv_size_tab,'Units','normalized','Position',...
               [0 rmv_panel_min_max_height+(1-rmv_panel_min_max_height)/2 1 (1-rmv_panel_min_max_height)/2],...
               'Title','Pixel Statistics (Area)');
           
           obj.data_disp_panel = uipanel(obj.data_disp_tab,'Units','normalized','Position',...
               [0 0 1 1]);
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % BUILD RAW IMAGE DISPLAY PANEL %
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           im_label_width = 0.3;
           image_side = 0.2;
           im_text_width = 1-3*X-im_label_width;
           im_text_x = 2*X+im_label_width;
           im_label_height = 0.025;
           im_text_fontsize = 0.7;
           icon_fontsize = im_text_fontsize-0.2;
           im_offset = 0.035;
           
           % Extract current filepath
           obj.raw_image_prop_image_dir = mfilename('fullpath');
           indx = strfind(obj.raw_image_prop_image_dir,'+Interfaces') - 1;
           obj.raw_image_prop_image_dir = [obj.raw_image_prop_image_dir(1:indx) '+Figure/'];
           
           % Image icon
           obj.raw_image_prop_image = axes(obj.raw_image_panel,'Units','normalized',...
               'Position',[X 1+im_offset-image_side image_side image_side],'Visible','off');
           obj.raw_image_prop_image.Toolbar.Visible = 'off';
           imshow(imread([obj.raw_image_prop_image_dir 'PlaceHolderImage_72.png']),'Parent',obj.raw_image_prop_image);
           im_name_Y = obj.raw_image_prop_image.Position(2)+obj.raw_image_prop_image.Position(4)/2-im_label_height/2;
           im_temp_X = obj.raw_image_prop_image.Position(1)+obj.raw_image_prop_image.Position(3)+X;
           im_temp_width = 1-im_temp_X;
           im_temp_height = im_label_height+0.01;
           obj.raw_image_name = uicontrol(obj.raw_image_panel,'Style','edit',...
               'String','','Units','normalized','Position',...
               [im_temp_X im_name_Y im_temp_width im_temp_height],'FontUnits',...
               'normalized','FontSize',icon_fontsize,'HorizontalAlignment',...
               'center','Enable','inactive');
           
           % Image type label and textbox
           im_Y = obj.raw_image_prop_image.Position(2) - im_label_height + Y;
           uicontrol(obj.raw_image_panel,'Style','text','String','Image Type:',...
               'Units','normalized','Position',[X im_Y im_label_width im_label_height],...
               'FontUnits','normalized','FontSize',im_text_fontsize,...
               'HorizontalAlignment','left');
           obj.raw_image_type_txt = uicontrol(obj.raw_image_panel,'Style','text',...
               'String','','Units','normalized','Position',...
               [im_text_x im_Y im_text_width im_label_height],'FontUnits',...
               'normalized','FontSize',im_text_fontsize,'HorizontalAlignment',...
               'left');
              
           % Image filepath label and textbox
           im_Y = im_Y - im_label_height - Y;
           uicontrol(obj.raw_image_panel,'Style','text','String','Location:',...
               'Units','normalized','Position',[X im_Y im_label_width im_label_height],...
               'FontUnits','normalized','FontSize',im_text_fontsize,...
               'HorizontalAlignment','left');
           obj.raw_image_filepath_txt = uicontrol(obj.raw_image_panel,'Style','text',...
               'String','','Units','normalized','Position',...
               [im_text_x im_Y im_text_width im_label_height],'FontUnits',...
               'normalized','FontSize',im_text_fontsize,'HorizontalAlignment',...
               'left'); 
           
           % Image bit depth label and textbox
           im_Y = im_Y - im_label_height - Y;
           uicontrol(obj.raw_image_panel,'Style','text','String','Bit Depth:',...
               'Units','normalized','Position',[X im_Y im_label_width im_label_height],...
               'FontUnits','normalized','FontSize',im_text_fontsize,...
               'HorizontalAlignment','left');
           obj.raw_image_bit_depth = uicontrol(obj.raw_image_panel,'Style','text',...
               'String','','Units','normalized','Position',...
               [im_text_x im_Y im_text_width im_label_height],'FontUnits',...
               'normalized','FontSize',im_text_fontsize,'HorizontalAlignment',...
               'left'); 
           
           % Image dimension label and textbox
           im_Y = im_Y - im_label_height - Y;
           uicontrol(obj.raw_image_panel,'Style','text','String','Image Dimensions:',...
               'Units','normalized','Position',[X im_Y im_label_width im_label_height],...
               'FontUnits','normalized','FontSize',im_text_fontsize,...
               'HorizontalAlignment','left');
           obj.raw_image_dimensions = uicontrol(obj.raw_image_panel,'Style','text',...
               'String','','Units','normalized','Position',...
               [im_text_x im_Y im_text_width im_label_height],'FontUnits',...
               'normalized','FontSize',im_text_fontsize,'HorizontalAlignment',...
               'left'); 
           
           % Image file size label and textbox
           im_Y = im_Y - im_label_height - Y;
           uicontrol(obj.raw_image_panel,'Style','text','String','File Size:',...
               'Units','normalized','Position',[X im_Y im_label_width im_label_height],...
               'FontUnits','normalized','FontSize',im_text_fontsize,...
               'HorizontalAlignment','left');
           obj.raw_image_file_size = uicontrol(obj.raw_image_panel,'Style','text',...
               'String','','Units','normalized','Position',...
               [im_text_x im_Y im_text_width im_label_height],'FontUnits',...
               'normalized','FontSize',im_text_fontsize,'HorizontalAlignment',...
               'left'); 
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % BUILD BACKGROUND SUBTRACTION PANEL %
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           text_height = 0.1;
           slider_width = 0.1;
           slide_height = 1-2*Y;
           X1 = 2*X;
           Y1 = 0.5-text_height/2;
           text_width = (1-(4*X1+slider_width))/2;
           
           bckgrnd_text_font_size = 0.4;
           bckgrnd_default_val = obj.bck_def_val;
           
           %%%%%%%%%%%%% labeled %%%%%%%%%%%%%%%%
           uicontrol(obj.bckgrnd_panel_labeled,'Style','text','String','Disc radius:','Units','normalized',...
               'Position',[X1 Y1-Y text_width text_height],'FontUnits','normalized','FontSize',bckgrnd_text_font_size);
           newX1 = X1+text_width+X1;
           slid_X1 = newX1 + text_width + X1;
           obj.bckgrnd_panel_labeled_slid = uicontrol(obj.bckgrnd_panel_labeled,...
               'Style','slider','Max',100,'Min',0,'Units','normalized',...
               'Position',[slid_X1 Y slider_width slide_height],'Value',...
               bckgrnd_default_val,'Tag','Back labeled Slider','Enable','off',...
               'Callback',@(src,~)bckgrndSubtraction(obj,src));
           obj.bckgrnd_panel_labeled_edit = uicontrol(obj.bckgrnd_panel_labeled,...
               'Style','edit','String',num2str(bckgrnd_default_val),'Units','normalized',...
               'Position',[newX1 Y1 text_width text_height],'FontUnits',...
               'normalized','FontSize',bckgrnd_text_font_size,'Tag',...
               'Back labeled Edit','Enable','off',...
               'Callback',@(src,~)bckgrndSubtraction(obj,src));
           
           %%%%%%%%%%%%% DNA %%%%%%%%%%%%%%%
           uicontrol(obj.bckgrnd_panel_dna,'Style','text','String','Disc radius:','Units','normalized',...
               'Position',[X1 Y1-Y text_width text_height],'FontUnits','normalized','FontSize',bckgrnd_text_font_size);
           obj.bckgrnd_panel_dna_slid = uicontrol(obj.bckgrnd_panel_dna,...
               'Style','slider','Max',100,'Min',0,'Units','normalized',...
               'Position',[slid_X1 Y slider_width slide_height],'Value',...
               bckgrnd_default_val,'Tag','Back DNA Slider','Enable','off',...
               'Callback',@(src,~)bckgrndSubtraction(obj,src));
           obj.bckgrnd_panel_dna_edit = uicontrol(obj.bckgrnd_panel_dna,...
               'Style','edit','String',num2str(bckgrnd_default_val),'Units','normalized',...
               'Position',[newX1 Y1 text_width text_height],'FontUnits',...
               'normalized','FontSize',bckgrnd_text_font_size,'Tag',...
               'Back DNA Edit','Enable','off',...
               'Callback',@(src,~)bckgrndSubtraction(obj,src));
           
           %%%%%%%%%%%%%%%%%%%%%%%%%
           % BUILD THRESHOLD PANEL %
           %%%%%%%%%%%%%%%%%%%%%%%%%
           
           thresh_text_font_size = 0.4;
           thresh_default_val = obj.thresh_def_val;
           
           %%%%%%%%%%%%% labeled %%%%%%%%%%%%%%%%
           uicontrol(obj.thresh_panel_labeled,'Style','text','String','Threshold Level:','Units','normalized',...
               'Position',[X1 Y1-Y text_width text_height],'FontUnits','normalized','FontSize',thresh_text_font_size);
           newX1 = X1+text_width+X1;
           slid_X1 = newX1 + text_width + X1;
           obj.thresh_panel_labeled_slid = uicontrol(obj.thresh_panel_labeled,...
               'Style','slider','Max',1,'Min',0,'Units','normalized',...
               'Position',[slid_X1 Y slider_width slide_height],'Value',...
               thresh_default_val,'Tag','Thresh labeled Slider','Enable','off',...
               'Callback',@(src,~)obj.manualThreshold(src));
           obj.thresh_panel_labeled_edit = uicontrol(obj.thresh_panel_labeled,...
               'Style','edit','String',num2str(thresh_default_val),'Units','normalized',...
               'Position',[newX1 Y1 text_width text_height],'FontUnits',...
               'normalized','FontSize',thresh_text_font_size,'Tag',...
               'Thresh labeled Edit','Enable','off','Callback',@(src,~)obj.manualThreshold(src));
           
           %%%%%%%%%%%%% DNA %%%%%%%%%%%%%%%
           uicontrol(obj.thresh_panel_dna,'Style','text','String','Threshold Level:','Units','normalized',...
               'Position',[X1 Y1-Y text_width text_height],'FontUnits','normalized','FontSize',thresh_text_font_size);
           obj.thresh_panel_dna_slid = uicontrol(obj.thresh_panel_dna,...
               'Style','slider','Max',1,'Min',0,'Units','normalized',...
               'Position',[slid_X1 Y slider_width slide_height],'Value',...
               thresh_default_val,'Tag','Thresh DNA Slider','Enable','off',...
               'Callback',@(src,~)obj.manualThreshold(src));
           obj.thresh_panel_dna_edit = uicontrol(obj.thresh_panel_dna,...
               'Style','edit','String',num2str(thresh_default_val),'Units','normalized',...
               'Position',[newX1 Y1 text_width text_height],'FontUnits',...
               'normalized','FontSize',thresh_text_font_size,'Tag',...
               'Thresh DNA Edit','Enable','off','Callback',@(src,~)obj.manualThreshold(src));
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % BUILD IMAGE ALIGNMENT PANEL %
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           % Create alignment panel with user input for pixel movement range. 
           
           text_height = 0.065;
           X1 = X/2;
           
           Y1 = 0.85-text_height/2;
           info_text_width = (1-(3*X1))/2;
           align_text_font_size = 0.3;
           align_default_val = obj.align_def_val;
           info_text_font_size = 0.03;
           
           spacing = 0.05;
           info_width = (1-spacing-4*X)/4;
           
           uicontrol(obj.align_panel,'Style','text','String','X-axis Shift:',...
               'Units','normalized','Position',[X Y info_width text_height],...
               'FontUnits','normalized','FontSize',align_text_font_size);
           
           newX = X + info_width + X;
           
           obj.align_panel_x = uicontrol(obj.align_panel,...
               'Style','text','String','','Units','normalized',...
               'Position',[newX Y info_width text_height],'FontUnits',...
               'normalized','FontSize',align_text_font_size,'Tag',...
               'Align X Shift');
           
           newX = newX + info_width + spacing;
           
           uicontrol(obj.align_panel,'Style','text','String','Y-axis Shift:',...
               'Units','normalized','Position',[newX Y info_width text_height],...
               'FontUnits','normalized','FontSize',align_text_font_size);
           
           newX = newX + info_width + X;
           
           obj.align_panel_y = uicontrol(obj.align_panel,...
               'Style','text','String','','Units','normalized',...
               'Position',[newX Y info_width text_height],'FontUnits',...
               'normalized','FontSize',align_text_font_size,'Tag',...
               'Align Y Shift');
           
           newY = Y + text_height;
           
           info_height = Y1-Y-newY-text_height-Y;
           
           uicontrol(obj.align_panel,'Style','text','String','Most Recent Alignment Values',...
               'Units','normalized','Position',[X newY info_width*4+spacing+2*X text_height],...
               'FontUnits','normalized','FontSize',align_text_font_size,...
               'FontWeight','bold');
           
           uicontrol(obj.align_panel,'Style','text','String','Maximum Step Length:','Units','normalized',...
               'Position',[X1 Y1-Y info_text_width text_height],'FontUnits','normalized','FontSize',align_text_font_size);
           newX = X1 + info_text_width + X1;
           obj.align_panel_edit = uicontrol(obj.align_panel,...
               'Style','edit','String',num2str(align_default_val),'Units','normalized',...
               'Position',[newX Y1 info_text_width text_height],'FontUnits',...
               'normalized','FontSize',align_text_font_size,'Tag',...
               'Align Edit','Enable','off','Callback',@(~,~)obj.alignment());
           uicontrol(obj.align_panel,'Style','text','String',['Initial step length, '...
               'specified as a positive scalar. The initial step length is the '...
               'maximum step length because the optimizer reduces the step size '...
               'during convergence. If you set MaximumStepLength to a large value, '...
               'the computation time decreases. However, the optimizer might fail to '...
               'converge if you set MaximumStepLength to an overly large value. The default is 0.0625.'],...
               'Units','normalized','Position',[X1 newY+Y+text_height 1-2*X1 info_height],...
               'FontUnits','normalized','FontSize',info_text_font_size);
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % BUILD PIXEL ARTIFACT PANEL %
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           width = (1-4*X)/3;
           X1 = X + width + X;
           X2 = X1 + width + X;
            
           text_corr = -0.04;
           height = (1-5*Y)/4;
           fontsize = 0.5;
           
           %%%%%%%%%%%%%%%% MIN/MAX EDIT PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           % Conv factor edit and text
           uicontrol(obj.rmv_panel_min_max,'Style','text','String','Conversion Factor (um/pixel)','Units',...
               'normalized','Position',[X Y+text_corr width height],'FontUnits','normalized','FontSize',...
               fontsize-0.15);
           
           obj.conv_factor = uicontrol(obj.rmv_panel_min_max,'Style','edit',...
               'Units','normalized','Position',[X1+width/2+X/2 Y width height],...
               'Enable','on','Callback',@(src,~)obj.conv_changed(src),'FontUnits','normalized',...
               'FontSize',fontsize,'Tag','ConvFactor');
           
           newY = Y + height + Y;
           
           % Max pixel edit and text
           uicontrol(obj.rmv_panel_min_max,'Style','text','String','Max pixel','Units',...
               'normalized','Position',[X newY+text_corr width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.max_pixel_edit_dna = uicontrol(obj.rmv_panel_min_max,'Style','edit',...
               'Units','normalized','Position',[X1 newY width height],...
               'Enable','off','Callback',@(src,~)obj.min_max_changed(),'FontUnits','normalized',...
               'FontSize',fontsize,'Tag','Max DNA','Callback',@(src,~)obj.min_max_changed(src),...
               'String','inf');
           
           obj.max_pixel_edit_labeled = uicontrol(obj.rmv_panel_min_max,'Style','edit',...
               'Units','normalized','Position',[X2 newY width height],...
               'Enable','off','Callback',@(src,~)obj.min_max_changed(src),'FontUnits','normalized',...
               'FontSize',fontsize,'Tag','Max labeled','Callback',@(src,~)obj.min_max_changed(src),...
               'String','inf');
           
           newY = newY + height + Y;
           
           % Min pixel edit and text
           uicontrol(obj.rmv_panel_min_max,'Style','text','String','Min pixel','Units',...
               'normalized','Position',[X newY+text_corr width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.min_pixel_edit_dna = uicontrol(obj.rmv_panel_min_max,'Style','edit',...
               'Units','normalized','Position',[X1 newY width height],...
               'Enable','off','Callback',@(src,~)obj.min_max_changed(),'FontUnits','normalized',...
               'FontSize',fontsize,'Tag','Min DNA','Callback',@(src,~)obj.min_max_changed(src),...
               'String','0');
           
           obj.min_pixel_edit_labeled = uicontrol(obj.rmv_panel_min_max,'Style','edit',...
               'Units','normalized','Position',[X2 newY width height],...
               'Enable','off','Callback',@(src,~)obj.min_max_changed(src),'FontUnits','normalized',...
               'FontSize',fontsize,'Tag','Min labeled','Callback',@(src,~)obj.min_max_changed(src),...
               'String','0');
           
           newY = newY + height + Y;
           
           % DNA and labeled titles
           uicontrol(obj.rmv_panel_min_max,'Style','text','String','DNA','Units',...
               'normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           uicontrol(obj.rmv_panel_min_max,'Style','text','String','LABELED','Units',...
               'normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           %%%%%%%%%%%%%%%%%%%%%% STAT PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           height = (1-7*Y)/6;
           fontsize = 0.4;
           
           % Cell texts
           uicontrol(obj.rmv_panel_stats,'Style','text','String','Total ROIs','Units',...
               'normalized','Position',[X Y width height],'FontUnits','normalized','FontSize',...
               fontsize,'FontUnits','normalized');
           
           obj.cell_dna = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X1 Y width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.cell_labeled = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X2 Y width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = Y + height + Y;
           
           % Median pixel texts
           uicontrol(obj.rmv_panel_stats,'Style','text','String','Median pixel','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.median_pixel_dna = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.median_pixel_labeled = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % Mean pixel texts
           uicontrol(obj.rmv_panel_stats,'Style','text','String','Mean pixel','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.mean_pixel_dna = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.mean_pixel_labeled = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % Max Pixel display
           uicontrol(obj.rmv_panel_stats,'Style','text','String','Max pixel','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.max_pixel_dna = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.max_pixel_labeled = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % Min Pixel display
           uicontrol(obj.rmv_panel_stats,'Style','text','String','Min pixel','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.min_pixel_dna = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.min_pixel_labeled = uicontrol(obj.rmv_panel_stats,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % DNA and labeled titles
           uicontrol(obj.rmv_panel_stats,'Style','text','String','DNA','Units',...
               'normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           uicontrol(obj.rmv_panel_stats,'Style','text','String','LABELED','Units',...
               'normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           %%%%%%%%%%%%%%%%%%%%%% STAT UM PANEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
           height = (1-7*Y)/5;
           
           % Median um texts
           uicontrol(obj.rmv_panel_um,'Style','text','String','Median um','Units',...
               'normalized','Position',[X Y width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.median_um_dna = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X1 Y width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.median_um_labeled = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X2 Y width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = Y + height + Y;
           
           % Mean um texts
           uicontrol(obj.rmv_panel_um,'Style','text','String','Mean um','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.mean_um_dna = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.mean_um_labeled = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % Max Pixel display
           uicontrol(obj.rmv_panel_um,'Style','text','String','Max um','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.max_um_dna = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.max_um_labeled = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % Min Pixel display
           uicontrol(obj.rmv_panel_um,'Style','text','String','Min um','Units',...
               'normalized','Position',[X newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           obj.min_um_dna = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           obj.min_um_labeled = uicontrol(obj.rmv_panel_um,'Style','text',...
               'Units','normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           newY = newY + height + Y;
           
           % DNA and labeled titles
           uicontrol(obj.rmv_panel_um,'Style','text','String','DNA','Units',...
               'normalized','Position',[X1 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           uicontrol(obj.rmv_panel_um,'Style','text','String','LABELED','Units',...
               'normalized','Position',[X2 newY width height],'FontUnits','normalized','FontSize',...
               fontsize);
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % BUILD DATA DISPLAY PANEL %
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           fontsize = 0.6;
           text_fontsize = 0.4;
           text_Y = Y/2;
           text_X = X;
           Y = 4*Y;
           Y2 = 0.75*Y;
           X = 4.5*X;
           tog_width = 0.5;
           tog_height = 0.03;
           
           btn_width = 0.4;
           btn_height = 0.03;
           btn_fontsize = 0.55;
           btn_X = 0.5-btn_width/2;
           
           axes_width = 0.5;
           axes_height = (1 - tog_height - 3*Y - Y2)/3;
           
           text_X1 = axes_width + X + 0.02;
           text_width = 0.2;
           text_height = 0.04;
           text_X2 = text_X1 + text_width + text_X;
           edit_width = 1-text_X2 - text_X;
           edit_offset = 0.01;
           
           title_fontsize = 0.07;
           
           %%%%% Save Button for histograms
           
           obj.save_hist_btn = uicontrol(obj.data_disp_panel,'Style','pushbutton','Units','normalized',...
               'Position',[btn_X text_Y btn_width btn_height],'Visible','on',...
               'FontUnits','normalized','FontSize',btn_fontsize,'String','Save Histograms',...
               'Enable','off','Callback',@(~,~)notify(obj,'SaveHistograms'));
           
           %%%%%%%%%%%%%%%%%% labeled:DNA Histogram %%%%%%%%%%%%%%%%%%%%%%%%
           obj.lab_dna_hist = axes(obj.data_disp_panel,'Units','normalized',...
               'Position',[X Y axes_width axes_height],'Visible','on');
           obj.lab_dna_histogram = histogram(obj.lab_dna_hist);
           title('LABELED:DNA Ratio','FontUnits','normalized','FontSize',...
               title_fontsize,'FontWeight','normal','Units','normalized')
           obj.lab_dna_hist.Title.Position(2) = obj.lab_dna_hist.Title.Position(2) + 0.02; 
           
           start_y = Y-0.02;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 start_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Max X:');
           
           obj.lab_dna_ratio_max_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 start_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','inf',...
               'Tag','Ratio Max','Callback',@(src,~)obj.axes_changed(src),...
               'Enable','off');
           
           text_y = start_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Min X:');
           
           obj.lab_dna_ratio_min_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 text_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','-inf',...
               'Tag','Ratio Min','Callback',@(src,~)obj.axes_changed(src),...
               'Enable','off');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Median:');
           
           obj.lab_dna_ratio_median = uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X2 text_y edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Mean:');
           
           obj.lab_dna_ratio_mean = uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X2 text_y edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Bins:');
           
           obj.lab_dna_ratio_bin_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 text_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String',num2str(obj.bin_def_val),...
               'Tag','Ratio Bin','Callback',@(~,~)obj.analysis_tool.update_histograms(obj),...
               'Enable','off');
           
           newY = axes_height + 2*Y;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           %%%%%%%%%%%%%%%%%%%% labeled:DNA BS Histogram %%%%%%%%%%%%%%%%%%%
           obj.lab_dna_bs_hist = axes(obj.data_disp_panel,'Units','normalized',...
               'Position',[X newY axes_width axes_height],'Visible','on',...
               'Title','LABELED to DNA Ratio Background Subtracted');
           obj.lab_dna_bs_histogram = histogram(obj.lab_dna_bs_hist);
           title('LABELED:DNA Ratio Background Subtracted','FontUnits',...
               'normalized','FontSize',title_fontsize,'FontWeight','normal',...
               'Units','normalized')
           obj.lab_dna_bs_hist.Title.Position(2) = obj.lab_dna_bs_hist.Title.Position(2) + 0.02; 
           
           start_y = newY-0.02;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 start_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Max X:');
           
           obj.lab_dna_bs_ratio_max_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 start_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','inf',...
               'Tag','Ratio BS Max','Callback',@(src,~)obj.axes_changed(src),...
               'Enable','off');
           
           text_y = start_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Min X:');
           
           obj.lab_dna_bs_ratio_min_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 text_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','-inf',...
               'Tag','Ratio BS Min','Callback',@(src,~)obj.axes_changed(src),...
               'Enable','off');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Median:');
           
           obj.lab_dna_bs_ratio_median = uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X2 text_y edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Mean:');
           
           obj.lab_dna_bs_ratio_mean = uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X2 text_y edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Bins:');
           
           obj.lab_dna_bs_ratio_bin_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 text_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String',num2str(obj.bin_def_val),...
               'Tag','Ratio BS Bin','Callback',@(~,~)obj.analysis_tool.update_histograms(obj),...
               'Enable','off');
           
           newY = newY + axes_height + Y;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           %%%%%%%%%%%%%%%% Size Distribution Histogram %%%%%%%%%%%%%%%%%%%
           obj.sz_distr_hist = axes(obj.data_disp_panel,'Units','normalized',...
               'Position',[X newY axes_width axes_height],'Visible','on',...
               'Title','Major Axis Length');
           obj.sz_distr_histogram = histogram(obj.sz_distr_hist);
           title('Major Axis Length (pixels)','FontUnits','normalized','FontSize',...
               title_fontsize,'FontWeight','normal','Units','normalized')
           obj.sz_distr_hist.Title.Position(2) = obj.sz_distr_hist.Title.Position(2) + 0.02; 
           
           start_y = newY-0.02;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 start_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Max X:');
           
           obj.size_max_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 start_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','inf',...
               'Tag','Size Max','Callback',@(src,~)obj.axes_changed(src),...
               'Enable','off');
           
           text_y = start_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Min X:');
           
           obj.size_min_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 text_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','-inf',...
               'Tag','Size Min','Callback',@(src,~)obj.axes_changed(src),...
               'Enable','off');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Median:');
           
           obj.size_median = uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X2 text_y edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Mean:');
           
           obj.size_mean = uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X2 text_y edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','');
           
           text_y = text_y + text_height + text_Y;
           
           uicontrol(obj.data_disp_panel,'Style','text','Units','normalized',...
               'Position',[text_X1 text_y text_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String','Bins:');
           
           obj.size_bin_edit = uicontrol(obj.data_disp_panel,'Style','edit','Units','normalized',...
               'Position',[text_X2 text_y+edit_offset edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String',num2str(obj.bin_def_val),...
               'Tag','Size Bin','Callback',@(~,~)obj.analysis_tool.update_histograms(obj),...
               'Enable','off');
           
           text_y = text_y + text_height + text_Y;
           
           obj.unit_disp = uicontrol(obj.data_disp_panel,'Style','popupmenu','Units','normalized',...
               'Position',[text_X1 text_y+edit_offset 2*edit_width text_height],'Visible','on',...
               'FontUnits','normalized','FontSize',text_fontsize,'String',{'Pixels','Micrometers'},...
               'Tag','Size Units','Callback',@(~,~)obj.analysis_tool.update_histograms(obj),...
               'Enable','off');
           
           newY = newY + axes_height + 0.75*Y2;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
           % Create dual zoom toggle
           obj.dual_zoom_tog = uicontrol(obj.data_disp_panel,'Style','checkbox','String','Toggle Dual Zoom','Units',...
               'normalized','Position',[X newY tog_width tog_height],'FontUnits','normalized','FontSize',...
               fontsize,'Callback',@(src,~)obj.dual_zoom(src),'Tag','DualZoom','Visible','on');
           
       end
   
       %%%%%%%%%% PROCEDURAL STEPS %%%%%%%%%%%%%%%%%%
       function obj = initialize_procedure(obj,evnt)
           % Grab passed analysis tool
           obj.analysis_tool = evnt.newValue;
                 
           % Add listeners
           addlistener(obj.analysis_tool,'RawImage',@(~,~)obj.analysis_tool.rawImage())
           addlistener(obj.analysis_tool,'BackgroundSubtraction',@(~,evntData)obj.analysis_tool.bckgrndSubtraction(evntData))
           addlistener(obj.analysis_tool,'ThresholdViruses',@(src,evntData)obj.analysis_tool.manualThreshold(evntData))
           addlistener(obj.analysis_tool,'AlignImages',@(~,evntData)obj.analysis_tool.alignment(evntData))
           addlistener(obj.analysis_tool,'RemovePixelArtifacts',@(~,evntData)obj.analysis_tool.min_max_changed(evntData))
           
           % Enable the data analysis tab if not enabled already
           obj.jparent.setEnabledAt(5,1);
           
           % Enable all histogram edit boxes
           obj.size_bin_edit.Enable = 'on';
           obj.size_min_edit.Enable = 'on';
           obj.size_max_edit.Enable = 'on';
           obj.lab_dna_bs_ratio_bin_edit.Enable = 'on';
           obj.lab_dna_ratio_bin_edit.Enable = 'on';
           obj.lab_dna_bs_ratio_max_edit.Enable = 'on';    
           obj.lab_dna_bs_ratio_min_edit.Enable = 'on';   
           obj.lab_dna_ratio_max_edit.Enable = 'on';    
           obj.lab_dna_ratio_min_edit.Enable = 'on';  
           obj.unit_disp.Enable = 'on';
           
           % Enable save histogram button
           obj.save_hist_btn.Enable = 'on';
           
           % If single image, disable dual zoom
           if ~isempty(obj.analysis_tool.isdna)
               obj.dual_zoom_tog.Enable = 'off';
           end
           
       end
       
       function obj = iterate_step(obj,src)
           % Disable iteration buttons to circumvent multiple user input;
           % lead to tabs not enabling properly
           
           obj.next_btn.Enable = 'off';
           obj.prev_btn.Enable = 'off';
           
           curr_tab = obj.parent.SelectedTab;
           temp_idx = find((curr_tab == obj.parent.Children)==1);
           
           if contains(src.Tag,'Previous')
                temp_idx = temp_idx - 1;
                if ~isempty(obj.analysis_tool) && obj.analysis_tool.parent.one_im && obj.parent.Children(temp_idx) == obj.align_im_tab
                    temp_idx = temp_idx - 1;
                end
                
                % If on data display, but haven't activated all steps, skip
                % tabs until reaching an already enabled step
                while ~obj.tab_enabled(temp_idx)
                    temp_idx = temp_idx - 1;
                end
                obj.parent.SelectedTab = obj.parent.Children(temp_idx);
                
           elseif contains(src.Tag,'Next')
                temp_idx = temp_idx + 1;
                
                % If on data display, but haven't activated all steps, skip
                % tabs until reaching an already enabled step
                if isempty(obj.analysis_tool)
                    while ~obj.tab_enabled(temp_idx)
                        temp_idx = temp_idx + 1;
                    end
                else
                    if obj.analysis_tool.parent.one_im && obj.parent.Children(temp_idx) == obj.align_im_tab
                        temp_idx = temp_idx + 1;
                    end
                end
                
                obj.parent.SelectedTab = obj.parent.Children(temp_idx);
                if ~obj.jparent.isEnabledAt(temp_idx-1)
                    obj.jparent.setEnabledAt(temp_idx-1,1);
                end
           end
           
           % Store current tab in case user tabs out during procedure
           new_curr_tab = obj.parent.SelectedTab;
           
           if ~isempty(obj.analysis_tool)
            obj.analysis_tool.selection_changed();
           end
           
           % Check if a child graphic object is disabled; if so, enable
           % them. 
           if ~obj.tab_enabled(temp_idx)
               notify(obj,new_curr_tab.Tag); % First time, trigger callback with default values
               
               % Enable all child objects, unless only one image was loaded
               isdna = obj.analysis_tool.isdna;
               
               % Look into increasing efficiency here; low importance, as
               % only occurs once per tab
               if isempty(isdna)
                   for i = 1:length(new_curr_tab.Children)
                       temp = new_curr_tab.Children(i);
                       for j = 1:length(temp.Children)
                            if strcmp(temp.Children(j).Enable,'off')
                                temp.Children(j).Enable = 'on';
                            end
                       end
                   end
               else
                   if isdna
                       for i = 1:length(new_curr_tab.Children)
                           temp = new_curr_tab.Children(i);
                           for j = 1:length(temp.Children)
                                if strcmp(temp.Children(j).Enable,'off') && contains(temp.Children(j).Tag,'DNA')
                                    temp.Children(j).Enable = 'on';
                                end
                           end
                       end
                   else
                       for i = 1:length(new_curr_tab.Children)
                           temp = new_curr_tab.Children(i);
                           for j = 1:length(temp.Children)
                                if strcmp(temp.Children(j).Enable,'off') && contains(temp.Children(j).Tag,'labeled')
                                    temp.Children(j).Enable = 'on';
                                end
                           end
                       end
                   end
               end
               % Note tab is now enabled; will not trigger again
               obj.tab_enabled(temp_idx) = 1;
           end
           
           if temp_idx == 1
                obj.prev_btn.Enable = 'off';
                obj.next_btn.Enable = 'on';
           elseif temp_idx == length(obj.parent.Children)
                obj.prev_btn.Enable = 'on';
                obj.next_btn.Enable = 'off';
           else
                obj.prev_btn.Enable = 'on';
                obj.next_btn.Enable = 'on';
           end
           
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%
       % SUPPORTING FUNCTIONS %
       %%%%%%%%%%%%%%%%%%%%%%%%
       
       function rawImage(obj)
           notify(obj.analysis_tool,'RawImage')
       end
       
       function bckgrndSubtraction(obj,src)
       %BCKGRNDSUBTRACTION
        if contains(src.Tag,'DNA')  
            if contains(src.Tag,'Edit')
                val = str2double(src.String);
                if isnan(val)
                   val =  obj.bckgrnd_panel_dna_slid.Value; 
                end
                
                if val > obj.bckgrnd_panel_dna_slid.Max && val < obj.bckgrnd_panel_dna_slid.Min
                   val =  obj.bckgrnd_panel_dna_slid.Value; 
                end
                
                if mod(val,1) ~= 0
                   val = floor(val);
                   obj.bckgrnd_panel_dna_edit.String = num2str(val);
                end
                
                obj.bckgrnd_panel_dna_slid.Value = val;
            else
                val = obj.bckgrnd_panel_dna_slid.Value;
                if mod(val,1) ~= 0
                   val = floor(val);
                   obj.bckgrnd_panel_dna_slid.Value = val;
                end
                obj.bckgrnd_panel_dna_edit.String = num2str(val);
            end
        else
            if contains(src.Tag,'Edit')
                val = str2double(src.String);
                
                % Check its a number
                if isnan(val)
                   val =  obj.bckgrnd_panel_labeled_slid.Value; 
                end
                
                % Check its within range
                if val > obj.bckgrnd_panel_labeled_slid.Max && val < obj.bckgrnd_panel_labeled_slid.Min
                   val =  obj.bckgrnd_panel_labeled_slid.Value; 
                end
                
                % Check its an integer
                if mod(val,1) ~= 0
                   val = floor(val);
                   obj.bckgrnd_panel_labeled_edit.String = num2str(val);
                end
                
                obj.bckgrnd_panel_labeled_slid.Value = val;
            else
                val = obj.bckgrnd_panel_labeled_slid.Value;
                if mod(val,1) ~= 0
                   val = floor(val);
                   obj.bckgrnd_panel_labeled_slid.Value = val;
                end
                obj.bckgrnd_panel_labeled_edit.String = num2str(val);
            end
        end
           notify(obj.analysis_tool,'BackgroundSubtraction',Events.ActionData(obj))
       end
       
       function manualThreshold(obj,src)
         if contains(src.Tag,'DNA')  
            if contains(src.Tag,'Edit')
                val = str2double(src.String);
                if isnan(val)
                   val =  obj.thresh_panel_dna_slid.Value; 
                end
                
                if val > obj.thresh_panel_dna_slid.Max && val < obj.thresh_panel_dna_slid.Min
                   val =  obj.thresh_panel_dna_slid.Value; 
                end
                
                obj.thresh_panel_dna_slid.Value = val;
            else
                val = obj.thresh_panel_dna_slid.Value;
                
                obj.thresh_panel_dna_edit.String = num2str(val);
            end
        else
            if contains(src.Tag,'Edit')
                val = str2double(src.String);
                
                % Check its a number
                if isnan(val)
                   val =  obj.thresh_panel_labeled_slid.Value; 
                end
                
                % Check its within range
                if val > obj.thresh_panel_labeled_slid.Max && val < obj.thresh_panel_labeled_slid.Min
                   val =  obj.thresh_panel_labeled_slid.Value; 
                end
                
                obj.thresh_panel_labeled_slid.Value = val;
            else
                val = obj.thresh_panel_labeled_slid.Value;
               
                obj.thresh_panel_labeled_edit.String = num2str(val);
            end
        end
           notify(obj.analysis_tool,'ThresholdViruses',Events.ActionData(obj)) 
       end
        
       function alignment(obj)
           % Align labeled to DNA
           if isnan(str2double(obj.align_panel_edit.String))
               status_text = 'Alignment input must be a nonnegative number';
               notify(obj,'Status_Update',Events.ActionData(status_text));
               warndlg(status_text);
               return;
           end
           notify(obj.analysis_tool,'AlignImages',Events.ActionData(obj)) 
       end
        
       function min_max_changed(obj,src)
           % Ensure all ranges are valid numbers
           valid = 1;
           if ~strcmp(src.Tag,'ChannelTool')
               val = str2double(src.String);

               if isnan(val) || val < 0
                  valid = 0;
               elseif contains(src.Tag,'Min labeled')
                   valid = val <= str2double(obj.max_pixel_edit_labeled.String);
               elseif contains(src.Tag,'Max labeled')
                   valid = val >= str2double(obj.min_pixel_edit_labeled.String);
               elseif contains(src.Tag,'Max DNA')
                   valid = val >= str2double(obj.min_pixel_edit_dna.String);
               elseif contains(src.Tag,'Min DNA')
                   valid = val <= str2double(obj.max_pixel_edit_dna.String);
               end
           end
           
           if valid
            notify(obj.analysis_tool,'RemovePixelArtifacts',Events.ActionData(obj)) 
           else
            warndlg('Value entered into Min/Max filter is not valid.');
            notify(obj,'Status_Update',Events.ActionData('Value entered into Min/Max filter is not valid.'));
           end
       end
       
       function conv_changed(obj,src)
           conv = str2double(src.String);
           
           if isnan(conv) || conv <= 0
                src.String = "";
                obj.median_um_dna.String = "";       
                obj.median_um_labeled.String = "";    
                obj.mean_um_dna.String = "";         
                obj.mean_um_labeled.String = "";      
                obj.max_um_dna.String = "";          
                obj.max_um_labeled.String = "";       
                obj.min_um_dna.String = "";          
                obj.min_um_labeled.String = ""; 
           else
               
               % Pixel is area, micrometer is major axis length
               if ~isempty(obj.median_pixel_dna.String)    
                    maj_axis_dna = obj.analysis_tool.region_stats_dna.MajorAxisLength;
                    obj.median_um_dna.String = num2str(conv*median(maj_axis_dna));  
                    obj.mean_um_dna.String = num2str(conv*mean(maj_axis_dna));  
                    obj.max_um_dna.String = num2str(conv*max(maj_axis_dna));  
                    obj.min_um_dna.String = num2str(conv*min(maj_axis_dna));  
               end
               
               if ~isempty(obj.median_pixel_labeled.String) 
                    maj_axis_lab = obj.analysis_tool.region_stats_labeled.MajorAxisLength;
                    obj.median_um_labeled.String = num2str(conv*median(maj_axis_lab));
                    obj.mean_um_labeled.String = num2str(conv*mean(maj_axis_lab));  
                    obj.max_um_labeled.String = num2str(conv*max(maj_axis_lab));  
                    obj.min_um_labeled.String = num2str(conv*min(maj_axis_lab));  
               end
           end
           obj.analysis_tool.update_histograms(obj);
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%
       % DATA DISPLAY FUNCTIONS %
       %%%%%%%%%%%%%%%%%%%%%%%%%%
       
       function dual_zoom(obj,src)
          % Set dual zoom property
          robot = java.awt.Robot;
          robot.keyPress(java.awt.event.KeyEvent.VK_L);
          robot.keyRelease(java.awt.event.KeyEvent.VK_L);
          obj.analysis_tool.dual_zoom = src.Value;
          
       end
       
       function axes_changed(obj,src)
           tag = src.Tag;
           val = str2double(src.String);
           
           if contains(tag,'Min')
               if isnan(val)
                   src.String = '-inf';
               else
                   if contains(tag,'BS')
                   % Background subtracted histogram
                        if  val > str2double(obj.lab_dna_bs_ratio_max_edit.String)
                            src.String = '-inf';
                        end
                   elseif contains(tag,'Size')
                   % Size histogram
                        if  val > str2double(obj.size_max_edit.String)
                            src.String = '-inf';
                        end
                   else
                   % Otherwise, raw image histogram
                        if  val > str2double(obj.lab_dna_ratio_max_edit.String)
                            src.String = '-inf';
                        end
                   end
               end
           else
               if isnan(val) || val < str2double(obj.lab_dna_ratio_min_edit.String)
                   src.String = 'inf';
               else
                   if contains(tag,'BS')
                   % Background subtracted histogram
                        if  val < str2double(obj.lab_dna_bs_ratio_min_edit.String)
                            src.String = '-inf';
                        end
                   elseif contains(tag,'Size')
                   % Size histogram
                        if  val < str2double(obj.size_min_edit.String)
                            src.String = '-inf';
                        end
                   else
                   % Otherwise, raw image histogram
                        if  val < str2double(obj.lab_dna_ratio_min_edit.String)
                            src.String = '-inf';
                        end
                   end
               end    
           end
           
           if ~isempty(obj.analysis_tool)
            obj.analysis_tool.update_histograms(obj);
           end
               
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%
       % RESET TOOL FUNCTION %
       %%%%%%%%%%%%%%%%%%%%%%%
       
       function reset_data(obj)
          % disable the tabs again, reset everything to default vals, set
          % current tab to first tab
          
          % Set tab to first tab
          obj.parent.SelectedTab = obj.raw_image_sub_tab;
          
          % Disable subsequent tabs
          obj.jparent.setEnabledAt(1,0);
          obj.jparent.setEnabledAt(2,0);
          obj.jparent.setEnabledAt(3,0);
          obj.jparent.setEnabledAt(4,0);
          obj.tab_enabled = [1 0 0 0 0 1];
          
          % Disable buttons
          obj.prev_btn.Enable = 'off';
          obj.next_btn.Enable = 'on';
          obj.size_bin_edit.Enable = 'off';
          obj.size_min_edit.Enable = 'off';
          obj.size_max_edit.Enable = 'off';
          obj.lab_dna_bs_ratio_bin_edit.Enable = 'off';
          obj.lab_dna_ratio_bin_edit.Enable = 'off';
          obj.lab_dna_bs_ratio_max_edit.Enable = 'off';    
          obj.lab_dna_bs_ratio_min_edit.Enable = 'off';   
          obj.lab_dna_ratio_max_edit.Enable = 'off';    
          obj.lab_dna_ratio_min_edit.Enable = 'off'; 
          
          % Reset background subtraction tab to default values
          set(obj.bckgrnd_panel_labeled_edit,{'String','Enable'},{num2str(obj.bck_def_val),'off'}); 
          set(obj.bckgrnd_panel_labeled_slid,{'Value','Enable'},{obj.bck_def_val,'off'}); 
          set(obj.bckgrnd_panel_dna_edit,{'String','Enable'},{num2str(obj.bck_def_val),'off'}); 
          set(obj.bckgrnd_panel_dna_slid,{'Value','Enable'},{obj.bck_def_val,'off'}); 
          
          % Reset threshold tab to default values
          set(obj.thresh_panel_labeled_edit,{'String','Enable'},{num2str(obj.thresh_def_val),'off'}); 
          set(obj.thresh_panel_labeled_slid,{'Value','Enable'},{obj.thresh_def_val,'off'}); 
          set(obj.thresh_panel_dna_edit,{'String','Enable'},{num2str(obj.thresh_def_val),'off'}); 
          set(obj.thresh_panel_dna_slid,{'Value','Enable'},{obj.thresh_def_val,'off'}); 
          
          % Reset alignment tab to default values
          set(obj.align_panel_edit,{'String','Enable'},{num2str(obj.align_def_val),'off'}); 
          
          % Reset statistics tab
           set(obj.max_pixel_edit_dna,{'String','Enable'},{'Inf','off'});
           set(obj.max_pixel_edit_labeled,{'String','Enable'},{'Inf','off'});
           set(obj.min_pixel_edit_dna,{'String','Enable'},{'0','off'});
           set(obj.min_pixel_edit_labeled,{'String','Enable'},{'0','off'});
           obj.cell_dna.String = '';                  
           obj.cell_labeled.String = '';
           obj.median_pixel_dna.String = '';
           obj.median_pixel_labeled.String = '';
           obj.mean_pixel_dna.String = '';
           obj.mean_pixel_labeled.String = '';
           obj.max_pixel_dna.String = '';
           obj.max_pixel_labeled.String = '';
           obj.min_pixel_dna.String = '';
           obj.min_pixel_labeled.String = '';

           obj.median_um_dna.String = '';
           obj.median_um_labeled.String = '';
           obj.mean_um_dna.String = '';
           obj.mean_um_labeled.String = '';
           obj.max_um_dna.String = '';
           obj.max_um_labeled.String = '';
           obj.min_um_dna.String = '';
           obj.min_um_labeled.String = '';
           
           % Reset data display tab
           obj.dual_zoom_tog.Enable = 'on';
           obj.lab_dna_histogram.Data = [];         
           obj.lab_dna_bs_histogram.Data = [];      
           obj.sz_distr_histogram.Data = [];        
           obj.save_hist_btn.Enable = 'off';

           set(obj.lab_dna_ratio_max_edit,{'String','Enable'},{'Inf','off'});
           set(obj.lab_dna_bs_ratio_max_edit,{'String','Enable'},{'Inf','off'});
           set(obj.size_max_edit,{'String','Enable'},{'Inf','off'});
           set(obj.lab_dna_ratio_min_edit,{'String','Enable'},{'-Inf','off'});
           set(obj.lab_dna_bs_ratio_min_edit,{'String','Enable'},{'-Inf','off'});
           set(obj.size_min_edit,{'String','Enable'},{'-Inf','off'});
           
           obj.lab_dna_ratio_median.String = '';
           obj.lab_dna_ratio_mean.String = '';
           obj.lab_dna_ratio_bin_edit.Enable = 'off';

           obj.lab_dna_bs_ratio_median.String = '';
           obj.lab_dna_bs_ratio_mean.String = '';
           obj.lab_dna_bs_ratio_bin_edit.Enable = 'off';

           obj.size_median.String = '';     
           obj.size_mean.String = '';       
           obj.size_bin_edit.Enable = 'off';
           obj.unit_disp.Value = 1;                 
       end
    
   end
end
