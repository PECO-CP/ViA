classdef file_select_display < handle
%FILE_SELECT_DISPLAY Supplementary GUI subclass; creates edit text box and
%uicontrol pushbutton to allow for simple file or directory user selection.
%
%      FILE_SELECT_DISPLAY creates a new FILE_SELECT_DISPLAY class object 
%      instance within the parent uipanel or figure object.
%
%      H = FILE_SELECT_DISPLAY returns the handle to a new FILE_SELECT_DISPLAY tool, 
%      displaying GUI interfaces and handling input values relevant to 
%      defining file or directory selection.
% 
%      This class was constructed to operate solely with the properties and 
%      objects of parent graphic objects uipanel or figure.
% 
%      This class requires 1-2 input arguments:
%
%       [parent] : With only one input argument, the class assumes it was
%                  given the handle to a figure or uipanel object and
%                  instantiates the class to open one.
%   [parent,dir] : With two input arguments, the first is assumed to be the
%                  handle to a figure or uipanel object while the second
%                  indicates whether or not the user wants the tool to
%                  select a file or a directory. 'dir' = 1 indicates a
%                  directory, while 'dir' = anything else indicates file
%                  selection.
%                       
%      The important passable properties available in MATLAB's uigetdir and
%      uigetfile are settable properties within this object, such as
%      uigetfile's file type filter and the browser's file or directory
%      selection title.
%
%      Position of the object can be edited after object created by
%      changing the 'Position' property with regular MATLAB dot notation.
%      However, currently this property expects normalized units; using
%      other units will result in slight positional discrepancies.

% Last Modified by JONATHAN HOOD v3.0 Sep-2022
    


