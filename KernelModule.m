classdef KernelModule < MathModule
    properties
        kernelFunction     % Stores the kernel function (numeric or symbolic)
        kernelType         % Type of kernel (e.g., exponential, Gaussian)
        integrationRange   % Range over which to integrate the kernel (numeric)
    end
    
    methods
        %% Constructor
        function obj = KernelModule(loadFlag)
            % Call the constructor of the MathModule class
            obj@MathModule(loadFlag);
            obj.moduleType = 'kernel';  % Set type to 'gravity'
            % Set up default properties specific to KernelModule
            if isempty(obj.kernelFunction)
                obj.kernelFunction = [];  % Placeholder for kernel function
                obj.kernelType = 'Undefined';  % Kernel type
                obj.integrationRange = [0, 1];  % Default integration range
            end
        end
        
        %% Override loadModule to account for kernel-specific properties
        function obj = loadModule(obj)
            % Call superclass method to load math-specific properties
            obj = loadModule@MathModule(obj);
            
            % Load kernel-specific properties
            [file, path] = uigetfile('*.mat', 'Select a Kernel Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.kernelFunction = loadedData.kernelFunction;
                obj.kernelType = loadedData.kernelType;
                obj.integrationRange = loadedData.integrationRange;
                disp(['Kernel module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Override printOverview to include kernel-specific properties
        function printOverview(obj)
            % Call superclass method to print shared math-specific properties
            printOverview@MathModule(obj);
            
            % Print kernel-specific properties
            disp(['Kernel Function: ', char(obj.kernelFunction)]);
            disp(['Kernel Type: ', obj.kernelType]);
            disp(['Integration Range: ', mat2str(obj.integrationRange)]);
        end
        
        %% Evaluate Kernel at given values
        function value = evaluateKernel(obj, variables)
            % Evaluate the kernel using the provided variable values
            if isempty(obj.kernelFunction)
                error('No kernel function available to evaluate.');
            end
            value = subs(obj.kernelFunction, obj.variables, variables);  % Substitute variables and evaluate
        end
        
        %% Visualize Kernel (calls GraphUtility)
        function visualizeKernel(obj)
            if isempty(obj.kernelFunction)
                disp('No kernel to visualize.');
                return;
            end
            % Call GraphUtility to handle the visualization of the kernel
            GraphUtility.visualizeKernel(obj.kernelFunction, obj.name);
        end
    end
end
