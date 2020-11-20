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
% modified by Bagaskara P P, November 17 2020
% plot sorted parameters from most to least significant 

function [prcc,sign,sign_label,hFig]=PRCC(LHSmatrix,model,time_points,PRCC_var,alpha)
s = 1:length(time_points); % index for time points
Y = model.state.(model.analyzeThisOutput).lhs; % desired analyzed output LHS
Y=Y(s,:)';% Define the output. Comment out if the Y is already 
          % a subset of all the time points and it already comprises
          % ONLY the s rows of interest
[a,k]=size(LHSmatrix); % Define the size of LHS matrix
[b,out]=size(Y);
for i=1:k  % Loop for the whole submatrices
    c=['LHStemp=LHSmatrix; LHStemp(:,',num2str(i),')=[]; Z',num2str(i),'=LHStemp; LHStemp=[];'];
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

sign_label=struct;
sign_label.uncorrected_sign=uncorrected_sign;

for r=1:length(s)
    hFig{1}.name = 'unsortedPRCC';
    hFig{1}.figure{r} =  figure();
%     c1=['PRCCs at time = ' num2str(s(r))];
    c1=['PRCCs at time point: ' num2str(time_points(r))];
    a=find(uncorrected_sign(r,:)<alpha);
    PRCC_var(a);
    prcc(r,a);
    b=num2str(prcc(r,a));
    sign_label.index{r}=a;
    sign_label.label{r}=PRCC_var(a);
    sign_label.value{r}=b;
    %% Plots of PRCCs and their p-values
    subplot(1,2,1),bar(PRCCs(r,:)),title(c1);
        set(gca,'XTickLabel',PRCC_var,'XTick',[1:k]); %,title('PRCCs');
    subplot(1,2,2),bar(uncorrected_sign(r,:)),...
       set(gca,'YLim',[0,.1]),title('P values');%'XTickLabel',PRCC_var,'XTick',[1:k],
   %% Plot sorted PRCCs
   % print all prcc parameters sorted from most to least significant
    [absPrccSortedValue, prccSortedIdx] = sort(abs(prcc(r,:)),'descend'); 
    fprintf('%d. TimePoint: %d\n',r,time_points(r));
    for sortIdx=1:numel(prccSortedIdx)
        prccSortedValue(sortIdx) = prcc(r,prccSortedIdx(sortIdx));
        prccSortedParamName{sortIdx} = model.paramName{prccSortedIdx(sortIdx)};
        prccSorted_var{sortIdx} = PRCC_var{prccSortedIdx(sortIdx)};
        fprintf('%s: %f',prccSortedParamName{sortIdx}, prccSortedValue(sortIdx));
        for signIdx=1:numel(sign_label.index{r})
            if(prccSortedIdx(sortIdx) == sign_label.index{r}(signIdx))
                fprintf(' (significant)');
            end
        end
        fprintf('\n');
    end
    fprintf('\n');

    hFig{2}.name = 'sortedPRCC';
    hFig{2}.figure{r} =  figure();
    bar(prccSortedValue); title(['Most to Least Significant ' c1]);
        set(gca,'XTickLabel',prccSorted_var,'XTick',[1:k]);
end

end