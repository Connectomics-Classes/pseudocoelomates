function connectome_plot(cval_cell,Labels, Names,Posclass)
% This function can be used to plot classification rates and ROC curves.
%
% cval_cell = a cell produced from cval_connectome.
% cval{1} = classification rates. cval{2:7} = class predication for
% classifiers.
% Labels = true classes.
% Names = Names of classifiers used
% Posclass determines whats is considered a postive. 

clf()
figure(1)
bar(cval_cell{1});
set(gca,'XTickLabel',Names)
title('Classification Rate')
xlabel('Classifier')
ylabel('Error')
sz = 6;
figure(2)
for i = 1 : 6
    figure(2)
    [X, Y] = perfcurve(cval_cell{i+1}, Labels, Posclass);
    plot(X, Y)
    hold on
end
legend(Names,'Location','Best')
title('ROC')
xlabel('False Positive Rate')
ylabel('True Positives')


end
