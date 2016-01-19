%For Box Plot, takes Errors, an n x m error matrix, where each column has n error values
%for classifer m, and Names, a cell array of strings labeling each
%classifier m.

%For ROC curve, takes Scores, an m x n matrix of classification scores for
%each classifier, m, the corresponding m x n matrix of true class labels
%for class m, Labels, and the positive class label Posclass (a string).


function connectome_plot(Errors, Names, Scores, Labels, Posclass)
clf()
figure(1)
boxplot(Errors, Names);
title('Classifier Error')
xlabel('Classifier')
ylabel('Error')
sz = size(Scores);
figure(2)
for i = 1 : sz(1,1)
    [X, Y] = perfcurve(Scores(i,:), Labels(i,:), Posclass);
    plot(X, Y)
    hold on
end
hold off
legend(Names)
title('ROC Curve for Classifiers')
xlabel('False Positive Rate')
ylabel('True Positives')
end