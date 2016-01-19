function [bin_vector_classifications] = connectome_project()
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

%% Convert all graphs to vectors and classify

% Vectorize brain graphs (excluding redundancies):

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
end%% Make graphs binary vectors and classify them 
%  Here 1 = edge exists between nodes. 0 = no edge.

% create binary matrix:

bin_graph_matrix = zeros(454, length(graph_matrix));

for j = 1:454
    for i = 1:length(graph_matrix)
        
        if graph_matrix(j,i) ~= 0
            bin_graph_matrix(j,i) = 1;
        end
        
    end
end

% Run classification function for vectorized brain graphs 

dim_graph_matrix = size(graph_matrix);
class_vector = [];

for i = 1:dim_graph_matrix(1)
    
    I = find(subjects(:,1) == str2num(matfiles(i).name(8:12)));
    
    class_vector(i) = subjects(I,3);
end

%% Run classification function for vectorized brain graphs

train_class = class_vector(1:227);

train_features = full(graph_matrix(1:227,:));

test_features = full(graph_matrix(228:454,:));

test_class = class_vector(228:454);

bin_train = full(graph_matrix(1:227,:));

bin_test = full(graph_matrix(228:454,:));

bin_vector_classifications = connectome_learn(bin_train,...
    train_class, bin_test, test_class);
 

end
