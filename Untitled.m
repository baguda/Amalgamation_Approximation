% Define 1D GravityModule with a Gaussian wavefunction
gravityWavefunction = @(x) exp(-x.^2);
x = linspace(-5, 5, 100);  % 1D grid
gravityModule = GravityModule('Gravity Module', gravityWavefunction(x), 'gravity');
gravityModule.boundaryConditionModule = BoundaryConditionModule('Dirichlet', 'gravity', 0);

% Define 1D QuantumModule with a sine wavefunction
quantumWavefunction = @(x) sin(x);
quantumModule = QuantumModule('Quantum Module', quantumWavefunction(x), 'quantum');
quantumModule.boundaryConditionModule = BoundaryConditionModule('Neumann', 'quantum', 0);

% Define InteractionModule
interactionModule = InteractionModule('Interaction Module', 0.1);

% Define KernelModule (simple exponential operator)
kernelModule = KernelModule('Kernel Module');

% Create the Amalgam object
amalgam = Amalgam(gravityModule, quantumModule, interactionModule, kernelModule);

% Perform amalgamation
amalgam.performAmalgamation();

% Run health diagnostics on the raw wavefunction
amalgam.runHealthDiagnostics();

% Optionally perform curing if errors are found
amalgam.performCuring();

% Visualize the raw and cured wavefunctions
amalgam.visualizeAmalgamWavefunction('raw');
amalgam.visualizeAmalgamWavefunction('cured');
