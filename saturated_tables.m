
%
% written by Francois Brissette in April 2005, 
% based on original work by Philippe Daigle, May 2002
%
% calculates saturated water tables for printing, up to 350C.  Saves in
% ASCII format
%
% follows IAPWS-97 formulation, Region 3 and 5 have NOT
% been implemented. This has been programmed for use by
% engineering students and regions 1, 2 and 4 cover the
% useful range.  See www.iapws.org for the paper describing
% the formulation in details.
%
% as such, you should NOT enter temperatures above 350C or corresponding
% pressure above 16529 kPa
%
% you are free to use, modify and distribute the functions as long
% as authorship is properly acknowledged
%

clear all
cas=1;    % 1=temp 2=pressure

CK=273.15;

if cas==1
	Temp=[0.01 5:5:350];  % T in C : DO NOT USE T above 350 !!!!  Results will be incorrect !!!
	Temp=Temp+CK;
	Pres=Thermo_State(Temp);
end

if cas==2
	P1=Thermo_State(0.01+CK)*1000;      % in kPa
	Pres=[P1 1:10 15:5:30 40:10:90 100:25:500 550:50:1000 1100:100:2000 2500:500:10000 11000:1000:16000];  % in kPa: DO NOT USE P above 16 529 kPa !!!!  Results will be incorrect !!!
	Pres=Pres/1000;   % kpa to MPa
	Temp = Pressure_State(Pres);
end


k=length(Temp);
P=length(Temp);
vg=length(Temp);
ug=length(Temp);
hg=length(Temp);
sg=length(Temp);
uf=length(Temp);
hf=length(Temp);
sf=length(Temp);

for i=1:k

    [P(i),T(i),vg(i),ug(i),sg(i),hg(i)] = property_PT(Pres(i),Temp(i),2); % saturated properties - gas
    [pp,tt,vf(i),uf(i),sf(i),hf(i)] = property_PT(Pres(i),Temp(i),1); % saturated properties - liquid
    
end

      
T = Temp - CK;  % Kelvin to Celcius
P=P*1000;           % MPa to kPa

if cas==1
    properties_steam_T=[T' P' vf' vg' uf' ug' hf' hg' sf' sg'];
    save properties_steam_T properties_steam_T -ascii
end


if cas==2
    properties_steam_P=[P' T' vf' vg' uf' ug' hf' hg' sf' sg'];
    save properties_steam_P properties_steam_P -ascii
end

    



