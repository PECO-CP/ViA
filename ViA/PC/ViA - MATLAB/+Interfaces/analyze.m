classdef analyze < handle
%ANALYZE Secondary MATLAB tool; child of image_analysis parent class
%      ANALYZE creates a new ANALYZE class object instance within the parent 
%      class or creates a nonfunctional GUI representation.
%
%      H = ANALYZE returns the handle to a new ANALYZE tool.
% 
%      This class was constructed to operate solely with the parent class
%      image_analysis in package Interfaces. This may change in future
%      releases.
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

    properties
        % Parent class objects and Constant properties
        parent                              % handle to parent class
        CONSTANTS = Constants.Graphics();   % graphics constants
        image_info = [];
        
        % Class graphic objects
        fig_handle = [];                    % handle to parent figure
        fig_title = [];                     % Original fig title; when dragzoom is disabled, necessary to reset title
        image_panel = [];                   % handle to parent panel (where image axes are displayed)
        image_axes_dna = [];                % handle to axes that display DNA image 
        image_axes_labeled = [];            % handle to axes that display labeled image 
        image_axes_dna_title = [];          % handlt to DNA axes title
        image_axes_labeled_title = [];      % handle to labeled axes title
        displayCentroids = 0;               % logical indicator if centroids of thresholded ROIs should be displayed
        
        % Image properties
        filepath = [];                      % image filepath(s)
        image_data = [];                    % for RGB and grayscale, just the image; for CZI, image, metadata, color map, OME metadata
        original_data = [];                 % holds specifically all color image data
        extra_channels = [];                % holds any non-empty channels not currently selected
        channel_exp_orig = {};              % for > 3 channel images, holds original exposure times for later use
        channel_exp = {};                   % cell array holding exposure times for individual channels
        channel_names_orig = {};            % for > 3 channel images, holds original channel names for later use
        channel_names = {};                 % cell array holding channel names
        color_channels = [];                % string array containing which channels are assigned to which color
        image_type = [];                    % image type; 1 for CZI, 2 for RGB, 3 for grayscale
        image_handle_dna = [];              % handle for created DNA image object
        image_handle_labeled = [];          % handle for created labeled image object
        image_unedited = [];                % original unedited image array
        image_unedited_dna = [];            % original unedited DNA image array
        image_unedited_labeled = [];        % original unedited labeled image array
        image_mask_original_dna = [];       % initial original normalized DNA image array
        image_mask_original_labeled = [];   % initial original normalized labeled image array
        image_mask_dna = [];                % current normalized DNA image array, unedited
        image_mask_labeled = [];            % current normalized labeled image array, unedited
        image_edited_dna = {};              % series of edited DNA image arrays
        image_edited_labeled = {};          % series of edited labeled image arrays
        image_mask_bin_dna = [];            % binary DNA image mask (logical array)
        image_mask_bin_labeled = [];        % binary labeled image mask (logical array)
        final_image_mask_bin_dna = [];      % final DNA image mask (logical array)
        final_image_mask_bin_labeled = [];  % final binary labeled image mask (logical array)
        image_mask_outlines_dna = [];       % ROI outlines in DNA image format (uint8 array)
        image_mask_outlines_labeled = [];   % ROI outlines in labeled image format (uint8 array)
        image_normalized_all = [];          % handle to image of all channels combined, normalized
        isdna = [];                         % handle to boolean if only one image is selected whether it is DNA or labeled
        
        % Zoom values
        zoom_limits_dna = {[0 inf],[0 inf]};                % current DNA axes limits to maintain zoom   
        zoom_reset_dna = {[0 inf],[0 inf]};                 % original DNA axes limits for zoom reset
        zoom_limits_labeled = {[0 inf],[0 inf]};            % current labeled axes limits to maintain zoom   
        zoom_reset_labeled = {[0 inf],[0 inf]};             % original labeled axes limits for zoom reset
        dual_zoom = 0;                                      % toggle on/off dual zoom axes
        
        % ROI Identification
        region_stats_dna = [];              % stores table data of identified ROI areas and centroids
        region_stats_labeled = [];          % stores table data of identified ROI areas and centroids
        
        channel_select_exit_code = [];      % handle to exit code for Channel Select tool
    end
    
    events
       Status_Update        % Status_Update event, indicating an event has occurred significant enough to display to the user
       SelectionMade        % SelectionMade event, indicating an image(s) has been selected
       ChannelChanged       % ChannelChanged event, indicating a channel's contrast has been changed, or a channel has been disabled/enabled.
       ChannelsSelected     % ChannelsSelected event, indicating the user has finished selecting the color channels for a CZI or grayscale image.
       AreaFilter           % AreaFilter event, indicating the user has changed the min/max ROI area
       RawImage
       BackgroundSubtraction
       ThresholdViruses
       AlignImages
       RemovePixelArtifacts
    end
    
    methods
        function obj = analyze(parent_class,filepath,filter_index)
            %ANALYZE Creates an analysis object that expands the parent figure
            % object to include the loaded image(s) and contains functions
            % for analysis.
            %
            %  Can be called with 0-3 input arguments. However, a call with
            %  any inputs less than 3 will result in a nonfunctional
            %  version of the tool.
            %
            %  Inputs:      parent_class : Parent class that will hold the
            %                              analysis tool object. Currently requires an instance of the 
            %                              image_analysis interface class as the parent class.
            %                   filepath : Filepath to the image to be
            %                              loaded. Can be either a cell array of
            %                              grayscale image filepaths or a character 
            %                              array of one .CZI or .tiff filepath.
            %               filter_index : Filter index indicates what type
            %                              of image was loaded.
            %                                   1 = CZI image
            %                                   2 = RGB image
            %                                   3 = Grayscale images
            %
            %  Outputs:              obj : An analyze object with the
            %                              properties and functions listed 
            %                              above and below.
            addlistener(obj,'Status_Update',@(~,evnt)obj.parent.status_bar.update_status(evnt));
            if nargin < 3
                filter_index = 'Default';
                if nargin < 2
                    filepath = 'Default';
                    if nargin < 1
                       fig_handle = Figure.blank_figure().fig_handle;
                       image_panel = uipanel(fig_handle);
                    end
                end
            else
               obj.parent = parent_class;
               fig_handle = parent_class.fig_handle;
               image_panel = parent_class.image_panel;
               temp_handle_display = findobj('Tag','Display Menu');
               if ~isempty(temp_handle_display)
                   for i = 1:length(temp_handle_display.Children)
                      temp_handle_display.Children(i).Enable = 'on'; 
                   end
               end
               temp_centr_disp = findobj('Tag','Display Centroids');
               temp_centr_disp.Enable = 'off';
            end
            
            obj.fig_handle = fig_handle;
            
            obj.fig_handle.WindowButtonMotionFcn = [];
            obj.fig_handle.WindowButtonDownFcn = [];
            obj.fig_handle.WindowButtonUpFcn = [];
            obj.fig_handle.Pointer = 'watch';
            
            % Update GUI
            drawnow
            
            obj.image_panel = image_panel;
            obj.filepath = filepath;
            
            %%%%%%%%%% CREATE IMAGE PANEL %%%%%%%%%%%%%%%%
            axes_height = 0.95;
            fontsize = 0.8;
            spacing = 0.02;
            width = 0.5-spacing/2;
            labeled_x = 0.5+spacing/2;
            
            obj.image_axes_dna_title = uicontrol(obj.image_panel,'Style','text','String','DNA','Units',...
              'normalized','Position',[0 axes_height width 1-axes_height],'FontUnits','normalized','FontSize',...
              fontsize,'Visible','off');
            obj.image_axes_dna = axes(obj.image_panel,'Units','normalized',...
                'Position',[0 0 width axes_height],'Visible','off');
            obj.image_axes_dna.Toolbar.Visible = 'off';
            
            obj.image_axes_labeled_title = uicontrol(obj.image_panel,'Style','text','String','LABELED','Units',...
               'normalized','Position',[labeled_x axes_height width 1-axes_height],'FontUnits','normalized','FontSize',...
               fontsize,'Visible','off');
            obj.image_axes_labeled = axes(obj.image_panel,'Units','normalized',...
                'Position',[labeled_x 0 width axes_height],'Visible','off');
            obj.image_axes_labeled.Toolbar.Visible = 'off';
            
            obj.fig_title = obj.fig_handle.Name;
            
            %%%%%%%%%%%%%%%% ANALYZE IMAGE %%%%%%%%%%%%%%%%%%
            chan_tool = obj.parent.channel_tool;
            im_prop_hand = chan_tool.raw_image_prop_image;
            if filter_index == 1
                % Filter index of 1 refers to a CZI image
                obj.image_data = bfmatlab.bfopen(filepath);
                obj.image_type = 1;
                s = dir(filepath);
                imshow(imread([chan_tool.raw_image_prop_image_dir 'czi_logo.png']),'Parent',im_prop_hand);
                obj.image_info = struct('FileSize',s.bytes,'Filename',filepath,'Format','czi');
                chan_tool.raw_image_type_txt.String = ['Carl Zeiss Image (.' obj.image_info.Format ')'];
                obj.analyzeCZI();
            elseif filter_index == 2
                obj.image_type = 2;
                imshow(imread([chan_tool.raw_image_prop_image_dir 'tiff_logo.jpg']),'Parent',im_prop_hand);
                if iscell(filepath)
                    for i = 1:length(filepath)
                        obj.image_info{i} = imfinfo(filepath{i});
                        obj.image_data{i} = imread(filepath{i});
                    end
                    chan_tool.raw_image_type_txt.String = ['Grayscale Image (.' obj.image_info{1}.Format ')'];
                else
                    obj.image_info = imfinfo(filepath);
                    obj.image_data = imread(filepath);
                    chan_tool.raw_image_type_txt.String = ['Grayscale Image (.' obj.image_info.Format ')'];
                    obj.parent.one_im = 1;
                end
                obj.analyzeGray(filepath);
            end
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % LOAD IMAGES FUNCTIONS %
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = analyzeGray(obj,filepath)
        %ANALYZEGRAY Analyze function for loading a grayscale image.
        % Function takes in grayscale image data, creates a binary mask matching
        % its size, then creates a 'Interfaces.select_channel' object to
        % allow the user to select which grayscale image should correspond
        % to which color channel.
        
            % Extract image data
            obj.image_unedited = obj.image_data;
            
            % Create binary mask
            if obj.parent.one_im
                obj.image_mask_bin_dna = false(size(obj.image_unedited));
                obj.image_mask_bin_labeled = false(size(obj.image_unedited));
            else
                obj.image_mask_bin_dna = false(size(obj.image_unedited{1}));
                obj.image_mask_bin_labeled = false(size(obj.image_unedited{1}));
            end
            % Reset figure pointer to arrow and reinstate pointer callbacks
            obj.fig_handle.Pointer = 'arrow';
            obj.parent.resetMouseMoveFunction;
            if ~iscell(filepath)
               temp_var = filepath;
               filepath = cell(1);
               filepath{1} = temp_var;
            end
            % Create new Interfaces.select_channel object
            channel_select_tool = Interfaces.select_channel(filepath);
            
            % Add event listeners to the new object
            addlistener(channel_select_tool,'ChannelsSelected',...
                @(~,evnt)obj.normalize_load_image(evnt));
            addlistener(channel_select_tool,'Status_Update',@(~,evnt)notify(obj,'Status_Update',evnt));
            
            % Extract channel names from filepath
            for i = 1:length(filepath)
                new_name = regexp(filepath{i},'([^\\/]+)(?!\\/)','tokens');
                if ~isempty(new_name)
                   obj.channel_names{i,1} = new_name{end}{1}; 
                else
                   obj.channel_names{i,1} = filepath{i}; 
                end
            end
            
            uiwait();
            if ~channel_select_tool.exit_code
               delete(obj); 
            end
            
        end
        
        function obj = analyzeCZI(obj)
        %ANALYZECZI Analyze function for loading a CZI image.
        % Function takes in CZI image data, creates a binary mask matching
        % its size, then creates a 'Interfaces.select_channel' object to
        % allow the user to select which CZI image should correspond
        % to which color channel.
        
            % Extract image from data
            obj.image_unedited = obj.image_data{1,1}(:,1);
            if length(obj.image_unedited) < 2
                % One loaded image
                notify(obj,'Status_Update',Events.ActionData(['For '...
                    'CZI analysis, the CZI must have at least two channels.']));
                warndlg(['For CZI analysis, ',...
                        'the CZI must have at least two channels.']);
                    % Reset pointer figure and pointer callback functions
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
                obj.delete();
                return;
            end
            % Create binary image mask
            obj.image_mask_bin_dna = false(size(obj.image_unedited{1}));
            obj.image_mask_bin_labeled = false(size(obj.image_unedited{1}));
            
            % Extract metadata from data
            metadata = obj.image_data{1,2};
              
            % Initialize channel tracking arrays
            channel_keys = cell(size(obj.image_unedited));
            channel_numbers = zeros(length(obj.image_data{1}),1);
                      
            %%%%%%%%%%%%%%%%%%% RETRIEVE CHANNEL NAMES %%%%%%%%%%%%%%%%%%%
            % retrieve all key names
            allKeys = arrayfun(@char, metadata.keySet.toArray, 'UniformOutput', false);
            % retrieve all key values
            allValues = cellfun(@(x) metadata.get(x), allKeys, 'UniformOutput', false);
            
            % Apply known .CZI Hashtable filters to find channel names
            for i = 1:length(obj.image_unedited)
                channel_keys{i,1} = ['Global Information|Image|Channel|Name #' num2str(i)];
            end
            temp_channel_names = cellfun(@(x) metadata.get(x),channel_keys, 'UniformOutput', false);
            
            % Find activated channel numbers
            channel_num_count = 0;
            for ii=1:length(allKeys)
                if contains(allKeys{ii,1},'Global Experiment')...
                        && contains(allKeys{ii,1},'AcquisitionBlock')...            
                        && contains(allKeys{ii,1},'IsActivated')...
                        && contains(allKeys{ii,1},'Track')...
                        && contains(allKeys{ii,1},'Channel')...
                        && ~contains(allKeys{ii,1},'ShadingReferenceTrack')...
                        && ~contains(allKeys{ii,1},'DataGrabberSetup')...
                        && ~contains(allKeys{ii,1},'FocusSetup')
                    
                        %true means that the channel was used
                        if strcmp(allValues{ii,1},'true')
                            %save channel numbers used
                            channel_num_count = channel_num_count + 1;
                            channel_numbers(channel_num_count) = str2double(allKeys{ii,1}(end)); 
                        end
                 end

            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %%%%%%%%%%%%%%%%% RETRIEVE EXPOSURE TIMES %%%%%%%%%%%%%%%%%%%%%
            % Extract channel exposure times and names associated with them
            names_channel_exp = cell([length(temp_channel_names) 1]);
            
            obj.image_info.Width = str2double(metadata.get('Global Information|Image|SizeX #1'));
            obj.image_info.Height =  str2double(metadata.get('Global Information|Image|SizeY #1'));
            obj.image_info.BitDepth =  str2double(metadata.get('Global Information|Image|Channel|ComponentBitCount #1'));

            for ii = 1:length(allKeys)
                if contains(allKeys{ii,1},'Global Experiment|AcquisitionBlock|')...
                   && ~contains(allKeys{ii,1},'IsActivated') ...
                   && ~contains(allKeys{ii,1},'FocusSetup')
                    for jj=1:length(channel_numbers)
                        if contains(allKeys{ii,1},['Channel|DataGrabberSetup|CameraFrameSetup|ExposureTime #' num2str(channel_numbers(jj))])
                            obj.channel_exp{jj,1} = str2double(allValues{ii,1});
                        end
                    end
                end
                
                for jj=1:length(channel_numbers)
                    if contains(allKeys{ii,1},['Track|Channel|Name #' num2str(channel_numbers(jj))])...
                        && ~contains(allKeys{ii,1},'FocusSetup')
                        names_channel_exp{jj,1} = string(allValues{ii,1});
                    end
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%% RE-INDEX EXPOSURE TIMES TO PROPER CHANNELS %%%%%%%%%%%%%
            % Exposure time array and channel names array do not always
            % match; this rearranges the exposure time array to match.
            temp_exp_arr = num2cell(zeros(length(temp_channel_names),1));
            for i = 1:length(temp_channel_names)
               logi = strcmp(string(temp_channel_names{i}),string(names_channel_exp));
               temp_exp_arr{i,1} = obj.channel_exp{logi};
            end
            obj.channel_exp = temp_exp_arr;
           
            obj.channel_names = temp_channel_names;
            % Reset pointer figure and pointer callback functions
            obj.fig_handle.Pointer = 'arrow';
            obj.parent.resetMouseMoveFunction;
            
            % Allow user to select which color they wish to assign to each channel
            channel_select_tool = Interfaces.select_channel(temp_channel_names);
            
            % Add event listeners to new tool
            addlistener(channel_select_tool,'ChannelsSelected',@(~,evnt)obj.normalize_load_image(evnt));
            addlistener(channel_select_tool,'Status_Update',@(~,evnt)notify(obj,'Status_Update',evnt));
            
            uiwait();
            if ~channel_select_tool.exit_code
               delete(obj); 
            end
            
        end
        
        function obj = normalize_load_image(obj,data)
        %NORMALIZE_LOAD_IMAGE Final loading function, implemented after CZI
        %or grayscale color channels have been selected for loading.
        % Function takes in channel selection data and creates a
        % three-channel RGB image based on selection data. It then
        % normalizes and displays that image.
            
            % Extract EventData
            selection = data.newValue;
            
            if selection == -1
               obj.parent.display_menu.Enable = 'off';
               return;
            end
            
            temp_path = obj.filepath;
            temp_names = obj.channel_names;
            
            % Reorder image channels and exposure times based on selection data
            
            % Create channel exposure time arrays
            if ~isempty(obj.channel_exp)
                obj.channel_exp_orig = obj.channel_exp;
            else
                obj.channel_exp_orig = cell(size(obj.channel_names_orig));
                obj.channel_exp = cell(size(obj.channel_names));
            end
            temp_exp = obj.channel_exp;
            
            % If selection is outside bounds for '1', DNA was selected as
            % 'no image'
            if iscell(obj.image_unedited)
                len = length(obj.image_unedited);
            else
                len = 1;
            end
            
            if find(selection==1) > len
                obj.parent.one_im = 1;
                obj.isdna = 0; % This means labeled was the loaded image
            else
                if iscell(obj.image_unedited)
                    image_dna = obj.image_unedited{selection==1};
                    temp_names{1} = obj.channel_names{selection==1};
                    temp_exp{1} = obj.channel_exp{selection==1};
                else
                    image_dna = obj.image_unedited;
                end
            end
            
            % If selection is outside bounds for '2', labeled was selected as
            % 'no image'
            if find(selection==2) > len
                obj.parent.one_im = 1;
                obj.isdna = 1; % this means DNA is the loaded image
            else
                if iscell(obj.image_unedited)
                    image_labeled = obj.image_unedited{selection==2};
                    temp_names{2} = obj.channel_names{selection==2};
                    temp_exp{2} = obj.channel_exp{selection==2};
                else
                    image_labeled = obj.image_unedited;
                end
            end
            obj.channel_names = temp_names;
            obj.channel_exp = temp_exp;
            
            obj.original_data = obj.image_unedited;
            chan_tool = obj.parent.channel_tool;
            if isempty(obj.isdna)
                % If DNA doesn't exist, create both images
                
                obj.image_unedited_dna = image_dna;
                % Normalize DNA image
                I2 = double(obj.image_unedited_dna);
                I2 = I2 - min(I2(:));
                I2 = I2 / max(I2(:));
                I2 = im2uint8(I2);
                obj.image_mask_dna = I2; % current image mask
                obj.image_mask_original_dna = I2; % original image mask
                % Create DNA mask outlines
                obj.image_mask_outlines_dna = uint8(zeros(size(obj.image_unedited_dna)));
                % Display DNA image
                obj.image_handle_dna = imshow(obj.image_mask_dna,'Parent',obj.image_axes_dna);
                obj.image_axes_dna_title.Visible = 'on';
                % Set DNA zoom limits
                obj.zoom_limits_dna = get(obj.image_axes_dna,{'XLim','YLim'});
                obj.zoom_reset_dna = obj.zoom_limits_dna;
                
                obj.image_unedited_labeled = image_labeled;
                % Normalize labeled image
                I2 = double(obj.image_unedited_labeled);
                I2 = I2 - min(I2(:));
                I2 = I2 / max(I2(:));
                I2 = im2uint8(I2);
                obj.image_mask_labeled = I2; % current image mask
                obj.image_mask_original_labeled = I2; % original image mask
                % Create labeled image mask outlines
                obj.image_mask_outlines_labeled = uint8(zeros(size(obj.image_unedited_labeled)));
                % Create and display normalized labeled image
                obj.image_handle_labeled = imshow(obj.image_mask_labeled,'Parent',obj.image_axes_labeled);
                obj.image_axes_labeled_title.Visible = 'on';
                % Record labeled image_axes limits
                obj.zoom_limits_labeled = get(obj.image_axes_labeled,{'XLim','YLim'});
                obj.zoom_reset_labeled = obj.zoom_limits_labeled;
                
                if iscell(obj.filepath)
                   temp_path = obj.filepath{selection==1};
                   chan_tool.raw_image_name.String = obj.channel_names{selection==1};
                   chan_tool.raw_image_bit_depth.String = num2str(obj.image_info{1}.BitDepth);
                   chan_tool.raw_image_dimensions.String = [num2str(obj.image_info{1}.Height) 'x' num2str(obj.image_info{1}.Width) ' pixels'];
                   chan_tool.raw_image_file_size.String = [num2str(obj.image_info{1}.FileSize/1024/1024) 'MB (' num2str(obj.image_info{1}.FileSize) ' bytes)'];           % handle to image file size text
                else
                   [~,fname,ext] = fileparts(temp_path);
                   if strcmp(ext,'.czi')
                    chan_tool.raw_image_name.String = [fname ext];   
                   else
                    chan_tool.raw_image_name.String = obj.channel_names;
                   end
                   chan_tool.raw_image_bit_depth.String = num2str(obj.image_info.BitDepth);
                   chan_tool.raw_image_dimensions.String = [num2str(obj.image_info.Height) 'x' num2str(obj.image_info.Width) ' pixels'];
                   chan_tool.raw_image_file_size.String = [num2str(obj.image_info.FileSize/1024/1024) 'MB (' num2str(obj.image_info.FileSize) ' bytes)'];           % handle to image file size text
                end
                
                chan_tool.raw_image_filepath_txt.String = regexprep(temp_path,' ','');
                chan_tool.raw_image_filepath_txt.Tooltip = temp_path;
            elseif ~obj.isdna
                % DNA was selected as 'No image' so load only labeled
                obj.image_unedited_labeled = image_labeled;
                % Normalize labeled image
                I2 = double(obj.image_unedited_labeled);
                I2 = I2 - min(I2(:));
                I2 = I2 / max(I2(:));
                I2 = im2uint8(I2);
                obj.image_mask_labeled = I2; % current image mask
                obj.image_mask_original_labeled = I2; % original image mask
                % Create labeled image mask outlines
                obj.image_mask_outlines_labeled = uint8(zeros(size(obj.image_unedited_labeled)));
                % Resize axes and title width to full display
                obj.image_axes_labeled.Position(1) = 0;
                obj.image_axes_labeled_title.Position(1) = 0;
                obj.image_axes_labeled.Position(3) = 1;
                obj.image_axes_labeled_title.Position(3) = 1;
                % Create and display normalized labeled image
                obj.image_handle_labeled = imshow(obj.image_mask_labeled,'Parent',obj.image_axes_labeled);
                obj.image_axes_labeled_title.Visible = 'on';
                % Record labeled image_axes limits
                obj.zoom_limits_labeled = get(obj.image_axes_labeled,{'XLim','YLim'});
                obj.zoom_reset_labeled = obj.zoom_limits_labeled;
                
                if iscell(obj.filepath)
                   temp_path = obj.filepath{selection==2};
                   chan_tool.raw_image_name.String = obj.channel_names{selection==2};
                   chan_tool.raw_image_bit_depth.String = num2str(obj.image_info{selection==2}.BitDepth);
                   chan_tool.raw_image_dimensions.String = [num2str(obj.image_info{selection==2}.Height) 'x' num2str(obj.image_info{selection==2}.Width) ' pixels'];
                   chan_tool.raw_image_file_size.String = [num2str(obj.image_info{selection==2}.FileSize/1024/1024) 'MB (' num2str(obj.image_info{selection==2}.FileSize) ' bytes)'];           % handle to image file size text
                else
                   chan_tool.raw_image_name.String = obj.channel_names;
                   chan_tool.raw_image_bit_depth.String = num2str(obj.image_info.BitDepth);
                   chan_tool.raw_image_dimensions.String = [num2str(obj.image_info.Height) 'x' num2str(obj.image_info.Width) ' pixels'];
                   chan_tool.raw_image_file_size.String = [num2str(obj.image_info.FileSize/1024/1024) 'MB (' num2str(obj.image_info.FileSize) ' bytes)'];           % handle to image file size text
                end
                
                chan_tool.raw_image_filepath_txt.String = regexprep(temp_path,' ','');
                chan_tool.raw_image_filepath_txt.Tooltip = temp_path;
            else
                % labeled was selected as 'No Image' so load only DNA
                obj.image_unedited_dna = image_dna;
                % Normalize DNA image
                I2 = double(obj.image_unedited_dna);
                I2 = I2 - min(I2(:));
                I2 = I2 / max(I2(:));
                I2 = im2uint8(I2);
                obj.image_mask_dna = I2; % current image mask
                obj.image_mask_original_dna = I2; % original image mask
                % Create DNA mask outlines
                obj.image_mask_outlines_dna = uint8(zeros(size(obj.image_unedited_dna)));
                % Resize axes and title width to full display
                obj.image_axes_dna.Position(3) = 1;
                obj.image_axes_dna_title.Position(3) = 1;
                % Display DNA image
                obj.image_handle_dna = imshow(obj.image_mask_dna,'Parent',obj.image_axes_dna);
                obj.image_axes_dna_title.Visible = 'on';
                % Set DNA zoom limits
                obj.zoom_limits_dna = get(obj.image_axes_dna,{'XLim','YLim'});
                obj.zoom_reset_dna = obj.zoom_limits_dna;
                
                if iscell(obj.filepath)
                   temp_path = obj.filepath{selection==1};
                   chan_tool.raw_image_name.String = obj.channel_names{selection==1};
                   chan_tool.raw_image_bit_depth.String = num2str(obj.image_info{selection==1}.BitDepth);
                   chan_tool.raw_image_dimensions.String = [num2str(obj.image_info{selection==1}.Height) 'x' num2str(obj.image_info{selection==1}.Width) ' pixels'];
                   chan_tool.raw_image_file_size.String = [num2str(obj.image_info{selection==1}.FileSize/1024/1024) 'MB (' num2str(obj.image_info{selection==1}.FileSize) ' bytes)'];           % handle to image file size text
                else
                   chan_tool.raw_image_name.String = obj.channel_names;
                   chan_tool.raw_image_bit_depth.String = num2str(obj.image_info.BitDepth);
                   chan_tool.raw_image_dimensions.String = [num2str(obj.image_info.Height) 'x' num2str(obj.image_info.Width) ' pixels'];
                   chan_tool.raw_image_file_size.String = [num2str(obj.image_info.FileSize/1024/1024) 'MB (' num2str(obj.image_info.FileSize) ' bytes)'];           % handle to image file size text
                end
                
                chan_tool.raw_image_filepath_txt.String = regexprep(temp_path,' ','');
                chan_tool.raw_image_filepath_txt.Tooltip = temp_path;
            end
            
            % May not be necessary; commented out
