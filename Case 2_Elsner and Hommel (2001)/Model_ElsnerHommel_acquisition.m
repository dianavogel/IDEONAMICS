%% acquisition phase for Experiment 1, Elsner & Hommel, 2001
% please use main file: Model_ElsnerHommel2001_Exp1

%% setting up the architecture (fields, interactions, and inputs)

% parameters shared by multiple elements
fieldSize = 50;

% stimulus settings
location1 = fieldSize/3; % stim location 1
location2 = location1*2; % stim location 2
sStrings = {'low', 'high'};
sValues = [location1, location2];
rStrings = {'left', 'right'};
rValues = [location1, location2];

rts = repmat(NaN, nTrials_acquisition, 1); % "response times"
responses = repmat(NaN, nTrials_acquisition, 1); % responses produced by the model

% create simulator object
sim = Simulator();

% create fields
sim.addElement(NeuralField('field sr', [fieldSize, fieldSize], 10, -4, 5));
sim.addElement(NeuralField('field s', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field r', fieldSize, 10, -4, 5));


% additional soft sigmoid output functions
sim.addElement(Sigmoid('sr soft', [fieldSize, fieldSize], 1, 0), 'field sr', 'activation');
sim.addElement(Sigmoid('s soft', fieldSize, 1, 0), 'field s', 'activation');
sim.addElement(Sigmoid('r soft', fieldSize, 1, 0), 'field r', 'activation');

sim.addElement(SumAllDimensions('sum sr soft', [fieldSize, fieldSize]), 'sr soft');

% create connections
% lateral interactions within fields
sim.addElement(LateralInteractions2D('sr -> sr', [fieldSize, fieldSize], 5, 15, 10, 20, -2), 'field sr', [], 'field sr');
sim.addElement(LateralInteractions1D('s -> s', fieldSize, 4, 15, 10, 15, -1), 'field s', [], 'field s');
sim.addElement(LateralInteractions1D('r -> r', fieldSize, 4, 15, 10, 15, -1), 'field r', [], 'field r');


% interactions between fields
sim.addElement(ScaleInput('s -> sr', fieldSize, 3), 's soft');
sim.addElement(ExpandDimension2D('expand s -> sr', 1, [fieldSize, fieldSize]), 's -> sr', [], 'field sr');

sim.addElement(ScaleInput('r -> sr', fieldSize, -1.5), 'r soft');
sim.addElement(ExpandDimension2D('expand r -> sr', 2, [fieldSize, fieldSize]), 'r -> sr', [], 'field sr');

sim.addElement(ScaleInput('sr -> r', fieldSize, 0), 'sum sr soft', 'horizontalSum', 'field r'); % weaker in the acquisition phase, no instruction

% preshape instruction layer - none in the acquisition phase
if congruency
    sim.addElement(GaussStimulus2D('preshape instruction_1', [fieldSize fieldSize], 5, 5, 0, location1, location1), [], [], 'field sr');
    sim.addElement(GaussStimulus2D('preshape instruction_2', [fieldSize fieldSize], 5, 5, 0, location2, location2), [], [], 'field sr');
else
    sim.addElement(GaussStimulus2D('preshape instruction_1', [fieldSize fieldSize], 5, 5, 0, location1, location2), [], [], 'field sr');
    sim.addElement(GaussStimulus2D('preshape instruction_2', [fieldSize fieldSize], 5, 5, 0, location2, location1), [], [], 'field sr');
end


% create stimuli
sim.addElement(GaussStimulus1D('input r_left', fieldSize, 5, 0, rValues(1), true), [], [], 'field r');
sim.addElement(GaussStimulus1D('input r_right', fieldSize, 5, 0, rValues(2), true), [], [], 'field r');
sim.addElement(GaussStimulus1D('input s_low', fieldSize, 5, 0, sValues(1), true), [], [], 'field s');
sim.addElement(GaussStimulus1D('input s_high', fieldSize, 5, 0, sValues(2), true), [], [], 'field s');

% noise
sim.addElement(NormalNoise('noise sr', [fieldSize, fieldSize], 1), [], [], 'field sr');
sim.addElement(NormalNoise('noise s', fieldSize, 1), [], [], 'field s');
sim.addElement(NormalNoise('noise r', fieldSize, 1), [], [], 'field r');

% coupling between fields and ordinal dynamics
sim.addElement(AdaptiveWeightMatrix('E-R ideomotor', [fieldSize, fieldSize], 0.001), ...
    {'field s', 'field r'});
sim.addElement(ScaleInput('E-R ideomotor -> r', fieldSize, 1), 'E-R ideomotor', [], 'field r');

sim.addElement(AdaptiveWeightMatrix('R-E ideomotor', [fieldSize, fieldSize], 0.001), ...
    {'field r', 'field s'});
sim.addElement(ScaleInput('R-E ideomotor -> s', fieldSize, 1), 'R-E ideomotor', [], 'field s');


%% set up gui
gui = StandardGUI(sim, [50, 50, 1900,800], 0.01, [0.0, 0.035, 0.75, 0.95], [7, 7], [0.015, 0.03], [0.75, 0, 0.25, 1], [25, 1]);

% stimulus field
gui.addVisualization(MultiPlot({'field s', 'field s', 'input s_low', 'input s_high'}, ...
    {'activation', 'output', 'output', 'output'}, [1, 10, 1, 1], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', rValues, 'XTickLabel', sStrings, ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}}, 'Stimulus/Effect field', 'Tone'), [2, 1], [1.3, 2.5]);

% 
% gui.addVisualization(MultiPlot({'field s', 'field s', 'input s_low', 'input s_high'}, ...
%     {'activation', 'output', 'output', 'output'}, [1, 10, 1, 1], 'vertical', ...
%     {'XLim', [-10, 10], 'Box', 'on', 'XGrid', 'on', 'XDir', 'reverse', 'YAxisLocation', 'right', ...
%     'XTick', [-10, -5, 0, 5, 10], 'XTickLabel', {'-10', '', '0', '', '10'}, 'YTick', [50, 100], 'YTickLabel', sStrings, 'YLim', [0, fieldSize]}, ...
%     {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}}, ...
%     'Stimulus field', [], 'Tone'), [4.5, 3.75], [2.5, 1]);


% response field
gui.addVisualization(MultiPlot({'field r', 'field r', 'input r_left', 'input r_right', 'E-R ideomotor -> r', 'sr -> r'}, ...
    {'activation', 'output', 'output', 'output', 'output', 'output'}, [1, 10, 1, 1, 1, 1], 'vertical', ...
    {'XLim', [-12.5, 12.5], 'Box', 'on', 'XGrid', 'on', 'XDir', 'reverse', 'YAxisLocation', 'right', 'YTick', rValues, 'YTickLabel', rStrings, ...
    'YLim', [0, fieldSize], ...
    'XTick', [-10, -5, 0, 5, 10], 'XTickLabel', {'-10', '', '0', '', '10'}},  ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'m', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}}, ...
    'Response field', 'Key'), [4, 3.75], [3.5, 1]);

% gui.addVisualization(MultiPlot({'field r', 'field r', 'input r_left', 'input r_right'}, ...
%     {'activation', 'output', 'output', 'output'}, [1, 10, 1, 1], ...
%     'horizontal', {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', rValues, 'XTickLabel', rStrings, ...
%     'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
%     {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, ...
%     {'g', 'LineWidth', 1.5}}, 'Response field', 'Key'), [3, 1], [1, 2.5]);


% sr instruction field
gui.addVisualization(ScaledImage('field sr', 'activation', [-7.5, 7.5], ...
    {'YAxisLocation', 'right', 'YDir', 'normal', 'XTick', rValues, 'XTickLabel', rStrings}, {},  ...
    'Instruction field'), [4, 1], [3.5, 2.5]);

% Ideomotor field
gui.addVisualization(ScaledImage('E-R ideomotor', 'weights', [0, 1], {}, {}, ...
    'R-E ideomotor field', 'Tone', 'Key'), [1, 3.5], [2.5, 1.5]);

% show simulation time
gui.addVisualization(TimeDisplay(), [10, 1], [1, 1], 'control');

% global control buttons
yButton = 19;
gui.addControl(GlobalControlButton('Pause', gui, 'pauseSimulation', true, false, false, 'pause simulation'), [4+yButton, 1]);
gui.addControl(GlobalControlButton('Reset', gui, 'resetSimulation', true, false, true, 'reset simulation'), [5+yButton, 1]);
gui.addControl(GlobalControlButton('Quit', gui, 'quitSimulation', true, false, false, 'quit simulation'), [6+yButton, 1]);


%% Start simulation acquisition phase

fprintf('\nrunning acquisition phase...\n')

sim.init();
if showRun
    gui.init();
    gui.connect(sim);
end


for t = 1 : nTrials_acquisition
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
    
    % introduce preshape for response layer
    sim.setElementParameters('input r_right', 'amplitude', 6);
    sim.setElementParameters('input r_left', 'amplitude', 6);
    stimOnsetTime = sim.t;
    
    while ~gui.quitSimulation
        if showRun
            gui.step();
            gui.updateVisualizations();
            pause(0.05);
        else
            sim.step();
        end
        
        act_r = sim.getComponent('field r', 'activation');
        out_r = sim.getComponent('field r', 'output');
        % read out rt and response; introduce post-response effect
        if any(out_r > 0.95)
            rts(t) = sim.t - stimOnsetTime;
            [nPeaks, peakPos] = singleLinkageClustering(act_r > 0, 3, 'circular');
            if nPeaks == 1 && peakPos < mean([location1, location2])
                sim.setElementParameters('input s_low', 'amplitude', 6);
                responses(t) = 1; % left response
            elseif nPeaks == 1 && peakPos >= mean([location1, location2])
                sim.setElementParameters('input s_high', 'amplitude', 6);
                responses(t) = 2; % right response
            end
        end
        
        % after post-response effect: stop response
        act_s = sim.getComponent('field s', 'activation');
        out_s = sim.getComponent('field s', 'output');
        if any(out_s > 0.95)
             for i = 1:2
                if showRun
                    gui.step();
                    gui.updateVisualizations();
                    pause(0.05);
                else
                    sim.step();
                end
            end
            sim.setElementParameters('input r_left', 'amplitude', 0);
            sim.setElementParameters('input r_right', 'amplitude', 0);
            
            % post-response effect presentation lasts for x time steps
            for i = 1:5
                if showRun
                    gui.step();
                    gui.updateVisualizations();
                    pause(0.05);
                else
                    sim.step();
                end
            end
            % stop post-response effect
            sim.setElementParameters('input s_low', 'amplitude', 0);
            sim.setElementParameters('input s_high', 'amplitude', 0);
            break;
        end
    end
    
    if ~mod(t,10)
        perc = t*100/nTrials_acquisition;
        fprintf('%d %s', perc, '%...')
    end
    
end

% add some time at the end to have fields at resting level
for i = 1:iti
    if showRun
        gui.step();
        gui.updateVisualizations();
        pause(0.05);
    else
        sim.step();
    end
end


if showRun
    gui.close();
end

% sim.close();