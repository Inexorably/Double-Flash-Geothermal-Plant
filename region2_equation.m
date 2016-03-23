function [gamma_0,gamma_pi0,gamma_r,gamma_pir,gamma_t0,gamma_tr] = region2_equation(dimless_pi,dimless_t)
% -----------------------------------------------------------------
% Author: Philippe Daigle
% Date: 9 juin 2002
% gamma value for region 2
% -----------------------------------------------------------------
[J0,n0,I,J,n] = gibbstable2;
cnt1 = 1:9;
cnt2 = 1:43;
gamma_0 = log( dimless_pi ) + sum( n0(cnt1) .* ( dimless_t ) .^ J0(cnt1) );
gamma_pi0 = 1 / dimless_pi + 0;
gamma_r = sum( n(cnt2) .* ( dimless_pi ).^I(cnt2) .* ( dimless_t - 0.5 ).^J(cnt2) );
gamma_pir = sum( n(cnt2) .* I(cnt2) .* ( dimless_pi ).^( I(cnt2) - 1 ) .* ( dimless_t - 0.5 ).^J(cnt2) );
gamma_t0 = 0 + sum( n0(cnt1) .* J0(cnt1) .* ( dimless_t ).^( J0(cnt1) - 1 ));
gamma_tr = sum( n(cnt2) .* ( dimless_pi ).^( I(cnt2) ) .* J(cnt2) .* ( dimless_t - 0.5 ).^( J(cnt2) - 1) );