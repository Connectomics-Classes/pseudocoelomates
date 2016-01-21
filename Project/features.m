function [Nodes] = features(lookup_table, index)
Nodes = [lookup_table(1,index,1), lookup_table(1,index,2)];
end
