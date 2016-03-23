function [outstruct] = WTP_PT(P,T)
% -----------------------------------------------------------------
% function [outstruct] = WTP_PT(P,T)
%
% written by Francois Brissette in April 2005, 
% based on original work by Philippe Daigle, May 2002
%
% calculates basic thermodynamic properties for water, 
% follows IAPWS-97 formulation, Region 3 and 5 have NOT
% been implemented. This has been programmed for use by
% engineering students and regions 1, 2 and 4 cover the
% useful range.  See www.iapws.org for the paper describing
% the formulation in details
%
% you are free to use, modify and distribute the functions as long
% as authorship is properly acknowledge
%
% INPUTS:
% P in kPa
% T in C
%
% OUPUT:
% outstruct - a structure of strings that contains the following:
% pressure in kPa, temperature in C, specific volume in m3/kg,
% internal energy in kJ/kg, enthalpy in kJ/kg, entropy in kJ/kg/K
% as well as two messages giving info such as the state or error message
% in the case of incorrect data entry
%
% if the P-T combo falls on the saturated line within the adjustable 
% tolerance, values for the liquid and vapor condensed phase are given
% 

tol_sat=0.0001;   % maximal difference between T and Tsaturated that will result in a 'saturated state' message
                    % for a given P
Pg=0; Tg=0; vg=0; ug=0; sg=0; hg=0;
Pf=0; Tf=0; vf=0; uf=0; sf=0; hf=0;
info_msg='';
info_msg_2='';

CK=273.15;
T23=5000;



T=T+CK;    % C to K
P=P/1000;   % kpa to MPa

if T <= 623.15              % region 4
    Ts=Pressure_State(P);  
    if (Ts-T) > tol_sat 
        state=1;    % supercooled liquid
    elseif (T-Ts) > tol_sat 
        state=2;    % superheated vapour
    else
        state=3;    % saturated conditions
    end
end
    

if T > 623.15       % boundary between region 2-3
    
    state =2;    % is either saurated vapour or is out of range
    
    n1=348.05185628969;
    n2=-1.1671859879975; 
    n3=.0010192970039326;
    Ptest=n1+n2*T+n3*T^2;
    
    if P > Ptest   % region 3
        state=5;
    end
end


if P<0.0001 | T < 273.15001   % basic quality control
    state=4;
end

    

if state==1 % T < Ts, sub cooled liquid
    info_msg = 'State: subcooled liquid water'
    if T > 623.15 | P >100
        info_msg_2= 'Undefined zone: P > 100 000 kPa'
        state=6;
    else  
        [Pf,Tf,vf,uf,sf,hf] = property_PT(P,T,1); % Region 1
    end
end

if state==2  % T > Ts, Vapeur surchauffée
    info_msg = 'State: superheated vapor water'
    if T > 1073.15 | P >100
        info_msg_2= 'Undefined zone: T > 800 C ou P > 100 000 kPa'
        state=6;
    else
        [Pg,Tg,vg,ug,sg,hg] = property_PT(P,T,2); % Region 2
    end
end

if state==3  % Liquide + Vapeur
    info_msg = 'State: saturated water'
    info_msg_2= 'Need 2 independent variables to determine state'
    [Pg,Tg,vg,ug,sg,hg] = property_PT(P,Ts,2); % Region 2 for steam
    [Pf,Tf,vf,uf,sf,hf] = property_PT(P,Ts,1); % Region 1 for supercooled liquid
end

if state==4  % impossible data
    info_msg = 'Incorrect data'
    info_msg_2= 'P ou T < 0'
end

if state==5  % out of range or region 3
    info_msg = 'Région 3 IAPWS-97 non implemented'
    info_msg_2= 'or Pressure above 100 MPa'
end

Tg = Tg - 273.15;   % Kelvin to Celcius
Pg=Pg*1000;         % MPa to kPa

Tf = Tf - 273.15;   % Kelvin to Celcius
Pf=Pf*1000;         % MPa to kPa
    
% Generate output structure for html page   

if state==1   
    outstruct.Pf = ['P: ',num2str(Pf),' kPa'];
    outstruct.Tf = ['T: ',num2str(Tf),' °C'];
    outstruct.vf = ['v: ',num2str(vf),' m^3/kg'];
    outstruct.uf = ['u: ',num2str(uf),' kJ/kg'];
    outstruct.hf = ['h: ',num2str(hf),' kJ/kg'];
    outstruct.sf = ['s: ',num2str(sf),' kJ/kg*K'];
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

if state==2   
    outstruct.Pg = ['P: ',num2str(Pg),' kPa'];
    outstruct.Tg = ['T: ',num2str(Tg),' °C'];
    outstruct.vg = ['v: ',num2str(vg),' m^3/kg'];
    outstruct.ug = ['u: ',num2str(ug),' kJ/kg'];
    outstruct.hg = ['h: ',num2str(hg),' kJ/kg'];
    outstruct.sg = ['s: ',num2str(sg),' kJ/kg*K'];
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

if state==3  
    outstruct.Pf = ['P: ',num2str(Pf),' kPa'];
    outstruct.Tf = ['T: ',num2str(Tf),' °C'];
    outstruct.vf = ['v: ',num2str(vf),' m^3/kg'];
    outstruct.uf = ['u: ',num2str(uf),' kJ/kg'];
    outstruct.hf = ['h: ',num2str(hf),' kJ/kg'];
    outstruct.sf = ['s: ',num2str(sf),' kJ/kg*K'];
    outstruct.Pg = ['P: ',num2str(Pg),' kPa'];
    outstruct.Tg = ['T: ',num2str(Tg),' °C'];
    outstruct.vg = ['v: ',num2str(vg),' m^3/kg'];
    outstruct.ug = ['u: ',num2str(ug),' kJ/kg'];
    outstruct.hg = ['h: ',num2str(hg),' kJ/kg'];
    outstruct.sg = ['s: ',num2str(sg),' kJ/kg*K'];
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

if state==4  | state==5 | state==6
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

