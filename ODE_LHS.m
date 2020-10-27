function dydt=TBmodel(model,t,y,LHSmatrix,x)
%% PARAMETERS %%
Tmax=1500; % Set constant parameters here. Don't initialize in config.txt

% Load parameter from LHSmatrix
s=LHSmatrix (x,find(strcmp(model.paramName,'s')));
muT=LHSmatrix (x,find(strcmp(model.paramName,'muT')));
r=LHSmatrix (x,find(strcmp(model.paramName,'r')));
k1=LHSmatrix (x,find(strcmp(model.paramName,'k1')));
k2=LHSmatrix (x,find(strcmp(model.paramName,'k2')));
mub=LHSmatrix (x,find(strcmp(model.paramName,'mub')));
N=LHSmatrix (x,find(strcmp(model.paramName,'N')));
muV=LHSmatrix (x,find(strcmp(model.paramName,'muV')));
dummy_LHS=LHSmatrix (x,find(strcmp(model.paramName,'dummy')));

% Load state value from y
T0 = y(find(strcmp(model.allStateName,'T0')));
T1 = y(find(strcmp(model.allStateName,'T1')));
T2 = y(find(strcmp(model.allStateName,'T2')));
V = y(find(strcmp(model.allStateName,'V')));

% [T] CD4+ uninfected: Tsource + Tprolif - Tinf
Tsource = s - muT*T0;
Tprolif = r*T0*(1-(T0+T1+T2)/Tmax);
Tinf = k1*T0*V;

% [T1] CD4+ latently infected: Tinf - T1death - T1inf
T1death = muT*T1;
T1inf = k2*T1;

% [T2] CD4+ actively infected: T1inf - T2death
T2death = mub*T2;

% [V] Free infectious virus: Vrelease - Tinf - Vdeath
Vrelease = N*T2death;
Vdeath = muV*V;

dydt = [Tsource + Tprolif - Tinf;
        Tinf - T1death - T1inf;
        T1inf - T2death;
        Vrelease - Tinf - Vdeath];