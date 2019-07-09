clear;
vps = 12;
iti = 40; % intertrial interval
congruency = 1; % 1: nonreversal group, | 0: reversal group
expType = 'A'; % A: Exp. 1A (with post-response effect tones in the test phase) | B: Exp. 1B without effect tones

rt_allAc = [];

for ijk=1:vps
   Model_ElsnerHommel2001_Exp1;
   rt_allAc = horzcat(rt_allAc, rts);
end

save('Ac.mat','rt_allAc');
%%

clear;
vps = 12;
iti = 40; % intertrial interval
congruency = 0; % 1: nonreversal group, | 0: reversal group
expType = 'A'; % A: Exp. 1A (with post-response effect tones in the test phase) | B: Exp. 1B without effect tones

rt_allAi = [];

for ijk=1:vps
   Model_ElsnerHommel2001_Exp1;
   rt_allAi = horzcat(rt_allAi, rts);
end

save('Ai.mat','rt_allAi');
%%
clear;
vps = 12;
iti = 40; % intertrial interval
congruency = 1; % 1: nonreversal group, | 0: reversal group
expType = 'B'; % A: Exp. 1A (with post-response effect tones in the test phase) | B: Exp. 1B without effect tones

rt_allBc = [];

for ijk=1:vps
   Model_ElsnerHommel2001_Exp1;
   rt_allBc = horzcat(rt_allBc, rts);
end

save('Bc.mat','rt_allBc');
%%

clear;
vps = 12;
iti = 40; % intertrial interval
congruency = 0; % 1: nonreversal group, | 0: reversal group
expType = 'B'; % A: Exp. 1A (with post-response effect tones in the test phase) | B: Exp. 1B without effect tones

rt_allBi = [];

for ijk=1:vps
   Model_ElsnerHommel2001_Exp1;
   rt_allBi = horzcat(rt_allBi, rts);
end

save('Bi.mat','rt_allBi');

clear;