function [weighted,binary] = connectome_project()
% This is the driver function for the pseudocoelomates' project. It does
% the following:
% 1.) loads the CSV file containing subject data
% 2.) loads all .mat files in your directory. Note: there is accompanying 
%     code written in python to extract the proper files online
%     automatically, storing them locally on your hardrive
% 3.) vectorizes the brain graphs, eliminating redundancies (and the 0
%     diagonal)
% 4.) creates binary copies for the purposes of analyzing just graph 
%     structure
% 5.) calls an accompanying function written by the pseudocoelmates
%     "cval_connectome" which runs a series of classification algorithms
% 6.) plots associated ROC curves and classification rates

% Download subject data:

subjects = xlsread('SWU_4');
subjects_count = length(subjects);
ones_count = 0;

for i = 1: subjects_count
    if subjects(i,3) == 1 
        ones_count = ones_count + 1;
    end
end

twos_count = length(subjects) - ones_count; 

% Download brain graph data from local disk. 
% Note there is seperate code wirtten in python
% to convert .graphml to .mat

matfiles = dir('*.mat');                   
files_count = length(matfiles);      
graphs = cell(1, files_count);

for i = 1:files_count                    
    graphs{i} = load(matfiles(i).name);
end
    
graph_matrix = zeros(length(matfiles),(length(graphs{1}.graph)^2-length(graphs{1}.graph))/2);

%% Vectorize brain graphs (excluding redundancies):

for i = 1: length(graphs)
    l = 1;
    for j = 1: length(graphs{i}.graph)
        for k = 1: length(graphs{i}.graph)
            if j < k
                graph_matrix(i,l) = graphs{i}.graph(j,k);
                l = l + 1;
            end
        end
    end
end

% Create a lookup table for graph index interpretation

lookup_table = zeros(1, (length(graphs{1}.graph)^2-length(graphs{1}.graph))/2,2);
l = 1;
for j = 1: length(graphs{1}.graph)
    for k = 1: length(graphs{1}.graph)
        if j < k
            lookup_table(1,l,1) = j;
            lookup_table(1,l,2) = k;
            l = l + 1;
        end
    end
end
%% Make graphs binary vectors

%  Here 1 = edge exists between nodes. 0 = no edge.

bin_graph_matrix = zeros(454, length(graph_matrix));

for j = 1:454
    for i = 1:length(graph_matrix)
        if graph_matrix(j,i) ~= 0
            bin_graph_matrix(j,i) = 1;
        end
    end
end

%% Create class vector

dim_graph_matrix = size(graph_matrix);
class_vector = [];

for i = 1:dim_graph_matrix(1)
    I = find(subjects(:,1) == str2num(matfiles(i).name(8:12)));
    class_vector(i) = subjects(I,3);
end

%% Classify vectorized brain graphs (binary and weighted)

 weighted = cval_connectome(full(graph_matrix),class_vector);
 binary = cval_connectome(full(bin_graph_matrix),class_vector);

classifiers = cell(1,6);
classifiers{1} = 'linear';
classifiers{2} = 'Random Forest';
classifiers{3} = 'SVM';
classifiers{4} = 'AdaBoost';
classifiers{5} = 'KNN';
classifiers{6} = 'Voting';

connectome_plot(weighted,class_vector,classifiers,2)
connectome_plot(binary,class_vector,classifiers,2)
 

end
