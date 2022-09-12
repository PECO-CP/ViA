classdef viral_analysis < handle
%IMAGE_ANALYSIS Primary MATLAB class file
%      IMAGE_ANALYSIS creates a new IMAGE_ANALYSIS instance or raises the 
%      existing GUI singleton.
% 
%      This IMAGE_ANALYSIS program was designed for analyzing regions of
%      interest (ROIs) in epiflourescence microscopy .CZI and .tiff images. 
%      It is capable of loading any number of .CZI channels or separate 
%      grayscale .tiff images as well as regular RGB .tiff images.
% 
%      Several interactive tools are available within the program to assist
%      in ROI definition; please refer to program help documentation for a
%      full tutorial.
%
%      ROI data can currently be exported in .CSV, .txt, or .xslx formats.
% 
%      H = IMAGE_ANALYSIS returns the handle to a new IMAGE_ANALYSIS or the 
%      handle to the existing singleton.

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
        % Class constants
        CONSTANTS = Constants.Graphics();   % handle to graphics constants values
        one_im = 0;                         % indicates whether one image was selected or two. Default is two
        
        % Class GUI objects
        blank_fig = [];                     % handle to blank_figure class
        status_bar = [];                    % handle to blank_figure's status_bar class
        fig_handle = [];                    % handle to Matlab Figure of blank_figure class
        panel_handle = [];                  % handle to uipanel; holds all children graphic objects
        
        % Class inset panels
        file_panel = [];                    % handle to uipanel for file and output directory selection
        image_panel = [];                   % handle to uipanel for image axes
        process_panel = [];                 % handle to uipanel for image channel options
        process_tab_grp = [];               % handle to uitabgroup inset in channel_panel for channel editing options
        image_review_tab = [];              % handle to uitab for raw image display and associated properties
        bckgrnd_sub_tab = [];               % handle to uitab for background subtraction and associated properties
        thresh_vir_tab = [];                % handle to uitab for virus thresholding and associated properties
        align_im_tab = [];                  % handle to uitab for image alignment and associated properties
        rmv_size_tab = [];                  % handle to uitab for removing pixel artifacts and associated properties
        data_disp_tab = [];                 % handle to uitab for displaying data and associated properties
        
        % Class menu options
        file_menu = [];                     % handle to 'File' uimenu; holds general program options such as 'Save' and 'Exit'
        display_menu = [];                  % handle to 'Display' uimenu; holds 'Zoom' and 'Default View' image options
        help_menu = [];                     % handle to 'Menu' uimenu; holds 'Manual' and 'Licensing' options
        connectivity = 4;                   % holds selected value for ROI connectivity; default is 4
        export_type = 'Excel';              % holds selected value for ROI data export data type; default is 'Excel'
        
        % Class inset panel children
        image_fp = [];                      % holds filepath of loaded image
        image_name = [];                    % holds name of loaded image
        output_dir = [];                    % holds output directory character string
        analysis_tool = [];                 % handle to instance-specific Interfaces.analyze class object
        channel_tool = [];                  % handle to instance-specific Interfaces.channel class object
        roi_stats_tool = [];                % handle to instance-specific Interfaces.roi_stats class object
        
        % Save Options
        dont_ask_again_data = 0;            % indicates whether the user has chosen 'Don't ask me again' after first 'Save ROI Data' save
        overwrite_data = 0;                 % indicates whether the user wishes to overwrite existing ROI data
        previous_filepath = pwd;             % holds previous opened folder, if any
        
        dont_ask_again_snapshot = 0;
        overwrite_snapshot = 0;
        
        Tag = 'Viral Analysis';             % class identifier
    end
    
    properties(Access = private)
       orig_file_filters =  {'CZI Files (*.czi,*.CZI)',{'czi';'CZI'},;...          
              'Grayscale Files (*.tif,*.tiff,*.TIF,*.TIFF)',{'tif';'tiff';'TIF';'TIFF'}};
       prev_filt_indx = 1;                                                                  % previous file extension index. Default is 1
    end
    
    events
        SelectionMade       % SelectionMade event, indicating an image(s) has been selected
        Status_Update       % Status_Update event, indicating an event has occurred significant enough to display to the user
        ChannelChanged      % ChannelChanged event, indicating a channel's contrast has been changed, or a channel has been disabled/enabled.
        ChannelsSelected    % ChannelsSelected event, indicating the user has finished selecting the color channels for a CZI or grayscale image.
        AreaFilter          % AreaFilter event, indicating the user has changed the min/max ROI area
        Reprocess           % Reprocess event, indicating the user has changed a step value
        SaveHistograms      % SaveHistograms event, indicatin user has selected save histogram button on data display
    end    

    methods
        function obj = viral_analysis()
        %IMAGE_ANALYSIS Construct a new instance of image_analysis or raise
        % an existing GUI.
        %   This class instantiates a new Image Analysis figure and
        %   object, unless a GUI for said object already exists. In that
        %   case, it raises the existing GUI.
        
            clear ans
            temp = findobj('Tag','Viral Analysis Figure');
            if isempty(temp)
                obj.blank_fig = Figure.blank_figure(1);
                obj.fig_handle = obj.blank_fig.fig_handle;
                obj.fig_handle.Tag = 'Viral Analysis Figure';
                obj.panel_handle = obj.blank_fig.panel_handle;
                obj.status_bar = obj.blank_fig.status_bar;
                obj.buildFcn();
            else
                figure(temp);
            end
        end
        
        function buildFcn(obj)
            %BUILDFCN Build the Image Analysis GUI.
            %   This function takes an input object and builds the basic
            %   image analysis GUI into the object's figure handle.
            
            % Overall figure constant spacing
            X = obj.CONSTANTS.X;
            Y = obj.CONSTANTS.Y;
            width = obj.CONSTANTS.OBJ_WIDTH;
            height = obj.CONSTANTS.OBJ_HEIGHT;
            file_selection_height = 0.35;
            im_disp_title_fontsize = 0.02;
            stat_chan_title_fontsize = 0.015;
            % Extract blank figure handle and set figure name
            fh = obj.fig_handle;
            fh.Visible = 'off';
            fh.Position = obj.CONSTANTS.FIG_POS_FULL;
            fh.CloseRequestFcn = @(~,~)obj.closefig();
            fh.Name = 'Viral Analysis Tool';
            
            fp = obj.panel_handle;
            
            %%%%%%%%%%%%%%%%
            % MENU TOOLBAR %
            %%%%%%%%%%%%%%%%
            
                % File menu item
            obj.file_menu = uimenu(fh,'Text','File','UserData',0);
                    % File submenu items
            file_load_image = uimenu(obj.file_menu,'Text','Load Image(s)','Callback',...
                @(src,~)obj.load_image(src)); %#ok<*NASGU>
            file_save_roi = uimenu(obj.file_menu,'Text','Save Data','Enable','off',...
                'UserData',0,'Callback',@(~,~)obj.save_roi_data(),'Tag','Save ROI',...
                'Separator','on');
            file_save_centroid = uimenu(obj.file_menu,'Text','Save Centroid Snapshot','Enable','off',...
                'UserData',0,'Callback',@(~,~)obj.save_centroids(),'Tag','Save Centroids');
            file_save_snapshot = uimenu(obj.file_menu,'Text','Save Snapshot','Enable','off',...
                'UserData',0,'Callback',@(~,~)obj.save_snapshot(),'Tag','Save Snapshot');
            file_export_data = uimenu(obj.file_menu,'Text','Export Data As...',...
                'Enable','off','Separator','On','Tag','Export_Options');
            
                % Export Data submenu items
            file_export_csv = uimenu(file_export_data,'Text','CSV (.csv)',...
                'Tag','CSV','Callback',@(src,~)obj.export_changed(src));
            file_export_txt = uimenu(file_export_data,'Text','Text (.txt)',...
                'Tag','Text','Callback',@(src,~)obj.export_changed(src));
            file_export_excel = uimenu(file_export_data,'Text','Excel (.xlsx)',...
                'Tag','Excel','Checked','on','Callback',@(src,~)obj.export_changed(src));
            file_exit = uimenu(obj.file_menu,'Text','Exit','Separator','on',...
                'Callback',@(~,~)obj.closefig());
            
                % Display menu item
            obj.display_menu = uimenu(fh,'Text','Display','Enable','Off',...
                'Tag','Display Menu');
                    % Display submenu items
            display_centroids = uimenu(obj.display_menu,'Text','Display Centroids',...
                'Enable','Off','Callback',@(src,~)obj.analysis_tool.display_centroids(src),...
                'Tag','Display Centroids');
            display_zoom = uimenu(obj.display_menu,'Text','Zoom','Callback',...
                @(src,~)obj.analysis_tool.enable_zoom(src),'Accelerator','Z',...
                'Tag','Zoom Menu','Enable','Off');
            
            
                % Help menu item 
            obj.help_menu = uimenu(fh,'Text','Help','UserData',0);
                    % Help submenu items
            help_manual = uimenu(obj.help_menu,'Text','Manual','Callback',...
                @(src,~)obj.load_manual(src)); %#ok<*NASGU>
            help_licensing = uimenu(obj.help_menu,'Text',...
                'Licensing','Separator','on','Callback',...
                @(src,~)obj.load_licensing(src));
            

            %%%%%%%%%%%%%%%%%%%%%
            % INITIALIZE PANELS %
            %%%%%%%%%%%%%%%%%%%%%
            
            process_panel_width = 0.31;
            file_image_panel_width = 1-process_panel_width;
            
            file_height = 0.15;
            newX = 0;
            
            % Create file selection panel (bottom frame)
            obj.file_panel = uipanel(fp,'Units','normalized',...
                'Position',[newX 0 file_image_panel_width file_height]);
            
            % Create image display panel
            newY = obj.file_panel.Position(2) + obj.file_panel.Position(4);
            obj.image_panel = uipanel(fp,'Units','normalized',...
                'Position',[newX newY file_image_panel_width 1-file_height],...
                'Title','Image Display','FontUnits','normalized',...
                'FontSize',im_disp_title_fontsize);
            
            % Create process editing panel
            newX = obj.image_panel.Position(1) + obj.image_panel.Position(3);
            
            obj.process_panel = uipanel(fp,'Units','normalized',...
                'Position',[newX 0 process_panel_width 1],'Title','Viral Analysis Procedure','FontUnits','normalized',...
                'FontSize',stat_chan_title_fontsize);
            obj.process_tab_grp = uitabgroup(obj.process_panel,'Units',...
                'normalized','Position',[0 0 1 0.9],'TabLocation','left',...
                'Tag','Process Tab Group');
            
            obj.image_review_tab = uitab(obj.process_tab_grp,'Title','Raw Image',...
                'Tag','RawImage');
            obj.bckgrnd_sub_tab = uitab(obj.process_tab_grp,'Title','Background Subtraction',...
                'Tag','BackgroundSubtraction');
            obj.thresh_vir_tab = uitab(obj.process_tab_grp,'Title','Threshold Viruses',...
                'Tag','ThresholdViruses');
            obj.align_im_tab = uitab(obj.process_tab_grp,'Title','Align Images',...
                'Tag','AlignImages');
            obj.rmv_size_tab = uitab(obj.process_tab_grp,'Title','Remove Pixel Artifacts',...
                'Tag','RemovePixelArtifacts');
            obj.data_disp_tab = uitab(obj.process_tab_grp,'Title','Data Display',...
                'Tag','DataDisplay');  
            
            %%Display for output directory%%
            output_dir_edit_string = 'Select Output Directory...';
            output_dir_browse_title = 'Select Output Directory';
            
            obj.output_dir = Figure.file_select_display(obj.file_panel,1); % create a
            % file_select_display object; '1' indicates selecting a directory rather than a file
            
            obj.output_dir.editString = output_dir_edit_string;
            obj.output_dir.browseTitle = output_dir_browse_title;
            
            obj.output_dir.Position = [X 2*Y width file_selection_height];
            
            newX = X;
            newY = 1- (obj.output_dir.Position(2) + obj.output_dir.Position(4));
            
            %%Display for chosen image file path%%
            
            % Set image selection parameters
            %image_selection_file_filter = {'*.czi;*.CZI;','CZI Files (*.czi,*.CZI)';...
             % '*.tif;*.tiff;*.TIF;*.TIFF;','Grayscale Files (*.tif,*.tiff,*.TIF,*.TIFF)'};
            image_selection_file_title = 'Select a CZI or grayscale image';
            
            image_selection_file_multi = 'On';
                        
            obj.image_fp = Figure.file_select_display(obj.file_panel);
            obj.image_fp.browseFilter = obj.orig_file_filters;
            obj.image_fp.browseTitle = image_selection_file_title;
            obj.image_fp.browseMulti = image_selection_file_multi;
            obj.image_fp.Position = [newX newY width file_selection_height];
                    
            fh.Visible = 'on';
            obj.channel_tool = Interfaces.channel(obj.process_tab_grp);
            
            % Bind listeners to file and output selection to enable
            % analysis
            addlistener(obj.image_fp,'SelectionMade',@(src,evnt)obj.load_image(src));
            addlistener(obj,'Status_Update',@(~,evnt)obj.status_bar.update_status(evnt));
            addlistener(obj.channel_tool,'SelectionMade',@(~,evnt)obj.channel_tool.initialize_procedure(evnt));
            addlistener(obj.channel_tool,'ThresholdChanged',@(src,evnt)obj.analysis_tool.(evnt));
            addlistener(obj.channel_tool,'SaveHistograms',@(~,~)obj.save_histograms());
            
            % Resize figure after child construction so that children
            % resize automatically
            fh.Position = obj.CONSTANTS.FIG_POS_FULL;
            obj.status_bar.update_status(Events.ActionData('Ready to Load Image'));
            obj.fig_handle.WindowButtonMotionFcn = @(~,~)obj.mouse_move();
            obj.fig_handle.WindowButtonDownFcn = @(~,~)obj.button_down();
            obj.fig_handle.WindowButtonUpFcn = @(~,~)obj.resize_panel();
        end
    end
    
    methods(Access = public)
        
       %%%%%%%%%%%%%%%%%%%%%%%%%
       % RESET MOUSE FUNCTIONS %
       %%%%%%%%%%%%%%%%%%%%%%%%%
       
       function resetMouseMoveFunction(obj)
           %RESETMOUSEMOVEFUNCTION Sets the image analysis figure mouse
           % callbacks to custom functions.
           %   This function is for use when another custom function or
           %   built-in MATLAB function changes the figure mouse
           %   callbacks. It resets all mouse functions to the custom
           %   class functions.
            
           obj.fig_handle.WindowButtonMotionFcn = @(~,~)obj.mouse_move();
           obj.fig_handle.WindowButtonDownFcn = @(~,~)obj.button_down();
           obj.fig_handle.WindowButtonUpFcn = @(~,~)obj.resize_panel();
       end
       
    end
    
    methods(Access = private)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FIGURE HANDLE CALLBACKS %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = mouse_move(obj)
        %MOUSE_MOVE Class-specific mouse move callback function.
        %   This function sets the pointer to an arrow at all points except
        %   near panel boundaries. There it switches to left-right or
        %   up-down arrows to indicate the option of resizing panels.
            current_pos = obj.fig_handle.CurrentPoint;
            yspace = obj.panel_handle.Position(2);
            padding = 0.0015;
            X = current_pos(1);
            Y = current_pos(2);
            
            file_pos = obj.file_panel.Position(1:2);
            file_pos(2) = (file_pos(2) + obj.file_panel.Position(4))*(1-yspace) + yspace;
            
            image_pos = obj.image_panel.Position(3);
            
            if X > image_pos-padding && X < image_pos+padding && Y >= yspace
                % Movement changes all horizontally
                obj.fig_handle.Pointer = 'right';
            elseif X > 0 && X < image_pos && Y > file_pos(2)-padding && Y < file_pos(2)+padding
                % Movement changes all vertically
                obj.fig_handle.Pointer = 'top';
            elseif strcmp(obj.fig_handle.Pointer,'fleur') || strcmp(obj.fig_handle.Pointer,'custom')
            else
               obj.fig_handle.Pointer = 'arrow';
            end
        end
        
        function obj = closefig(obj)
        %CLOSEFIG Custom close figure callback function.
        %   Closes the image analysis figure and any child manual
        %   threshold interfaces, as well as ending the logger.
            
           delete(gcf);
           temp = findobj('Tag','manual_threshold_interface');
           if ~isempty(temp)
              delete(temp); 
           end
           clear ans
           diary off
           fclose('all');
        end
        
        function obj = button_down(obj)
        %BUTTON_DOWN Custom mouse click callback function.
        %   Clicking the mouse will keep the pointer an arrow or custom
        %   image unless it's a left-right or up-down arrow, indicating
        %   that the user is trying to change the size of a panel. In that
        %   case, the 'mouse move' callback is set to null to maintain the
        %   pointer.
        
           if strcmp(obj.fig_handle.Pointer,'arrow') || strcmp(obj.fig_handle.Pointer,'custom')
               return;
           end
           obj.fig_handle.WindowButtonMotionFcn = [];
        end
        
        function obj = resize_panel(obj)
        %RESIZE_PANEL Custom button-up callback function.
        %   If the pointer is an up-down or left-right arrow, resizes
        %   panels to current pointer position. Otherwise, does nothing.
            if ~strcmp(obj.fig_handle.Pointer,'left') && ...
                    ~strcmp(obj.fig_handle.Pointer,'right') && ...
                    ~strcmp(obj.fig_handle.Pointer,'top') && ...
                    ~strcmp(obj.fig_handle.Pointer,'bottom') 
               return;
            end
            
            current_pos = obj.fig_handle.CurrentPoint;
            yspace = obj.panel_handle.Position(2);
            
            X = current_pos(1);
            if X < 0
                X = 0;
            elseif X > 1
                X = 1;
            end
            Y = current_pos(2);
            if Y < yspace
                Y = yspace;
            elseif Y > 1
                Y = 1;
            end
            if strcmp(obj.fig_handle.Pointer,'right')
                 % Image panel size change
                obj.process_panel.Position(1) = X;
                obj.process_panel.Position(3) = 1-X;
                xspace = 1-obj.process_panel.Position(3);
                if xspace < 0
                    xspace = 0.01;
                end
                obj.image_panel.Position(3) = xspace;
                obj.file_panel.Position(3) = xspace;
            elseif strcmp(obj.fig_handle.Pointer,'top')
               % File panel size change
               ymove = Y - yspace;
               obj.file_panel.Position(4) = ymove;
               obj.image_panel.Position(2) = ymove;
               obj.image_panel.Position(4) = 1-(ymove);
            end
            obj.fig_handle.WindowButtonMotionFcn = @(~,~)obj.mouse_move();
        end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % FILE MENU CALLBACK FUNCTIONS %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       %%%%%% LOAD IMAGE CALLBACK %%%%%%%%%%%
       function obj = load_image(obj,src)
        %LOADIMAGE Uimenu 'Load Image' callback function.
        %   Sets image filepath and save names, and notifies the object
        %   that an image has been selected, activating the 'image_fp'
        %   callback function 'enable_analysis'.
        
        imag_fp_handle = obj.image_fp;
        if ~strcmp(class(src),'Figure.file_select_display') %#ok<STISA> Compared class is custom

            [file,path,filterIndex] = Figure.MacFix.uigetfile_with_preview(imag_fp_handle.browseFilter,...
                imag_fp_handle.browseTitle,obj.previous_filepath,'',imag_fp_handle.browseMulti);

            path = [path '/'];
            
            if filterIndex ~= 0
                
                % Rearrange filter so selected filter index is primary on
                % next load
                logiFilter = cellfun(@(x)isequal(x,imag_fp_handle.browseFilter{filterIndex,2}),obj.orig_file_filters(:,2));
                imag_fp_handle.browseFilter(1,:) = obj.orig_file_filters(logiFilter,:);
                imag_fp_handle.browseFilter(2:end,:) = obj.orig_file_filters(~logiFilter,:);
                
                % Resort filter index to equal the indx associated with
                % original file filters
                filterIndex = find(logiFilter);
                
                % Checks and patches an incorrectly deleted analysis tool
