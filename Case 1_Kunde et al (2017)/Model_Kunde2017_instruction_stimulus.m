%% Preshape constructor for Experiment 1, Kunde, 2017
% please use main file: Model_Kunde2017_Exp1_main_file

%% Build 2D field preshapes

function stimulus_instruction = Model_Kunde2017_instruction_stimulus(fieldSize, condition, amplitude)

% create simulator object
sim = Simulator();

% create fields
sim.addElement(NeuralField('field s', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field r', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field e', fieldSize, 10, -4, 5));
sim.addElement(NeuralField('field sr', [fieldSize, fieldSize], 10, -4, 5));
sim.addElement(NeuralField('field se', [fieldSize, fieldSize], 10, -4, 5));


% additional soft sigmoid output functions
sim.addElement(Sigmoid('sr soft', [fieldSize, fieldSize], 1, 0), 'field sr', 'activation');
sim.addElement(Sigmoid('se soft', [fieldSize, fieldSize], 1, 0), 'field se', 'activation');
sim.addElement(Sigmoid('s soft', fieldSize, 1, 0), 'field s', 'activation');
sim.addElement(Sigmoid('r soft', fieldSize, 1, 0), 'field r', 'activation');
sim.addElement(Sigmoid('e soft', fieldSize, 1, 0), 'field e', 'activation');

sim.addElement(SumAllDimensions('sum sr soft', [fieldSize, fieldSize]), 'sr soft');
sim.addElement(SumAllDimensions('sum se soft', [fieldSize, fieldSize]), 'se soft');

% create connections
% lateral interactions within fields
sim.addElement(LateralInteractions1D('s -> s', fieldSize, 5, 20, 10, 15, -1), 'field s', [], 'field s');
sim.addElement(LateralInteractions1D('r -> r', fieldSize, 5, 20, 10, 15, -1), 'field r', [], 'field r');
sim.addElement(LateralInteractions1D('e -> e', fieldSize, 5, 20, 10, 15, -1), 'field e', [], 'field e');
sim.addElement(LateralInteractions2D('sr -> sr', [fieldSize, fieldSize], 5, 20, 10, 15, -2), 'field sr', [], 'field sr');
sim.addElement(LateralInteractions2D('se -> se', [fieldSize, fieldSize], 5, 20, 10, 15, -2), 'field se', [], 'field se');

% interactions between fields
sim.addElement(ScaleInput('s -> sr', fieldSize, 5), 's soft');
sim.addElement(ExpandDimension2D('expand s -> sr', 2, [fieldSize, fieldSize]), 's -> sr', [], 'field sr');

sim.addElement(ScaleInput('s -> se', fieldSize, 5), 's soft');
sim.addElement(ExpandDimension2D('expand s -> se', 2, [fieldSize, fieldSize]), 's -> se', [], 'field se');

sim.addElement(ScaleInput('r -> sr', fieldSize, -1), 'r soft');
sim.addElement(ExpandDimension2D('expand r -> sr', 1, [fieldSize, fieldSize]), 'r -> sr', [], 'field sr');

sim.addElement(ScaleInput('sr -> r', fieldSize, 1), 'sum sr soft', 'verticalSum', 'field r');
sim.addElement(ScaleInput('se -> e', fieldSize, 1), 'sum se soft', 'verticalSum', 'field e');

% preshape instruction and effect layer
if strcmp(condition, 'reversed')
    for i=1:5:fieldSize
        sim.addElement(GaussStimulus2D(['preshape instruction', num2str(i)], [fieldSize fieldSize], 3, 3, amplitude, fieldSize-i, i, false, false), [], [], 'field sr');
    end
else
    for i=1:5:fieldSize
        sim.addElement(GaussStimulus2D(['preshape instruction', num2str(i)], [fieldSize fieldSize], 3, 3, amplitude, i, i, false, false), [], [], 'field sr');
    end
end
sim.init();

stimulus_instruction =  zeros(fieldSize, fieldSize);
for i=1:5:fieldSize
    stimulus_instruction = stimulus_instruction + sim.getComponent(['preshape instruction', num2str(i)], 'output');
end

end