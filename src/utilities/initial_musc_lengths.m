function l_0 = initial_musc_lengths(theta_1, theta_2)
% FUNCTION DESCRIPTION
%   You give the intial state of the arm (position) in terms of the 
%   two angles theta-1 and theta-2. Given the parameters hardcoded here
%   this will give you the position of the muscles at this state.
%
%   Why is this helpful? Muscle force calculations are based in part on a 
%   rest position, so we here can calculate that. 
% INPUTS
%   theta_1: angle between coordinate system and link 1 of the arm
%       (radians)
%   theta_2: angle between system link 1 and system link 2 of the arm 
%       (radians)
% OUTPUTS
%    l_0: 6x1 vector of muscle lengths in meters, where each muscle length
%        should line up with the order in which muscles are given in the
%        arm simulation. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arm parameters (excluding muscles)

% Upper arm (length, mass, Intertia, and mass-center)
L_1 = 0.310; % (m)

% Fore arm (length, mass, Intertia, and mass-center)
L_2 = 0.1700; % (m)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Muscle parameters 

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
% Muscle lengths 

% Finding lengths of the muscles l-1 through l-9
l_0 = [ (r_1^2 + s_1^2 + 2*r_1*s_1*cos(theta_1))^.5; ...
      (r_2^2 + s_2^2 - 2*r_2*s_2*cos(theta_1))^.5; ...
      (r_3^2 + s_3^2 + 2*r_3*s_3*cos(theta_2))^.5; ...
      (r_4^2 + s_4^2 - 2*r_4*s_4*cos(theta_2))^.5; ...
      (w_51^2 + w_52^2 + L_1^2 + 2*w_51*L_1*cos(theta_1) + 2*w_52*L_1*cos(theta_2) + 2*w_51*w_52*cos(theta_1 + theta_2))^.5; ...
      (w_61^2 + w_62^2 + L_1^2 - 2*w_61*L_1*cos(theta_1) - 2*w_62*L_1*cos(theta_2) + 2*w_61*w_52*cos(theta_1 + theta_2))^.5];