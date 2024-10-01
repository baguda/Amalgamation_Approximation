classdef WavefunctionModule < Module
    properties
        wavefunctionData        % Stores the actual wavefunction data (numerical)
        boundaryConditions      % Boundary conditions for the wavefunction
        approximations          % Approximations used in constructing the wavefunction
        dimension               % Dimensionality of the wavefunction (1D, 2D, 3D)
        wavefunctionType        % Type of wavefunction (e.g., gravity, quantum)
        precision               % Numerical precision (single, double) of the wavefunction
    end
    
    methods
        %% Constructor
        function obj = WavefunctionModule(loadFlag)
            % Call the constructor of the superclass
            obj@Module(loadFlag);
            
            % Set up default wavefunction properties for blank module
            if isempty(obj.wavefunctionData)
                obj.wavefunctionData = [];
                obj.boundaryConditions = [];
                obj.approximations = [];
                obj.dimension = 0;
                obj.wavefunctionType = 'Undefined';
                obj.precision = 'Double';
            end
        end
        
        %% Override loadModule to account for wavefunction-specific properties
        function obj = loadModule(obj)
            % Call superclass method to load shared properties
            obj = loadModule@Module(obj);

            
            % Load wavefunction-specific properties
            [file, path] = uigetfile('*.mat', 'Select a Wavefunction Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.wavefunctionData = loadedData.wavefunctionData;
                obj.boundaryConditions = loadedData.boundaryConditions;
                obj.approximations = loadedData.approximations;
                obj.dimension = loadedData.dimension;
                obj.wavefunctionType = loadedData.wavefunctionType;
                obj.precision = loadedData.precision;
                disp(['Wavefunction module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Override printOverview to include wavefunction-specific properties
        function printOverview(obj)
            % Call superclass method to print shared properties
            printOverview@Module(obj);
            
            % Print wavefunction-specific properties
            disp(['Wavefunction Type: ', obj.wavefunctionType]);
            disp(['Dimension: ', num2str(obj.dimension)]);
            disp(['Precision: ', obj.precision]);
            disp(['Boundary Conditions: ', mat2str(obj.boundaryConditions)]);
            disp(['Approximations: ', mat2str(obj.approximations)]);
        end

        %% Visualize the Wavefunction Data (calls GraphUtility)
        function visualizeWavefunction(obj)
            if isempty(obj.wavefunctionData)
                disp('No wavefunction data to visualize.');
                return;
            end
            % Call the GraphUtility to handle plotting
            GraphUtility.visualizeWavefunction(obj.wavefunctionData, obj.dimension, obj.name);
        end
        
        %% Evaluate Wavefunction at a Point
        function value = evaluateWavefunction(obj, coords)
            % Evaluate the wavefunction at specific coordinates
            if isempty(obj.wavefunctionData)
                error('Wavefunction data is not available.');
            end
            
            switch obj.dimension
                case 1
                    if coords(1) > length(obj.wavefunctionData)
                        error('Coordinates exceed the 1D wavefunction bounds.');
                    end
                    value = obj.wavefunctionData(coords(1));
                case 2
                    if any(coords > size(obj.wavefunctionData))
                        error('Coordinates exceed the 2D wavefunction bounds.');
                    end
                    value = obj.wavefunctionData(coords(1), coords(2));
                case 3
                    if any(coords > size(obj.wavefunctionData))
                        error('Coordinates exceed the 3D wavefunction bounds.');
                    end
                    value = obj.wavefunctionData(coords(1), coords(2), coords(3));
                otherwise
                    error('Unsupported wavefunction dimensionality.');
            end
        end
    end
end
