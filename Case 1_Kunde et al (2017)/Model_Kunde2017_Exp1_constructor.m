%% Constructor for Experiment 1, Kunde, 2017
% please use main file: Model_Kunde2017_Exp1_main_file

%% setting up the architecture (fields, interactions, and inputs)

% parameters shared by multiple elements
fieldSize = 50;
newposition_s = fieldSize/2;

% create simulator object
sim = Simulator('deltaT', 3);

% create fields
sim.addElement(NeuralField('field s', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field r', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field e', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field se', [fieldSize, fieldSize], 10, -4, 5));
sim.addElement(NeuralField('field er', [fieldSize, fieldSize], 10, -4, 5));


% additional soft sigmoid output functions
sim.addElement(Sigmoid('s soft', fieldSize, 1, 0), 'field s', 'activation');
sim.addElement(Sigmoid('r soft', fieldSize, 1, 0), 'field r', 'activation');
sim.addElement(Sigmoid('e soft', fieldSize, 1, 0), 'field e', 'activation');
sim.addElement(Sigmoid('se soft', [fieldSize, fieldSize], 1, 0), 'field se', 'activation');
sim.addElement(Sigmoid('er soft', [fieldSize, fieldSize], 1, 0), 'field er', 'activation');

sim.addElement(SumAllDimensions('sum se soft', [fieldSize, fieldSize]), 'se soft');
sim.addElement(SumAllDimensions('sum er soft', [fieldSize, fieldSize]), 'er soft');

% create connections
% lateral interactions within fields
sim.addElement(LateralInteractions1D('s -> s', fieldSize, 4, 15, 10, 15, -1), 'field s', [], 'field s');
sim.addElement(LateralInteractions1D('r -> r', fieldSize, 4, 15, 10, 15, -1), 'field r', [], 'field r');
sim.addElement(LateralInteractions1D('e -> e', fieldSize, 4, 15, 10, 15, -1), 'field e', [], 'field e');
sim.addElement(LateralInteractions2D('se -> se', [fieldSize, fieldSize], 5, 15, 10, 20, -2), 'field se', [], 'field se');
sim.addElement(LateralInteractions2D('er -> er', [fieldSize, fieldSize], 5, 15, 10, 20, -2), 'field er', [], 'field er');

% interactions between fields
sim.addElement(ScaleInput('s -> se', fieldSize, 2.5), 's soft');
sim.addElement(ExpandDimension2D('expand s -> se', 1, [fieldSize, fieldSize]), 's -> se', [], 'field se');

sim.addElement(ScaleInput('se -> e', fieldSize, 0), 'sum se soft', 'horizontalSum', 'field e'); % zero input for acquisition simulation

sim.addElement(ScaleInput('e -> er', fieldSize, 0), 'e soft'); % zero input for acquisition simulation
sim.addElement(ExpandDimension2D('expand e -> er', 2, [fieldSize, fieldSize]), 'e -> er', [], 'field er');

sim.addElement(ScaleInput('er -> r', fieldSize, 0), 'sum er soft', 'verticalSum', 'field r'); % zero input for acquisition simulation

sim.addElement(ScaleInput('r -> er', fieldSize, 0), 'r soft');
sim.addElement(ExpandDimension2D('expand r -> er', 1, [fieldSize, fieldSize]), 'r -> er', [], 'field er');


% preshape instruction and effect layer
% define preshape in instruction and anticipation layer as sequence of
% gaussian stimuli
% for se layer
preshape = Model_Kunde2017_instruction_stimulus(fieldSize, 'reversed', 2);
sim.addElement(CustomStimulus('preshape anticipation', preshape), [], [], 'field se');
% for er layer
preshape = Model_Kunde2017_instruction_stimulus(fieldSize, condition, 2);
sim.addElement(CustomStimulus('preshape instruction', preshape), [], [], 'field er');


% create stimuli
sim.addElement(GaussStimulus1D('input s', fieldSize, 5, 0, 0, false), [], [], 'field s');
sim.addElement(GaussStimulus1D('input r', fieldSize, 5, 0, 0, false), [], [], 'field r');
sim.addElement(GaussStimulus1D('input e', fieldSize, 5, 0, 0, false), [], [], 'field e');

% noise
sim.addElement(NormalNoise('noise s', fieldSize, 1), [], [], 'field s');
sim.addElement(NormalNoise('noise r', fieldSize, 1), [], [], 'field r');
sim.addElement(NormalNoise('noise e', fieldSize, 1), [], [], 'field e');
sim.addElement(NormalNoise('noise se', [fieldSize, fieldSize], 1), [], [], 'field se');
sim.addElement(NormalNoise('noise er', [fieldSize, fieldSize], 1), [], [], 'field er');

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
gui.addVisualization(MultiPlot({'field s', 'field s', 'input s'}, ...
    {'activation', 'output', 'output'}, [1, 10, 1], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', [fieldSize/4, fieldSize/2, 3*fieldSize/4], 'XTickLabel', {}, ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}}, 'Stimulus field', ''), [2, 1], [1.3, 2.5]);

% effect field
gui.addVisualization(MultiPlot({'field e', 'field e', 'se -> e', 'R-E ideomotor'}, ...
    {'activation', 'output', 'output', 'output'}, [1, 10, 1, 1], 'vertical', ...
    {'XLim', [-12.5, 12.5], 'Box', 'on', 'XGrid', 'on', 'XDir', 'reverse', 'YAxisLocation', 'right', 'YTick', [fieldSize/4, fieldSize/2, 3*fieldSize/4], 'YTickLabel', {}, ...
    'YLim', [0, fieldSize], ...
    'XTick', [-10, -5, 0, 5, 10], 'XTickLabel', {'-10', '', '0', '', '10'}},  ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'m', 'LineWidth', 1.5}}, ...
    'Effect (Goal) field', [], ''), [3.5, 4.75], [3.5, 1]);

% response field
gui.addVisualization(MultiPlot({'field r', 'field r', 'er -> r', 'R-E ideomotor'}, ...
    {'activation', 'output', 'output', 'output'}, [1, 10, 1, 1], 'horizontal', ...
    {'YLim', [-12.5, 12.5], 'Box', 'on', 'YGrid', 'on', 'XTick', [fieldSize/4, fieldSize/2, 3*fieldSize/4], 'XTickLabel', {}, ...
    'YTick', [-10, -5, 0, 5, 10], 'YTickLabel', {'-10', '', '0', '', '10'}}, ...
    {{'b', 'LineWidth', 1.5}, {'r', 'LineWidth', 1.5}, {'g', 'LineWidth', 1.5}, {'m', 'LineWidth', 1.5}}, 'Response field', ''), [2, 6], [1.3, 2.5]);

% se anticipation field
gui.addVisualization(ScaledImage('field se', 'activation', [-7.5, 7.5], ...
    {'YAxisLocation', 'right', 'YDir', 'normal', 'XTick', fieldSize/2, 'XTickLabel', '', ...
    'YTick', fieldSize/2, 'YTickLabel', ''}, {},  ...
    'Anticipation field'), [3.5, 1], [3.5, 2.5]);

% sr instruction field
gui.addVisualization(ScaledImage('field er', 'activation', [-7.5, 7.5], ...
    {'YAxisLocation', 'right', 'YDir', 'normal', 'XTick', fieldSize/2, 'XTickLabel', '', ...
    'YTick', fieldSize/2, 'YTickLabel', ''}, {},  ...
    'Instruction field'), [3.5, 6], [3.5, 2.5]);


% Ideomotor field
gui.addVisualization(ScaledImage('E-R ideomotor', 'weights', [0, 1], {'YDir', 'normal'}, {}, ...
    'Ideomotor field', '', ''), [1, 4.5], [2.5, 1.5]);

% show simulation time
gui.addVisualization(TimeDisplay(), [11, 1.5], [1, 1], 'control');

% gui.addControl(ParameterSwitchButton('Response on/off', {'s -> sr' 'E-R ideomotor -> r'}, {'amplitude', 'amplitude'},  {0, 0}, {2, 1}, 'Initiate or inhibit response', true), [11, 1], [1, 1], 'control');

% global control buttons
gui.addControl(GlobalControlButton('Pause', gui, 'pauseSimulation', true, false, false, 'pause simulation'), [24, 1]);
gui.addControl(GlobalControlButton('Quit', gui, 'quitSimulation', true, false, false, 'quit simulation'), [25, 1]);


%% Start simulation acquisition phase

fprintf('\nsimulate learning...\n')

sim.init();
if showRun
    gui.init();
    gui.connect(sim);
end


for t = 1:2
    sim.setElementParameters('input r', 'amplitude', 6);
    sim.setElementParameters('input e', 'amplitude', 6);
    position = 0;
    sim.setElementParameters('input r', 'position', position);
    sim.setElementParameters('input e', 'position', position);
    while ~gui.quitSimulation && position <= fieldSize
        if showRun
            gui.step();
            gui.updateVisualizations();
            pause(0.05);
        else
            sim.step();
        end
        
        position = sim.getElementParameter('input r', 'position');
        sim.setElementParameters('input r', 'position', position + 1);
        sim.setElementParameters('input e', 'position', position + 1);
        
        % let it settle
        for i = 1:10
            if showRun
                gui.step();
                gui.updateVisualizations();
                pause(0.05);
            else
                sim.step();
            end
        end
    end
end


% add some time to have fields in resting level
sim.setElementParameters('input r', 'amplitude', 0);
sim.setElementParameters('input e', 'amplitude', 0);
for i = 1:50
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
