function [outstruct] = WTP_uP(u,P)
% -----------------------------------------------------------------
% function [outstruct] = WTP_PT(u,P)
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
% u internal energy in kJ/kg
% P in kPa
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
P=P/1000;  % kPa to MPa

% first step - establish the thermodynamic state by supposing first that
% consitions are saturated
%

T=Pressure_State(P);

if P <= 16.53
    [Pg,Tg,vg,ug,sg,hg] = property_PT(P,T,2); % Region 4 for steam
    [Pf,Tf,vf,uf,sf,hf] = property_PT(P,T,1); % Region 1 for supercooled liquid
    if u < ug & u > uf
        state=3;    % saturated
    end
    
    if u < uf
        [Pf,Tf,vf,u_test,sf,hf] = property_PT(P,0.0001,1); 
        state=1;   % supercooled liquid
    end
    
    if u > ug
        state=2;   % superheated vapour
    end
end

if P > 16.53  % either it's condensed liquid if T < 350, superheated vapour if in region 2, or it is out of range (region 3)
    n3=.0010192970039326;
    n4=572.54459862746;
    n5=13.918839778870;
    Ttest=n4+sqrt((P-n5)/n3);
  
    [Pg,Tg,vg,u_test2,sg,hg] = property_PT(P,350+CK,1);  % verify the volume for condensed liquid at 350
    if u<u_test2     % we are in region 1
        state=1;
    end
    
    if Ttest>863.15     % T at which P = 100MPa along the line separating regions 2 and 3
        Ttest=863.15;
    end
    [Pg,Tg,vg,ug,sg,hg] = property_PT(P,Ttest,2); % Region 2
    
    if u > ug
        state=2;   % superheated vapour
    end
    
    if u < ug & u > u_test2
        state=4;    % out of range
    end
    
    if P > 100
        state=4;    % outside of range
    end
end

[Pg,Tg,vg,u_test3,sg,hg] = property_PT(P,800+CK,2); % Region 2

if u > u_test3
    state=4;    
end

if T < 273.15001   % basic quality control
    state=5;
end

if u < 0.00001   % basic quality control
    state=6;
end
    

if state==1 %  Liquide comprimé
    info_msg = 'State: subcooled liquid water'
    if P > 16.53  % iterate to find correct solution      
        Tmax=350+CK;
        Tmin=CK+0.00001;
    else
        Tmax=T;
        Tmin=CK+0.00001;
    end  
    
    % verify volume is within the bounds
           [Pf,Tf,vf,ut1,sf,hf] = property_PT(P,Tmin,1); 
           [Pf,Tf,vf,ut2,sf,hf] = property_PT(P,Tmax,1); 
    if u < ut2 & u >ut1       
        tol=0.0000001;
        u_est=100000000;
        while abs(u_est-u)>tol
            Tavg=0.5*(Tmin+Tmax);
            [Pf,Tf,vf,u_est,sf,hf] = property_PT(P,Tavg,1); 
            if u_est < u
                Tmin=Tavg;
            else
                Tmax=Tavg;
            end
        end
        uf=u_est;
        
    else
        state=6;
    end
end


if state==2  % T > Ts, Vapeur surchauffé
    info_msg = 'State: superheated vapor water'
    if T > 1073.15 | P >100
        info_msg_2= 'Undefined zone: T > 800 C ou P > 100 000 kPa'
        Pg=0; Tg=0; vg=0; ug=0; sg=0; hg=0;
    else 
        % iterate to find correct solution
        
        Tmax=1073.15;
        
        if P < 16.53
            Tmin=T;
        else
            Tmin=Ttest;
        end
        
        tol=0.000001;
        u_est=100000000;
        while abs(u_est-u)>tol
            Tavg=0.5*(Tmin+Tmax);
            [Pg,Tg,vg,u_est,sg,hg] = property_PT(P,Tavg,2); 
            if u_est < u
                Tmin=Tavg;
            else
                Tmax=Tavg;
            end
        end
        ug=u_est;
    end
end

if state==3  % Liquide + Vapeur
    info_msg = 'State: saturated water'
        [Pg,Tg,vg,ug,sg,hg] = property_PT(P,T,2); % Region 4 for steam
        [Pf,Tf,vf,uf,sf,hf] = property_PT(P,T,1); % Region 1 for supercooled liquid
        x=(u-uf)/(ug-uf);
        ut=u;
        vt=vf+x*(vg-vf);
        ht=hf+x*(hg-hf);
        st=sf+x*(sg-sf);
        
end

if state==4  % impossible data
    info_msg = 'Région 3 IAPWS-97 non implemented'
    info_msg_2= 'or P > 100000 kPa ou T > 800C'
end

if state==5  % impossible data
    info_msg = 'Incorrect data'
    info_msg_2= 'P ou T < 0'
end

if state==6  % impossible data
    info_msg = 'Incorrect data'
    info_msg_2= 'u < 0.00001 m/kg or impossible data'
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

if state==4 | state==5 | state==6
    outstruct.info_msg=info_msg;
    outstruct.info_msg_2=info_msg_2;
end


