function [pressure,temperature,v,u,s,h] = property_PT(pressure,temperature,region)
% -----------------------------------------------------------------
% Author: Philippe Daigle
% Date: 10 mai 2002
% Calculation of thermodynamics value depend of entry
% -----------------------------------------------------------------    
R = .461526;
switch region,
case {1,4},
    dimless_pi = pressure / (16.53);
    dimless_t = 1386 / temperature;
    v = ( dimless_pi * gammapi(dimless_pi,dimless_t) * R .* temperature ) / (pressure*10^3);
    u = ( dimless_t * gammaT(dimless_pi,dimless_t) - dimless_pi * gammapi(dimless_pi,dimless_t) ) * R * temperature;
    s = ( dimless_t * gammaT(dimless_pi,dimless_t) - gamma(dimless_pi,dimless_t) ) * R;
    h = ( dimless_t * gammaT(dimless_pi,dimless_t) ) * R * temperature;
case 2,
    dimless_pi = pressure / (1);
    dimless_t = 540 / temperature;
    [gamma_0,gamma_pi0,gamma_r,gamma_pir,gamma_t0,gamma_tr] = region2_equation(dimless_pi,dimless_t);
    v = dimless_pi * ( gamma_pi0 + gamma_pir ) * R * temperature / (pressure*10^3);
    u = R * temperature * ( dimless_t * ( gamma_t0 + gamma_tr ) - dimless_pi * ( gamma_pi0 + gamma_pir) );
    s = R * ( dimless_t * ( gamma_t0 + gamma_tr ) - ( gamma_0 + gamma_r ) );
    h = dimless_t * ( gamma_t0 + gamma_tr ) * R * temperature;
otherwise,
    pressure = 0;temperature = 0;v = 0;u = 0;s = 0;h = 0;
end
