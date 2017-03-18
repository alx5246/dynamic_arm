%
% (AJL) This is just for testing the simulator out a bit to see if it is
% working at all. 

% I am going to run the simulation for n time-intervals. Over each
% time-interval I am going to at random pick a set of muscles to use,
% and randomly pick their muscle activation level. The duration of each
% time-interval is randomly generated as well. The muscle activations are
% held constanct during the interval. 

% Set the time-step for the simulation
dt = .001;

% Pick the number of n time-intervals
numb_time_intervals = 20;

% Initialize the system.
theta_1 = pi/2;
theta_1_dot = 0.0;
theta_2 = pi/2;
theta_2_dot = 0.0;

% Plot out the initial state of the system.
arm_plotter(theta_1, theta_2, zeros(6,1))

% Iterate over the n intervals
for i=1:numb_time_intervals

    % For time-interval i, pick which muscles (there are six of them) that 
    % will be active, then assign those active muscles an activation level
    % over teh interval [0,1]. 
    is_act = rand(6,1);
    is_act(is_act>=.2) = 0;
    is_act(is_act>0) = 1;
    is_act = rand(6,1).*is_act;
    
    % "alpha" is the activation level (just keeping with the original
    % papers notation.
    alpha = is_act;
    
    % Determine at random how long time-interval i will be. 
    time = rand(1)*.4 + .1;
    
    % Given the length of time, how many time-steps will we simulate for?
    intervals = floor(time/dt);
    
    % Only simulate if some of the muscles are actually activated.
    if sum(is_act)>.01
        
        % Simulate over each of the time-steps. 
        for j=1:intervals

            % Use the Euler 1-Step simulator to determine the systems 
            % next state.
            [theta_1, theta_1_dot, theta_2, theta_2_dot] = arm_model(theta_1, theta_1_dot, theta_2, theta_2_dot, alpha, dt);
            
            % Plot out the system state every 10 time-steps. 
            if mod(j,10)==0
                fprintf('\nPlotting time-step %g or %g',j,intervals)
                arm_plotter(theta_1, theta_2, alpha)
            end
            
        end
        
    end
     
end