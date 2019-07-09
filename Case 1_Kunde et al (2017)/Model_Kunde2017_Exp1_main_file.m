%% Simulation of Kunde, Schmidts, Wirth, Herbort (2017), Experiment 1
% Kunde, W., Schmidts, C., Wirth, R., Herbort, O. (2017).
% Action Effects Are Coded as Transitions From Current to Future Stimulation: Evidence From Compatibility Effects in Tracking
% Journal of Experimental Psychology: Human Perception and Performance, 43(3), 477-486

clear;
iti = 50; % intertrial interval
condition = 'straight'; % either 'straight' or 'reversed'
nTrials = 100; % number of different stimulus locations ("trials")

%% Run constructor
showRun = 0;
showAll = 0;
Model_Kunde2017_Exp1_constructor

%% Do you want to see the experiment running?
showRun = 1; % 1: online mode | 0: offline mode
showAll = 0; % show also intertrial interval

%% parameters shared by multiple elements

sim.t = sim.tZero;
sim.setElementParameters('input s', 'position', fieldSize/2);
sim.setElementParameters('input r', 'position', fieldSize/2);
sim.setElementParameters('input e', 'position', fieldSize/2);

sim.setElementParameters('input s', 'amplitude', 6);
sim.setElementParameters('input r', 'amplitude', 0);
sim.setElementParameters('input e', 'amplitude', 0);

sim.setElementParameters('R-E ideomotor', 'learningRate', 0);
sim.setElementParameters('E-R ideomotor', 'learningRate', 0);

sim.setElementParameters('se -> e', 'amplitude', 2.5);
sim.setElementParameters('e -> er', 'amplitude', 1.5);
sim.setElementParameters('er -> r', 'amplitude', 2.5);

%% Start simulation acquisition phase

acceleration = 1.2;  % acceleration to superimpose field dynamics
oldposition_s = sim.getElementParameter('input s', 'position');
newposition_s = fieldSize/2;
activity_r = 0;

% start experiment
fprintf('\nrunning experiment...\n')

if showRun
    gui.init();
    gui.connect(sim);
end


% update gui
for i = 1:iti/5
    if showRun && showAll
        gui.step();
        gui.updateVisualizations();
        pause(0.02);
    else
        sim.step();
    end
end

for t = 1 : nTrials
    diff = 0;
    trialStartTime = sim.t;
    deviation = [];
    % shift stimulus towards trial location
    while ~gui.quitSimulation && (sim.t - trialStartTime) < 450  
        % update gui
        for i = 1:10*sim.deltaT
            if showRun
                gui.step();
                gui.updateVisualizations();
                pause(0.02);
            else
                sim.step();
            end
        end
        
        oldposition_s = sim.getElementParameter('input s', 'position');
        deviation = [deviation; (oldposition_s-fieldSize/2).^2];
        while diff == 0
            if oldposition_s < 5
                diff = 1;
            elseif oldposition_s > fieldSize+5
                diff = -1;
            else
                diff = randi([-1, 1])
            end
        end
        shift_s = 3*diff;
 
        % determine response
        act_r = sim.getComponent('field r', 'activation');
        [~, newpeakPos_r] = singleLinkageClustering(act_r > 0, 3, 'circular');
        if length(newpeakPos_r) == 1
            activity_r = newpeakPos_r - fieldSize/2 ;
            if strcmp(condition, 'straight')
                shift_r = acceleration*activity_r;
            else
                shift_r = -acceleration*activity_r;
            end
            if abs(oldposition_s - fieldSize/2) < 5
                shift_r = 0;
            end
        else
            shift_r = 0;
        end
        
        % move stimulus
        if ~gui.pauseSimulation
            if oldposition_s + (shift_s + shift_r) < 5 || oldposition_s + (shift_s + shift_r) > fieldSize-5
                break
            end
            sim.setElementParameters('input s', 'position', oldposition_s + (shift_s + shift_r));
        end
        act_r = sim.getComponent('field r', 'activation');
    end
    data(t).deviation = vertcat(deviation);
end


if showRun
    gui.close();
end
sim.close();


for i=1:length(data)
    deviation = [deviation; data(i).deviation];
end
MSE = mean(deviation);
RMSE = sqrt(MSE);