
%
% creates superheated vapor water thermodynamics tables for each pressure
% in the pressure vector entered below
%
% returns matrices named P_nnnn  where nnnn is the pressure in kPa with 5
% columns: T(C) v(m3/kg) u(kJ/kg) h(kJ/kg) s(kJ/kg/K)
%
clear all
P=[10 50 100:100:600 800 1000:200:2000 2500:500:5000  6000:1000:10000];   % in kPa : maximum P is 16529 kPa

j=length(P);
Tmax=800;   % maximum temperature in C,  800 is the max
dt=50;  % delta T temperature

P=P/1000;   % kPa to MPa
CK=273.15;


for i=1:j
    Tsat=Pressure_State(P(i));
    T50=ceil((Tsat-CK)/50)*50;
    T=[Tsat-CK T50:dt:Tmax];
    k=length(T);
    for n=1:k
        PP=P(i)*1000;
        eval(['P_' num2str(PP) '=zeros(k,5);']);
    end
    
    for n=1:k
        [Pg,Tg,vg,ug,sg,hg] = property_PT(P(i),T(n)+CK,2);
        Pg=Pg*1000;  
        Tg=Tg-CK;
        eval(['P_' num2str(Pg) '(n,:)=[Tg vg ug hg sg];']);
    end
end



