
function local_shade(t,W,col)
% Mean +/- SEM
if isempty(W), return, end
ok = any(isfinite(W),2);
W = W(ok,:);
m  = mean(W,1,'omitnan');
se = std(W,0,1,'omitnan')./sqrt(size(W,1));
fill([t fliplr(t)],[m+se fliplr(m-se)],col,'FaceAlpha',0.25,'EdgeColor','none');
plot(t,m,'Color',col,'LineWidth',2.5);
end