%                 if ~exist('obj.analysis_tool','class')
%                     obj.analysis_tool = [];
%                 end
                
                if ~isempty(obj.analysis_tool)
                    cont = obj.reload_analysis();
                    if ~cont; return; end
                end
                obj.previous_filepath = path;
                % Check if multiple files were selected
                if iscell(file)
                   if filterIndex ~= 2
                    warning('Multiple image selection is not supported for non-grayscale images; please select a single image for analysis.')
                    notify(obj,'Status_Update',...
                            Events.ActionData(['Multiple image selection is ',...
                            'not supported for non-grayscale images; please select a ',...
                            'single image for analysis.']));
                    obj.load_image(src);
                    return;
                   end
                   for i = 1:length(file)
                      imag_fp_handle.filepath{i} = [path file{i}]; 
                   end
                   obj.image_name = file;
                   imag_fp_handle.edit.String = path; 
                else
                   if filterIndex ~= 1
                       obj.one_im = 1;
                   end
                   imag_fp_handle.filepath = [path file];
                   obj.image_name = file;
                   imag_fp_handle.edit.String = imag_fp_handle.filepath; 
                end
                imag_fp_handle.path = path;
                imag_fp_handle.browseIndex = filterIndex;
                imag_fp_handle.selectionEventData = 1;
            else
               return; 
            end
        else
            % If string of filepath was edited, possible that extension is
            % not valid
            if ~any(strcmpi(imag_fp_handle.exten,{'.tif','.tiff','.czi'}))
                notify(obj,'Status_Update',Events.ActionData('Invalid file extension; image must be a .czi, .tiff, or .tif.'));
                return;
            end
            
            % Check for incorrectly deleted analysis tool
