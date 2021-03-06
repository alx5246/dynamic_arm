function [theta_1_new, theta_1_dot_new, theta_2_new, theta_2_dot_new] = arm_model(theta_1, theta_1_dot, theta_2, theta_2_dot, alpha, dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION DESCRIPTION
%    This is a Euler 1-step simulation of the 6-muscle, 2-link arm. To use
%    this you provide the current state (all the theta's and theta-dots),
%    along with a vector alpha, which has the activation level (over the
%    domain [0,1]) for each muscle, and the time-step length (dt) in
%    seconds, and this will output the systems next step. 
%
%    We assume here the muscle forces are constant over each time-step. 
%
%    VERY VERY much of this is hardcoded here. Such things hard coded are
%    the masses, inertias, lengths, along with all muscle parameters. If 
%    you change these make sure you also change them appropriately in other
%    functions/methods like the arm-plotter. 
%
%    This model is generated from "On control of reaching movements for
%    musculo-skeletal redundant arm model" (2009), Tajara et al. Where in
%    while they use a 3-DOF arm model with 9 muscles, we here have a 2-DOF
%    arm with 6 muscles. Many of the paramters here by default come from
%    there paper, these values include
%        a) lengts of appendages
%        b) masses and intertia values
%        c) position of muscles
%        d) c_0 muscle dampling
%    other values like, f_0, which is the maximum muscle force output and
%    l_0 which is the rest lenght of the muscles have generated based on
%    observations from the paper, though those values are not directly
%    given. 
%
%    The system also has hard limits on the range of motion, as would any
%    real arm. They are described below is section "STATE BOUNDS". These
%    bounds are inforced by a simple model wherein if the bound is reached,
%    the state is set to the maximum value, and the velocities are
%    reversed. This is a simple way to mimic bouncing off a wall. 
%        
% INPUTS
%    theta_1: angle of arm link-1 realtive to coordinate system x-axis, in
%        radians.
%    theta_1_dot: angular velocity of arm link-1 relative to coordinate
%        system in rads/sec. 
%    theta_2: angle of arm link-2 raltive to arm-link 1, in radians.
%    theta_2_dot: angular velocity of arm link-2 realtive to arm link-1 in
%        radians/sec.
%    alpha: 6x1 vector of muscle activations for each 6 muscles, where the 
%        order of muscles follows that of the paper this model comes from.
%
% OUTPUTS
%    The new state values. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATE BOUNDS
% I think we need bounds on the arm (as would be in physical reality) or 
% the arm dynamics at some point will break down. We may also have to
% sufficienlty alter the dynamics so we do not violate these bounds. In 
% order to enforce these bounds I will probably have to add a non-linear
% spring and damper term, or just a simple constraint. 
theta_1_min = 30.0*(pi/180);
theta_1_max = 150.0*(pi/180);
theta_2_min = 30.0*(pi/180);
theta_2_max = 150.0*(pi/180);

% This is how we will determine how much reversal velocity the thing has
% after it hits the limit. 
coef_restitution = .1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARM PARAMETERS (excluding muscles)

% Upper arm (length, mass, Intertia, and mass-center)
L_1 = 0.310; % (m)
m_1 = 1.930; % (kg)
I_1 = 0.0141; % (kg * m^2)
mc_1 = 0.165; % (m) 

% Fore arm (length, mass, Intertia, and mass-center)
L_2 = 0.1700; % (m)
m_2 = 1.3200; % (kg)
I_2 = 0.0120; % (kg * m^2)
mc_2 = 0.1350; % (m) 


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

% Muscle rest lengths, these values NEED to be set by the user and is the 
% rest length of the muscles in the system. Check src/utilities/ for 
% appropriate functions.
l_0 = [0.0971; ...
       0.0971; ...
       0.1237; ...
       0.1237; ...
       0.3100; ...
       0.3100];

% Alpha parameters, these are the f_0 values that scale up our muslce
% forces
f_0 = 10 * ones(6,1); % (newtons)

