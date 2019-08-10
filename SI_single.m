function  [SI, SI_PHREEQC] = SI_single(IKSinput)
%
% Used to calculate a calcite/dolomite/aragonite/CO2(g) SI for a single
% water sample/measurement
% Input: IKSinput.XXX >>
%
% .database- string name of database file, usually
%            'phreeqc.dat' (default, place in folder with function please)
%            If not in function folder then do:
%            .database = ['whatever path' '\USGS\IPhreeqcCOM 3.3.7-11094\database\phreeqc.dat']
%
% .units- string for units 'mmol/L' or 'mol/L' or 'mg/L' or any other accepted in Matlab.
%         Otherwise, mg/L is the default
%
% .data- int of data in this order: T,pH,Ca,Mg,Na,Cl,NO3,SO4,Alkalinaty
%        insert zeros where if value
%
%
% Output: SI and SI_PHREEQC (w titles): calcite,dolomite,aragonite,CO2(g)
%
% Created by Yuval Burstyn (yuval.burstyn@mail.huji.ac.il)
%
  
% Test input structure
eval('x=1;IKSinput.database;','x=0;');
eval('y=1;IKSinput.units;','y=0;');
eval('z=1;IKSinput.data;','z=0;');

if x == 0
    IKSinput.database = ('phreeqc.dat'); %default
    %fprintf('Make sure phreeqc.dat is in the same folder as fuction');
end
if y == 0
    IKSinput.units = ('mg/L');
end
if z == 0
   fprintf('Please enter .data');
   return
elseif length(IKSinput.data) ~= 9
    fprintf('Please enter the requested 9 paramters (see help)');
    return
end

% initialize COM object and check database
iphreeqc = actxserver('IPhreeqcCOM.Object');

% remove this if using function in loop, it will annoy you.
if iphreeqc.LoadDatabase(IKSinput.database) == 0;
    fprintf('Database checked and loaded\n')
else
    fprintf('Database contains errors\n')
    return
end

%Clear previous ipheeqc run
iphreeqc.ClearAccumulatedLines;

% --------Build input string--------
iphreeqc.AccumulateLine ('SOLUTION 1 ');

%Set defaults to be using if no input - you can change the defaults 
iphreeqc.AccumulateLine ('-ph 8.0');
iphreeqc.AccumulateLine ('-temp 22');

%Units to use mol/L or mg/L
iphreeqc.AccumulateLine (['-units ' IKSinput.units]);

%Build the matrix paramter + value
iphreeqc.AccumulateLine (['Ca ' num2str(IKSinput.data(3))]);
iphreeqc.AccumulateLine (['Mg ' num2str(IKSinput.data(4))]);
iphreeqc.AccumulateLine (['Na ' num2str(IKSinput.data(5))]);
iphreeqc.AccumulateLine (['Cl ' num2str(IKSinput.data(6))]);
iphreeqc.AccumulateLine (['N(5) ' num2str(IKSinput.data(7))]);
iphreeqc.AccumulateLine (['S(6) ' num2str(IKSinput.data(8))]);
iphreeqc.AccumulateLine (['Alkalinity ' num2str(IKSinput.data(9))]);
% pH must! be ~=0
if IKSinput.data(2) ~= 0
iphreeqc.AccumulateLine (['pH ' num2str(IKSinput.data(2))]);
else fprintf('Used default pH\n');
end
% T should be ~=0
if IKSinput.data(1) ~= 0
iphreeqc.AccumulateLine (['Temp ' num2str(IKSinput.data(1))]);
else fprintf('Used default pH\n');
end

% --------Output block--------
iphreeqc.AccumulateLine ('SELECTED_OUTPUT');
iphreeqc.AccumulateLine ('-reset false');
iphreeqc.AccumulateLine ('-SI Calcite Dolomite Aragonite CO2(g)');
%iphreeqc.AccumulateLine ('-activities Ca+2 CO3-2');
%iphreeqc.AccumulateLine ('-ionic_strength');
%iphreeqc.AccumulateLine ('-pH');
iphreeqc.AccumulateLine ('END');

% -------- Run this bad boy--------
try
    iphreeqc.RunAccumulated;
catch
    return;
end
% Exploit!
SI_PHREEQC = iphreeqc.GetSelectedOutputArray;
SI = [SI_PHREEQC{2,:}];

%close all existing IPhreeqc COM objects
iphreeqc.delete  % May cause longer loops, test if looping

end
