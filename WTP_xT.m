function [outstruct] = WTP_xT(x,T)
% -----------------------------------------------------------------
% function [outstruct] = WTP_xT(x,T)
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
% as authorship is properly acknowledged
%
% INPUTS:
% x quality between 0 and 1
% T in C
%
% OUPUT:
% outstruct - a structure of strings that contains the following:
% pressure in kPa, temperature in C, specific volume in m3/kg,
% internal energy in kJ/kg, enthalpy in kJ/kg, entropy in kJ/kg/K
% as well as two messages giving info such as the state or error message
% in the case of incorrect data entry
%

Pg=0; Tg=0; vg=0; ug=0; sg=0; hg=0;
Pf=0; Tf=0; vf=0; uf=0; sf=0; hf=0;
info_msg='';
info_msg_2='';

CK=273.15;
T23=5000;

T=T+CK;    % C to K
P=Thermo_State(T);

if T<(CK+0.0001) | x < 0 | x > 1
    state=4;
    info_msg = 'Incorrect data entry'
    info_msg_2= 'T<0.0001C or x<0 or x>1'
elseif T>623.15 & T<647.096
    state=4;
    info_msg = 'IAPWS region 3 not implemented'
    info_msg_2= 'T must be smaller than 350 C'
elseif T>=647.096
    state=4;
    info_msg = 'T is above critical point'
    info_msg_2= 'x makes no sense'
else
    state=3;
end


if state==3  % Liquide + Vapeur
    info_msg = 'State: saturated water'
    info_msg_2= '';
    [Pg,Tg,vg,ug,sg,hg] = property_PT(P,T,2); % Region 4 for steam
    [Pf,Tf,vf,uf,sf,hf] = property_PT(P,T,1); % Region 1 for supercooled liquid
    vt=vf+x*(vg-vf);
    ut=uf+x*(ug-uf);
    ht=hf+x*(hg-hf);
    st=sf+x*(sg-sf);
end


T = T - CK;   % Kelvin to Celcius
P=P*1000;         % MPa to kPa

    
% Generate output structure for html page   

if state==3  
    outstruct.P = ['P: ',num2str(P),' kPa'];
    outstruct.T = ['T: ',num2str(T),' °C'];
    outstruct.x = ['x: ',num2str(x)];
    outstruct.vt = ['v: ',num2str(vt),' m^3/kg'];
    outstruct.ut = ['u: ',num2str(ut),' kJ/kg'];
    outstruct.ht = ['h: ',num2str(ht),' kJ/kg'];
    outstruct.st = ['s: ',num2str(st),' kJ/kg*K'];
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

if state==4 
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

