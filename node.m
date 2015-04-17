classdef node < handle
    properties
        isLeafNode=0;
        feature_no=0;
        branchOutput=0;
        childern;
        nChildren=0;
        FeatureVals;
        
    end
        
    methods
        
        function n= node(isLeaf,arg1,arg2)
            if (isLeaf==0)
                n.isLeafNode = 0;
                n.branchOutput = 0;
                n.feature_no = arg1;
                n.nChildren = length(arg2);
                
                %for i=1:n.nChildren
                %    n.childern(i) = node(0,0,0);
                %end
                
                n.childern = cell(n.nChildren,1);
                n.FeatureVals = arg2;
            else
                
                n.isLeafNode=1;
                n.branchOutput=arg1;
            end   
        end
        
        function addLeafChild(n,fVal,Output)
            chIndex = find(n.FeatureVals==fVal);
            %fprintf('chIndex %d', chIndex);
            n.childern{chIndex} = node(1,Output,Output);
        end
        
        function addChild(n,fVal,f,allVals)
            chIndex = find(n.FeatureVals==fVal);
            n.childern{chIndex} = node(0,f,allVals);
        end
        
        function c=getChild(n,fVal)
            chIndex = find(n.FeatureVals==fVal);
            c = n.childern{chIndex};
        end
        
    end
    
end
