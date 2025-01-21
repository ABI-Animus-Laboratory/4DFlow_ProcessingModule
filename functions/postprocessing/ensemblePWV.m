function [PWV]=ensemblePWV(Results,W)
    if W==0
        off=18;
    elseif W==1
        off=0;
    elseif W==2
        off=9;
    end
    X1=Results.PWV(:,(1+off):(3+off));
    X2=Results.PWV(:,(4+off):(6+off));
    X3=Results.PWV(:,(7+off):(9+off));
    PWV=nan([length(X1(:,1)),3]);
    outlier=nan([length(X1(:,1)),3]);
    for i=1:length(X1(:,1))
        for j=1:3
            Vals=[X1(i,j) X2(i,j) X3(i,j)];
            idx1=find(Vals<=0); %Find Failed fits
            if isempty(idx1) %If all techniques succeeded
                diffs=[1 1 2;2 3 3;3 2 1];
                deltas=abs(Vals(diffs(1,:))-(Vals(diffs(2,:))));
                [~,minidx]=min(deltas);
                MN = mean(Vals(diffs(1:2,minidx)));
                sigma=std(Vals(diffs(1:2,minidx)));
                if abs(Vals(diffs(3,minidx))-MN)>=2*sigma %Outlier
                    outlier(i,j)=diffs(3,minidx);
                    if deltas(minidx)<1.35          %If they agree within 1.35m/s
                            PWV(i,j)=mean(Vals(diffs(1:2,minidx)));
                        else
                            outlier(i,j)=4;                            %inconclusive
                    end
                else                                      %No outliers, full mean
                    PWV(i,j)=mean(Vals);
                end
            else %If there were failed techniques
                Vals(idx1)=[];
                if length(Vals)>1
                    if abs(Vals(1)-Vals(2))<1.35
                        PWV(i,j)=mean(Vals);
                    else                                  %inconclusive
                         outlier(i,j)=5;
                    end
                else
                    outlier(i,j)=6;
                end
            end
        end
    end
    %outlier 4 means all techniques worked, but none were similar
    %outlier 5 means one technique failed, and the other two were not similar
    %outlier 6 means at least 2 techniques failed, and only 1 measurement couldn't be conclusive
    % outlier(outlier(:,:)==3)=0;
    % outlier(outlier(:,:)==-1)=1;
    % outlier(isnan(outlier))=0;
    % sum(outlier(:))
end