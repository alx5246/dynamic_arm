function arm_plotter(theta_1, theta_2, alpha)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION DESCRIPTION
%    This is a simple plotter of the 2-DOF arm, with 6 muscles. The plotter
%    will output onto Figure(2), a visual depiction of the system. 
%
%    The bones of the system will be in blue.
%    The muscles when activated will be in red.
%    The muscles when not activated will be in green.
%
%    Much here is hard coded. If you change your simulation and therein
%    change important parameters in your "arm_model.m" like position of 
%    muscles or lenths of bones, then you will here too have to make those
%    same adjustments. 
%
% INPUTS
%     theta_1: the rotation of arm link-1 relative to the x-axis, in
%         radians.
%     theta_2: the rotation of arm link-2 relative to arm link-1, in
%         radians.
%     alpha: 6x1 muscle activation vector. 
%
% OUTPUTS
%     N/A, simply plots onto Figure(2)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARM PARAMETERS (excluding muscles)

% Upper arm (length, mass, Intertia, and mass-center)
L_1 = 0.310; % (m)

% Fore arm (length, mass, Intertia, and mass-center)
L_2 = 0.1700; % (m)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MUSCLE PARAMETERS

% Muscle attachment points (as given in the original paper.

% Muscle l-1
r_1 = 0.055; % (m)
s_1 = 0.080; % (m)

% Muscle l-2
r_2 = 0.055; % (m)
s_2 = 0.080; % (m)

% Muscle l-3
r_3 = 0.030; % (m)
s_3 = 0.120; % (m)

% Muscle l-4
r_4 = 0.030; % (m)
s_4 = 0.120; % (m)

% Muscle l-5
w_51 = 0.040; % (m)
w_52 = 0.045; % (m)

% Muscle l-6
w_61 = 0.040; % (m)
w_62 = 0.045; % (m)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MUSCLE LENGTHS & LENGTH CHANGES 

% Finding lengths of the muscles l-1 through l-9
l = [ (r_1^2 + s_1^2 + 2*r_1*s_1*cos(theta_1))^.5; ...
      (r_2^2 + s_2^2 - 2*r_2*s_2*cos(theta_1))^.5; ...
      (r_3^2 + s_3^2 + 2*r_3*s_3*cos(theta_2))^.5; ...
      (r_4^2 + s_4^2 - 2*r_4*s_4*cos(theta_2))^.5; ...
      (w_51^2 + w_52^2 + L_1^2 + 2*w_51*L_1*cos(theta_1) + 2*w_52*L_1*cos(theta_2) + 2*w_51*w_52*cos(theta_1 + theta_2))^.5; ...
      (w_61^2 + w_62^2 + L_1^2 - 2*w_61*L_1*cos(theta_1) - 2*w_62*L_1*cos(theta_2) + 2*w_61*w_52*cos(theta_1 + theta_2))^.5];

  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING OUT THINGS

figure(2)
%clf
hold off

% Plot first arm link
x = [0, L_1*cos(theta_1)];
y = [0, L_1*sin(theta_1)];
plot(x, y, 'b-o', 'LineWidth', 2, 'MarkerSize', 10)

hold on

% Plot second arm link
x = [L_1*cos(theta_1), L_1*cos(theta_1) + L_2*cos(theta_1+theta_2)];
y = [L_1*sin(theta_1), L_1*sin(theta_1) + L_2*sin(theta_1+theta_2)];
plot(x, y, 'b-o', 'LineWidth', 2, 'MarkerSize', 10)
x = [L_1*cos(theta_1), L_1*cos(theta_1) + 1.1*w_62*cos(theta_1+theta_2-pi)];
y = [L_1*sin(theta_1), L_1*sin(theta_1) + 1.1*w_62*sin(theta_1+theta_2-pi)];
plot(x, y, 'b-o', 'LineWidth', 2, 'MarkerSize', 10)

% Plot first muscle
x = [-r_1, s_1*cos(theta_1)];
y = [0, s_1*sin(theta_1)];
if alpha(1)>0
    plot(x, y, 'r')
else
    plot(x, y, 'g')
end

% Plot second muscle
x = [r_2, s_2*cos(theta_1)];
y = [0, s_2*sin(theta_1)];
if alpha(2)>0
    plot(x, y, 'r')
else
    plot(x, y, 'g')
end

% Plot third muscle
x = [s_3*cos(theta_1), L_1*cos(theta_1) + r_3*cos(theta_1+theta_2)];
y = [s_3*sin(theta_1), L_1*sin(theta_1) + r_3*sin(theta_1+theta_2)];
if alpha(3)>0
    plot(x, y, 'r')
else
    plot(x, y, 'g')
end

% Plot fourth muscle
x = [s_4*cos(theta_1), L_1*cos(theta_1) + r_4*cos(theta_1+theta_2-pi)];
y = [s_4*sin(theta_1), L_1*sin(theta_1) + r_4*sin(theta_1+theta_2-pi)];
if alpha(4)>0
    plot(x, y, 'r')
else
    plot(x, y, 'g')
end

% Plot fifth muscle
x = [-w_51, L_1*cos(theta_1) + w_52*cos(theta_1+theta_2)];
y = [0, L_1*sin(theta_1) + w_52*sin(theta_1+theta_2)];
if alpha(5)>0
    plot(x, y, 'r')
else
    plot(x, y, 'g')
end

% Plot sixth muscle
x = [w_61, L_1*cos(theta_1) + w_62*cos(theta_1+theta_2-pi)];
y = [0, L_1*sin(theta_1) + w_62*sin(theta_1+theta_2-pi)];
if alpha(6)>0
    plot(x, y, 'r')
else
    plot(x, y, 'g')
end

% Set plot things
xlim([-.5, .5])
ylim([0,.45])

drawnow
pause(.05)

hold off


  