%% Intentional action initiation
%% setting up the architecture (fields, interactions, and inputs)

%% Acquisition phase
% Do you want to see the acquisition?
showRun = 0; % 1: online mode | 0 offline mode
showAll = 0; % show also intertrial interval
nTrials = 150; % number of trials - must be an even digit
Ideomotor_action_production_acquisition

%% Do you want to see the experiment running?
showRun = 1; % 1: online mode | 0: offline mode
showAll = 1; % show also intertrial interval

%% parameters shared by multiple elements
fieldSize = 50;
nTrials = 10;
iti = 20;

% stimulus settings
location1 = fieldSize/3; % stim location 1
location2 = location1*2; % stim location 2
eValues = [location1, location2];


sim.t = sim.tZero;
% boost R-E connection for retrieval
sim.setElementParameters('E-R ideomotor -> r', 'amplitude', 1.5);
sim.setElementParameters('R-E ideomotor -> e', 'amplitude', 1.5);

%% set up gui
gui = StandardGUI(sim, [50, 50, 1900,800], 0.01, [0.0, 0.035, 0.75, 0.95], [7, 7], [0.015, 0.03], [0.75, 0, 0.25, 1], [25, 1]);

% stimulus field
gui.addVisualization(MultiPlot({'field e', 'field e', 'input e_left', 'input e_right', 'R-E ideomotor -> e'}, ...
    {'activation', 'output', 'output', 'output', 'output'}, [1, 10, 1, 1, 1], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', eValues, 'XTickLabel', [], ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'m', 'LineWidth', 1.5}}, 'Effect field', 'Effect space'), [2, 1], [1.3,2.5]);

% response field
gui.addVisualization(MultiPlot({'field r', 'field r', 'E-R ideomotor -> r'}, ...
    {'activation', 'output', 'output'}, [1, 10, 1], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', eValues, 'XTickLabel', [], ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'m', 'LineWidth', 1.5}}, 'Response field', 'Response space'), [2, 5], [1.3, 2.5]);

% Ideomotor field
gui.addVisualization(ScaledImage('E-R ideomotor', 'weights', [0, 1], {}, {}, ...
    'R-E ideomotor field', 'Effect space', 'Response space'), [1, 3.5], [2.5, 1.5]);

% show simulation time
gui.addVisualization(TimeDisplay(), [10, 1], [1, 1], 'control');

% global control buttons
yButton = 19;
gui.addControl(GlobalControlButton('Pause', gui, 'pauseSimulation', true, false, false, 'pause simulation'), [4+yButton, 1]);
gui.addControl(GlobalControlButton('Reset', gui, 'resetSimulation', true, false, true, 'reset simulation'), [5+yButton, 1]);
gui.addControl(GlobalControlButton('Quit', gui, 'quitSimulation', true, false, false, 'quit simulation'), [6+yButton, 1]);


%% Start simulation

fprintf('\nrunning ...\n')


if showRun
    gui.init();
    gui.connect(sim);
end

% generate effect sequence
goals =  repmat([1; 2], [nTrials/2, 1]);
goals = goals(randperm(length(goals)));
eInput = {'input e_left', 'input e_right'};


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
    
    sim.setElementParameters(eInput(goals(t)), 'amplitude', 6);
    stimOnsetTime = sim.t;
    
    while ~gui.quitSimulation && (sim.t - trialStartTime) < 100
        if showRun
            gui.step();
            gui.updateVisualizations();
            pause(0.05);
        else
            sim.step();
        end
                
        % after response: wair for some time steps and stop effect
        act_r = sim.getComponent('field r', 'activation'); 
        out_r = sim.getComponent('field r', 'output');
        if any(out_r > 0.95)
            for i = 1:5
                if showRun
                    gui.step();
                    gui.updateVisualizations();
                    pause(0.05);
                else
                    sim.step();
                end
                
            end
            sim.setElementParameters('input e_left', 'amplitude', 0);
            sim.setElementParameters('input e_right', 'amplitude', 0);
        end
        
        % after deadline: stop effect
        if (sim.t > stimOnsetTime + 70)
            sim.setElementParameters('input e_left', 'amplitude', 0);
            sim.setElementParameters('input e_right', 'amplitude', 0);
        end
    end
    
end

for i = 1 : iti
    if showRun && showAll
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