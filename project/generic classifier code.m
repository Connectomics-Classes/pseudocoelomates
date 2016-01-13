function connectome_learn()

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
    
graphs_matrix = ones(length(graphs{1}.graph),length(matfiles));

% Convert all graphs to vectors and store them in matrix
for i = 1: length(graphs)
    
    graph_matrix(i,:) = reshape(graphs{i}.graph,70*70, 1);
end

% create a class vector

dim_graph_matrix = size(graph_matrix);
class_vector = [];

for i = 1:dim_graph_matrix(1)
    
    I = find(subjects(:,1) == str2num(matfiles(i).name(8:12)));
    
    class_vector(i) = subjects(I,3);
end


%train data:

train_class = class_vector(1:227);

%quadclass = fitcdiscr(graph_matrix(1:227,:),train_class,'discrimType','pseudoLinear');

trees = TreeBagger(100,full(graph_matrix(1:227,:)),train_class);

class_test = predict(trees,full(graph_matrix(228:454,:)));
%class_test = predict(quadclass,graph_matrix(228:454,:))

%error(trees,full(graph_matrix(228:454,:)),class_vector(228:454))


end
