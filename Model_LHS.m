%% The results should be compared to the PRCC results section in
%% Supplementary Material D and Table D.1 for different N (specified by
%% "runs" in the script below)
clear all; close all;
%% [EDITABLE] Sample size N
runs=100;

%% [EDITABLE] Load Model Parameters and Variables
model.analyzeThisOutput = 'V'; % Chosen output variable name to do PRCC analysis

model.dir = pwd; %directory of ODE model and config
model = loadModel(model);
model = loadPRCCconfig(model,'lhs-prcc-modified/PRCCconfig.txt'); %contains config for PRCC min,baseline,max,initial

% Parameter Labels 
PRCC_var={'s', '\mu_T', 'r', 'k_1','k_2', '\mu_b','N_V', '\mu_V','dummy'};

% Variable Labels
y_var_label={'T','T*','T**','V'};

%% [EDITABLE] TIME SPAN OF THE SIMULATION
t_end=4000; % length of the simulations
tspan=(0:1:t_end);   % time points where the output is calculated
time_points=[2000 4000]; % time points of interest for the US analysis

%% [EDITABLE] INITIAL CONDITION FOR THE ODE MODEL
%  Change the values in the PRCCconfig.txt
% OR set manually: y0(find(strcmp(model.allStateName,'V'))) = 1e-3
y0 = [];
for yi=1:numel(model.allStateName)
    y0 = [y0, model.state.(model.allStateName{yi}).initial]; 
end

for lhsIdx=1:numel(model.paramName)
    model.param.(model.paramName{lhsIdx}).LHS = LHS_Call(model.param.(model.paramName{lhsIdx}).min,...
                                                         model.param.(model.paramName{lhsIdx}).baseline,...
                                                         model.param.(model.paramName{lhsIdx}).max,0, runs, 'unif');
end

%% LHS MATRIX and PARAMETER LABELS
LHSmatrix = [];
for lhsIdx=1:numel(model.paramName)
    LHSmatrix = [LHSmatrix model.param.(model.paramName{lhsIdx}).LHS];
end
for x=1:runs %Run solution x times choosing different values
    f=@ODE_LHS;
    x;
    LHSmatrix(x,:);
    [t,y]=ode15s(@(t,y)f(model,t,y,LHSmatrix,x),tspan,y0,[]); 
    A=[t y]; % [time y]
    %% Save the outputs at ALL time points [tspan]
    %T_lhs(:,x)=Anew(:,1);
    %CD4_lhs(:,x)=Anew(:,2);
    %T1_lhs(:,x)=Anew(:,3);
    %T2_lhs(:,x)=Anew(:,4);
    %V_lhs(:,x)=Anew(:,5);
    
    %% Save only the outputs at the time points of interest [time_points]:
    %% MORE EFFICIENT
    for stIdx=1:numel(model.allStateName)
        model.state.(model.allStateName{stIdx}).lhs(:,x) = A(time_points+1,stIdx+1);
    end
end
%% Save the workspace
save Model_LHS.mat;
% CALCULATE PRCC
alpha = 0.01; %0.05; %threshold for significant PRCCs (uncorrelated < alpha)
[prcc sign sign_label]=PRCC(LHSmatrix,model,time_points,PRCC_var,alpha);
% https://www.mathworks.com/matlabcentral/answers/376781-too-many-input-arguments-error

% PRCC_PLOT(X,Y,s,PRCC_var,y_var)
PRCC_PLOT(LHSmatrix, model.state.(model.analyzeThisOutput).lhs, length(time_points), PRCC_var, model.analyzeThisOutput)
