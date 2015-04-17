
% feature cardinality

function bits=Info(labels)
allVals = unique(labels);
cardinality = length(allVals);
N = length(labels);
bits=0;

for i=1:cardinality
    Ni = length(find(labels==allVals(i)));
    p=Ni/N;
    bits = bits - p*log2(p);
end
