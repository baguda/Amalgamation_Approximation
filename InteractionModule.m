classdef InteractionModule < MathModule
    properties
        interactionHamiltonian  % Stores the interaction Hamiltonian (symbolic or numeric)
        interactionType         % Type of interaction (e.g., gravitational, quantum field, electroweak)
        couplingConstant        % Coupling constant associated with the interaction
    end
    
    methods
        %% Constructor
        function obj = InteractionModule(loadFlag)
            % Call the constructor of the MathModule class
            obj@MathModule(loadFlag);
            obj.moduleType = 'interaction';  % Set type to 'gravity'
            % Set up default properties specific to InteractionModule
            if isempty(obj.interactionHamiltonian)
                obj.interactionHamiltonian = [];  % Placeholder for Hamiltonian
                obj.interactionType = 'Undefined';  % Type of interaction
                obj.couplingConstant = 1;  % Default coupling constant
            end
        end
        
        %% Override loadModule to account for interaction-specific properties
        function obj = loadModule(obj)
            % Call superclass method to load math-specific properties
            obj = loadModule@MathModule(obj);
            
            % Load interaction-specific properties
            [file, path] = uigetfile('*.mat', 'Select an Interaction Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.interactionHamiltonian = loadedData.interactionHamiltonian;
                obj.interactionType = loadedData.interactionType;
                obj.couplingConstant = loadedData.couplingConstant;
                disp(['Interaction module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Override printOverview to include interaction-specific properties
        function printOverview(obj)
            % Call superclass method to print shared math-specific properties
            printOverview@MathModule(obj);
            
            % Print interaction-specific properties
            disp(['Interaction Hamiltonian: ', char(obj.interactionHamiltonian)]);
            disp(['Interaction Type: ', obj.interactionType]);
            disp(['Coupling Constant: ', num2str(obj.couplingConstant)]);
        end
        
        %% Evaluate Interaction Hamiltonian at given values
        function value = evaluateHamiltonian(obj, variables)
            % Evaluate the interaction Hamiltonian using provided variable values
            if isempty(obj.interactionHamiltonian)
                error('No interaction Hamiltonian available to evaluate.');
            end
            value = subs(obj.interactionHamiltonian, obj.variables, variables);  % Substitute variables and evaluate
        end
        
        %% Visualize Interaction Hamiltonian (calls GraphUtility)
        function visualizeHamiltonian(obj)
            if isempty(obj.interactionHamiltonian)
                disp('No interaction Hamiltonian to visualize.');
                return;
            end
            % Call GraphUtility to handle the visualization of the interaction Hamiltonian
            GraphUtility.visualizeHamiltonian(obj.interactionHamiltonian, obj.name);
        end
    end
end
