% ----------------------------------------------------------------------
% Parameter setting for the visco-elastic problem
% domains   - number of subdomains (no 1 is the one on the surface )
% L         - length (horizontal size) of the domain                (m)
% H         - vertical size of the domain                           (m)
% L_char    - characteristic length of the domain = max(L,H)        (m)
% l_ice     - max width of the ice sheet                            (m)
% h_ice     - max height of the ice sheet                           (m)
% nju       - Poisson ratio (per subdomain)                dimensionless
% E         - Young modulus (per subdomain)      (Pa = N/m^2 = kg/(m.s^2))
% rho_ice   - ice density                                        (kg/m^3)
% rho_earth - Earth density                                      (kg/m^3)
% eta       - viscosity                                          (Pa s)
% grav      - gravity constant                                    (m/s)
% S_char    - characteristic stress (S=max(E_i), i = 1:domains)    (Pa)
% U_char    - characteristic displacement                           (m)
% scal_fact - scaling factor (L/(S*U)                            (m/Pa)
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% T_BEG     - time >0, when the ice load starts to be imposed
% T_LGM     - time to reach the glacial maximum
% T_EOG     - time for the ice to melt
% T_run     - time to run after the ice has melted
% load_surf - load surface = 1(boxcar), 2(ellpce), 3(hyperbola)
%
% The array 'Disco' describes the discontinuity regions
% Disco(*,*,k) is the kth region
% Disco(*,1,k) x-interval
% Disco(*,2,k) y-interval
% --------------------------
% Discoef(1,k) = nju    in region k
% Discoef(2,k) = E      in region k
% Discoef(3,k) = mu/eta in region k
%
%    --------------------
%    |                  |
%    |                  | 
%    |                  |
%    |                  |
%    |   Omega          | 
%    --------------------


%
function [L,H,l_ice,h_ice,rho_ice,rho_earth,...
    Disco,Discoef,grav,load_surf,...
    L_char, S_char, U_char, N_char, T_char, ...
    T_LGM, T_EOG, T, delta_t_char] = Elasto_parameters(domains,wh,Emagn)
%% - - - - - - problem and geometry parameters
% - - - - - Tuned to Wu paper "Deformation of an incompressible viscoelastic 
% - - - - - - - - flat earth with power law creep" page 37
E_domains = 1*ones(domains,1); % Young's modulus, Pa

L0         = 1;   % m
H(1)       =-1;   % m
l_ice0     = 1;   % m
h_ice0     = 1.1080e-05;   % m
rho_ice0   = 920;   % kg/m^3
rho_earth0 = 5000;   % kg/m^3
nju(1)     = 0.25;   % dimensionless
eta0       = 1.45e+21;  % Viscosity Pa s
grav       = 9.81;   % m/s^2
Years      = 18400; % total simulation time (years)
T_LGM0     = 0; %90000*secs_per_year;         % Last Glaciation Maximum duration in seconds.
T_EOG0     = 0; %T_LGM0+10000*secs_per_year;  % End of Glaciation.


load_surf  = []; %18.1e+6;% pa

%% Rescaling 
E0            = max(E_domains); % Pa
mju0          = E_domains./(2*(1+nju'));
secs_per_year = 365*24*3600; % Duration of a year in seconds
T0            = Years*secs_per_year; % s - total simulation time in seconds

% - - - - - - characteristic values to obtain dimensionless problem
L_char     = abs(L0);  %L_char=max(abs(L),abs(H));
S_char     = E0;       %S_char=max(E) in all subdomains
U_char     = 1;
N_char     = eta0; % max(of eta) in all subdomains
T_char     = N_char/S_char; % so that S_char*T_char/N_char = 1
%- - - - -



% - - - - - - scaled values
L  = L0/L_char;
H  = H/L_char;
E  = E_domains/S_char;
l_ice     = l_ice0/L_char;
h_ice     = h_ice0/L_char;
rho_ice   = rho_ice0;   
rho_earth = rho_earth0; 
eta       = eta0/N_char; % 
T         = T0/T_char;
T_LGM     = T_LGM0/T_char;
T_EOG     = T_EOG0/T_char;
delta_t_char = secs_per_year/T_char;

Disco(1,1,1:domains) =  0;   %form x
Disco(2,1,1:domains) =  L;   %to   x
%  Horizontal split of the domain into strips (two in this case)
Disco(1,2,1) =  0;     %from y
Disco(2,2,1) = H(1);   %to   y
%(1,2,2) = H(1);   %from y
%Disco(2,2,2) = H(2);   %to   y

Discoef(1,1:domains) = nju(1:domains);
Discoef(2,1:domains) = E';
mju                  = mju0/S_char;
Discoef(3,1:domains) = mju(1:domains)'/eta;% inverse of the Maxwell time

return
