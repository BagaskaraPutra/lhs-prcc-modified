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

alpha = 0.001; %0.05; %threshold for significant PRCCs (uncorrelated < alpha)
% Parameter Labels 
PRCC_var = model.paramLabel; %{'s', '\mu_T', 'r', 'k_1','k_2', '\mu_b','N_V', '\mu_V','dummy'};

% Variable Labels
y_var_label = model.yVarLabel; %{'T','T*','T**','V'};

%% [EDITABLE] TIME SPAN OF THE SIMULATION
t_end = 4000; % length of the simulations
tspan = (0:1:t_end);   % time points where the output is calculated
time_points = [2000 4000]; % time points of interest for the US analysis

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
% save Model_LHS.mat;
% CALCULATE PRCC
[prcc sign sign_label hFig] = PRCC(LHSmatrix,model,time_points,PRCC_var,alpha);
% https://www.mathworks.com/matlabcentral/answers/376781-too-many-input-arguments-error

% PRCC_PLOT(X,Y,s,PRCC_var,y_var)
% PRCC_PLOT(LHSmatrix, model.state.(model.analyzeThisOutput).lhs, length(time_points), PRCC_var, model.analyzeThisOutput)

prompt = 'Do you want to save all variables and figures? If yes, Enter [Y]. If not enter random: ';
savePrompt = input(prompt, 's');
if(savePrompt == 'Y' || savePrompt == 'y')
    nowVector = clock();
    for tIdx=1:5
        nowCell{tIdx} = num2str(nowVector(tIdx));
    end
    timeString = strjoin(nowCell,'-');
    saveDir = ['results/' 'variable_' model.analyzeThisOutput '/' timeString]; mkdir(saveDir);
    save([saveDir '/PRCCofOutputVar_' model.analyzeThisOutput '.mat'],'-regexp','^(?!(hFig)$).');
    fprintf(['MAT file saved in ' saveDir '\n']);
    saveDir = ['results/' 'variable_' model.analyzeThisOutput '/' timeString '/tables']; mkdir(saveDir);
    for tpIdx=1:numel(time_points)
        fid=fopen([saveDir '/unsortedPRCC' num2str(tpIdx) '_' num2str(time_points(tpIdx)) '.csv'],'w');
        for parIdx=1:numel(model.paramName)
           fprintf(fid,model.paramName{parIdx});
           if(parIdx == numel(model.paramName))
               break;
           else
               fprintf(fid, ',');
           end
        end
        fprintf(fid,'\n');
        for parIdx=1:numel(model.paramName) 
           fprintf(fid,'%.4f',prcc(tpIdx,parIdx)); 
           if(parIdx == numel(model.paramName))
               break;
           else
               fprintf(fid, ',');
           end
        end
        fclose(fid);
    end
    fprintf(['Tables saved in ' saveDir '\n']);
    saveDir = ['results/' 'variable_' model.analyzeThisOutput '/' timeString '/figures'];
    mkdir(saveDir);
    for hfIdx=1:numel(hFig)
        for tpIdx=1:numel(hFig{hfIdx}.figure)
            saveas(hFig{hfIdx}.figure{tpIdx},[saveDir '/' hFig{hfIdx}.name num2str(tpIdx) '_' num2str(time_points(tpIdx)) '.png']);
            saveas(hFig{hfIdx}.figure{tpIdx},[saveDir '/' hFig{hfIdx}.name num2str(tpIdx) '_' num2str(time_points(tpIdx)) '.fig']);
        end
    end
    fprintf(['Figures saved in ' saveDir '\n']);
else
    disp('Figure not saved. If you still want to save, please save them manually.');
end