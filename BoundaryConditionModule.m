classdef BoundaryConditionModule < MathModule
    properties
        boundaryType         % Type of boundary condition (e.g., 'Dirichlet', 'Neumann', 'Robin', etc.)
        boundaryValue        % Value for the boundary condition (for Dirichlet, Neumann)
        boundaryParameters   % Additional parameters for boundary conditions (for Robin, radiation, etc.)
        customFunction       % Custom function for user-defined boundary conditions
    end
    
    methods
        %% Constructor
        function obj = BoundaryConditionModule(boundaryType, boundaryValue, varargin)
            obj@MathModule();  % Inherit from MathModule
            obj.boundaryType = boundaryType;
            obj.boundaryValue = boundaryValue;
            
            % Additional parameters (e.g., a, b, c for Robin, c for Radiation)
            if nargin > 2
                obj.boundaryParameters = varargin{1};  % Store additional parameters
            end
            
            % Handle custom function for 'Custom' boundary conditions
            if strcmp(boundaryType, 'Custom') && nargin > 3
                obj.customFunction = varargin{2};
            end
        end
        
        %% Apply Boundary Condition
        function applyBoundaryCondition(obj, wavefunction)
            % Modify wavefunction according to boundary condition type
            switch obj.boundaryType
                case 'Dirichlet'
                    wavefunction(1,:) = obj.boundaryValue;  % Top boundary
                    wavefunction(end,:) = obj.boundaryValue; % Bottom boundary
                    wavefunction(:,1) = obj.boundaryValue;  % Left boundary
                    wavefunction(:,end) = obj.boundaryValue; % Right boundary
                    
                case 'Neumann'
                    % Modify gradient for Neumann boundary
                    wavefunction(1,:) = wavefunction(2,:) + obj.boundaryValue;  % Top boundary
                    wavefunction(end,:) = wavefunction(end-1,:) + obj.boundaryValue; % Bottom boundary
                    
                case 'Robin'
                    % Use boundary parameters (a, b, c)
                    a = obj.boundaryParameters.a;
                    b = obj.boundaryParameters.b;
                    c = obj.boundaryParameters.c;
                    wavefunction(1,:) = (c - b*wavefunction(2,:)) / a;  % Top boundary
                    wavefunction(end,:) = (c - b*wavefunction(end-1,:)) / a;  % Bottom boundary

                case 'Periodic'
                    % Set periodic boundaries
                    wavefunction(1,:) = wavefunction(end,:);  % Top and bottom are periodic
                    wavefunction(:,1) = wavefunction(:,end);  % Left and right are periodic

                case 'Radiation'
                    % Radiation: Sommerfeld condition for outgoing waves (absorbing)
                    c = obj.boundaryParameters.waveSpeed;  % Speed of wave propagation
                    dt = obj.boundaryParameters.dt;         % Time step for radiation condition
                    for k = 1:size(wavefunction, 2)
                        % Apply radiation condition ??/?t + c ??/?x = 0
                        if abs((wavefunction(1, k) - wavefunction(2, k)) / dt + ...
                                c * (wavefunction(1, k) - wavefunction(2, k))) > 1e-3
                            wavefunction(1, k) = wavefunction(2, k);  % Adjust top boundary
                        end
                        if abs((wavefunction(end, k) - wavefunction(end-1, k)) / dt + ...
                                c * (wavefunction(end, k) - wavefunction(end-1, k))) > 1e-3
                            wavefunction(end, k) = wavefunction(end-1, k);  % Adjust bottom boundary
                        end
                    end

                case 'Asymptotic'
                    % Asymptotic: Ensure wavefunction decays to zero at far boundaries
                    for k = 1:size(wavefunction, 2)
                        if abs(wavefunction(1, k)) > 1e-3  % Top boundary should approach zero
                            wavefunction(1, k) = 0;
                        end
                        if abs(wavefunction(end, k)) > 1e-3  % Bottom boundary should approach zero
                            wavefunction(end, k) = 0;
                        end
                    end

                case 'Custom'
                    % Apply custom boundary function if defined
                    for i = 1:size(wavefunction, 2)
                        wavefunction(1, i) = obj.customFunction(wavefunction(1, i));  % Top boundary
                        wavefunction(end, i) = obj.customFunction(wavefunction(end, i)); % Bottom boundary
                    end

                otherwise
                    error('Unsupported boundary condition type');
            end
        end
        
        %% Print Boundary Condition Overview
        function printBoundaryOverview(obj)
            fprintf('Boundary Condition: %s\n', obj.boundaryType);
            fprintf('Boundary Value: %.2f\n', obj.boundaryValue);
            if ~isempty(obj.boundaryParameters)
                disp('Boundary Parameters:');
                disp(obj.boundaryParameters);
            end
            if strcmp(obj.boundaryType, 'Custom')
                disp('Custom Function is defined.');
            end
        end
        
        %% Export Boundary Condition
        function exportBoundaryCondition(obj, filename)
            if nargin < 2
                filename = 'boundary_condition.txt';
            end
            fid = fopen(filename, 'w');
            fprintf(fid, 'Boundary Condition: %s\n', obj.boundaryType);
            fprintf(fid, 'Boundary Value: %.2f\n', obj.boundaryValue);
            if ~isempty(obj.boundaryParameters)
                fprintf(fid, 'Boundary Parameters:\n');
                disp(obj.boundaryParameters);
            end
            fclose(fid);
            disp(['Boundary condition exported to ', filename]);
        end
    end
end
