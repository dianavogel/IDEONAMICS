rt_all(:,:,1) = rt_allAc;

rts1 = rt_all(1:20,:);
rts2 = rt_all(21:40,:);
rts3 = rt_all(41:60,:);
rts4 = rt_all(61:80,:);
rts5 = rt_all(81:100,:);
meanrts(:,:,1) = [mean(rts1,1); mean(rts2,1); mean(rts3,1); mean(rts4,1); mean(rts5,1)];

%%
rt_all(:,:,1) = rt_allAi;

rts1 = rt_all(1:20,:);
rts2 = rt_all(21:40,:);
rts3 = rt_all(41:60,:);
rts4 = rt_all(61:80,:);
rts5 = rt_all(81:100,:);
meanrts(:,:,2) = [nanmean(rts1,1); mean(rts2,1); mean(rts3,1); mean(rts4,1); mean(rts5,1)];

%%
rt_all(:,:,1) = rt_allBc;

rts1 = rt_all(1:20,:);
rts2 = rt_all(21:40,:);
rts3 = rt_all(41:60,:);
rts4 = rt_all(61:80,:);
rts5 = rt_all(81:100,:);
meanrts(:,:,3) = [mean(rts1,1); mean(rts2,1); mean(rts3,1); mean(rts4,1); mean(rts5,1)];

%%
rt_all(:,:,1) = rt_allBi;

rts1 = rt_all(1:20,:);
rts2 = rt_all(21:40,:);
rts3 = rt_all(41:60,:);
rts4 = rt_all(61:80,:);
rts5 = rt_all(81:100,:);
meanrts(:,:,4) = [mean(rts1,1); mean(rts2,1); mean(rts3,1); mean(rts4,1); mean(rts5,1)];

%%

plotmeans12 = [mean(meanrts(:,:,1),2), mean(meanrts(:,:,2),2)];
plotse12 = [std(meanrts(:,:,1),0,2), std(meanrts(:,:,2),0,2)];

plotmeans34 = [mean(meanrts(:,:,3),2), mean(meanrts(:,:,4),2)];
plotse34 = [std(meanrts(:,:,3),0,2), std(meanrts(:,:,3),0,2)];
%%
subplot(1,2,1);
hold on;
errorbar(repmat([1;2;3;4;5],1,1), plotmeans12(:,2), plotse12(:,2), '-ko','MarkerSize',5,'MarkerEdgeColor','black','MarkerFaceColor','black')
errorbar(repmat([1;2;3;4;5],1,1), plotmeans12(:,1), plotse12(:,1), '-ko','MarkerSize',5,'MarkerEdgeColor','black','MarkerFaceColor','white')
xlim([0.8,5.2]);
ylim([5,25]);
xticks(1:5);
xticklabels({'1:20', '21-40', '41-60', '61-80', '81-100'});

subplot(1,2,2);
hold on;
errorbar(repmat([1;2;3;4;5],1,1), plotmeans34(:,2), plotse34(:,2), '-ko','MarkerSize',5,'MarkerEdgeColor','black','MarkerFaceColor','black')
errorbar(repmat([1;2;3;4;5],1,1), plotmeans34(:,1), plotse34(:,1), '-ko','MarkerSize',5,'MarkerEdgeColor','black','MarkerFaceColor','white')
xlim([0.8,5.2]);
ylim([5,25]);
xticks(1:5);
xticklabels({'1:20', '21-40', '41-60', '61-80', '81-100'});
hold off
legend({'Reversal group', 'Nonreversal group'});
set(gcf,'color','w');
