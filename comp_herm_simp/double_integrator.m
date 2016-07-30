global gridN
gridN = 10;

tic
% Minimize the simulation time
time_min = @(x) x(1);
% The initial parameter guess; 1 second, fifty positions, fifty velocities,
% fifty accelerations at nodes, fifty accelerations at midpoints
x0 = [1; linspace(0,1,gridN)';  linspace(0,1,gridN)'; ... 
         ones(gridN, 1) * 5;    ones(gridN - 1, 1) * 5];
% No linear inequality or equality constraints
A = [];
b = [];
Aeq = [];
Beq = [];
% Lower bound the simulation time at zero seconds, and bound the
% accelerations between -10 and 30
lb = [0;    ones(gridN * 2, 1) * -Inf;  ones(gridN * 2 - 1, 1) * -10];
ub = [Inf;  ones(gridN * 2, 1) * Inf;   ones(gridN * 2 - 1, 1) * 30];
% Options for fmincon
options = optimset('TolFun', 0.00000001, 'MaxIter', 100000, ...
                   'MaxFunEvals', 100000);
% Solve for the best simulation time + states + control inputs
optimal = fmincon(time_min, x0, A, b, Aeq, Beq, lb, ub, ...
              @double_integrator_constraints, options);

sim_time = optimal(1);
delta_time = sim_time / gridN;
times = 0 : delta_time : sim_time - delta_time;
% Get the states and control inputs out of the optimal vector
positions   = optimal(2             : 1 + gridN);
vels        = optimal(2 + gridN     : 1 + gridN * 2);
nodeaccs    = optimal(2 + gridN * 2 : 1 + gridN * 3);
midaccs     = optimal(2 + gridN * 3 : end);

% Interleave the node and middle accelerations for display purposes
combaccs = [nodeaccs, [midaccs ; 0]]';
combaccs = combaccs(:)';
combaccs = combaccs(1:end-1);

% Make the plots
figure();
plot(0 : delta_time / 2 : sim_time - delta_time, combaccs);
title('Control Input (Acceleration) vs Time');
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
figure();
plot(times, vels);
title('Velocity vs Time');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
figure();
plot(times, positions);
title('Position vs Time');
xlabel('Time (s)');
ylabel('Position (m)');
disp(sprintf('Finished in %f seconds', toc));