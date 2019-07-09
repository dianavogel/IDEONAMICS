%% acquisition phase for Intentional action initiation
%% setting up the architecture (fields, interactions, and inputs)

% parameters shared by multiple elements
fieldSize = 50;
iti = 30;

% stimulus settings
location1 = fieldSize/3; % stim location 1
location2 = location1*2; % stim location 2
eValues = [location1, location2];

% create simulator object
sim = Simulator();

% create fields
sim.addElement(NeuralField('field e', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field r', fieldSize, 10, -3, 5));


% create connections
% lateral interactions within fields
sim.addElement(LateralInteractions1D('e -> e', fieldSize, 4, 15, 10, 15, -1), 'field e', [], 'field e');
sim.addElement(LateralInteractions1D('r -> r', fieldSize, 4, 15, 10, 15, -1), 'field r', [], 'field r');

% create stimuli
sim.addElement(GaussStimulus1D('input e_left', fieldSize, 5, 0, eValues(1), true), [], [], 'field e');
sim.addElement(GaussStimulus1D('input e_right', fieldSize, 5, 0, eValues(2), true), [], [], 'field e');
sim.addElement(GaussStimulus1D('input r_left', fieldSize, 5, 0, eValues(1), true), [], [], 'field r');
sim.addElement(GaussStimulus1D('input r_right', fieldSize, 5, 0, eValues(2), true), [], [], 'field r');

% noise
sim.addElement(NormalNoise('noise e', fieldSize, 1), [], [], 'field e');
sim.addElement(NormalNoise('noise r', fieldSize, 1), [], [], 'field r');

% coupling between fields and ordinal dynamics
sim.addElement(AdaptiveWeightMatrix('E-R ideomotor', [fieldSize, fieldSize], 0.008), ...
    {'field e', 'field r'});
sim.addElement(ScaleInput('E-R ideomotor -> r', fieldSize, 1), 'E-R ideomotor', [], 'field r');

sim.addElement(AdaptiveWeightMatrix('R-E ideomotor', [fieldSize, fieldSize], 0.008), ...
    {'field r', 'field e'});
sim.addElement(ScaleInput('R-E ideomotor -> e', fieldSize, 1), 'R-E ideomotor', [], 'field e');


%% set up gui
gui = StandardGUI(sim, [50, 50, 1900,800], 0.01, [0.0, 0.035, 0.75, 0.95], [7, 7], [0.015, 0.03], [0.75, 0, 0.25, 1], [25, 1]);

% stimulus field
gui.addVisualization(MultiPlot({'field e', 'field e'}, ...
    {'activation', 'output'}, [1, 10], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', eValues, 'XTickLabel', [], ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}}, 'Effect field', 'Effect space'), [2, 1], [1.3, 2.5]);


% response field
gui.addVisualization(MultiPlot({'field r', 'field r', 'input r_left', 'input r_right', 'E-R ideomotor -> r'}, ...
    {'activation', 'output', 'output', 'output', 'output'}, [1, 10, 1, 1, 1], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', eValues, 'XTickLabel', [], ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'m', 'LineWidth', 1.5}}, ...
    'Response field', 'Response space'), [2, 5], [1.3 2.5]);

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


for t = 1 : nTrials
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
        
        % action triggers effect
        act_r = sim.getComponent('field r', 'activation');
        out_r = sim.getComponent('field r', 'output');
        % read out rt and response; introduce post-response effect
        if any(out_r > 0.95)
            [nPeaks, peakPos] = singleLinkageClustering(act_r > 0.3, 3, 'circular');
            if nPeaks == 1 && peakPos < mean([location1, location2])
                sim.setElementParameters('input e_left', 'amplitude', 5);
            elseif nPeaks == 1 && peakPos >= mean([location1, location2])
                sim.setElementParameters('input e_right', 'amplitude', 5);
            end
        end
                     
        % after post-response effect: stop response
        out_e = sim.getComponent('field e', 'output');
        if any(out_e > 0.9)
            for i = 1:5
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
            sim.setElementParameters('input e_left', 'amplitude', 0);
            sim.setElementParameters('input e_right', 'amplitude', 0);
            break;
        end
    end
    
    
end

% add some time at the end to have fields at resting level
sim.setElementParameters('input r_left', 'amplitude', 0);
sim.setElementParameters('input r_right', 'amplitude', 0);
sim.setElementParameters('input e_left', 'amplitude', 0);
sim.setElementParameters('input e_right', 'amplitude', 0);
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