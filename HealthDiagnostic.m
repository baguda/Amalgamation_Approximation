classdef HealthDiagnostic
    properties
        amalgam                % Reference to the Amalgam object
        logData                % Log of diagnostic events
        errorList              % Structured list of detected errors (magnitudes, locations, etc.)
        loggingSystem          % Instance of the Logging class for tracking events
        healthReport           % Store the overall health report
    end
    
    methods
        %% Constructor
        function obj = HealthDiagnostic(amalgam)
            obj.amalgam = amalgam;  % Store reference to Amalgam object
            obj.logData = {};       % Initialize empty log
            obj.errorList = {};     % Initialize empty error list
            obj.loggingSystem = Logging();  % Create instance of Logging class
            obj.healthReport = struct();  % Initialize empty health report
        end
        
        %% Run Comprehensive Health Check with Scan Settings
        function healthReport = scanWavefunction(obj, wavefunction, expectedParams, scanSettings)
            % Initialize health report fields
            obj.healthReport.maxValue = max(wavefunction(:));
            obj.healthReport.minValue = min(wavefunction(:));
            obj.healthReport.nanCount = sum(isnan(wavefunction(:)));
            obj.healthReport.infCount = sum(isinf(wavefunction(:)));

            % Log extreme values and NaNs/Infs
            obj.loggingSystem.logEvent(sprintf('Max Value: %.2f', obj.healthReport.maxValue));
            obj.loggingSystem.logEvent(sprintf('Min Value: %.2f', obj.healthReport.minValue));
            obj.loggingSystem.logEvent(sprintf('NaN Count: %d', obj.healthReport.nanCount));
            obj.loggingSystem.logEvent(sprintf('Infinity Count: %d', obj.healthReport.infCount));

            % Detect discontinuities
            [obj.healthReport.discontinuities, obj.healthReport.discontinuityLocations] = obj.detectDiscontinuities(wavefunction, scanSettings);
            
            % Check smoothness (gradients)
            [gradientX, gradientY] = gradient(wavefunction);
            obj.healthReport.maxGradient = max(max(abs(gradientX(:))), max(abs(gradientY(:))));
            obj.loggingSystem.logEvent(sprintf('Max Gradient: %.2f', obj.healthReport.maxGradient));

             % Detect boundary mismatches using the BoundaryConditionModule
                [obj.healthReport.boundaryMismatches, obj.healthReport.boundaryMismatchLocations] = ...
                    obj.checkBoundaryMismatch(wavefunction);

                % Log the boundary mismatch data
                obj.loggingSystem.logError('Boundary Mismatch Detected', obj.healthReport.boundaryMismatches, ...
                               obj.healthReport.boundaryMismatchLocations);

            % Energy conservation check
            obj.healthReport.energyDeviation = obj.checkEnergyConservation(wavefunction, expectedParams.expectedEnergy);
            obj.loggingSystem.logEvent(sprintf('Energy Deviation: %.2f', obj.healthReport.energyDeviation));

            % Detect excessive oscillations
            obj.healthReport.oscillations = obj.checkOscillations(wavefunction, expectedParams.expectedOscillations);
            obj.loggingSystem.logEvent(sprintf('Excessive Oscillations: %d', obj.healthReport.oscillations));

            % Detect spikes
            [obj.healthReport.spikeCount, obj.healthReport.spikeLocations] = obj.detectSpikes(wavefunction, scanSettings);
            obj.loggingSystem.logError('Spike Detected', obj.healthReport.spikeCount, obj.healthReport.spikeLocations);

            % Detect outliers
            [obj.healthReport.outlierCount, obj.healthReport.outlierLocations] = obj.detectOutliers(wavefunction);
            obj.loggingSystem.logError('Outliers Detected', obj.healthReport.outlierCount, obj.healthReport.outlierLocations);

            % Detect gradient anomalies
            [obj.healthReport.gradientAnomalies, obj.healthReport.gradientAnomalyLocations] = obj.detectGradientAnomalies(gradientX, gradientY, scanSettings);
            obj.loggingSystem.logError('Gradient Anomalies Detected', obj.healthReport.gradientAnomalies, obj.healthReport.gradientAnomalyLocations);

            % Log completion of diagnostics
            obj.loggingSystem.logEvent('Health Diagnostic completed for wavefunction.');

            % Return health report
            healthReport = obj.healthReport;
        end

        function [mismatches, locations] = checkBoundaryMismatch(obj, wavefunction)
            % Retrieve boundary conditions from the BoundaryConditionModule
            boundaryConditionModule = obj.amalgam.boundaryConditionModule;

            % Use the boundary condition module to check for mismatches
            [mismatches, locations] = boundaryConditionModule.checkBoundaryMismatch(wavefunction);
        end

        %% Check Energy Conservation
        function energyDeviation = checkEnergyConservation(~, wavefunction, expectedEnergy)
            totalEnergy = sum(abs(wavefunction(:)).^2);
            energyDeviation = abs(totalEnergy - expectedEnergy);
        end

        %% Check Oscillations
        function oscillations = checkOscillations(~, wavefunction, expectedOscillations)
            fftWave = fft2(wavefunction);
            freqs = abs(fftshift(fftWave));
            oscillations = sum(freqs(:) > expectedOscillations);
        end

        %% Detect Discontinuities
        function [discontinuities, locations] = detectDiscontinuities(~, wavefunction, scanSettings)
            discontinuities = 0;
            locations = [];
            [rows, cols] = size(wavefunction);
            for i = 2:rows
                for j = 2:cols
                    diffX = abs(wavefunction(i, j) - wavefunction(i-1, j));  
                    diffY = abs(wavefunction(i, j) - wavefunction(i, j-1));
                    if diffX > scanSettings.discontinuityThreshold || diffY > scanSettings.discontinuityThreshold
                        discontinuities = discontinuities + 1;
                        locations = [locations; i, j];
                    end
                end
            end
        end

        %% Detect Spikes
        function [spikeCount, locations] = detectSpikes(~, wavefunction, scanSettings)
            diffX = abs(diff(wavefunction, 1, 1));  
            diffY = abs(diff(wavefunction, 1, 2));  
            spikeThreshold = scanSettings.spikeThreshold;
            spikeCount = sum(diffX(:) > spikeThreshold) + sum(diffY(:) > spikeThreshold);
            [rows, cols] = size(wavefunction);
            locations = [];
            for i = 2:rows
                for j = 2:cols
                    if abs(wavefunction(i, j) - wavefunction(i-1, j)) > spikeThreshold || ...
                            abs(wavefunction(i, j) - wavefunction(i, j-1)) > spikeThreshold
                        locations = [locations; i, j];
                    end
                end
            end
        end

        %% Detect Outliers
        function [outlierCount, locations] = detectOutliers(~, wavefunction)
            waveMean = mean(wavefunction(:));
            waveStd = std(wavefunction(:));
            zScores = (wavefunction(:) - waveMean) / waveStd;
            outlierThreshold = 3.5;  % Z-score > 3 indicates an outlier
            outlierCount = sum(abs(zScores) > outlierThreshold);
            [outlierIdx] = find(abs(zScores) > outlierThreshold);
            locations = [mod(outlierIdx - 1, size(wavefunction, 1)) + 1, floor((outlierIdx - 1) / size(wavefunction, 1)) + 1];
        end

        %% Detect Gradient Anomalies
        function [anomalyCount, locations] = detectGradientAnomalies(~, gradientX, gradientY, scanSettings)
            gradThreshold = scanSettings.gradientThreshold;
            anomalyCount = sum(abs(gradientX(:)) > gradThreshold) + sum(abs(gradientY(:)) > gradThreshold);
            [gradXIdx, gradYIdx] = find(abs(gradientX) > gradThreshold | abs(gradientY) > gradThreshold);
            locations = [gradXIdx, gradYIdx];
        end
    end
end