% ViA Figure package providing graphical support classes for ViA
% interfaces.
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
        % Constant properties
        CONSTANTS = Constants.Graphics();   % set of figure constants
        
        % Class GUI objects
        edit = [];                          % handle to the edit text object
        editString = 'File Select...';      % default edit box string
        browse = [];                        % ellipses browse button
        font_size = 0.5;                    % size of font in edit text box
        ellipse_size = 0.5;                 % size of ellipses browse button
        
        % File selection class values
        browseFilter = {'*.', 'All Files'}; % optional file filtering for browse button
        browseTitle = 'Select File to Open';% optional title for browse dialog
        browseMulti = 'Off';                % default options for dialog multiselect
        browseIndex = 0;                    % default browse dialog filter index
        path = pwd;                         % default directory path
        filepath = [];                      % file path
        file_name = [];                     % file name(s)
        exten = [];                         % file extension
        selectionEventData = 0;             % if file is loaded/directory selected, becomes '1'
        Position = [];                      % object position
    end
    
    events
       SelectionMade    % SelectionMade event, indicating a file or directory has been selected
       Status_Update    % Status_Update event, designed for use in Figure.status_bar object
    end
    
    methods
        function obj = file_select_display(parent,dir)
        %FILE_SELECT_DISPLAY Creates a new file_select_display object.
        % Builds a new file_select_display object and sets callback
        % functions.
            if nargin == 1
                func_hand = @(src,~)obj.loadFile(src);
            else
                if dir == 1
                    func_hand = @(src,~)obj.loadFolder(src);
                    obj.browseTitle = 'Select Folder to Open';
                else
                    func_hand = @(src,~)obj.loadFile(src);
                end
            end
            % Grab constant graphic properties
            figConstants = obj.CONSTANTS;
            X = figConstants.X;
            Y = figConstants.Y;
            width = figConstants.OBJ_WIDTH;
            height = figConstants.OBJ_HEIGHT;
            
            % Create text edit box
            obj.edit = uicontrol(parent,'Style','edit','String',...
                obj.editString,'HorizontalAlignment','Left','Units',...
                'normalized','Position',[X Y width-2*X height],'FontUnits',...
                'normalized','FontSize',obj.font_size,'Callback',func_hand,...
                'Tag','edit');
            newX = obj.edit.Position(1) + obj.edit.Position(3) + X;
            
            % Create browse pushbutton next to text edit box
            obj.browse = uicontrol(parent,'Style','pushbutton','String',...
                '...','Units','normalized','Position',[newX Y 1-newX-X height],...
                'FontUnits','normalized','FontSize',obj.ellipse_size,...
                'Callback',func_hand,'Tag','browse');
            obj.Position = [X Y obj.edit.Position(3)+obj.browse.Position(3) height];
       
        end
           
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % PROPERTY SET FUNCTIONS %
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function set.browseMulti(obj,isMulti)
        %SET.BROWSEMULTI Set class property 'browseMulti' to either 'on' or
        %'off'. 
        % Passed value indicates whether user can select multiple files or
        % not when callback activates uigetfile.
        
           % Check that input is valid and change property value
           if strcmp(isMulti,'on') || strcmp(isMulti,'On') || strcmp(isMulti,'off') || strcmp(isMulti,'Off')
               obj.browseMulti = isMulti;
           else
               error('Passed value must be ''on'',''off'',''On'', or ''Off''.')
           end
        end
        
        function set.editString(obj,string)
        %SET.EDITSTRING Set class property 'editString' to passed value.
        % Passed value changes the text in object edit text box.
        
            % Check that input is a string or character array
            if ~isstring(string) && ~ischar(string)
                error('Input must be a string or character array.');
            end
            
            % Set object properties
            obj.editString = string;
            obj.edit.String = string; %#ok<*MCSUP> all properties accessed within other properties are necessary and defined to avoid internal errors
            
        end
        
        function set.browseFilter(obj,filter)
        %SET.BROWSEFILTER Set class property 'browseFilter' to passed value.
        % Passed value changes the uigetfile file filter.
        
            % Check that input is a cell array
            if ~iscell(filter)
               error('Input filter must be a cell array.') 
            end
            
            % Check that input is an even array
            [~,col] = size(filter);
            if mod(col,2) ~= 0
               error(['Input cell filter must contain an even number of ',...
                   'elements indicating file extension and file extension ',...
                   'description.']) 
            end
            
            % Set object property
            obj.browseFilter = filter;
        end
        
        function set.browseTitle(obj,title)
        %SET.BROWSEFILTER Set class property 'browseTitle' to passed value.
        % Passed value changes the title of the file or directory dialog.
        
            % Check that input is valid
            if ~isstring(title) && ~ischar(title)
               error('Input title must be a string or character array.'); 
            end
            
            % Set object property
            obj.browseTitle = title;
        end
        
        function set.Position(obj,newPos)
        %SET.POSITION Set class property 'Position' to passed value.
        % Passed value changes the position of the entire object.
        
            % Check that input has four values
            if length(newPos) ~= 4
                error('Position array must have four values.');
            end
            
            % Extract positional data
            X = obj.CONSTANTS.X;
            newX = newPos(1);
            newY = newPos(2);
            newWidth = newPos(3);
            newHeight = newPos(4);
            
            % Change object positions
            obj.edit.Position = [newX newY newWidth-2*X newHeight];
            
            newX = obj.edit.Position(1) + obj.edit.Position(3) + X;
            
            obj.browse.Position = [newX newY 1-newX-X newHeight];
            
            obj.Position = newPos;
        end
        
    end
    
    methods(Access = public)
        function obj = clear_prop(obj)
        % CLEAR_PROP Clears properties between file loading if using the
        % same file_select_display object.
        
            obj.filepath = [];                      % file path
            obj.file_name = [];                     % file name(s)
        end
    end
    
    methods(Access = private)
        function obj = loadFile(obj,src)
        %LOADFILE Uicontrol pushbutton callback for loading a file.
        % Functions uses object properties and runs MATLAB's uigetfile
        % command. It then sets object properties path, browseIndex,
        % selectionEventData, filepath, and editString to values pertaining
        % to selected file. Notifies parent object with event
        % 'SelectionMade'.
        if strcmp(src.Tag,'edit')
            if exist(obj.edit.String,'file') == 2 
                [dirpath,filename,ext] = fileparts(obj.edit.String);
                if strcmp(obj.filepath,obj.edit.String)
                   return; 
                end
                obj.exten = ext;
                obj.filepath = obj.edit.String;
                obj.browseIndex = ext;
                obj.path = dirpath;
                if contains(obj.path,'/')
                    obj.path = [obj.path '/']; 
                else
                    obj.path = [obj.path '\']; 
                end
                obj.file_name = filename;
                obj.selectionEventData = 1;
                notify(obj,'SelectionMade')
                return;
            else
                notify(obj,'Status_Update',Events.ActionData(['Invalid filename; reset to: ' obj.filepath]));
                obj.edit.String = obj.filepath; % Set filepath to original if not valid file
                return;
            end
        end
            % Ask user to select file
            if isempty(obj.path)
                [file,dir_path,filterIndex] = Figure.MacFix.uigetfile_with_preview(obj.browseFilter,...
                obj.browseTitle,'',obj.browseMulti);
            else
                [file,dir_path,filterIndex] = Figure.MacFix.uigetfile_with_preview(obj.browseFilter,...
                obj.browseTitle,obj.path,'',obj.browseMulti);
            end
            % Check that a file was selected
            if filterIndex ~= 0
                % Check if multiple files were selected
                if iscell(file)
                   for i = 1:length(file)
                      obj.filepath{i} = [dir_path '/' file{i}]; 
                   end
                   obj.edit.String = dir_path; 
                   
                   % Set object properties
                   [obj.path,obj.file_name,obj.exten] = fileparts(obj.filepath{1});
                else
                    obj.filepath = [dir_path '/' file];
                    obj.edit.String = obj.filepath; 
                    
                    % Set object properties
                    [obj.path,obj.file_name,obj.exten] = fileparts(obj.filepath);
                end
                
                if contains(obj.path,'/')
                    obj.path = [obj.path '/']; 
                else
                    obj.path = [obj.path '\']; 
                end
                
                obj.browseIndex = filterIndex;
                obj.selectionEventData = 1;
                
                % Notify SelectionMade
                notify(obj,'SelectionMade')
            end
        end
        
        function obj = loadFolder(obj,src)
        %LOADFOLDER Uicontrol pushbutton callback for loading a directory.
        % Functions uses object properties and runs MATLAB's uigetdir
        % command. It then sets object properties path, selectionEventData, 
        % and editString to values pertaining to selected directory. 
        % Notifies parent object with event 'SelectionMade'.
            if strcmp(src.Tag,'edit')
                if exist(obj.edit.String,'dir') == 7 
                    [selpath,~] = fileparts(obj.edit.String);
                else
                    notify(obj,'Status_Update',Events.ActionData(['Invalid output directory. Previous valid output directory will be used : ' obj.path]));
                    return;
                end
            else
                % Ask user to select directory
                selpath = uigetdir(obj.path,obj.browseTitle);
            end
            
            % Check that a directory was selected and set object
            % properties.
            if selpath ~= 0
                if contains(selpath,'/')
                    obj.path = [selpath '/']; 
                else
                    obj.path = [selpath '\']; 
                end
                obj.edit.String = obj.path;
                obj.selectionEventData = 1;
                notify(obj,'Status_Update',Events.ActionData(['Output directory changed to: ' obj.path]));
                notify(obj,'SelectionMade')
            end
        end
        
    end
    
    
    
end

