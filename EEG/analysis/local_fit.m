
function [r,lamUse,mFinal] = local_fit(X,Y,fs,dirTRF,tmin,tmax,lambdas,regMethod,pickLambda)
% Within-subject: lambda by CV over segments, r by leave-one-segment-out.

cv = mTRFcrossval(X,Y,fs,dirTRF,tmin,tmax,lambdas, ...
    'method',regMethod,'verbose',0);

rLam   = squeeze(mean(mean(cv.r,1),3));
lamUse = pickLambda(rLam);

n = numel(X);
predAll = cell(n,1);
obsAll  = cell(n,1);

for k = 1:n
    trainIdx = setdiff(1:n,k);

    m = mTRFtrain(X(trainIdx),Y(trainIdx),fs,dirTRF,tmin,tmax,lamUse, ...
        'method',regMethod,'verbose',0);

    [p,~] = mTRFpredict(X(k),Y(k),m,'verbose',0);
    if iscell(p), p = p{1}; end

    predAll{k} = p(:);
    obsAll{k}  = Y{k}(:);
end

pc = vertcat(predAll{:});      % concatenated AFTER prediction
oc = vertcat(obsAll{:});
good = isfinite(pc) & isfinite(oc);

if sum(good) >= 3
    r = corr(pc(good),oc(good),'type','Pearson');
else
    r = NaN;
end

mFinal = mTRFtrain(X,Y,fs,dirTRF,tmin,tmax,lamUse, ...
    'method',regMethod,'verbose',0);
end