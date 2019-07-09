%% Simulation of Elsner & Hommel (2001), Experiment 1
% Elsner, B. & Hommel, B. (2001). Effect anticipation and action control.
% Jornal of Experimental Psychology, 27(1), 229–240.

% clear;
% iti = 40; % intertrial interval
% congruency = 0; % 1: nonreversal group, | 0: reversal group
% expType = 'A'; % A: Exp. 1A (with post-response effect tones in the test phase) | B: Exp. 1B without effect tones

%% Acquisition phase
% Do you want to see the acquisition phase?
showRun = 0; % 1: online mode | 0 offline mode
showAll = 0; % show also intertrial interval

nTrials_acquisition = 200; % number of trials - must be an even digit
Model_ElsnerHommel_acquisition

%% Do you want to see the test phase running?
showRun = 0; % 1: online mode | 0 offline mode
showAll = 0; % show also intertrial interval

%% parameters shared by multiple elements
nTrials = 100; % number of trials - must be an even digit

rts = NaN(nTrials, 1); % "response times"
responses = NaN(nTrials, 1); % responses produced by the model

sim.t = sim.tZero;
sim.setElementParameters('input s_low', 'amplitude', 0);
sim.setElementParameters('input s_high', 'amplitude', 0);
sim.setElementParameters('preshape instruction_1', 'amplitude', 2.5);
sim.setElementParameters('preshape instruction_2', 'amplitude', 2.5);
sim.setElementParameters('sr -> r', 'amplitude', 2.5);


%% Start simulation acquisition phase

fprintf('\nrunning test phase...\n')

if showRun
    gui.init();
    gui.connect(sim);
end

% generate random stimulus sequence
stimuli =  repmat([1; 2], [nTrials/2, 1]);
stimuli = stimuli(randperm(length(stimuli)));
stimInput = {'input s_low', 'input s_high'};

for t = 1 : nTrials
    sim.setElementParameters('input s_low', 'amplitude', 0);
    sim.setElementParameters('input s_high', 'amplitude', 0);
    trialStartTime = sim.t;
    
    % iti before trial
    for i = 1 : iti
        if showRun && showAll
            gui.step();
            gui.updateVisualizations();
            pause(0.05);
        else
            sim.step();
        end
    end
    
    % introduce input for stimulus layer
    sim.setElementParameters('s -> sr', 'amplitude', 3);
    sim.setElementParameters(stimInput(stimuli(t)), 'amplitude', 6);
    stimOnsetTime = sim.t;
    
    while ~gui.quitSimulation
        if showRun
            gui.step();
            gui.updateVisualizations();
            pause(0.05);
        else
            sim.step();
        end
        
        if sim.t > (stimOnsetTime + 30)
            sim.setElementParameters('input s_low', 'amplitude', 0);
            sim.setElementParameters('input s_high', 'amplitude', 0);
        end
        
        act_r = sim.getComponent('field r', 'activation');
        out_r = sim.getComponent('field r', 'output');
        % read out rt and response; introduce post-response effect
        if any(out_r > 0.90)
            rts(t) = sim.t - stimOnsetTime;
            [nPeaks, peakPos] = singleLinkageClustering(act_r > 0, 3, 'circular');
            if nPeaks == 1
                if peakPos < mean([location1, location2])
                    if strcmp(expType, 'A')
                        sim.setElementParameters(stimInput(stimuli(t)), 'amplitude', 0);
                        sim.setElementParameters('input s_low', 'amplitude', 6); % present effect tones
                        sim.setElementParameters('s -> sr', 'amplitude', 0);
                    end
                    responses(t) = 1; % left response
                elseif peakPos >= mean([location1, location2])
                    if strcmp(expType, 'A')
                        sim.setElementParameters(stimInput(stimuli(t)), 'amplitude', 0);
                        sim.setElementParameters('input s_high', 'amplitude', 6); % present effect tones
                        sim.setElementParameters('s -> sr', 'amplitude', 0);
                    end
                    responses(t) = 2; % right response
                end
            end
            
            
            % stop post-response effect
            if strcmp(expType, 'A')
                % possible post-response effect presentation lasts for 20 time steps
                for i = 1:20
                    if showRun
                        gui.step();
                        gui.updateVisualizations();
                        pause(0.05);
                    else
                        sim.step();
                    end
                end
                sim.setElementParameters('input s_low', 'amplitude', 0);
                sim.setElementParameters('input s_high', 'amplitude', 0);
            end
            break;
        elseif (sim.t - stimOnsetTime) > 60 % missed
            break;
        end
    end
    if ~mod(t,10)
        perc = t*100/nTrials;
        fprintf('%d %s', perc, '%...')
    end
end


if showRun
    gui.close();
end
sim.close();