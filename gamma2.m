function result = gamma(dimless_P,dimless_T)
% -----------------------------------------------------------------
% Author: Philippe Daigle
% Date: 10 mai 2002
% gamma value for a adimensionnal pressure and a adimensionnal 
% temperature
% -----------------------------------------------------------------
[I,J,n] = gibbstablePT;
cnt = 1:34;
result = sum( n(cnt) .* (7.1 - dimless_P).^I(cnt) .* (dimless_T - 1.222).^J(cnt) );
