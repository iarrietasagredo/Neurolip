function [Wm,t] = local_collectW(Wcell,ix,smoothMs)
% Collect weights of predictor ix -> nSubs x nLags, optional smoothing (ms)
if nargin < 3, smoothMs = 0; end

t  = [];
Wm = [];

first = find(~cellfun(@isempty,Wcell),1);
if isempty(first), return, end

t  = Wcell{first}.t(:)';
Wm = nan(numel(Wcell),numel(t));

dt   = mean(diff(t));                        % ms between lags
nWin = max(1,round(smoothMs/dt));            % window in samples

for s = 1:numel(Wcell)
    if isempty(Wcell{s}), continue, end

    w = Wcell{s}.w;                          % predictors x lags x channels
    w = squeeze(w(ix,:,1));
    w = w(:)';

    if nWin > 1
        w = movmean(w,nWin);
    end

    Wm(s,:) = w;
end
end


function local_shade(t,W,col)
% Mean +/- SEM, spline-interpolated for a smooth display
if isempty(W), return, end

ok = any(isfinite(W),2);
W  = W(ok,:);

m  = mean(W,1,'omitnan');
se = std(W,0,1,'omitnan')./sqrt(size(W,1));

tF  = linspace(t(1),t(end),600);
mF  = interp1(t,m, tF,'spline');
seF = interp1(t,se,tF,'spline');

fill([tF fliplr(tF)],[mF+seF fliplr(mF-seF)],col, ...
    'FaceAlpha',0.25,'EdgeColor','none');
plot(tF,mF,'Color',col,'LineWidth',2.5);
end