% Muscle intrinsic viscosity c_0 as set by the paper is constant and
c_0 = .2 * ones(6,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MUSCLE LENGTHS & LENGTH CHANGES 

% Finding lengths of the muscles l-1 through l-9
l = [ (r_1^2 + s_1^2 + 2*r_1*s_1*cos(theta_1))^.5; ...
      (r_2^2 + s_2^2 - 2*r_2*s_2*cos(theta_1))^.5; ...
      (r_3^2 + s_3^2 + 2*r_3*s_3*cos(theta_2))^.5; ...
      (r_4^2 + s_4^2 - 2*r_4*s_4*cos(theta_2))^.5; ...
      (w_51^2 + w_52^2 + L_1^2 + 2*w_51*L_1*cos(theta_1) + 2*w_52*L_1*cos(theta_2) + 2*w_51*w_52*cos(theta_1 + theta_2))^.5; ...
      (w_61^2 + w_62^2 + L_1^2 - 2*w_61*L_1*cos(theta_1) - 2*w_62*L_1*cos(theta_2) + 2*w_61*w_52*cos(theta_1 + theta_2))^.5];
  
% Later we will need to understand how the lengths are chaning, in order to
% do this we need the Jacobin of "l" with respect to the the values of 
% the angles, this Jacobian will be called "W" and will be a 9x3 matrix
W = [ .5*(r_1^2 + s_1^2 + 2*r_1*s_1*cos(theta_1))^(-.5) * (-2*r_1*s_1*sin(theta_1)), ...
      0.0;
      .5*(r_2^2 + s_2^2 - 2*r_2*s_2*cos(theta_1))^(-.5) * (2*r_2*s_2*sin(theta_1)), ...
      0.0;
      0.0, ...
      .5*(r_3^2 + s_3^2 + 2*r_3*s_3*cos(theta_2))^(-.5) * (-2*r_3*s_3*sin(theta_2));
      0.0, ...
      .5*(r_4^2 + s_4^2 - 2*r_4*s_4*cos(theta_2))^(-.5) * (2*r_4*s_4*sin(theta_2));
      .5*(w_51^2 + w_52^2 + L_1^2 + 2*w_51*L_1*cos(theta_1) + 2*w_52*L_1*cos(theta_2) + 2*w_51*w_52*cos(theta_1 + theta_2))^(-.5) * (-2*w_51*L_1*sin(theta_1) - 2*w_51*w_52*sin(theta_1 + theta_2)), ...
      .5*(w_51^2 + w_52^2 + L_1^2 + 2*w_51*L_1*cos(theta_1) + 2*w_52*L_1*cos(theta_2) + 2*w_51*w_52*cos(theta_1 + theta_2))^(-.5) * (-2*w_52*L_1*sin(theta_2) - 2*w_51*w_52*sin(theta_1 + theta_2));
      .5*(w_61^2 + w_62^2 + L_1^2 - 2*w_61*L_1*cos(theta_1) - 2*w_62*L_1*cos(theta_2) + 2*w_61*w_62*cos(theta_1 + theta_2))^(-.5) * (2*w_61*L_1*sin(theta_1) - 2*w_61*w_62*sin(theta_1 + theta_2)), ...
      .5*(w_61^2 + w_62^2 + L_1^2 - 2*w_61*L_1*cos(theta_1) - 2*w_62*L_1*cos(theta_2) + 2*w_61*w_62*cos(theta_1 + theta_2))^(-.5) * (2*w_62*L_1*sin(theta_2) - 2*w_61*w_62*sin(theta_1 + theta_2))];

% Now calculate rate of muscle lenth change
l_dot = W*[theta_1_dot; theta_2_dot]; % should be a 6X1 vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MUSLCE FORCE CALCULATIONS

% "alpha_hat" is the scaled up values of alphs
alpha_hat = f_0 .* alpha; % shold be a 6x1 vector

% "A" is the matrix version of "alpha_hat"
A = diag(alpha_hat);

% Calculate the "p" values
p = (.9.*l_0)./(.9.*l_0 + abs(l_dot)); % should be a 6x1 vector

% "P" is the matrix version of "p"
P = diag(p);

% Calculate the "c" values depending on sign of direction change
c = zeros(6,1);
for i=1:6
    if l_dot(i) >= 0
        c(i) = max( 0.25/(.9*l_0(i)), 0);
    else
        c(i) = max( 2.25/(.9*l_0(i)), 0);
    end
end
  
% "C" is the matrix version of "c"
C = diag(c);

% "C_0" is the matrix version of "c_0"
C_0 = diag(c_0);

% Fm are the forces applied by the muscles!
Fm = P*alpha_hat - P*(A*C+C_0)*l_dot; % should be a 6X1 matrix 

% Tm is the torque applied by the muscles. For some reason I think I have
% shit backwards so I need a negative in front of the this?
Tm = -W'*Fm; % should be a 2X1 matrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% ARM DYNAMICS

% H*Theta_dot_dot + S*Theta_dot = Torque

H_11 = m_1*(mc_1^2) + I_1 + m_2*(L_1^2 + mc_2^2 + 2*L_1*mc_2*cos(theta_2)) + I_2;
H_12 = m_2*L_1*mc_2*cos(theta_2) + m_2*(mc_2^2) + I_2;
H_21 = H_12;
H_22 = m_2*mc_2^2 + I_2;

H = [H_11, H_12; H_21, H_22];

h = m_2*L_1*(mc_2^2)*sin(theta_2);

S = [-h*theta_2_dot, -h*(theta_1_dot+theta_2_dot);...
     h*theta_1_dot, 0.0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARM SIMULATION
% Here we are going to apply Euler-One Step to find Theta_dot_dot 

% Find Theta_dot approximation
The_dots = [theta_1_dot; theta_2_dot] + inv(H)*(Tm - S*[theta_1_dot; theta_2_dot]) .* dt;
theta_1_dot_new = The_dots(1);
theta_2_dot_new = The_dots(2);

The = [theta_1;theta_2] + The_dots.*dt;
theta_1_new = The(1);
theta_2_new = The(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRAINT CHECKS
% These are here to make sure we do not exceede the limits of the system as
% desired. 

if theta_1_new < theta_1_min
    theta_1_new = theta_1_min;
    if theta_1_dot_new < 0
        theta_1_dot_new = coef_restitution * -1.0 * theta_1_dot_new;
    end
elseif theta_1_new > theta_1_max
    theta_1_new = theta_1_max;
    if theta_1_dot_new > 0
        theta_1_dot_new = coef_restitution * -1.0 * theta_1_dot_new;
    end
end
    
if theta_2_new < theta_2_min
    theta_2_new = theta_2_min;
    if theta_2_dot_new < 0
        theta_2_dot_new = coef_restitution * -1.0 * theta_2_dot_new;
    end
elseif theta_2_new > theta_2_max
    theta_2_new = theta_2_max;
    if theta_2_dot_new > 0
        theta_2_dot_new = coef_restitution * -1.0 * theta_2_dot_new;
    end
end
    
      

      
      

