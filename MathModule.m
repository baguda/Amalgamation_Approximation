classdef MathModule < Module
    properties
        expression              % Stores symbolic or analytical mathematical expressions
        precision               % Numerical precision (single, double) used in calculations
        variables               % Variables involved in the expression (e.g., x, t)
    end
    
    methods
        %% Constructor
        function obj = MathModule(loadFlag)
            % Call the constructor of the superclass
            obj@Module(loadFlag);
            
            % Set up default math module properties for blank module
            if isempty(obj.expression)
                obj.expression = '';
                obj.variables = {};
                obj.precision = 'Double';
            end
        end
        
        %% Override loadModule to account for math-specific properties
        function obj = loadModule(obj)
            % Call superclass method to load shared properties
            obj = loadModule@Module(obj);
            
            % Load math-specific properties
            [file, path] = uigetfile('*.mat', 'Select a Math Module File');
            if isequal(file, 0)
                disp('User canceled file selection.');
            else
                loadedData = load(fullfile(path, file), '-mat');
                obj.expression = loadedData.expression;
                obj.variables = loadedData.variables;
                obj.precision = loadedData.precision;
                disp(['Math module loaded from: ', fullfile(path, file)]);
            end
        end
        
        %% Override printOverview to include math-specific properties
        function printOverview(obj)
            % Call superclass method to print shared properties
            printOverview@Module(obj);
            
            % Print math-specific properties
            disp(['Expression: ', char(obj.expression)]);
            disp(['Variables: ', strjoin(obj.variables, ', ')]);
            disp(['Precision: ', obj.precision]);
        end

        %% Visualize the Expression (calls GraphUtility)
        function visualizeExpression(obj)
            if isempty(obj.expression)
                disp('No expression to visualize.');
                return;
            end
            % Call the GraphUtility to handle plotting (future implementation)
            GraphUtility.visualizeExpression(obj.expression, obj.variables, obj.name);
        end
        
        %% Evaluate Expression at given values
        function result = evaluateExpression(obj, values)
            % Evaluate the symbolic expression using the provided variable values
            if isempty(obj.expression)
                error('No expression available to evaluate.');
            end
            
            % Substitute the provided values into the expression and evaluate
            try
                result = subs(obj.expression, obj.variables, values);
            catch ME
                error('Error evaluating the expression: %s', ME.message);
            end
        end
    end
end