%             if ~exist('obj.analysis_tool','class')
%                 obj.analysis_tool = [];
%             end
            
            % If extension is valid, check for existing analysis tool and
            % reload
            if ~isempty(obj.analysis_tool)
                cont = obj.reload_analysis();
                if ~cont; return; end
            end
            
            obj.previous_filepath = imag_fp_handle.path;
            obj.image_name = imag_fp_handle.file_name;
        end
        obj.enable_analysis();
       end 
       
       function obj = enable_analysis(obj)
        %ENABLE_ANALYSIS Enables all necessary GUI objects for image
        %analysis.
        %   'image_fp' SelectionMade callback. Enables all ROI and display
        %   menu tools, populates file selection fields, and creates and
        %   runs a new Interface.analyze object for image analysis.
           if obj.image_fp.selectionEventData == 1
               if obj.output_dir.selectionEventData ~= 1
                  obj.output_dir.editString = obj.image_fp.path;
               end
               
               if ~isnumeric(obj.image_fp.browseIndex)
                   if strcmpi(obj.image_fp.browseIndex,'.czi')
                       obj.image_fp.browseIndex = 1;
                   else
                       obj.image_fp.browseIndex = 2;
                   end
               end
               
               obj.analysis_tool = Interfaces.analyze...   % analyze image
               (obj,obj.image_fp.filepath,obj.image_fp.browseIndex);
               
               if ~isvalid(obj.analysis_tool)
                   obj.reload_analysis();
                   return;
               end
           
               children = obj.file_menu.Children;
               for i = 1:length(children)
                  children(i).Enable = 'on'; 
               end
               
               % Disable 'Save Centroids' until a binary mask exists
               temp_save_ctr = findobj('Tag','Save Centroids');
               temp_save_ctr.Enable = 'off';
               temp_save_roi = findobj('Tag','Save ROI');
               temp_save_roi.Enable = 'off';
               
               obj.display_menu.Enable = 'On';
               
               notify(obj.channel_tool,'SelectionMade',Events.ActionData(obj.analysis_tool));
           end
       end
       
       %%%%%%%%%%% SAVE ALL CALLBACK %%%%%%%%%%%%%
       function save_all(obj)
        %SAVE_ALL File menu 'Save ROI Data & Masks' callback.
        %   Saves ROI Data and current ROI mask.
           obj.save_roi_mask();
           obj.save_roi_data();
           obj.save_ids();
           notify(obj,'Status_Update',Events.ActionData('All ROI data and masks saved successfully.'))
       end
       
       %%%%%%%% SAVE SNAPSHOT CALLBACK %%%%%%%%%%
       function save_centroids(obj)
        %SAVE_SNAPSHOT File menu 'Save Snapshot' callback function.
        %   Saves only the current displayed image
           obj.fig_handle.WindowButtonMotionFcn = [];
           obj.fig_handle.WindowButtonDownFcn = [];
           obj.fig_handle.WindowButtonUpFcn = [];
           obj.fig_handle.Pointer = 'watch';
           notify(obj,'Status_Update',Events.ActionData('Saving Centroid Snapshot(s)...'))
           pause(0.1);
           
           if iscell(obj.image_name)
               labeled_filepath = [obj.output_dir.edit.String obj.image_name{2}];
               dna_filepath = [obj.output_dir.edit.String obj.image_name{1}];
           else
               labeled_filepath = [obj.output_dir.edit.String obj.image_name];
               dna_filepath = [obj.output_dir.edit.String obj.image_name];
           end
           
           filepath = regexprep(labeled_filepath,'\.[a-zA-Z]+','_centroid_snapshot');
           if strcmp(labeled_filepath,filepath)
               labeled_filepath = [labeled_filepath '_centroid_snapshot'];
           else
               labeled_filepath = filepath;
           end
           
           filepath = regexprep(dna_filepath,'\.[a-zA-Z]+','_centroid_snapshot');
           if strcmp(dna_filepath,filepath)
               dna_filepath = [dna_filepath '_centroid_snapshot'];
           else
               dna_filepath = filepath;
           end
                 
           isdna = obj.analysis_tool.isdna;
           
           labeled_filepath = [labeled_filepath '_labeled.png'];
           dna_filepath = [dna_filepath '_dna.png'];
           
           if isfile(labeled_filepath) || isfile(dna_filepath)
              if ~obj.dont_ask_again_snapshot
                  sel = Figure.custom_questdlg('Overwrite saved centroid snapshot(s)?',{'Yes','No','Cancel'},'Overwrite Saved Centroid Snapshot','yes');
                  obj.dont_ask_again_snapshot = sel.dont_ask_again_val;
                  switch sel.selection
                      case 'Yes'
                        obj.overwrite_snapshot = 1;
                      case 'No'
                        obj.overwrite_snapshot = 0;
                      otherwise
                          return;
                  end
              end
              if ~obj.overwrite_snapshot
                    count = 0;
                    while isfile(labeled_filepath)
                        count = count + 1;
                        labeled_filepath = regexprep(labeled_filepath,'_centroid_snapshot(\([0-9]+\))?\.png',['_centroid_snapshot(' num2str(count) ').png']);
                    end
                    count = 0;
                    while isfile(dna_filepath)
                        count = count + 1;
                        dna_filepath = regexprep(dna_filepath,'_centroid_snapshot(\([0-9]+\))?\.png',['_centroid_snapshot(' num2str(count) ').png']);
                    end
              end
           end
           
           % Display centroids on graph
           obj.analysis_tool.display_centroids();
           
           % Save both snapshots
           exportgraphics(obj.analysis_tool.image_axes_dna,dna_filepath);
           exportgraphics(obj.analysis_tool.image_axes_labeled,labeled_filepath);

           % Redraw axes; if centroid activated, no change, otherwise
           % removes centroid outlines
           obj.analysis_tool.selection_changed();
           
           notify(obj,'Status_Update',Events.ActionData('Saved centroid snapshot(s) sucessfully.'))
           obj.fig_handle.Pointer = 'arrow';
           obj.resetMouseMoveFunction;
       end
       
       function save_snapshot(obj)
       %SAVE_SNAPSHOT File menu 'Save Snapshot' callback function.
        %   Saves only the current displayed image
           obj.fig_handle.WindowButtonMotionFcn = [];
           obj.fig_handle.WindowButtonDownFcn = [];
           obj.fig_handle.WindowButtonUpFcn = [];
           obj.fig_handle.Pointer = 'watch';
           notify(obj,'Status_Update',Events.ActionData('Saving Snapshot(s)...'))
           pause(0.1);
           
           if iscell(obj.image_name)
               labeled_filepath = [obj.output_dir.edit.String obj.image_name{2}];
               dna_filepath = [obj.output_dir.edit.String obj.image_name{1}];
           else
               labeled_filepath = [obj.output_dir.edit.String obj.image_name];
               dna_filepath = [obj.output_dir.edit.String obj.image_name];
           end
           
           filepath = regexprep(labeled_filepath,'\.[a-zA-Z]+','_snapshot');
           if strcmp(labeled_filepath,filepath)
               labeled_filepath = [labeled_filepath '_snapshot'];
           else
               labeled_filepath = filepath;
           end
           
           filepath = regexprep(dna_filepath,'\.[a-zA-Z]+','_snapshot');
           if strcmp(dna_filepath,filepath)
               dna_filepath = [dna_filepath '_snapshot'];
           else
               dna_filepath = filepath;
           end
                
           isdna = obj.analysis_tool.isdna;
           
           if isempty(isdna)
               labeled_filepath = [labeled_filepath '_labeled.png'];
               dna_filepath = [dna_filepath '_dna.png'];
           else
               if isdna
                   dna_filepath = [dna_filepath '_dna.png'];
                   labeled_filepath = '';
               else
                   labeled_filepath = [labeled_filepath '_labeled.png'];
                   dna_filepath = '';
               end
           end
           
           if isfile(labeled_filepath) || isfile(dna_filepath)
              if ~obj.dont_ask_again_snapshot
                  sel = Figure.custom_questdlg('Overwrite saved snapshot(s)?',{'Yes','No','Cancel'},'Overwrite Saved Snapshot','yes');
                  obj.dont_ask_again_snapshot = sel.dont_ask_again_val;
                  switch sel.selection
                      case 'Yes'
                        obj.overwrite_snapshot = 1;
                      case 'No'
                        obj.overwrite_snapshot = 0;
                      otherwise
                          return;
                  end
              end
              if ~obj.overwrite_snapshot
                    count = 0;
                    while isfile(labeled_filepath)
                        count = count + 1;
                        labeled_filepath = regexprep(labeled_filepath,'_snapshot(\([0-9]+\))?\.png',['_centroid_snapshot(' num2str(count) ').png']);
                    end
                    count = 0;
                    while isfile(dna_filepath)
                        count = count + 1;
                        dna_filepath = regexprep(dna_filepath,'_snapshot(\([0-9]+\))?\.png',['_centroid_snapshot(' num2str(count) ').png']);
                    end
              end
           end
           
           if isempty(isdna)
               % If both images save both
               dna_im = getimage(obj.analysis_tool.image_axes_dna);
               labeled_im = getimage(obj.analysis_tool.image_axes_labeled);
           
               imwrite(dna_im,dna_filepath); % imwrite will ignore the centroids if they are displayed
               imwrite(labeled_im,labeled_filepath);
           else
               if isdna
                   % If DNA, just save DNA
                   dna_im = getimage(obj.analysis_tool.image_axes_dna);
                   imwrite(dna_im,dna_filepath);
               else
                   % labeled
                   labeled_im = getimage(obj.analysis_tool.image_axes_labeled);
                   imwrite(labeled_im,labeled_filepath);
               end
           end
           
           notify(obj,'Status_Update',Events.ActionData('Saved snapshot(s) sucessfully.'))
           obj.fig_handle.Pointer = 'arrow';
           obj.resetMouseMoveFunction;
       end
       
       %%%%%%%%% SAVE HISTOGRAMS %%%%%%%%%%%%%%%%
       function save_histograms(obj)
           % Save PNG images of the histogram
           notify(obj,'Status_Update',Events.ActionData('Saving histograms...'))
           obj.fig_handle.Pointer = 'watch';
           chanTool = obj.channel_tool;
           output_str = obj.output_dir.editString;
           if isempty(obj.analysis_tool.isdna)
               % If empty, save all histograms for two images
               [~,fp_name,~] = fileparts(obj.image_fp.filepath{1});
               exportgraphics(chanTool.lab_dna_hist,[output_str fp_name '_labeled_DNA_Ratio_histogram.png']);
               exportgraphics(chanTool.lab_dna_bs_hist,[output_str fp_name '_labeled_DNA_Background_Subtracted_Ratio_histogram.png']);
           else
               % If empty, save all histograms for one image
               [~,fp_name,~] = fileparts(obj.image_fp.filepath);
               exportgraphics(chanTool.lab_dna_hist,[output_str fp_name '_Fluorescence_intensity_histogram.png']);
               exportgraphics(chanTool.lab_dna_bs_hist,[output_str fp_name '_Fluorescence_intensity_background_subtracted_histogram.png']);
           end
           exportgraphics(chanTool.sz_distr_hist,[output_str fp_name '_LABELED_DNA_MajorAxisLength_histogram.png']);
           notify(obj,'Status_Update',Events.ActionData('Histograms saved successfully.'))
           obj.fig_handle.Pointer = 'arrow';
       end
       
       %%%%%%%%%% SAVE ROI DATA/EXPORT OPTIONS CALLBACK %%%%%%%%%%%%%%
       function save_roi_data(obj)
        %SAVE_ROI_DATA File menu 'Save ROI Data' callback function.
        %   Saves the statistics of current ROIs based on the current
        %   binary mask in the format selected under 'Export Options'.
        %   Default export type is as an Excel spreadsheet. Note that saved
        %   intensity values are taken from the original, unedited, not-
        %   normalized uint16 image. Gives user the additional option to
        %   save unused channels if any are detected.
        
            notify(obj,'Status_Update',Events.ActionData('Saving ROI Data...'))
            obj.fig_handle.WindowButtonMotionFcn = [];
            obj.fig_handle.WindowButtonDownFcn = [];
            obj.fig_handle.WindowButtonUpFcn = [];
            obj.fig_handle.Pointer = 'watch';
            
            pause(0.1);
            
            % Set null variable states
            dna_stats  = [];
            dna_bs_stats = [];
            labeled_stats = [];
            labeled_bs_stats = [];
            
            if isempty(obj.analysis_tool.isdna)
                master_mask = obj.analysis_tool.final_image_mask_bin_dna;
                
                % Extract raw region data, applying DNA mask to both images
                dna_stats = regionprops('table',master_mask,obj.analysis_tool.image_unedited_dna,'area','centroid','majoraxislength','maxintensity');
                dna_stats.Properties.VariableNames = {'area', 'centroid','major_length','max_intensity_dna_raw'};
                
                labeled_stats = regionprops('table',master_mask,obj.analysis_tool.image_unedited_labeled,'maxintensity');
                labeled_stats.Properties.VariableNames = {'max_intensity_labeled_raw'};

                % Extract edited region data
                dna_bs_stats = regionprops('table',master_mask,obj.analysis_tool.image_mask_dna,'maxintensity');
                dna_bs_stats.Properties.VariableNames = {'max_intensity_dna_bs'};

                labeled_bs_stats = regionprops('table',master_mask,obj.analysis_tool.image_mask_labeled,'maxintensity');
                labeled_bs_stats.Properties.VariableNames = {'max_intensity_labeled_bs'};
                [rows,~] = size(dna_stats);
            else
               if obj.analysis_tool.isdna
                   master_mask = obj.analysis_tool.final_image_mask_bin_dna;
                   % Extract raw region data, applying DNA mask to both images
                    dna_stats = regionprops('table',master_mask,obj.analysis_tool.image_unedited_dna,'area','centroid','majoraxislength','maxintensity');
                    dna_stats.Properties.VariableNames = {'area', 'centroid','major_length','max_intensity_dna_raw'};
            
                    % Extract edited region data
                    dna_bs_stats = regionprops('table',master_mask,obj.analysis_tool.image_mask_dna,'maxintensity');
                    dna_bs_stats.Properties.VariableNames = {'max_intensity_dna_bs'};
                    [rows,~] = size(dna_stats);
               else
                   master_mask = obj.analysis_tool.final_image_mask_bin_labeled;
                   
                    labeled_stats = regionprops('table',master_mask,obj.analysis_tool.image_unedited_labeled,'area','centroid','majoraxislength','maxintensity');
                    labeled_stats.Properties.VariableNames = {'area', 'centroid','major_length','max_intensity_labeled_raw'};

                    labeled_bs_stats = regionprops('table',master_mask,obj.analysis_tool.image_mask_labeled,'maxintensity');
                    labeled_bs_stats.Properties.VariableNames = {'max_intensity_labeled_bs'};
                    [rows,~] = size(labeled_stats);
               end
            end
            
            % Create image name and number table
            
            counter = 1:1:rows;
            image_names = cell([rows 1]);
            dna_exp = image_names;
            lab_exp = image_names;
            if iscell(obj.image_name)
                image_names(:,1) = obj.image_name(1);
            else
                image_names(:,1) = {obj.image_name};
            end
            
            var_names = {'image_name','roi_num'};
            
            master_regions = table(image_names,counter','VariableNames',var_names);
            
            if ~isempty(obj.analysis_tool.channel_exp)
                exp_times = obj.analysis_tool.channel_exp;
                if ~isempty(exp_times{1})
                    dna_exp(:,1) = exp_times(1);
                    master_regions = [master_regions table(dna_exp) dna_stats dna_bs_stats];
                else
                    master_regions = [master_regions dna_stats dna_bs_stats];
                end
                
                if length(exp_times) > 1 && ~isempty(exp_times{2})
                    lab_exp(:,1) = exp_times(2);
                    master_regions = [master_regions table(lab_exp) labeled_stats labeled_bs_stats];
                else
                    master_regions = [master_regions labeled_stats labeled_bs_stats];
                end
                
            else
                master_regions = [master_regions dna_stats dna_bs_stats labeled_stats labeled_bs_stats];
            end
            
            if iscell(obj.image_name)
                old_filepath = [obj.output_dir.edit.String obj.image_name{1}];
            else
                old_filepath = [obj.output_dir.edit.String obj.image_name];
            end
            
            switch obj.export_type
               case 'Excel'
                   summ_data = table();
                   if isempty(obj.analysis_tool.isdna)
                       % Two images
                       dna_num = obj.channel_tool.cell_dna.String;
                       dna_mean = obj.channel_tool.mean_pixel_dna.String;
                       dna_thresh = obj.channel_tool.thresh_panel_dna_edit.String;
                       dna_disc_rad = obj.channel_tool.bckgrnd_panel_dna_edit.String;
                       
                       lab_dna_ratio = obj.channel_tool.lab_dna_ratio_mean.String;
                       lab_dna_bs_ratio = obj.channel_tool.lab_dna_bs_ratio_mean.String;
                       lab_thresh =  obj.channel_tool.thresh_panel_labeled_edit.String;
                       lab_disc_rad = obj.channel_tool.bckgrnd_panel_labeled_edit.String;
                       
                       labeled_mean = obj.channel_tool.mean_pixel_labeled.String;
                       lab_num = obj.channel_tool.cell_labeled.String;
                       align_shift_x = obj.channel_tool.align_panel_x.String;
                       align_shift_y = obj.channel_tool.align_panel_y.String;
                       
                       var_names = {'dna_total_rois','dna_mean_pixel','dna_bs_disc_rad',...
                           'dna_thresh','labeled_cells','labeled_mean_pixel',...
                           'labeled_bs_disc_rad','labeled_thresh','labeled_dna_ratio',...
                           'labeled_dna_bs_ratio','alignment_shift_x','alignment_shift_y'};
                       
                       summ_data = [summ_data table(str2double(dna_num),...
                           str2double(dna_mean), str2double(dna_disc_rad),... 
                           str2double(dna_thresh),str2double(lab_num),...
                           str2double(labeled_mean), str2double(lab_disc_rad),...
                           str2double(lab_thresh), str2double(lab_dna_ratio),...
                           str2double(lab_dna_bs_ratio),str2double(align_shift_x),...
                           str2double(align_shift_y),'VariableNames',var_names)];
                   else
                       if obj.analysis_tool.isdna
                           % DNA
                           dna_num = obj.channel_tool.cell_dna.String;
                           dna_mean = obj.channel_tool.mean_pixel_dna.String;
                           dna_thresh = obj.channel_tool.thresh_panel_dna_edit.String;
                           dna_disc_rad = obj.channel_tool.bckgrnd_panel_dna_edit.String;

                           var_names = {'dna_cells','dna_mean_pixel','dna_bs_disc_rad',...
                               'dna_thresh'};

                           summ_data = [summ_data table(str2double(dna_num),...
                               str2double(dna_mean), str2double(dna_disc_rad),... 
                               str2double(dna_thresh),'VariableNames',var_names)];
                       else
                           % labeled
                           lab_thresh =  obj.channel_tool.thresh_panel_labeled_edit.String;
                           lab_disc_rad = obj.channel_tool.bckgrnd_panel_labeled_edit.String;
                           labeled_mean = obj.channel_tool.mean_pixel_labeled.String;
                           lab_num = obj.channel_tool.cell_labeled.String;
                           
                           var_names = {'labeled_cells','labeled_mean_pixel',...
                               'labeled_bs_disc_rad','labeled_thresh'};

                           summ_data = [summ_data table(str2double(lab_num),...
                               str2double(labeled_mean), str2double(lab_disc_rad),...
                               str2double(lab_thresh),'VariableNames',var_names)];
                       end
                       
                   end
                   
                    notify(obj,'Status_Update',Events.ActionData('Writing to Excel file...'))
                    
                    filepath = regexprep(old_filepath,'\.[a-zA-Z]+','_ROI_Data.xlsx');
                    if strcmp(old_filepath,filepath)
                       filepath = [filepath '_ROI_Data.xlsx'];
                    end
                    
                    if isfile(filepath)
                      if obj.check_fopen(filepath) == -1
                         notify(obj,'Status_Update',Events.ActionData('File in use; save canceled.'))
                         obj.fig_handle.Pointer = 'arrow';
                         obj.resetMouseMoveFunction;
                         temp = 0;
                         return; 
                      end
                      if ~obj.dont_ask_again_data
                          sel = Figure.custom_questdlg('Overwrite saved ROI data?',{'Yes','No','Cancel'},'Overwrite Saved ROI Data','yes');
                          obj.dont_ask_again_data = sel.dont_ask_again_val;
                          switch sel.selection
                              case 'Yes'
                                obj.overwrite_data = 1;
                              case 'No'
                                obj.overwrite_data = 0;
                              otherwise
                                  return;
                          end
                      end
                      if ~obj.overwrite_data  
                          file_num = 0;
                          while isfile(filepath)
                             file_num = file_num + 1;
                             filepath = regexprep(filepath,'_ROI_Data(\([0-9]+\))?\.xlsx',['_ROI_Data(' num2str(file_num) ').xlsx']);
                          end
                      else
                         delete(filepath); 
                      end
                    end
                    
                    writetable(master_regions,filepath,'Sheet','Full Data','Range','A1');
                    writetable(summ_data,filepath,'Sheet','Data Summary','Range','A1');
               case 'CSV'
                    notify(obj,'Status_Update',Events.ActionData('Writing to CSV file...'))
                    
                    filepath = regexprep(old_filepath,'\.[a-zA-Z]+','_ROI_Data.csv');
                    if strcmp(old_filepath,filepath)
                       filepath = [filepath '_ROI_Data.csv'];
                    end
                    
                    if isfile(filepath)
                      if obj.check_fopen(filepath) == -1
                         notify(obj,'Status_Update',Events.ActionData('File in use; save canceled.'))
                         obj.fig_handle.Pointer = 'arrow';
                         obj.resetMouseMoveFunction;
                         temp = 0;
                         return; 
                      end
                      if ~obj.dont_ask_again_data
                          sel = Figure.custom_questdlg('Overwrite saved ROI data?',{'Yes','No','Cancel'},'Overwrite Saved ROI Data','yes');
                          obj.dont_ask_again_data = sel.dont_ask_again_val;
                          switch sel.selection
                              case 'Yes'
                                obj.overwrite_data = 1;
                              case 'No'
                                obj.overwrite_data = 0;
                              otherwise
                                  return;
                          end
                      end
                      if ~obj.overwrite_data  
                          file_num = 0;
                          while isfile(filepath)
                             file_num = file_num + 1;
                             filepath = regexprep(filepath,'_ROI_Data(\([0-9]+\))?\.csv',['_ROI_Data(' num2str(file_num) ').csv']);
                          end
                      else
                         delete(filepath); 
                      end
                    end
                    
                    writetable(master_regions,filepath);
               case 'Text'
                    notify(obj,'Status_Update',Events.ActionData('Writing to text file...'))
                    
                    filepath = regexprep(old_filepath,'\.[a-zA-Z]+','_ROI_Data.txt');
                    if strcmp(old_filepath,filepath)
                       filepath = [filepath '_ROI_Data.txt'];
                    end
                    
                    if isfile(filepath)
                      if obj.check_fopen(filepath) == -1
                         notify(obj,'Status_Update',Events.ActionData('File in use; save canceled.'))
                         obj.fig_handle.Pointer = 'arrow';
                         obj.resetMouseMoveFunction;
                         temp = 0;
                         return; 
                      end
                      if ~obj.dont_ask_again_data
                          sel = Figure.custom_questdlg('Overwrite saved ROI data?',{'Yes','No','Cancel'},'Overwrite Saved ROI Data','yes');
                          obj.dont_ask_again_data = sel.dont_ask_again_val;
                          switch sel.selection
                              case 'Yes'
                                obj.overwrite_data = 1;
                              case 'No'
                                obj.overwrite_data = 0;
                              otherwise
                                  return;
                          end
                      end
                      if ~obj.overwrite_data  
                          file_num = 0;
                          while isfile(filepath)
                             file_num = file_num + 1;
                             filepath = regexprep(filepath,'_ROI_Data(\([0-9]+\))?\.txt',['_ROI_Data(' num2str(file_num) ').txt']);
                          end
                      else
                         delete(filepath); 
                      end
                    end
                    
                    writetable(master_regions,filepath);
               otherwise
                    notify(obj,'Status_Update',Events.ActionData('Output selection not recognized. Writing to Excel file...'))
                    
                    filepath = regexprep(old_filepath,'\.[a-zA-Z]+','_ROI_Data.xlsx');
                    if strcmp(old_filepath,filepath)
                       filepath = [filepath '_ROI_Data.xlsx'];
                    end
                    
                    if isfile(filepath)
                      if ~obj.dont_ask_again_data
                          sel = Figure.custom_questdlg('Overwrite saved ROI data?',{'Yes','No','Cancel'},'Overwrite Saved ROI Data','yes');
                          obj.dont_ask_again_data = sel.dont_ask_again_val;
                          switch sel.selection
                              case 'Yes'
                                obj.overwrite_data = 1;
                              case 'No'
                                obj.overwrite_data = 0;
                              otherwise
                                  return;
                          end
                      end
                      if ~obj.overwrite_data  
                          file_num = 0;
                          while isfile(filepath)
                             file_num = file_num + 1;
                             filepath = regexprep(filepath,'_ROI_Data(\([0-9]+\))?\.xlsx',['_ROI_Data(' num2str(file_num) ').xlsx']);
                          end
                      else
                         delete(filepath); 
                      end
                    end
                          
                   summ_data = table();
                   if isempty(obj.analysis_tool.isdna)
                       % Two images
                       dna_num = obj.channel_tool.cell_dna.String;
                       dna_mean = obj.channel_tool.mean_pixel_dna.String;
                       dna_thresh = obj.channel_tool.thresh_panel_dna_edit.String;
                       dna_disc_rad = obj.channel_tool.bckgrnd_panel_dna_edit.String;
                       
                       lab_dna_ratio = obj.channel_tool.lab_dna_ratio_mean.String;
                       lab_dna_bs_ratio = obj.channel_tool.lab_dna_bs_ratio_mean.String;
                       lab_thresh =  obj.channel_tool.thresh_panel_labeled_edit.String;
                       lab_disc_rad = obj.channel_tool.bckgrnd_panel_labeled_edit.String;
                       
                       labeled_mean = obj.channel_tool.mean_pixel_labeled.String;
                       lab_num = obj.channel_tool.cell_labeled.String;
                       align_shift_x = obj.channel_tool.align_panel_x.String;
                       align_shift_y = obj.channel_tool.align_panel_y.String;
                       
                       var_names = {'dna_cells','dna_mean','dna_bs_disc_rad',...
                           'dna_thresh','labeled_cells','labeled_mean',...
                           'labeled_bs_disc_rad','labeled_thresh','labeled_dna_ratio',...
                           'labeled_dna_bs_ratio','alignment_shift_x','alignment_shift_y'};
                       
                       summ_data = [summ_data table(str2double(dna_num),...
                           str2double(dna_mean), str2double(dna_disc_rad),... 
                           str2double(dna_thresh),str2double(lab_num),...
                           str2double(labeled_mean), str2double(lab_disc_rad),...
                           str2double(lab_thresh), str2double(lab_dna_ratio),...
                           str2double(lab_dna_bs_ratio),str2double(align_shift_x),...
                           str2double(align_shift_y),'VariableNames',var_names)];
                   else
                       if obj.analysis_tool.isdna
                           % DNA
                           dna_num = obj.channel_tool.cell_dna.String;
                           dna_mean = obj.channel_tool.mean_pixel_dna.String;
                           dna_thresh = obj.channel_tool.thresh_panel_dna_edit.String;
                           dna_disc_rad = obj.channel_tool.bckgrnd_panel_dna_edit.String;

                           var_names = {'dna_cells','dna_mean','dna_bs_disc_rad',...
                               'dna_thresh'};

                           summ_data = [summ_data table(str2double(dna_num),...
                               str2double(dna_mean), str2double(dna_disc_rad),... 
                               str2double(dna_thresh),'VariableNames',var_names)];
                       else
                           % labeled
                           lab_thresh =  obj.channel_tool.thresh_panel_labeled_edit.String;
                           lab_disc_rad = obj.channel_tool.bckgrnd_panel_labeled_edit.String;
                           labeled_mean = obj.channel_tool.mean_pixel_labeled.String;
                           lab_num = obj.channel_tool.cell_labeled.String;
                           
                           var_names = {'labeled_cells','labeled_mean',...
                               'labeled_bs_disc_rad','labeled_thresh'};

                           summ_data = [summ_data table(str2double(lab_num),...
                               str2double(labeled_mean), str2double(lab_disc_rad),...
                               str2double(lab_thresh),'VariableNames',var_names)];
                       end
                       
                   end
                   
                   writetable(master_regions,filepath,'Sheet','Full Data','Range','A1');
                   writetable(summ_data,filepath,'Sheet','Data Summary','Range','A1');
            end
            
           notify(obj,'Status_Update',Events.ActionData('ROI Data saved successfully.'))
           obj.fig_handle.Pointer = 'arrow';
           obj.resetMouseMoveFunction;
       end
       

       function export_changed(obj,src)
        %EXPORT_CHANGED File menu 'Export Options' callback functions.
        %   Checks the selected export option and ensures all other export
        %   options are unchecked. Stores that data in the property
        %   'export_type'.
           exp_menu = findobj('Tag','Export_Options');
           for i = 1:length(exp_menu.Children)
               child = exp_menu.Children(i);
              if strcmp(src.Tag,child.Tag)
                  obj.export_type = src.Tag;
                  src.Checked = 'on';
              else
                  child.Checked = 'off';
              end
           end
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%
       % HELP MENU CALLBACKS %
       %%%%%%%%%%%%%%%%%%%%%%%
       
       function load_manual(obj,src)
       %LOAD MANUAL Load stored manual PDF and display.
          man_filepath = mfilename('fullpath');
          indx = strfind(man_filepath,'+Interfaces') + 11;
          man_filepath = [man_filepath(1:indx) 'ViA_Manual.pdf'];
          system(['open ''' man_filepath ''''])
       end

       function load_licensing(obj,src)
       %LOAD LICENSING Load stored license text and display.
          blank_fig_temp = Figure.blank_figure();
          fig_handle_temp = blank_fig_temp.fig_handle;
          fig_handle_temp.Name = "GNU General Public License V3";
          fig_handle_temp.Units = 'normalized';
          fig_handle_temp.WindowStyle = 'modal';
          fig_handle_temp.Position = [0.3 0.2 0.3 0.3];
          panel_handle_temp = blank_fig_temp.panel_handle;

          lic_filepath = mfilename('fullpath');
          indx = strfind(lic_filepath,'+Interfaces') + 11;
          lic_filepath = [lic_filepath(1:indx) 'license_txt.txt'];
          lic_text_temp = fileread(lic_filepath);
          
          uicontrol(panel_handle_temp,'Style','edit','String',lic_text_temp,...
               'Units','normalized','Position',[0.02 0.105 0.96 0.8],...
               'FontUnits','normalized','FontSize',0.04,'Enable',...
               'inactive','Min',0,'Max',2);
          uicontrol(panel_handle_temp,'Style','pushbutton','String',"OK",...
              'Units','normalized','Position',[0.45 0.02 0.1 0.08],...
              'Callback',fig_handle_temp.CloseRequestFcn)
       end



       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % INTERNAL CALLBACK FUNCTIONS %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       function cont = reload_analysis(obj)
          
           notify(obj,'Status_Update',Events.ActionData('Reloading Analysis...'))
           cont = 1;
           obj.one_im = 0;
          % Remove for now; if 'Save Presets' ever added, might be useful
          %{
%           if nnz(obj.analysis_tool.image_mask_bin)
%               sel = Figure.custom_questdlg('Save existing ROI mask?',...
%                   {'Yes','No','Cancel'},'Overwrite Saved ROI Data','no');
% 
%               switch sel.selection
%                   case 'Yes'
%                       cont = obj.save_roi_mask();
%                       if ~cont; return; end
%                   case 'No'
% 
%                   otherwise
%                       cont = 0;
%                       return;
%               end
%           end
%}
           
          % Temporarily disable save and export options as well as display
          % menu
          temp_save = findobj(obj.file_menu,'Tag','Save ROI');
          temp_export = findobj(obj.file_menu,'Tag','Export_Options');
          temp_disp_centr = findobj(obj.display_menu,'Tag','Display Centroids');
          temp_disp_centr.Checked = 'off';
          temp_save.Enable = 'off';
          temp_export.Enable = 'off';
          obj.display_menu.Enable = 'off';
          
           
          
          % Delete the Analysis Tool
           if isvalid(obj.analysis_tool)
            delete(obj.analysis_tool);
           end
           
           % Reset the Channel Tool
           obj.channel_tool.reset_data;
           
           % Clear the filepath panel
           obj.image_fp.clear_prop();
           notify(obj,'Status_Update',Events.ActionData('Ready to Load Image'))
           
           
          % Removes and resets user data so that function 'dragzoom' in
           % package '+Figure' acts as though a new set of axes has been
           % created
           UserData = get(obj.fig_handle, 'UserData');

           if isfield(UserData, 'axesinfo')
               UserData = rmfield(UserData,{'origcallbacks','axesinfo','origfigname','tools'});
               set(obj.fig_handle,'UserData',UserData);
           end
       end
       
       function temp = check_fopen(obj,filepath)
       %CHECK_FOPEN Check if a given file is already open in another
       %program and inform the user if true. Otherwise, do nothing.
       
          temp = fopen(filepath,'w');
          if temp == -1
            % Inform user file is in use and exit
            d = dialog('units','normalized','Position',[0.4 0.4 0.2 0.15],...
                'Name','File In Use');
            uicontrol(d,'Style','text','units','normalized',...
                'Position',[0 0.6 1 0.3],'String',['Existing file ',...
                'is in use by another application; close and try ',...
                'again.'],'FontUnits','normalized','FontSize',0.4);
            uicontrol(d,'units','normalized','Position',...
                [0.4 0.2 0.2 0.2],'String',...
                'OK','Callback',@(~,~)delete(d),...
                'FontUnits','normalized','FontSize',0.4);
          else
             % If file is not in use, close to avoid 'file in
             % use' by MATLAB
             fclose(temp); 
          end
       end
       %%%%%%%%%%% HOLDOVER FUNCTIONS: could be implemented later %%%%%%%%%%%%%
       %{
       %%%%%%%%%%% SAVE MASK CALLBACK %%%%%%%%%%%%%
       function cont = save_roi_mask(obj)
        %SAVE_ROI_MASK File menu 'Save ROI Mask' callback.
        %   Saves only the current ROI binary mask to the value of
        %   obj.mask_save_name. Asks the user if they want to save to a
        %   different name.
        cont = 1;
           obj.fig_handle.WindowButtonMotionFcn = [];
           obj.fig_handle.WindowButtonDownFcn = [];
           obj.fig_handle.WindowButtonUpFcn = [];
           obj.fig_handle.Pointer = 'watch';
           notify(obj,'Status_Update',Events.ActionData('Saving ROI mask...'))
           pause(0.1);
           if obj.file_menu.UserData == 0
              input = obj.new_save(); 
              if strcmp(input,'Cancel') == 1
                  cont = 0;
                  return;
              else
                  if iscell(input)
                    obj.mask_save_name = input{1};  
                  else
                    obj.mask_save_name = input;
                  end
              end
           end
           old_filepath = [obj.output_dir.edit.String obj.mask_save_name];
           filepath = regexprep(old_filepath,'\.[a-zA-Z]+','_mask.mat');
           if strcmp(old_filepath,filepath)
               filepath = [filepath '_mask.mat'];
           end
          
           if isfile(filepath)
              if ~obj.dont_ask_again_mask
                  sel = Figure.custom_questdlg('Overwrite saved ROI mask?',{'Yes','No','Cancel'},'Overwrite Saved Mask','yes');
                  obj.dont_ask_again_mask = sel.dont_ask_again_val;
                  switch sel.selection
                      case 'Yes'
                        obj.overwrite_mask = 1;
                      case 'No'
                        obj.overwrite_mask = 0;
                      otherwise
                          cont = 0;
                          return;
                  end
              end
              if ~obj.overwrite_mask
                    count = 0;
                    while isfile(filepath)
                        count = count + 1;
                        filepath = regexprep(filepath,'_mask(\([0-9]+\))?\.mat',['_mask(' num2str(count) ').mat']);
                    end
              end
           end
           
           temp_bin_mask = obj.analysis_tool.image_mask_bin; 
           if ~isempty(obj.roi_id)
            temp_roi_id = obj.roi_id;
            save(filepath,'temp_bin_mask','temp_roi_id');   
           else
            save(filepath,'temp_bin_mask');
           end
           obj.fig_handle.Pointer = 'arrow';
           obj.resetMouseMoveFunction;
           notify(obj,'Status_Update',Events.ActionData('Saved ROI mask successfully.'))
       end
       
       function waitbar_close_fnc(obj,src) %#ok<INUSL> obj is unused in this method but is necessary to call the method
        %WAITBAR_CLOSE_FNC Custom waitbar close function for waitbar
        %activated in 'save_roi_data'.
        %   The waitbar created when saving ROI data that displays the
        %   progress of the function requires this custom waitbar close
        %   function for the 'Cancel' button present in waitbar. If the
        %   'Cancel' button is the source of the close, it deletes the
        %   parent waitbar figure, while if the red 'X' option is the
        %   source of the close, it deletes the source.
           if isa(src,'matlab.ui.Figure')
               delete(src);
           else
               delete(src.Parent);
           end
       end
       
       function save_ids(obj)
           if ~isempty(obj.roi_id)
                notify(obj,'Status_Update',Events.ActionData('Saving ROI IDs to CSV file...'))
                    
                old_filepath = [obj.output_dir.edit.String obj.mask_save_name];
                filepath = regexprep(old_filepath,'\.[a-zA-Z]+','_ROI_IDs.csv');
                if strcmp(old_filepath,filepath)
                        filepath = [filepath '_ROI_IDs.csv'];
                end

                if isfile(filepath)
                  if ~obj.dont_ask_again_ids
                      sel = Figure.custom_questdlg('Overwrite saved ROI IDs?',{'Yes','No','Cancel'},'Overwrite Saved ROI IDs','yes');
                      obj.dont_ask_again_ids = sel.dont_ask_again_val;
                      switch sel.selection
                          case 'Yes'
                            obj.overwrite_ids = 1;
                          case 'No'
                            obj.overwrite_ids = 0;
                          otherwise
                              return;
                      end
                  end
                  if ~obj.overwrite_ids  
                      file_num = 0;
                      while isfile(filepath)
                         file_num = file_num + 1;
                         filepath = regexprep(filepath,'_ROI_IDs(\([0-9]+\))?\.csv',['_ROI_IDs(' num2str(file_num) ').csv']);
                      end
                  end
                end
                temp_table = table(obj.roi_id','VariableNames',{'roi_id'});
                writetable(temp_table,filepath);
                notify(obj,'Status_Update',Events.ActionData('ROI IDs saved successfully.'))
           end
       end
       
       
       function input = new_save(obj)
        %NEW_SAVE Asks the user for a mask name.
        %   Requests a mask name from the user if this is the first
        %   time a mask is saved.
           answer = questdlg('Save ROI mask under image name?','Save Mask',...
               'Yes.','Save with another name.','Cancel','Yes.');
           switch answer
               case 'Yes.'
                   obj.file_menu.UserData = 1;
                   input = obj.image_name;
               case 'Save with another name.'
                   input = inputdlg('Enter ROI mask name:','Save as',[1 35]...
                       ,{obj.image_name});
                   if ~strcmp(input,'Cancel')
                      obj.file_menu.UserData = 1; 
                   else
                      input = obj.image_name; 
                   end
               case 'Cancel'
                   input = 'Cancel';
                   return;
           end
       end
       %{
       %%%%%%%%%% LOAD MASK CALLBACK %%%%%%%%%%%%
       function load_mask(obj,src)
        %LOADMASK Callback function to the ROI Tools menu 'Load Mask'
        %option.
        %   This function loads a user-selected binary ROI mask onto the
        %   current image axes. This mask can either replace the current
        %   mask or add on to it.
        
           % Get current image mask
           current_image_mask = obj.analysis_tool.image_mask_bin;
           
           % Check if current mask has any ROIs; if so, ask the user
           % whether or not to overwrite
           if any(current_image_mask,'all')
               answer = questdlg('Overwrite existing ROIs?','Load Mask',...
               'Yes.','No.','No.');
           
                if isempty(answer); return; end
                
                switch answer
                    case 'Yes.'
                        replace = 1;
                    case 'No.'
                        replace = 0;
                end
           else
               replace = 1;
           end
           
           % Autosave section within save callback
           if strcmp(src.Tag,'Autosave')
               filepath = [obj.output_dir.edit.String obj.mask_save_name];
               filepath = regexprep(filepath,'\.[a-zA-Z]+','_autosaved_mask.mat');
               new_mask = load(filepath);
               if isempty(new_mask)
                    notify(obj,'Status_Update',Events.ActionData(['WARNING: '...
                      'No autosaved mask for this image found in selected output directory.']));
                  return;
               end
              arr_name = fieldnames(new_mask);
               if length(arr_name) ~= 1
                   roi_name = arr_name{2};
                   new_roi_id = new_mask.(roi_name);
               end
              arr_name = arr_name{1};
              new_mask = new_mask.(arr_name); 
           else
               % Select a binary image mask to load
               mask_selection_file_filter = {'*.mat;','MATLAB Binary Files (*.mat)'};
               mask_selection_file_title = 'Select a MATLAB .mat image mask';

               [file,path,filterIndex] = uigetfile(mask_selection_file_filter,...
                    mask_selection_file_title);
                if filterIndex ~= 0
                   full_mask_path = [path file];
                   new_mask = load(full_mask_path);
                   arr_name = fieldnames(new_mask);
                   if length(arr_name) ~= 1
                       roi_name = arr_name{2};
                       new_roi_id = new_mask.(roi_name);
                   end
                   mask_name = arr_name{1};
                   new_mask = new_mask.(mask_name);
                else
                   return; 
                end
           end
           
           % Check mask is a logical array
           if ~islogical(new_mask)
               notify(obj,'Status_Update',Events.ActionData(['WARNING: '...
                  'Loaded mask must be a logical array.'])) 
              return;
           end
           
           % Check if mask size is equivalent to current image size
           if isequal(size(current_image_mask),size(new_mask))

               % If user chose to overwrite, replace existing mask and
               % redefine ROIs

               if replace
                  obj.analysis_tool.image_mask_bin = new_mask;
                  if exist('new_roi_id','var')
                      obj.roi_id = new_roi_id;
                  end
               else
                   obj.analysis_tool.image_mask_bin(new_mask) = 1;
                   % If ROI IDs were loaded, need to substitute in the
                   % loaded ids to existing ids
                   if exist('new_roi_id','var')
                       
                      if ~obj.dont_ask_again_load_ids
                          sel = Figure.custom_questdlg('ROI IDs detected in loaded mask: overwrite existing?',{'Yes','No','Cancel'},'Overwrite Saved ROI IDs','yes');
                          obj.dont_ask_again_load_ids = sel.dont_ask_again_val;
                          switch sel.selection
                              case 'Yes'
                                obj.overwrite_load_ids = 1;
                              case 'No'
                                obj.overwrite_load_ids = 0;
                              otherwise
                                  return;
                          end
                      end
                      if obj.overwrite_load_ids 
                            obj.roi_id = new_roi_id;
                      else
                        prev_stats = obj.roi_stats_tool.table_data.Centroid;
                        temp_mask = bwlabel(new_mask,obj.connectivity);
                        loaded_stats = regionprops('table',temp_mask,'Centroid');
                        loaded_stats = loaded_stats.Centroid;

                        obj.roi_stats_tool.update_stats(obj.analysis_tool.image_mask_bin);
                        new_stats = obj.roi_stats_tool.table_data.Centroid;
                        
                        [prev_row,~] = size(prev_stats);
                        [load_row,~] = size(loaded_stats);
                        [new_row,~] = size(new_stats);
                        
                        temp_id = cell([1 new_row]);
                        temp_id(:) = {'Undefined'};
                        % Possible existing ROIs haven't been defined yet;
                        % if so, only compare to loaded stats
                        % Note: If a loaded ROI coincides exactly with an
                        % existing ROI, the existing ID takes precedence.
                        if ~isempty(obj.roi_id)
                            for i = 1:new_row
                                curr_centr = new_stats(i,:);
                                found = 0;
                                for ii = 1:load_row
                                    if curr_centr==loaded_stats(ii,:)
                                        if strcmp(new_roi_id(ii),'Undefined')
                                            break;
                                        end
                                        temp_id(i) = new_roi_id(ii);
                                        found = 1;
                                        break;
                                    end
                                end
                                if ~found
                                    for ii = 1:prev_row
                                        if curr_centr==prev_stats(ii,:)
                                            temp_id(i) = obj.roi_id(ii);
                                            break;
                                        end
                                    end
                                end
                            end
                        else
                            for i = 1:new_row
                                curr_centr = new_stats(i,:);
                                for ii = 1:load_row
                                    if curr_centr==loaded_stats(ii,:)
                                        temp_id(i) = new_roi_id(ii);
                                        found = 1;
                                        break;
                                    end
                                end
                            end
                        end
                        obj.roi_id = temp_id;
                        obj.analysis_tool.last_id_mask = obj.analysis_tool.image_mask_bin;
                      end
                   end
               end
               obj.roi_stats_tool.update_stats(obj.analysis_tool.image_mask_bin);
               obj.analysis_tool.redraw_rois();
               obj.analysis_tool.add_to_record();
               notify(obj,'Status_Update',Events.ActionData(['ROI mask '...
                  'loaded successfully.']))
           else
              notify(obj,'Status_Update',Events.ActionData(['WARNING: '...
                  'Loaded mask size does not match current image size.'])) 
              return;
           end
       end
       %}
       
       %}
       
       
    end
end

