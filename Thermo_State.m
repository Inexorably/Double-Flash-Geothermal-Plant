function Ps = Thermo_State(Ts)
n = satTable;
T_dimless = 1;
P_dimless = 1;
V = Ts ./ T_dimless + n(9) ./ ( (Ts / T_dimless) - n(10) );
A = V.^2 + n(1) .* V + n(2);
B = n(3) * V.^2 + n(4) * V + n(5);
C = n(6) * V.^2 + n(7) * V + n(8);
Ps = P_dimless * (( 2 * C ) ./ ( -B + ( B.^2 - 4 * A .* C ).^(1/2) )).^4;
