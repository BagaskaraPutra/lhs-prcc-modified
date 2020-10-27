% It calculates PRCCs and their significances
% (uncorrected p-value and Bonferroni correction)
% LHSmatrix: LHS matrix (N x k) 
% Y: output matrix (time x N) 
% s: time points to test (row vector) 
% PRCC_var: cell array of strings {'p1','p2',...,'pk'}
%            to label all the parameters varied in the LHS
% by Simeone Marino, May 29 2007 
% modified by Marissa Renardy, October 8 2020
% N.B.: this version uses ONE output at a time

function [prcc,sign,sign_label]=PRCC(LHSmatrix,Y,s,PRCC_var,alpha);

Y=Y(s,:)';% Define the output. Comment out if the Y is already 
          % a subset of all the time points and it already comprises
          % ONLY the s rows of interest
[a,k]=size(LHSmatrix); % Define the size of LHS matrix
[b,out]=size(Y);
for i=1:k  % Loop for the whole submatrices
    c=['LHStemp=LHSmatrix;LHStemp(:,',num2str(i),')=[];Z',num2str(i),'=LHStemp;LHStemp=[];'];
    eval(c);
    % Loop to calculate PRCCs and significances
    c1=['[LHSmatrix(:,',num2str(i),'),Y];'];
    c2=['Z',num2str(i)];
    [rho,p]=partialcorr(eval(c1),eval(c2),'type','Spearman');
    for j=1:out
        c3=['prcc_',num2str(i),'(',num2str(j),')=rho(1,',num2str(j+1),');'];
        c4=['prcc_sign_',num2str(i),'(',num2str(j),')=p(1,',num2str(j+1),');'];
        eval(c3);
        eval(c4);
    end
    c5=['clear Z',num2str(i),';'];
    eval(c5);
end
prcc=[];
prcc_sign=[];
for i=1:k
    d1=['prcc=[prcc ; prcc_',num2str(i),'];'];
    eval(d1);
    d2=['prcc_sign=[prcc_sign ; prcc_sign_',num2str(i),'];'];
    eval(d2);
end
[length(s) k out];
PRCCs=prcc';
uncorrected_sign=prcc_sign';
prcc=PRCCs;
sign=uncorrected_sign;

%% Multiple tests correction: Bonferroni
%tests=length(s)*k; % # of tests performed
%correction_factor=tests;
%Bonf_sign=uncorrected_sign*tests;
%uncorrected_sign; % uncorrected p-value
%Bonf_sign;  % Bonferroni correction

sign_label_struct=struct;
sign_label_struct.uncorrected_sign=uncorrected_sign;

%figure
for r=1:length(s)
    figure();
    c1=['PRCCs at time = ' num2str(s(r))];
    a=find(uncorrected_sign(r,:)<alpha);
    ['Significant PRCCs'];
    a;
    PRCC_var(a);
    prcc(r,a);
    b=num2str(prcc(r,a));
    sign_label_struct.index{r}=a;
    sign_label_struct.label{r}=PRCC_var(a);
    sign_label_struct.value{r}=b;
    %% Plots of PRCCs and their p-values
    subplot(1,2,1),bar(PRCCs(r,:)),title(c1);
        set(gca,'XTickLabel',PRCC_var,'XTick',[1:k]); %,title('PRCCs');
    subplot(1,2,2),bar(uncorrected_sign(r,:)),...
       set(gca,'YLim',[0,.1]),title('P values');%'XTickLabel',PRCC_var,'XTick',[1:k],
end
sign_label=sign_label_struct;