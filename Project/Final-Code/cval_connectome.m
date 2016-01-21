function [store] = cval_connectome(data,class)
% This function was designed for the Intro to Connectomics intersession 
%course a class taught at Johns Hopkins University.
% 
% This function takes a set of features and an associated
% class vector and performs 5 fold cross validation, using  
% 5 different built in MATLAB classifier algorithms: fitcdiscr (linear)
%,TreeBagger (random forest),fitcsvm (SVM), fitensemble (adaboost),
% fitcknn (k nearest neighbor).
%
% Note: it is assumed the data is a desikan atlas in the SW China data
% set

idxRand = randperm(227);
idxAll = 1:227;
nFold = 5;
nSample = floor(size(idxAll,2)/nFold);

% divide 227 into 5 buckets

for i = 1:nFold
    if i ~= nFold
        g{i} = (i-1)*nSample+1:i*nSample;
    else
        g{i} = (i-1)*nSample+1:size(idxAll,2);
    end
end

% map to random partitions. Need to ensure that scans from one subject
% remain in the same bucket. Note: every two scans in our graph matrix
% belong to the same person.

for i = 1:nFold
    gg{i} = [idxRand(g{i})*2 idxRand(g{i})*2-1];
end

% Run cross validation

linear_pred = zeros(size(data,1),1);
tree_pred = zeros(size(data,1),1);
svm_pred = zeros(size(data,1),1);
ens_pred = zeros(size(data,1),1);
knn_pred = zeros(size(data,1),1);

for i = 1:nFold
    
    idx = 1:nFold;
    idxTest = idx(idx == i);
    idxTrain = idx(idx ~= i);
    xtrain = data([gg{idxTrain}],:);
    ytrain = class([gg{idxTrain}]);
    xtest = data(gg{idxTest},:);
    %ytest = class(gg{idxTest},:);
   
    % (1) Linear
    linear_model = fitcdiscr(xtrain,ytrain,'discrimType','pseudoLinear');
    linear_pred([gg{idxTest}]) = predict(linear_model,xtest);
    
    % (2) Random Forest
    tree_model = TreeBagger(300,xtrain,ytrain);
    tree_pred([gg{idxTest}]) = str2num(cell2mat(predict(tree_model,xtest)));
    
    % (3) SVM
    svm_model = fitcsvm(xtrain,ytrain);
    svm_pred([gg{idxTest}]) = predict(svm_model,xtest);
    
    % (4) Ensemble method
    ens_model = fitensemble(xtrain,ytrain,'AdaBoostM1',200,'Tree');
    ens_pred([gg{idxTest}]) = predict(ens_model,xtest);
    
    % (5) nearest Neighbor
    knn_model = fitcknn(xtrain,ytrain,'NumNeighbors',round(sqrt(length(xtrain))));
    knn_pred([gg{idxTest}]) = predict(knn_model,xtest);
    
   
end

% linear classification rate
linear_misses = sum(abs(linear_pred - class'));
linear_hit = 1 - (linear_misses/length(linear_pred'));

% tree classification rate
tree_misses = sum(abs(tree_pred - class'));
tree_hit = 1 - (tree_misses/length(tree_pred'));

% SVM classification rate
svm_misses = sum(abs(svm_pred - class'));
svm_hit = 1 - (svm_misses/length(svm_pred'));

% Ensemble classification rate
ens_misses = sum(abs(ens_pred - class'));
ens_hit = 1 - (ens_misses/length(ens_pred'));

% knn classification rate
knn_misses = sum(abs(knn_pred - class'));
knn_hit = 1 - (knn_misses/length(knn_pred'));


vote_pred = [];

for i = 1:length(class)

    count = 0;
    
    if linear_pred(i) == 1
        count = count + 1;
    end
    
    if tree_pred(i) == 1
        count = count + 1;
    end
    
    if svm_pred(i) == 1
        count = count + 1;
    end
    
    if ens_pred(i) == 1
        count = count + 1;
    end
    
    if knn_pred(i) == 1
        count = count + 1;
    end
    
    % take a vote   
    if count >= 3
        vote_pred(i) = 1;
    else
        vote_pred(i) = 2;
        
    end
 
end

vote_misses = sum(abs(vote_pred - class));
vote_hit = 1 - (vote_misses/length(vote_pred));

store = cell(1,7);
store{1} = [linear_hit tree_hit svm_hit ens_hit knn_hit vote_hit];
store{2} = linear_pred;
store{3} = tree_pred;
store{4} = svm_pred;
store{5} = ens_pred;
store{6} = knn_pred;
store{7} = vote_pred';

end
