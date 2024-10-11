classdef Module
    properties
        name                    % Name of the module
        description             % Description of the module
        moduleType              % Type of module ('gravity', 'quantum', 'interaction', 'kernel')
        metadata                % General metadata (struct format)
        creationDate            % Date the module was created or last modified
        units                   % Units associated with the module
        source                  % Source of the module (algorithm, model, reference)
        version                 % Version of the module
        symmetry                % Symmetry properties (applies to both wavefunction and math)
    end
    
    methods
        %% Constructor
        function obj = Module(loadFlag)
            obj.moduleType = 'undefined';  % Default until child classes assign type
            if nargin < 1 || loadFlag == true
                % If no input or loadFlag is true, prompt to load
                fprintf('Do you want to load an existing module? (y/n)\n');
                answer = input('Input: ', 's');
                if strcmpi(answer, 'y')
                    obj = obj.loadModule();  % Load a saved module
                else
                    % Create blank module
                    disp('Creating blank module...');
                    obj = obj.createBlankModule();
                end
            else
                % If loadFlag is false, create a blank module
                disp('Creating blank module...');
                obj = obj.createBlankModule();
            end
        end

        %% Create Blank Module
        function obj = createBlankModule(obj)
            obj.name = 'New Blank Module';
            obj.description = 'Blank module, define properties';
            obj.creationDate = datestr(now);
            obj.units = '';
            obj.source = 'User-defined';
            obj.version = '1.0';
            obj.symmetry = 'None';
            obj.metadata = struct();
        end
        
        %% Save Module
function saveModule(obj)
    % Suggest default filename based on the 'name' property
    if ~isempty(obj.name)
        defaultFileName = [obj.name, '.mat'];
    else
        defaultFileName = 'Module.mat';  % Fallback if name is not defined
    end
    
    % Use uiputfile to prompt the user to save the file, with the default name suggested
    [file, path] = uiputfile('*.mat', 'Save Module As', defaultFileName);
    
    if isequal(file, 0)
        disp('User canceled the save operation.');
    else
        save(fullfile(path, file), '-struct', 'obj');
        disp(['Module saved as: ', fullfile(path, file)]);
    end
end

        
        %% Load Module
        function obj = loadModule(obj)
            [file, path] = uigetfile('*.mat', 'Select a Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.name = loadedData.name;
                obj.description = loadedData.description;
                obj.creationDate = loadedData.creationDate;
                obj.units = loadedData.units;
                obj.source = loadedData.source;
                obj.version = loadedData.version;
                obj.symmetry = loadedData.symmetry;
                obj.metadata = loadedData.metadata;
                disp(['Module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Delete Module
        function deleteModule(obj)
            clear obj;
            disp('Module instance deleted.');
        end
        
        %% Print Overview of the Module
        function printOverview(obj)
            disp(['Module Name: ', obj.name]);
            disp(['Description: ', obj.description]);
            disp(['Creation Date: ', obj.creationDate]);
            disp(['Units: ', obj.units]);
            disp(['Source: ', obj.source]);
            disp(['Version: ', obj.version]);
            disp(['Symmetry: ', obj.symmetry]);
            %disp(['Metadata: ', struct2str(obj.metadata)]);
        end
    end
end
