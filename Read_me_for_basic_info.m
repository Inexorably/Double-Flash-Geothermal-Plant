% This package was written by Francois Brissette in April 2005, 
% based on original work by Philippe Daigle, May 2002.
%
% Was tested under Matlab 6 and 7.  Should also work on older versions.
%
% Francois Brissette is a professor of Construction Engineering at Ecole de
% technologie supérieure, www.etsmtl.ca, Université du Québec, Montreal, Canada
% He teaches, amongst other things,
% basic thermodynamics. He can be reached at fbrissette@ctn.etsmtl.ca
%
% This package consists of functions that calculate basic thermodynamic properties for water. 
% All functions follow the IAPWS-97 formulation. Please note that Regions 3 and 5 have NOT
% been implemented. This has been programmed for use by
% engineering students and regions 1, 2 and 4 cover the
% useful range.  See www.iapws.org for the paper describing
% the formulation in details
%
%  The useful functions are:
%
%  WTP_PT  -  return thermodynamic state and properties from given P and T
%  WTP_vT  -  return thermodynamic state and properties from given v and T
%  WTP_vP  -  return thermodynamic state and properties from given v and P
%  WTP_uT  -  return thermodynamic state and properties from given u and T
%  WTP_uP  -  return thermodynamic state and properties from given u and P
%  WTP_xP -  return thermodynamic state and properties from given x and P
%  WTP_xT  -  return thermodynamic state and properties from given x and T
%
% where P:pressure  T:temperature  x:quality  v:specific volume  u:internal
% energy  h:enthalpy   s:entropy
%
% you are free to use, modify and distribute the functions as long
% as authorship is properly acknowledged
%
% All functions return a structure named 'outstruct' that contains the following:
% pressure in kPa, temperature in C, specific volume in m3/kg,
% internal energy in kJ/kg, enthalpy in kJ/kg, entropy in kJ/kg/K
% as well as two messages giving info such as the state or error message
% in the case of incorrect data entry
%
% The functions only use the direct equations for P and T.  An iterative scheme around
% the direct equations was setup for combinations of values including v or u. Results will
% be identical up to the tolerance defined in the function.  Default is
% 10^-7.  Select help function_name for details.
%
% The following two m-files may also be useful:
%
%  saturated_tables - 
%  will create a matrix of saturated properties for a
%  vector input of temperatures or pressure.  Useful to construct written
%  tables for use by students
%
%  superheated_tables -
%  creates superheated vapor water thermodynamics tables for a pressure
%  vector input. Useful to construct written tables for use by students
%
% All other functions included are used by the ones described above
%
% All functions have undergone a fair amount of testing. The IAPWS-97
% checkpoint have all been tested up to 12 decimals.  Entering grossly
% incorrect or impossible values or combinations of values should result in
% an appropriate error message returned to the user and not in a program
% failure.  However, experience tells that there are always remaining bugs.
% If you find any, please contact the author: fbrissette@ctn.etsmtl.ca
%