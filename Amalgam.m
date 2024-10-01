classdef Amalgam
    properties
        gravityModule            % GravityModule object
        quantumModule            % QuantumModule object
        interactionModule        % InteractionModule object
        kernelModule             % KernelModule object
        boundaryConditionModule  % BoundaryConditionModule object (new)
        
        rawAmalgamWavefunction    % Raw wavefunction after amalgamation
        curedAmalgamWavefunction  % Cured wavefunction after patching
        
        rawHealthReport           % Health report for raw wavefunction
        curedHealthReport         % Health report for cured wavefunction
        
        healthDiagnostic          % HealthDiagnostic object
        curingProcess             % Curing object
        
        amalgamLog                % Log of amalgamation process
    end
    
    methods
        %% Constructor
        function obj = Amalgam(gravity, quantum, interaction, kernel, boundaryCondition)
            % Use setter methods to validate input modules
            obj.setGravityModule(gravity);
            obj.setQuantumModule(quantum);
            obj.setInteractionModule(interaction);
            obj.setKernelModule(kernel);
            obj.setBoundaryConditionModule(boundaryCondition);  % Add boundary condition module
            
            % Initialize health diagnostics and curing process
            obj.healthDiagnostic = HealthDiagnostic(obj);  % Initialize with amalgam reference
            obj.curingProcess = Curing(obj);  % Initialize with amalgam reference
        end
        
        %% Set Methods for Module Validation
        function setGravityModule(obj, gravity)
            if strcmp(gravity.moduleType, 'gravity')
                obj.gravityModule = gravity;
            else
                error('Invalid module: Expected a GravityModule.');
            end
        end
        
        function setQuantumModule(obj, quantum)
            if strcmp(quantum.moduleType, 'quantum')
                obj.quantumModule = quantum;
            else
                error('Invalid module: Expected a QuantumModule.');
            end
        end
        
        function setInteractionModule(obj, interaction)
            if strcmp(interaction.moduleType, 'interaction')
                obj.interactionModule = interaction;
            else
                error('Invalid module: Expected an InteractionModule.');
            end
        end
        
        function setKernelModule(obj, kernel)
            if strcmp(kernel.moduleType, 'kernel')
                obj.kernelModule = kernel;
            else
                error('Invalid module: Expected a KernelModule.');
            end
        end

        function setBoundaryConditionModule(obj, boundaryCondition)
            if strcmp(boundaryCondition.moduleType, 'boundaryCondition')
                obj.boundaryConditionModule = boundaryCondition;
            else
                error('Invalid module: Expected a BoundaryConditionModule.');
            end
        end
        
        %% Perform Amalgamation
        function performAmalgamation(obj)
            % Combine gravity and quantum modules using the interaction and kernel modules
            obj.rawAmalgamWavefunction = obj.kernelModule.evaluateKernel(...
                obj.gravityModule.wavefunctionData, obj.quantumModule.wavefunctionData);
            
            % Apply boundary conditions after amalgamation
            obj.boundaryConditionModule.applyBoundaryCondition(obj.rawAmalgamWavefunction);
            
            % Log the amalgamation process
            obj.amalgamLog = obj.logAmalgamationProcess();
        end
        
        %% Run Health Diagnostics
        function runHealthDiagnostics(obj)
            obj.rawHealthReport = obj.healthDiagnostic.scanWavefunction(obj.rawAmalgamWavefunction);
        end
        
        %% Perform Curing
        function performCuring(obj)
            [obj.curedAmalgamWavefunction, cureLog] = obj.curingProcess.cureWavefunction(obj.rawAmalgamWavefunction, obj.rawHealthReport);
            obj.amalgamLog = [obj.amalgamLog; cureLog];  % Append cure log to amalgam log
            obj.curedHealthReport = obj.healthDiagnostic.scanWavefunction(obj.curedAmalgamWavefunction);
        end
        
        %% Visualize Wavefunctions
        function visualizeAmalgamWavefunction(obj, type)
            if strcmp(type, 'raw')
                GraphUtility.visualizeWavefunction(obj.rawAmalgamWavefunction, 3, 'Raw Amalgam Wavefunction');
            elseif strcmp(type, 'cured')
                GraphUtility.visualizeWavefunction(obj.curedAmalgamWavefunction, 3, 'Cured Amalgam Wavefunction');
            else
                error('Invalid wavefunction type. Choose "raw" or "cured".');
            end
        end
        
        %% Log Amalgamation Process
        function log = logAmalgamationProcess(obj)
            log = sprintf('Amalgamation process log for modules: %s, %s, %s, %s', ...
                          obj.gravityModule.name, obj.quantumModule.name, obj.interactionModule.name, obj.kernelModule.name);
        end
        
    end
end