%             % Store all channels
%             if iscell(obj.original_data)
%                 I3 = obj.original_data{1};
%                 for i = 2:length(obj.original_data)
%                     I3 = cat(3,I3,obj.original_data{i});
%                 end           
%             else
%                 I3 = obj.original_data;
%             end
%             obj.image_normalized_all = I3;
            
            % Notify parent class that channels have been selected and
            % image loaded
            notify(obj,'ChannelsSelected',Events.ActionData(obj));
            
            if ~isempty(obj.channel_exp) && ~isempty(obj.channel_exp{1})
                notify(obj,'Status_Update',Events.ActionData([temp_path ' and Exposure Times Loaded']))
            else
                notify(obj,'Status_Update',Events.ActionData([temp_path ' Loaded']))
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % PROCEDURE FUNCTIONS %
        %%%%%%%%%%%%%%%%%%%%%%%
        
        function rawImage(obj)
            try
               % Notify user system is busy
               obj.fig_handle.WindowButtonMotionFcn = [];
               obj.fig_handle.WindowButtonDownFcn = [];
               obj.fig_handle.WindowButtonUpFcn = [];
               obj.fig_handle.Pointer = 'watch';

               notify(obj,'Status_Update',Events.ActionData('Displaying raw images...'));

               if isempty(obj.isdna)
                   % Display both original images
                   imshow(obj.image_mask_original_dna,'Parent',obj.image_axes_dna);
                   imshow(obj.image_mask_original_labeled,'Parent',obj.image_axes_labeled);
                   set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                   set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
               else
                  if obj.isdna
                      imshow(obj.image_mask_original_dna,'Parent',obj.image_axes_dna);
                      set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                  else
                      imshow(obj.image_mask_original_labeled,'Parent',obj.image_axes_labeled);
                      set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                  end
               end
               if obj.displayCentroids
                obj.display_centroids(); 
               end
               notify(obj,'Status_Update',Events.ActionData('Display complete.'));
               obj.fig_handle.Pointer = 'arrow';
               obj.parent.resetMouseMoveFunction;

           catch ME
                opts = struct('WindowStyle','modal','Interpreter','tex');
                errordlg(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\newline\newline'...
                    ME.message],'Exception Found',opts);
                warning(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\n\n%s'],getReport(ME));
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
            end
        end
       
        function bckgrndSubtraction(obj,evntData)
            try
                % Notify user system is busy
                obj.fig_handle.WindowButtonMotionFcn = [];
                obj.fig_handle.WindowButtonDownFcn = [];
                obj.fig_handle.WindowButtonUpFcn = [];
                obj.fig_handle.Pointer = 'watch';

                notify(obj,'Status_Update',Events.ActionData('Performing background subtraction...'));

                % Ensure 'dragzoom' is disabled.
                obj.check_zoom();

                % Extract passed channel tool
                chanTool = evntData.newValue; 

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % STEP ONE: BACKGROUND SUBTRACTION %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Check two images were loaded
                if isempty(obj.isdna)
                    background = imopen(obj.image_unedited_dna,strel('disk',chanTool.bckgrnd_panel_dna_slid.Value)); 
                    obj.image_mask_dna = obj.image_unedited_dna-background;

                    dna_image = double(obj.image_mask_dna);
                    dna_image = dna_image - min(dna_image(:));
                    dna_image = dna_image / max(dna_image(:));
                    dna_image = im2uint8(dna_image);

                    obj.image_handle_dna = imshow(dna_image,'Parent',obj.image_axes_dna);
                    set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);

                    background = imopen(obj.image_unedited_labeled,strel('disk',chanTool.bckgrnd_panel_labeled_slid.Value)); 
                    obj.image_mask_labeled = obj.image_unedited_labeled-background;

                    labeled_image = double(obj.image_mask_labeled);
                    labeled_image = labeled_image - min(labeled_image(:));
                    labeled_image = labeled_image / max(labeled_image(:));
                    labeled_image = im2uint8(labeled_image);

                    obj.image_handle_labeled = imshow(labeled_image,'Parent',obj.image_axes_labeled);
                    set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                    if obj.displayCentroids
                        obj.display_centroids(); 
                    end
                else
                    % If not check whether DNA or labeled was loaded
                    if obj.isdna
                        background = imopen(obj.image_unedited_dna,strel('disk',chanTool.bckgrnd_panel_dna_slid.Value)); 
                        obj.image_mask_dna = obj.image_unedited_dna-background;

                        dna_image = double(obj.image_mask_dna);
                        dna_image = dna_image - min(dna_image(:));
                        dna_image = dna_image / max(dna_image(:));
                        dna_image = im2uint8(dna_image);

                        obj.image_handle_dna = imshow(dna_image,'Parent',obj.image_axes_dna);
                        set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                    else
                        background = imopen(obj.image_unedited_labeled,strel('disk',chanTool.bckgrnd_panel_labeled_slid.Value)); 
                        obj.image_mask_labeled = obj.image_unedited_labeled-background;

                        labeled_image = double(obj.image_mask_labeled);
                        labeled_image = labeled_image - min(labeled_image(:));
                        labeled_image = labeled_image / max(labeled_image(:));
                        labeled_image = im2uint8(labeled_image);

                        obj.image_handle_labeled = imshow(labeled_image,'Parent',obj.image_axes_labeled);
                        set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                    end
                end
                
                % If already thresholded, update threshold. Third input
                % indicates not to redisplay binary mask
                if chanTool.tab_enabled(3)
                    obj.manualThreshold(Events.ActionData(chanTool),1);
                end
                notify(obj,'Status_Update',Events.ActionData('Background subtraction complete.'));
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
            catch ME
                opts = struct('WindowStyle','modal','Interpreter','tex');
                errordlg(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\newline\newline'...
                    ME.message],'Exception Found',opts);
                warning(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\n\n%s'],getReport(ME));
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
            end
        end
       
        function manualThreshold(obj,evntData,~)
            try
                % Notify user system is busy
                obj.fig_handle.WindowButtonMotionFcn = [];
                obj.fig_handle.WindowButtonDownFcn = [];
                obj.fig_handle.WindowButtonUpFcn = [];
                obj.fig_handle.Pointer = 'watch';
                
                % Ensure 'dragzoom' is disabled.
                obj.check_zoom();

                % Extract passed channel tool
                chanTool = evntData.newValue; 
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                % STEP TWO: THRESHOLDING %
                %%%%%%%%%%%%%%%%%%%%%%%%%%

                notify(obj,'Status_Update',Events.ActionData('Performing thresholding...'));
                if isempty(obj.isdna)
                    thresh_level_labeled = chanTool.thresh_panel_labeled_slid.Value;
                    thresh_level_dna = chanTool.thresh_panel_dna_slid.Value;

                    % If user set to 0, auto threshold
                    if thresh_level_dna == 0
                       thresh_level_dna = graythresh(obj.image_mask_dna);
                    end

                    if thresh_level_labeled == 0
                       thresh_level_labeled = graythresh(obj.image_mask_labeled);
                    end

                    % Sometimes Otsu's fails at low thresholds; if level is still
                    % 0, set to other. 
                    if thresh_level_dna == 0
                        thresh_level_dna = thresh_level_labeled;
                    end
                    if thresh_level_labeled == 0
                        thresh_level_labeled = thresh_level_dna; 
                    end

                    % If still 0 after this point, set to arbitrary low
                    % value to produce some results
                    if thresh_level_dna == 0
                        thresh_level_dna = 0.01;
                    end
                    if thresh_level_labeled == 0
                        thresh_level_labeled = thresh_level_dna; 
                    end
                    
                    chanTool.thresh_panel_dna_slid.Value = thresh_level_dna;
                    chanTool.thresh_panel_dna_edit.String = num2str(thresh_level_dna);
                    chanTool.thresh_panel_labeled_slid.Value = thresh_level_labeled;
                    chanTool.thresh_panel_labeled_edit.String = num2str(thresh_level_labeled);

                    % Create a temp binary image mask based on manual thresholding
                    % type

                    current_mask_labeled = imbinarize(obj.image_mask_labeled,thresh_level_labeled);
                    current_mask_dna = imbinarize(obj.image_mask_dna,thresh_level_dna);

                    current_mask_labeled = imfill(current_mask_labeled,'holes');
                    current_mask_dna = imfill(current_mask_dna,'holes');

                    % Create temporary copy of binary mask, including new temporary
                    % ROI outlines
                    obj.image_mask_bin_dna = current_mask_dna;
                    obj.image_mask_bin_labeled = current_mask_labeled;

                    if nargin == 2
                        imshow(obj.image_mask_bin_dna,'Parent',obj.image_axes_dna);
                        imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled);
                        set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                        set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                    end
                    % Now that a mask exists, turn on centroid display
                    temp_centr_disp = findobj('Tag','Display Centroids');
                    temp_centr_disp.Enable = 'on';
                    temp_save_ctr = findobj('Tag','Save Centroids');
                    temp_save_ctr.Enable = 'on';
                    
                    % Call min max with 3 arguments to update stats and final
                    % mask but not display new mask
                    obj.min_max_changed(Events.ActionData(chanTool),1);
                    
                    if obj.displayCentroids
                        obj.display_centroids(); 
                    end
                else
                   if obj.isdna
                        thresh_level_dna = chanTool.thresh_panel_dna_slid.Value;

                        % If user set to 0, auto threshold
                        if thresh_level_dna == 0
                           thresh_level_dna = graythresh(obj.image_mask_dna);
                        end

                        % If still 0, set to small number
                        if thresh_level_dna == 0
                           thresh_level_dna = 0.01;
                        end
                        
                        chanTool.thresh_panel_dna_slid.Value = thresh_level_dna;
                        chanTool.thresh_panel_dna_edit.String = num2str(thresh_level_dna);
                        
                        % Create a temp binary image mask based on manual thresholding
                        % type
                        current_mask_dna = imbinarize(obj.image_mask_dna,thresh_level_dna);
                        current_mask_dna = imfill(current_mask_dna,'holes');

                        % Create temporary copy of binary mask, including new temporary
                        % ROI outlines
                        obj.image_mask_bin_dna = current_mask_dna;

                        imshow(obj.image_mask_bin_dna,'Parent',obj.image_axes_dna);
                        set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                    
                   else
                        thresh_level_labeled = chanTool.thresh_panel_labeled_slid.Value;
                        
                        % If user set to 0, auto threshold
                        if thresh_level_labeled == 0
                           thresh_level_labeled = graythresh(obj.image_mask_labeled);
                        end

                        
                        % If still 0, set to small number
                        if thresh_level_labeled == 0
                           thresh_level_labeled = 0.01;
                        end
                        
                        chanTool.thresh_panel_labeled_slid.Value = thresh_level_labeled;
                        chanTool.thresh_panel_labeled_edit.String = num2str(thresh_level_labeled);

                        % Create a temp binary image mask based on manual thresholding
                        % type

                        current_mask_labeled = imbinarize(obj.image_mask_labeled,thresh_level_labeled);
                        current_mask_labeled = imfill(current_mask_labeled,'holes');
                        
                        % Create temporary copy of binary mask, including new temporary
                        % ROI outlines
                        obj.image_mask_bin_labeled = current_mask_labeled;

                        imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled);
                        set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);

                   end
                    % Call min max with 3 arguments to update stats and final
                    % mask but not display new mask
                    obj.min_max_changed(Events.ActionData(chanTool),1);
                end
                
                % Not necessary to update histograms here as that happens
                % in min_max changed automatically
                
                % Enable Save Data now that a threshold exists
                temp_save_roi = findobj('Tag','Save ROI');
                temp_save_roi.Enable = 'on';
                
                % Notify user that thresholding is complete
                notify(obj,'Status_Update',Events.ActionData('Thresholding complete.'));
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
            catch ME
                opts = struct('WindowStyle','modal','Interpreter','tex');
                errordlg(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\newline\newline'...
                    ME.message],'Exception Found',opts);
                warning(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\n\n%s'],getReport(ME));
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
            end
        end
        
        function alignment(obj,evntData)
            try
               % Notify user system is busy
               obj.fig_handle.WindowButtonMotionFcn = [];
               obj.fig_handle.WindowButtonDownFcn = [];
               obj.fig_handle.WindowButtonUpFcn = [];
               obj.fig_handle.Pointer = 'watch';
               pause(0.1);
               % Ensure 'dragzoom' is disabled.
               obj.check_zoom();

               % Extract passed channel tool
               chanTool = evntData.newValue; 

               % No need to check for single images; if activated, there
               % must be two
               initial_radius = str2double(chanTool.align_panel_edit.String);

               % Set reference image to DNA and moving image to labeled
               notify(obj,'Status_Update',Events.ActionData('Beginning alignment...'));
               fixed_ref = double(obj.image_mask_bin_dna);
               moving_im = double(obj.image_mask_bin_labeled);
               
               % Set imregister configuration settings
               notify(obj,'Status_Update',Events.ActionData('Setting image registration configuration options...'));
                
               % Specify 'monomodal' for similar brightness and contrast
               [optimizer,metric] = imregconfig('monomodal');

               % Optimizer props: what to let user edit?
               % GradientMagnitudeTolerance: should be small; indicates the
               % smallest gradient between pixels allowed
               % MinimumStepLength: minimum step size; smaller = longer
               % =more accurate
               % MaximumStepLength: intial step size and max; step size
               % decreases as program runs
               % MaximumIterations: max num of optimizer iterations
               % RelaxationFactor: how much to reduce step by, between 0
               % and 1. Increase if metric is noisy

               optimizer.MaximumStepLength = initial_radius;

               % Metric props: none

               % Register image
               notify(obj,'Status_Update',Events.ActionData('Aligning LABELED to DNA image...'));
               
               tform = imregtform(moving_im,fixed_ref,'translation',optimizer,metric);
               x_shift = tform.T(3,1); % translation along the x-axis
               y_shift = tform.T(3,2); % translation along the y-axis
               
               chanTool.align_panel_y.String = num2str(y_shift);
               chanTool.align_panel_x.String = num2str(x_shift);
               % Transform binary mask, raw image, and BS image
               obj.image_mask_bin_labeled = logical(imwarp(moving_im,tform));
               obj.image_mask_original_labeled = imwarp(obj.image_mask_original_labeled,tform);
               obj.image_mask_labeled = imwarp(obj.image_mask_labeled,tform);
               
               % Display aligned binary labeled
               imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled);
               
               % Provide user with details of shift
               notify(obj,'Status_Update',Events.ActionData('Alignment complete.'));
               set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
               set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
               if obj.displayCentroids
                obj.display_centroids(); 
               end
               obj.fig_handle.Pointer = 'arrow';
               obj.parent.resetMouseMoveFunction;
           catch ME
                opts = struct('WindowStyle','modal','Interpreter','tex');
                errordlg(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\newline\newline'...
                    ME.message],'Exception Found',opts);
                warning(['Unhandled exception caught. Please report this error '...
                    'to the current point-of-contact identified in the User '...
                    'Manual. The MATLAB description for this error is as follows:\n\n%s'],getReport(ME));
                obj.fig_handle.Pointer = 'arrow';
                obj.parent.resetMouseMoveFunction;
            end
        end
        
        function min_max_changed(obj,evntData,~)
           try
               % Notify user system is busy
               obj.fig_handle.WindowButtonMotionFcn = [];
               obj.fig_handle.WindowButtonDownFcn = [];
               obj.fig_handle.WindowButtonUpFcn = [];
               obj.fig_handle.Pointer = 'watch';

               % Ensure 'dragzoom' is disabled.
               obj.check_zoom();

               % Extract passed channel tool
               chanTool = evntData.newValue; 
               
                % Pixel stats = area
                % Micron stats = major axis length

               if isempty(obj.isdna)
                   dna_range = [str2double(chanTool.min_pixel_edit_dna.String) str2double(chanTool.max_pixel_edit_dna.String)];
                   labeled_range = [str2double(chanTool.min_pixel_edit_labeled.String) str2double(chanTool.max_pixel_edit_labeled.String)];
                   obj.final_image_mask_bin_dna = bwareafilt(obj.image_mask_bin_dna,dna_range,4);
                   obj.final_image_mask_bin_labeled = bwareafilt(obj.image_mask_bin_labeled,labeled_range,4);

                   obj.region_stats_dna = regionprops('table',obj.final_image_mask_bin_dna,'Area','Centroid','MajorAxisLength');
                   [cell_num_dna,~] = size(obj.region_stats_dna);

                   obj.region_stats_labeled = regionprops('table',obj.final_image_mask_bin_labeled,'Area','Centroid','MajorAxisLength');
                   [cell_num_labeled,~] = size(obj.region_stats_labeled);

                   areas_dna = obj.region_stats_dna.Area;
                   areas_labeled = obj.region_stats_labeled.Area;
                   chanTool.cell_dna.String = num2str(cell_num_dna);                
                   chanTool.median_pixel_dna.String = num2str(median(areas_dna));   
                   chanTool.mean_pixel_dna.String = num2str(mean(areas_dna));         
                   chanTool.max_pixel_dna.String = num2str(max(areas_dna));         
                   chanTool.min_pixel_dna.String = num2str(min(areas_dna));            

                   chanTool.cell_labeled.String = num2str(cell_num_labeled);                
                   chanTool.median_pixel_labeled.String = num2str(median(areas_labeled));   
                   chanTool.mean_pixel_labeled.String = num2str(mean(areas_labeled));         
                   chanTool.max_pixel_labeled.String = num2str(max(areas_labeled));         
                   chanTool.min_pixel_labeled.String = num2str(min(areas_labeled));
                   
                   if nargin == 2
                       imshow(obj.final_image_mask_bin_dna,'Parent',obj.image_axes_dna);
                       imshow(obj.final_image_mask_bin_labeled,'Parent',obj.image_axes_labeled);
                       set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                       set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                   end
                   if obj.displayCentroids
                    obj.display_centroids(); 
                   end
               else
                  if obj.isdna
                       dna_range = [str2double(chanTool.min_pixel_edit_dna.String) str2double(chanTool.max_pixel_edit_dna.String)];
                       obj.final_image_mask_bin_dna = bwareafilt(obj.image_mask_bin_dna,dna_range,4);
                       
                       obj.region_stats_dna = regionprops('table',obj.final_image_mask_bin_dna,'Area','Centroid','MajorAxisLength');
                       [cell_num_dna,~] = size(obj.region_stats_dna);

                       areas_dna = obj.region_stats_dna.Area;
                       
                       chanTool.cell_dna.String = num2str(cell_num_dna);                
                       chanTool.median_pixel_dna.String = num2str(median(areas_dna));   
                       chanTool.mean_pixel_dna.String = num2str(mean(areas_dna));         
                       chanTool.max_pixel_dna.String = num2str(max(areas_dna));         
                       chanTool.min_pixel_dna.String = num2str(min(areas_dna));            
                       if nargin == 2
                           imshow(obj.final_image_mask_bin_dna,'Parent',obj.image_axes_dna);
                           set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                       end

                  else
                       labeled_range = [str2double(chanTool.min_pixel_edit_labeled.String) str2double(chanTool.max_pixel_edit_labeled.String)];
                       obj.final_image_mask_bin_labeled = bwareafilt(obj.image_mask_bin_labeled,labeled_range,4);

                       obj.region_stats_labeled = regionprops('table',obj.final_image_mask_bin_labeled,'Area','Centroid', ...
                           'MajorAxisLength');
                       [cell_num_labeled,~] = size(obj.region_stats_labeled);

                       areas_labeled = obj.region_stats_labeled.Area;
                       
                       chanTool.cell_labeled.String = num2str(cell_num_labeled);                
                       chanTool.median_pixel_labeled.String = num2str(median(areas_labeled));   
                       chanTool.mean_pixel_labeled.String = num2str(mean(areas_labeled));         
                       chanTool.max_pixel_labeled.String = num2str(max(areas_labeled));         
                       chanTool.min_pixel_labeled.String = num2str(min(areas_labeled));
                        if nargin == 2
                           imshow(obj.final_image_mask_bin_labeled,'Parent',obj.image_axes_labeled);
                           set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                        end
                  end
               end
               chanTool.conv_changed(chanTool.conv_factor);
               obj.update_histograms(chanTool);
               obj.fig_handle.Pointer = 'arrow';
               obj.parent.resetMouseMoveFunction;
           catch ME
               opts = struct('WindowStyle','modal','Interpreter','tex');
               errordlg(['Unhandled exception caught. Please report this error '...
                   'to the current point-of-contact identified in the User '...
                   'Manual. The MATLAB description for this error is as follows:\newline\newline'...
                   ME.message],'Exception Found',opts);
               warning(['Unhandled exception caught. Please report this error '...
                   'to the current point-of-contact identified in the User '...
                   'Manual. The MATLAB description for this error is as follows:\n\n%s'],getReport(ME));
               obj.fig_handle.Pointer = 'arrow';
               obj.parent.resetMouseMoveFunction;
           end
        end
       
        function selection_changed(obj)
            try
               obj.check_zoom();
               src = obj.parent.process_tab_grp;
               
               if strcmp(src.SelectedTab.Tag,'RawImage')
                   obj.rawImage();
               elseif isempty(obj.isdna)
                    if strcmp(src.SelectedTab.Tag,'BackgroundSubtraction')
                        dna_image = double(obj.image_mask_dna);
                        dna_image = dna_image - min(dna_image(:));
                        dna_image = dna_image / max(dna_image(:));
                        dna_image = im2uint8(dna_image);
                        obj.image_handle_dna = imshow(dna_image,'Parent',obj.image_axes_dna);
                        
                        labeled_image = double(obj.image_mask_labeled);
                        labeled_image = labeled_image - min(labeled_image(:));
                        labeled_image = labeled_image / max(labeled_image(:));
                        labeled_image = im2uint8(labeled_image);
                        obj.image_handle_labeled = imshow(labeled_image,'Parent',obj.image_axes_labeled);
                        
                    elseif strcmp(src.SelectedTab.Tag,'ThresholdViruses')
                        imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled)
                        imshow(obj.image_mask_bin_dna,'Parent',obj.image_axes_dna)
                    elseif strcmp(src.SelectedTab.Tag,'AlignImages')
                        imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled)
                        imshow(obj.image_mask_bin_dna,'Parent',obj.image_axes_dna)
                    else
                        imshow(obj.final_image_mask_bin_labeled,'Parent',obj.image_axes_labeled)
                        imshow(obj.final_image_mask_bin_dna,'Parent',obj.image_axes_dna)
                    end
                    set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                    set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
               else
                   if obj.isdna
                        if strcmp(src.SelectedTab.Tag,'BackgroundSubtraction')
                            dna_image = double(obj.image_mask_dna);
                            dna_image = dna_image - min(dna_image(:));
                            dna_image = dna_image / max(dna_image(:));
                            dna_image = im2uint8(dna_image);
                            obj.image_handle_dna = imshow(dna_image,'Parent',obj.image_axes_dna);
                        elseif strcmp(src.SelectedTab.Tag,'ThresholdViruses')
                            imshow(obj.image_mask_bin_dna,'Parent',obj.image_axes_dna)
                        elseif strcmp(src.SelectedTab.Tag,'AlignImages')
                            imshow(obj.image_mask_bin_dna,'Parent',obj.image_axes_dna)
                        else
                            imshow(obj.final_image_mask_bin_dna,'Parent',obj.image_axes_dna)
                        end
                        set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
                   else
                        if strcmp(src.SelectedTab.Tag,'BackgroundSubtraction')
                            labeled_image = double(obj.image_mask_labeled);
                            labeled_image = labeled_image - min(labeled_image(:));
                            labeled_image = labeled_image / max(labeled_image(:));
                            labeled_image = im2uint8(labeled_image);
                            obj.image_handle_labeled = imshow(labeled_image,'Parent',obj.image_axes_labeled);
                        elseif strcmp(src.SelectedTab.Tag,'ThresholdViruses')
                            imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled)
                        elseif strcmp(src.SelectedTab.Tag,'AlignImages')
                            imshow(obj.image_mask_bin_labeled,'Parent',obj.image_axes_labeled)
                        else
                            imshow(obj.final_image_mask_bin_labeled,'Parent',obj.image_axes_labeled)
                        end
                        set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
                   end
               end
               if obj.displayCentroids
                  obj.display_centroids(); 
               end
            catch ME
               opts = struct('WindowStyle','modal','Interpreter','tex');
               errordlg(['Unhandled exception caught. Please report this error '...
                   'to the current point-of-contact identified in the User '...
                   'Manual. The MATLAB description for this error is as follows:\newline\newline'...
                   ME.message],'Exception Found',opts);
               warning(['Unhandled exception caught. Please report this error '...
                   'to the current point-of-contact identified in the User '...
                   'Manual. The MATLAB description for this error is as follows:\n\n%s'],getReport(ME));
               obj.fig_handle.Pointer = 'arrow';
               obj.parent.resetMouseMoveFunction;
           end
        end
        
        function update_histograms(obj,chanTool)
            if isempty(obj.final_image_mask_bin_dna) && isempty(obj.final_image_mask_bin_labeled)
                return;
            end
            
            if isempty(obj.isdna)
                % Extract raw region data, applying DNA mask to both images
                dna_stats = regionprops('table',obj.final_image_mask_bin_dna,obj.image_unedited_dna,'majoraxislength','maxintensity','Area');
                labeled_stats = regionprops('table',obj.final_image_mask_bin_dna,obj.image_unedited_labeled,'majoraxislength','maxintensity','Area');
                
                % Extract edited region data
                dna_bs_stats = regionprops('table',obj.final_image_mask_bin_dna,obj.image_mask_dna,'majoraxislength','maxintensity','Area');
                labeled_bs_stats = regionprops('table',obj.final_image_mask_bin_dna,obj.image_mask_labeled,'majoraxislength','maxintensity','Area');
                
                lab_dna_ratio = double(labeled_stats.MaxIntensity)./double(dna_stats.MaxIntensity);
                lab_dna_bs_ratio = double(labeled_bs_stats.MaxIntensity)./double(dna_bs_stats.MaxIntensity);
                
                % Plot labeled:DNA Ratio histogram data
                chanTool.lab_dna_histogram.Data = lab_dna_ratio;
                numBins = str2double(chanTool.lab_dna_ratio_bin_edit.String);
                if isnan(numBins) || numBins <= 0
                   numBins = 20; 
                   chanTool.lab_dna_ratio_bin_edit.String = '20';
                end
                chanTool.lab_dna_histogram.NumBins = numBins;
                set(chanTool.lab_dna_hist,'XLim',...
                    [str2double(chanTool.lab_dna_ratio_min_edit.String),...
                    str2double(chanTool.lab_dna_ratio_max_edit.String)]);
                chanTool.lab_dna_hist.Title.String = 'LABELED:DNA Ratio';
                chanTool.lab_dna_ratio_median.String = num2str(median(lab_dna_ratio));      
                chanTool.lab_dna_ratio_mean.String = num2str(mean(lab_dna_ratio));      
                
                % Plot labeled:DNA BS histogram data
                chanTool.lab_dna_bs_histogram.Data = lab_dna_bs_ratio;
                numBins = str2double(chanTool.lab_dna_bs_ratio_bin_edit.String);
                if isnan(numBins) || numBins <= 0
                   numBins = 20; 
                   chanTool.lab_dna_bs_ratio_bin_edit.String = '20';
                end
                chanTool.lab_dna_bs_histogram.NumBins = numBins;
                set(chanTool.lab_dna_bs_hist,'XLim',...
                    [str2double(chanTool.lab_dna_bs_ratio_min_edit.String),...
                    str2double(chanTool.lab_dna_bs_ratio_max_edit.String)]);
                chanTool.lab_dna_bs_hist.Title.String = 'LABELED:DNA Ratio Background Subtracted';
                chanTool.lab_dna_bs_ratio_median.String = num2str(median(lab_dna_bs_ratio));      
                chanTool.lab_dna_bs_ratio_mean.String = num2str(mean(lab_dna_bs_ratio));      
                
                % Grab DNA size histogram data
                size_stats = dna_stats.MajorAxisLength;
                area_stats = dna_stats.Area;
            else
                % Only one image; no ratios, just size
                if obj.isdna
                    dna_stats = regionprops('table',obj.final_image_mask_bin_dna,obj.image_unedited_dna,'majoraxislength','maxintensity','Area');
                    dna_bs_stats = regionprops('table',obj.final_image_mask_bin_dna,obj.image_mask_dna,'majoraxislength','maxintensity','Area');
                    
                    fluor_intensity = double(dna_stats.MaxIntensity);
                    fluor_intensity_bs = double(dna_bs_stats.MaxIntensity);
                    size_stats = dna_stats.MajorAxisLength;
                    area_stats = dna_stats.Area;
                else
                    labeled_stats = regionprops('table',obj.final_image_mask_bin_labeled,obj.image_unedited_labeled,'majoraxislength','maxintensity','Area');
                    labeled_bs_stats = regionprops('table',obj.final_image_mask_bin_labeled,obj.image_mask_labeled,'majoraxislength','maxintensity','Area');
                    
                    fluor_intensity = double(labeled_stats.MaxIntensity);
                    fluor_intensity_bs = double(labeled_bs_stats.MaxIntensity);
                    size_stats = labeled_stats.MajorAxisLength;
                    area_stats = labeled_stats.Area;
                end
                
                

                % Plot Fluorescence intensity histogram data
                chanTool.lab_dna_histogram.Data = fluor_intensity;
                numBins = str2double(chanTool.lab_dna_ratio_bin_edit.String);
                if isnan(numBins) || numBins <= 0
                   numBins = 20; 
                   chanTool.lab_dna_ratio_bin_edit.String = '20';
                end
                chanTool.lab_dna_histogram.NumBins = numBins;
                set(chanTool.lab_dna_hist,'XLim',...
                    [str2double(chanTool.lab_dna_ratio_min_edit.String),...
                    str2double(chanTool.lab_dna_ratio_max_edit.String)]);
                
                chanTool.lab_dna_ratio_median.String = num2str(median(fluor_intensity));      
                chanTool.lab_dna_ratio_mean.String = num2str(mean(fluor_intensity));      
                chanTool.lab_dna_hist.Title.String = 'Fluorescence Intensity';
                
                % Plot Fluorescence intensity BS histogram data
                chanTool.lab_dna_bs_histogram.Data = fluor_intensity_bs;
                numBins = str2double(chanTool.lab_dna_bs_ratio_bin_edit.String);
                if isnan(numBins) || numBins <= 0
                   numBins = 20; 
                   chanTool.lab_dna_bs_ratio_bin_edit.String = '20';
                end
                chanTool.lab_dna_bs_histogram.NumBins = numBins;
                set(chanTool.lab_dna_bs_hist,'XLim',...
                    [str2double(chanTool.lab_dna_bs_ratio_min_edit.String),...
                    str2double(chanTool.lab_dna_bs_ratio_max_edit.String)]);
                chanTool.lab_dna_bs_hist.Title.String = 'Fluorescence Intensity BS';
                chanTool.lab_dna_bs_ratio_median.String = num2str(median(fluor_intensity_bs));      
                chanTool.lab_dna_bs_ratio_mean.String = num2str(mean(fluor_intensity_bs));      
                
            end
            
            if chanTool.unit_disp.Value == 2
                % Unit selection was micrometers; if conv_factor not empty,
                % use it to convert data
                % Micrometers displays major axis length
                % Pixels displays area
                if ~isempty(chanTool.conv_factor.String)
                    % Direct conversion from pixels to micrometers
                    size_stats = size_stats*str2double(chanTool.conv_factor.String);
                    chanTool.sz_distr_hist.Title.String = 'Major Axis Length (um)';
                    chanTool.sz_distr_histogram.Data = size_stats;
                else
                    chanTool.unit_disp.Value = 1;
                    chanTool.sz_distr_hist.Title.String = 'Area (pixels^2)';
                    chanTool.sz_distr_histogram.Data = area_stats;
                end
            else
                chanTool.sz_distr_hist.Title.String = 'Area (pixels^2)';
                chanTool.sz_distr_histogram.Data = area_stats;
            end
            
            %chanTool.sz_distr_histogram.Data = size_stats;
            % Finalize size histogram
            numBins = str2double(chanTool.size_bin_edit.String);
            if isnan(numBins) || numBins <= 0
               numBins = 20; 
               chanTool.size_bin_edit.String = '20';
            end
            chanTool.sz_distr_histogram.NumBins = numBins;
            set(chanTool.sz_distr_hist,'XLim',...
                    [str2double(chanTool.size_min_edit.String),...
                    str2double(chanTool.size_max_edit.String)]);
                
            chanTool.size_median.String = num2str(median(chanTool.sz_distr_histogram.Data));      
            chanTool.size_mean.String = num2str(mean(chanTool.sz_distr_histogram.Data));    
        end
        
        %%%%%%%%%%%%%%%%%%
        % MENU FUNCTIONS %
        %%%%%%%%%%%%%%%%%%
        
        function display_centroids(obj,src)
            if nargin == 2
                % Menu option selected; display or remove
                switch src.Checked
                    case 'off'
                        obj.displayCentroids = 1;
                        src.Checked = 'on';
                    case 'on'
                        obj.displayCentroids = 0;
                        src.Checked = 'off';
                        obj.selection_changed();
                        return;
                end
            end
            notify(obj,'Status_Update',Events.ActionData('Drawing Centroids...'))
            % Either called with nargin == 1 or centroids turned on;
            % display centroids
            
            % Get centroid data of DNA; use most current mask
            if isempty(obj.final_image_mask_bin_dna)
                centroid_data = table2array(regionprops('table',obj.image_mask_bin_dna,'Centroid'));
            else
                centroid_data = table2array(regionprops('table',obj.final_image_mask_bin_dna,'Centroid'));
            end
            
            if isempty(centroid_data)
                notify(obj,'Status_Update',Events.ActionData('No centroids to display.'))
            else
                % Must be two images to be activated
                hold(obj.image_axes_dna,'on')
                hold(obj.image_axes_labeled,'on')
                plot(obj.image_axes_dna,centroid_data(:,1),centroid_data(:,2),'ro')
                plot(obj.image_axes_labeled,centroid_data(:,1),centroid_data(:,2),'ro')
                hold(obj.image_axes_dna,'off')
                hold(obj.image_axes_labeled,'off')
                notify(obj,'Status_Update',Events.ActionData('Centroids displayed.'))
            end
        end
        
        %%%%%%%%%%%%%%%%%%
        % ZOOM FUNCTIONS %
        %%%%%%%%%%%%%%%%%%
        
        function enable_zoom(obj,src,status)
        %ENABLE_ZOOM Turns on or off 'dragzoom' functionality for image
        %axes.
        % This function expects to be called only by the uimenu option
        % 'Zoom'. It can be called either with two or three input
        % arguments:
        %
        %        [obj,src] : the function acts as a zoom switch, turning
        %                    off 'dragzoom' if it is on and turning on 'dragzoom' 
        %                    if it is off. 
        % [obj,src,status] : the function sets 'dragzoom' to the value of
        % 'status'. Status must be either 'on', 'On', 'off' , or 'Off'.
        %
        % DRAGZOOM function from https://www.mathworks.com/matlabcentral/fileexchange/29276-dragzoom-drag-and-zoom-tool
        % IMPORTANT DRAGZOOM NOTE: dragzoom functionality may be limited as
        % the function expects the figure to be in units of 'Pixels' rather
        % than in normalized units. dragzoom was partially edited to
        % workaround this issue, allowing zoom functionality with a mouse
        % scrollwheel, but other issues may arise from this problem.
        
        if isempty(obj.isdna)
            axes_handles = [obj.image_axes_dna;obj.image_axes_labeled];
        elseif obj.isdna
            axes_handles = obj.image_axes_dna;
        else
            axes_handles = obj.image_axes_labeled;
        end
        
            % Check number of input arguments
            if nargin == 2
                % Set dragzoom status to opposite of menu checked state
                if isa(src,'matlab.ui.container.Menu')
                    if strcmp(src.Checked,'on')
                        src.Checked = 'off';
                        Figure.Functions.dragzoom(axes_handles,'off');  
                        obj.fig_handle.Name = obj.fig_title;
                    else
                        src.Checked = 'on';
                        Figure.Functions.dragzoom(axes_handles,'on'); 
                        % If dual zoom is enabled, mimic an 'l' keypress
                        if obj.dual_zoom
                            robot = java.awt.Robot;
                            % If user used accelerator Ctrl+Z to enable
                            % zoom, ctrl+l will be enabled instead of 'l',
                            % so mimic releasing ctrl
                            robot.keyRelease(java.awt.event.KeyEvent.VK_CONTROL);
                            robot.keyPress(java.awt.event.KeyEvent.VK_L);
                            robot.keyRelease(java.awt.event.KeyEvent.VK_L);
                        end
                    end
                else
                   warning('Input source must be a menu item.') 
                end
            else
                % Set dragzoom status to input status
                if strcmp(status,'on') || strcmp(status,'On')
                    src.Checked = status;
                    Figure.Functions.dragzoom(axes_handles,'on');   
                    if obj.dual_zoom
                        robot = java.awt.Robot;
                        robot.keyRelease(java.awt.event.KeyEvent.VK_CONTROL);
                        robot.keyPress(java.awt.event.KeyEvent.VK_L);
                        robot.keyRelease(java.awt.event.KeyEvent.VK_L);
                    end
                elseif strcmp(status,'off') || strcmp(status,'Off')
                    src.Checked = status;
                    Figure.Functions.dragzoom(axes_handles,'off'); 
                    obj.fig_handle.Name = obj.fig_title;
                else
                    error('Status must be either ''on'', ''On'', ''off'', or ''Off''.');
                end
            end
        end
        
        function check_zoom(obj)
        %CHECK_ZOOM Disables dragzoom.
        % This function disables dragzoom, regardless of the current object
        % state.
        
            % Find and grab the handle to the Zoom menu object
            zoom_menu = findobj('Tag','Zoom Menu');
            
            % Return if Zoom does not exist; otherwise, disable dragzoom
            % and set new zoom limits
            if isempty(zoom_menu)
                return;
            else
               obj.zoom_limits_dna = get(obj.image_axes_dna,{'XLim','YLim'});
               obj.zoom_limits_labeled = get(obj.image_axes_labeled,{'XLim','YLim'});
               obj.enable_zoom(zoom_menu,'off');
               set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_limits_dna);
               set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_limits_labeled);
            end
        end
        
        function reset_zoom(obj)
        %RESET_ZOOM Callback function for 'Default View' menu option in the 
        %parent image_analysis class. Sets image_axes to default view.
        % This function resets the image axes limits to its default size. 
           set(obj.image_axes_dna,{'XLim','YLim'},obj.zoom_reset_dna); 
           set(obj.image_axes_labeled,{'XLim','YLim'},obj.zoom_reset_labeled); 
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DELETE/REFRESH ANALYSIS %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function delete(obj)
            if isvalid(obj.image_axes_dna) && isvalid(obj.image_axes_labeled)
                obj.check_zoom();
                obj.reset_zoom();
                obj.image_axes_labeled_title.Visible = 'off';
                obj.image_axes_dna_title.Visible = 'off';
                cla(obj.image_axes_dna);
                cla(obj.image_axes_labeled);
            end
            if isprop(obj,'AutoListeners__')
                for i = 1:numel(obj.AutoListeners__)
                    delete(obj.AutoListeners__{i}); %#ok<MCNPN> AutoListeners is an undocumented property
                end
            end
            
            delete(obj);
        end
        
    end
    
end

