classdef QuantumModule < WavefunctionModule
    properties
        quantumField        % Stores the quantum field, which could be numeric or symbolic
        potentialFunction   % Potential function for the quantum system (numeric or symbolic)
        quantumOperators    % Operators acting on the quantum field (e.g., creation/annihilation)
        particleType        % Type of particle (e.g., fermion, boson)
        particleMass
        charge
        
    end
    
    methods
        %% Constructor
        function obj = QuantumModule(loadFlag)
            % Call the constructor of the WavefunctionModule class
            obj@WavefunctionModule(loadFlag);
            obj.moduleType = 'quantum';  % Set type to 'gravity'
            % Set up default properties specific to QuantumModule
            if isempty(obj.quantumField)
                obj.quantumField = [];  % Placeholder for quantum field
                obj.potentialFunction = [];  % Placeholder for potential function
                obj.quantumOperators = [];  % Placeholder for operators
                obj.particleType = 'Undefined';  % Particle type (fermion, boson, etc.)
            end
        end
        
        %% Override loadModule to account for quantum-specific properties
        function obj = loadModule(obj)
            % Call superclass method to load wavefunction-specific properties
            obj = loadModule@WavefunctionModule(obj);
            
            % Load quantum-specific properties
            [file, path] = uigetfile('*.mat', 'Select a Quantum Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.quantumField = loadedData.quantumField;  % Load quantum field
                obj.potentialFunction = loadedData.potentialFunction;  % Load potential function
                obj.quantumOperators = loadedData.quantumOperators;  % Load quantum operators
                obj.particleType = loadedData.particleType;  % Load particle type
                disp(['Quantum module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Override printOverview to include quantum-specific properties
       function printOverview(obj)
        % Call superclass method to print shared and wavefunction-specific properties
        printOverview@WavefunctionModule(obj);

        % Print quantum-specific properties
        disp(['Particle Mass: ', num2str(obj.particleMass)]);
        disp(['Charge: ', num2str(obj.charge)]);

        % Check if potentialFunction is a function handle
        if isa(obj.potentialFunction, 'function_handle')
            disp('Potential Function: Defined as a function handle');
        else
            disp(['Potential Function: ', mat2str(obj.potentialFunction)]);
        end

        % Print quantum operators
        if ~isempty(obj.quantumOperators)
            disp(['Quantum Operators: ', strjoin(obj.quantumOperators, ', ')]);
        else
            disp('Quantum Operators: Not defined');
        end

        % Print particle type
        disp(['Particle Type: ', obj.particleType]);
    end

        %% Evaluate Quantum Field at a Point
        function value = evaluateQuantumField(obj, coords)
            % Evaluate the quantum field at specific coordinates
            if isempty(obj.quantumField)
                error('Quantum field data is not available.');
            end
            
            switch obj.dimension
                case 1
                    if coords(1) > length(obj.quantumField)
                        error('Coordinates exceed the 1D quantum field bounds.');
                    end
                    value = obj.quantumField(coords(1));
                case 2
                    if any(coords > size(obj.quantumField))
                        error('Coordinates exceed the 2D quantum field bounds.');
                    end
                    value = obj.quantumField(coords(1), coords(2));
                case 3
                    if any(coords > size(obj.quantumField))
                        error('Coordinates exceed the 3D quantum field bounds.');
                    end
                    value = obj.quantumField(coords(1), coords(2), coords(3));
                otherwise
                    error('Unsupported quantum field dimensionality.');
            end
        end

        %% Visualize Quantum Field (calls GraphUtility)
        function visualizeQuantumField(obj)
            if isempty(obj.quantumField)
                disp('No quantum field to visualize.');
                return;
            end
            % Call GraphUtility to handle the visualization of the quantum field
            GraphUtility.visualizeQuantumField(obj.quantumField, obj.dimension, obj.name);
        end
    end
end
