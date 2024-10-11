classdef GravityModule < WavefunctionModule
    properties
        gravitationalConstant  % Gravitational constant, G = 6.67430e-11 m^3 kg^-1 s^-2
        curvatureTensor         % Stores the actual curvature tensor (numeric array or symbolic)
        spacetimeMetric         % Stores the metric tensor (numeric array, symbolic, or reference)
        massDistribution        % Mass or energy distribution relevant to the gravitational field
    end
    
    methods
        %% Constructor
        function obj = GravityModule(loadFlag)
            % Call the constructor of the WavefunctionModule class
            obj@WavefunctionModule(loadFlag);
            obj.moduleType = 'gravity';  % Set type to 'gravity'
            % Set up default properties specific to GravityModule
            if isempty(obj.gravitationalConstant)
                obj.gravitationalConstant = 6.67430e-11;  % Initialize G
                obj.curvatureTensor = [];  % Placeholder for tensor data (numeric or symbolic)
                obj.spacetimeMetric = [];  % Placeholder for metric tensor (numeric, symbolic, or reference)
                obj.massDistribution = [];  % Placeholder for mass/energy distribution data
            end
        end
        
        %% Override loadModule to account for gravity-specific properties
        function obj = loadModule(obj)
            % Call superclass method to load wavefunction-specific properties
            obj = loadModule@WavefunctionModule(obj);
            
            % Load gravity-specific properties
            [file, path] = uigetfile('*.mat', 'Select a Gravity Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.gravitationalConstant = loadedData.gravitationalConstant;
                obj.curvatureTensor = loadedData.curvatureTensor;  % Load tensor as array or symbolic
                obj.spacetimeMetric = loadedData.spacetimeMetric;  % Load metric as array, symbolic, or reference
                obj.massDistribution = loadedData.massDistribution;
                disp(['Gravity module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Override printOverview to include gravity-specific properties
        function printOverview(obj)
            % Call superclass method to print shared and wavefunction-specific properties
            printOverview@Module(obj);

            % Check if metadata exists, then print
            if isstruct(obj.metadata)
                disp('Metadata:');
                fields = fieldnames(obj.metadata);
                for i = 1:numel(fields)
                    fieldValue = obj.metadata.(fields{i});
                    if isnumeric(fieldValue)
                        fieldValue = num2str(fieldValue);  % Convert numeric values to strings if needed
                    end
                    disp([fields{i}, ': ', fieldValue]);
                end
            else
                disp('No metadata available.');
            end

            % Print gravity-specific properties
            disp(['Gravitational Constant (G): ', num2str(obj.gravitationalConstant)]);
            disp(['Spacetime Metric: ', mat2str(obj.spacetimeMetric)]);
            disp(['Curvature Tensor: ', mat2str(obj.curvatureTensor)]);
            disp(['Mass Distribution: ', mat2str(obj.massDistribution)]);
        end

        %% Calculate Spacetime Curvature (Example Method)
        function curvature = calculateCurvature(obj)
            % Method to calculate spacetime curvature using mass distribution and metric tensor
            if isempty(obj.massDistribution) || isempty(obj.spacetimeMetric)
                error('Insufficient data to calculate spacetime curvature.');
            end
            % Placeholder logic to compute curvature using tensors
            curvature = obj.gravitationalConstant * obj.massDistribution;  % Simplified example
            % More complex calculations using tensor math would be implemented here
        end
        
        %% Visualize Spacetime Metric (calls GraphUtility)
        function visualizeSpacetimeMetric(obj)
            if isempty(obj.spacetimeMetric)
                disp('No spacetime metric to visualize.');
                return;
            end
            % Call GraphUtility for custom visualization (expand later)
            GraphUtility.visualizeMetric(obj.spacetimeMetric, obj.name);
        end


    end
end
