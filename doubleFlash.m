%The variables which we have control over.
%Celsius -> Kelvin
%Note that I am debugging and calling doubleFlash.m.  This requires values
%for t2 and t6.  The below values will only be loaded if we are not looping
%in the doubleFlashLoop script.
if ~exist('loop', 'var')
    clear all
    close all
    clc
    disp('Loading standard t2 and t6 values.  No loop detected.')
    t2 = 190+273.15;   %Separator
    t6 = 140+273.15;   %Flash vessel
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Utilities
%Create an anon function for saturated enthalpies.
%hLt is saturated liquid enthalpy as function of T.
hLt = @(t) XSteam('hL_T', t-273.15);
hVt = @(t) XSteam('hV_T', t-273.15);

sLt = @(t) XSteam('sL_T', t-273.15);
sVt = @(t) XSteam('sV_T', t-273.15);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preset variables.  I am inputting typical values so I can actually test
%the script, but we can change these for specific simulations.
nHPT = 0.85;    %Efficiency of high pressure turbine, lpt respectively.
nLPT = 0.85;    %Efficiency of the low pressure turbine.
t1 = 280+273.15;   %Temperature of brine coming out of production well.
m1dot = 0.5;     %kg/s.  The mass flow rate from the production well.
mbrinedot = m1dot;  %Same thing.
t10 = 30 + 273.15;  %The temperature of the condensor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Assume that the thermodynamic properties of the brine are equivalent to
%that of water.

%The temperature of the brine coming out of the well is t1.
h1 = hLt(t1);

%Passes through isenthalpic throttle valve.
h2 = h1;

%Enters separator where sat mixture 2 is turned into sat liquid 3 and sat
%vapor 4.
h3 = hLt(t2);
h4 = hVt(t2);
x2 = (h2-h3)/(h4-h3);

%Mass flow rate into high pressure turbine, m4dot, and flash vessel, m3dot.
m4dot = x2 *  m1dot;
m3dot = (1-x2)*m1dot;

%Sat liquid exiting separator.
h6 = h3;

%From flash vessel, sat liquid 7 and vapour 8.
h7 = hLt(t6);
h8 = hVt(t6);
x6 = (h6 - h7)/(h8-h7);
m6dot = m3dot;

%Mass flow rate of sat steam exiting flash vessel, 8, is from quality 6.
m8dot = x6 * m6dot;

%Into inejection well.
m7dot = (1-x6)*m6dot;

%High pressure turbine.
s5s = sVt(t2);
s7 = sLt(t6);
s8 = sVt(t6);
x5s = (s5s - s7)/(s8 - s7);
h5s = h7 + x5s * (h8 - h7);

%Baumannn Rule. n = efficency of turbine.
%Typical value is 0.85.
%LPT == Low Pressure Turbine.
ALPT = (nLPT/2)*(h4-h5s);
x4 = 1;
h5 = ((h4 - ALPT) * (x4 - (h7/(h8-h7))))/(1+ALPT/(h8-h7));

%The entropy at state 5, s5.  We find x5 from enthalpy, and then use it to
%find entropy.
%Steins
x5 = (h5 - h7)/(h8-h7);
% x5 = IAPWS_IF97('x_hT', h5, T6);
s5 = x5*(s8-s7)+s7;

%Power output of the high pressure turbine.
Whptdot = m4dot * (h4 - h5);

%Low pressure turbine.
m5dot = m4dot;

%Saturated steam 8 exits the flash vessel to mix with saturated mixture
%exiting the high pressure turbine to create a high quality saturated
%mixture, 9, with a mass flow rate equal to sum.
m9dot = m5dot + m8dot;
h9 = (m5dot * h5 + m8dot * h8)/m9dot;
x9 = (h9-h7)/(h8-h7);
s9 = s7 + x9 * (s8 - s7);

%State 10s is from the saturated mixture assuming isentropic expansion
%through low pressure turbine.
s10s = s9;
s11 = sLt(t10);
s12 = sVt(t10);
x10s = (s10s - s11)/(s12 - s11);
h11 = hLt(t10);
h12 = hVt(t10);
h10s = h11 + x10s * (h12 - h11);

%Apply the Baumann rule again.
AHPT = 0.5 * nHPT/2 * (h9 - h10s);
h10 = (h9 - AHPT * (x9 - h11/(h12 - h11)))/(1 + AHPT/(h12-h11));

%Find x10 and through that s10.
%Steins
%Need to account for superheated (greater than 1).  This will be done in
%the filter section in doubleFlashLoop.m.
x10 = (h10-h11)/(h12 - h11);
s10 = x10 * (s12 - s11) + s11;

%Power output of the lp turbine.
Wlptdot = m9dot * (h9 - h10);

%The total power output.
Wtotaldot = Wlptdot + Whptdot;

%Specific power output.
w = Wtotaldot/mbrinedot;

%Constraints.
%Upper limit on silica saturation index (SSI).
%Qeq is the equlibrium concentration of crystalline quartz assuming no
%salinity of brine.
syms varQeq
eqn1 = -42.198 + 0.28831 * varQeq - 3.6686*10^-4*varQeq^2+3.1665*10^-7*varQeq^3+77.034*log(varQeq) == t1 - 273.15;  %Celsius
Qeq = solve(eqn1, varQeq);

%Crystalline quartz transforms into amorphous silica as it cools, and
%concentration of amorphous silica in the remaining brine, S becomes
%greater than Qeq as brine is flashed to steam.
S = Qeq * m1dot / m7dot;

%We now find the equilibrium concentration of amorphous silica, Seq (ppm),
%using Fournier and Marshall correlation.
syms varSeq
t7 = XSteam('T_hs', h7, s7) + 273.15;   %Kelvin
eqn2 = log(varSeq/58400) == -6.116 + 0.01625 * t7 - 1.758 * 10^-5 * t7^2 + 5.257*10^-9*t7^3;
Seq = solve(eqn2, varSeq);

%Calculate SSI.
SSI = S/Seq;