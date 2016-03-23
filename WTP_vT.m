function [outstruct] = WTP_vT(v,T)
% -----------------------------------------------------------------
% function [outstruct] = WTP_PT(v,T)
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
% v specific volume in m3/kg
% T in C
%
% OUPUT:
% outstruct - a structure of strings that contains the following:
% pressure in kPa, temperature in C, specific volume in m3/kg,
% internal energy in kJ/kg, enthalpy in kJ/kg, entropy in kJ/kg/K
% as well as two messages giving info such as the state or error message
% in the case of incorrect data entry
%
% NB: This function does not use the reverse equations of the formulation
% but iterated using the direct equations for P and T.  Results will
% be identical up to the tolerance defined in the function.  Default is
% 10^-7
%


Pg=0; Tg=0; vg=0; ug=0; sg=0; hg=0;
Pf=0; Tf=0; vf=0; uf=0; sf=0; hf=0;
info_msg='';
info_msg_2='';

CK=273.15;
T=T+CK;    % C to K

% first step - establish the thermodynamic state by supposing first that
% consitions are saturated
%

P=Thermo_State(T);

if T <= 623.15
    [Pg,Tg,vg,ug,sg,hg] = property_PT(P,T,2); % Region 4 for steam
    [Pf,Tf,vf,uf,sf,hf] = property_PT(P,T,1); % Region 1 for supercooled liquid
    if v < vg & v > vf
        state=3;    % saturated
    end
    
    if v < vf
        [Pf,Tf,v_test,uf,sf,hf] = property_PT(100,T,1); 
        state=1;   % supercooled liquid
    end
    
    if v > vg
        state=2;   % superheated vapour
    end
    
     [Pf,Tf,v_test2,uf,sf,hf] = property_PT(0.000001,T,2); 
    if v > v_test2
        state=5;   % v will result in P too close to zero
    end
end

if T > 623.15  % either it's superheated vapour, or it is out of range
    n1=348.05185628969;
    n2=-1.1671859879975; 
    n3=.0010192970039326;
    Ptest=n1+n2*T+n3*T^2;   % calculate P in boundary between region 2 and 3
    if Ptest>100
        Ptest=100;
    end
    [Pg,Tg,vg,ug,sg,hg] = property_PT(Ptest,T,2); % Region 2
    
    if v > vg
        state=2;   % superheated vapour
    end
    
    if v < vg 
        state=4;    % region 3 or P > 100 000
    end
    
end


if T < 273.15001 | v<0  % basic quality control
    state=5;
end

    

if state==1 % T < Ts, Liquide comprimé
    info_msg = 'State: subcooled liquid water'
    if v < v_test 
        info_msg_2= 'Undefined zone: P > 100 000 kPa'
        Pf=0; Tf=0; vf=0; uf=0; sf=0; hf=0;
    else  
        % iterate to find correct solution
        Pmax=100000;
        Pmin=P;
        tol=0.0000001;
        v_est=100000000;
        while abs(v_est-v)>tol
            Pavg=0.5*(Pmin+Pmax);
            [Pf,Tf,v_est,uf,sf,hf] = property_PT(Pavg,T,1); 
            if v_est < v
                Pmax=Pavg;
            else
                Pmin=Pavg;
            end
        end
        vf=v_est;
    end
end

if state==2  % T > Ts, Vapeur surchauffé
    info_msg = 'State: superheated vapor water'
    if T > 1073.15 | P >100
        info_msg_2= 'Undefined zone: T > 800 C ou P > 100 000 kPa'
        Pg=0; Tg=0; vg=0; ug=0; sg=0; hg=0;
    else 
        % iterate to find correct solution
        if T <= 623.15 
            Pmax=P;
        else
            Pmax=Ptest;
        end
        Pmin=0.000001;
        tol=0.000001;
        v_est=100000000;
        while abs(v_est-v)>tol
            Pavg=0.5*(Pmin+Pmax);
            [Pg,Tg,v_est,ug,sg,hg] = property_PT(Pavg,T,2); 
            if v_est < v
                Pmax=Pavg;
            else
                Pmin=Pavg;
            end
        end
        vg=v_est;
    end
end

if state==3  % Liquide + Vapeur
    info_msg = 'State: saturated water'
        [Pg,Tg,vg,ug,sg,hg] = property_PT(P,T,2); % Region 4 for steam
        [Pf,Tf,vf,uf,sf,hf] = property_PT(P,T,1); % Region 1 for supercooled liquid
        x=(v-vf)/(vg-vf);
        vt=v;
        ut=uf+x*(ug-uf);
        ht=hf+x*(hg-hf);
        st=sf+x*(sg-sf);
    end
end

if state==4  % impossible data
    info_msg = 'Région 3 IAPWS-97 non implemented'
    info_msg_2= 'or Pressure > 100000 kPa'
end

if state==5  % impossible data
    info_msg = 'incorrect data'
    info_msg_2= 'P or T < 0, or P to close to 0'
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

if state==5   
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end

