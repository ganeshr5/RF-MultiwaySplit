function infovals=InfoRem(features, labels)
nFeatures = size(features,2);
infovals = zeros(1, nFeatures);

for f = 1:nFeatures
feature = features(:,f);
allVals = unique(feature); 
cardinality = length(allVals); % find cardinality
N = length(labels); % lenth of class labels vector
infoval = 0;

    for i=1:cardinality
        branchedDataIndices = find(feature==allVals(i));
        Ni=length(branchedDataIndices);
        infoval = infoval + (Ni/N)*Info(labels(branchedDataIndices));
    end
       
infovals(f)= infoval;
end
