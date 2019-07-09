
# IDEONAMICS
## An integrative computational dynamic model of ideomotor learning and effect-based action control

Written by Diana Vogel Technische Universität Dresden, Germany. <br>
Developed by Diana Vogel<sup>1</sup>, Wilfried Kunde<sup>2</sup>, Oliver Herbort<sup>2</sup> and Stefan Scherbaum<sup>1</sup><br>
<sup>1</sup> Department of Psychology, Technische Universität Dresden, Germany <br>
<sup>2</sup> Department of Psychology (III), Julius Maximilians University Würzburg

Copyright (c) 2019 [Diana Vogel](Diana.Vogel@tu-dresden.de) <br>
Published under the Simplified BSD License (see [LICENSE file](https://github.com/dianavogel/IDEONAMICS/blob/master/LICENSE))


## OVERVIEW

IDEONAMICS is a dynamic field based neurocognitive architecture which simulates basic experiments in the research field of ideomotor theory and effect-based action control in MATLAB. The technical and methodological framework of IDEONAMICS is Dynamic Field Theory (DFT), as it is implemented in the [COSIVINA](https://bitbucket.org/sschneegans/cosivina) toolbox.

## ABSTRACT

When people perform a motor action, they observe its subsequent perceptual effects and store corresponding action-effect associations. According to ideomotor theory people recollect effect memories and induce corresponding actions across these associations, when intending to generate motor actions. Hence, actions are represented, controlled and retrieved by means of the sensory effects that these actions experientially engender. The theory has received extensive supporting evidence in recent years. To capture this particular effect-based view on action control and goal-directed behavior, we developed IDEONAMICS, an integrative computational based on Dynamic Field Theory that contains several dynamic fields, each of which reflecting a specific component of the action control process. We show that IDEONAMICS can be applied conveniently to different types of experimental ideomotor settings to simulate key findings and reapproach the underlying cognitive mechanisms from a computational point of view. IDEONAMICS generates explanations for experimental results as well as novel predictions that can be investigated in further research. We encourage the application of IDEONAMICS to more types of ideomotor settings to gain insights into effect-based action control. 

## DESCRIPTION

The model consists of a number of dynamic fields that reflect specific components of the cognitive processes in effect-based action control. Dynamic fields consist of a number of nodes that bear a specific activation value. Nodes in one field co-activate adjacent nodes (local activation) and inhibit more distant nodes (local inhibition) which leads to a Mexican hat shape of an activation peak. Input can be introduced to a field as an independent stimulus or as output passed from another field. Once the activation value of a location within the field surpasses zero, it produces output. Connections between fields carry over the output of the sender field and add the activation value to the corresponding location in the receiver field. Connections are defined either excitatory or inhibitory.  Before activation is carried over, fields may also hold an a priori sub-threshold pre-activation, for instance, for modeling discrete components, such as keypresses or different colors, or for modeling relations between two dimensions, as used for implementing instructions. 

The main field types reflect sensory evoked entities of stimuli, effects and responses and are connected in a predefined manner. Between these fields, two-dimensional fields are employed to map activation between the fields’ variable space. The content-wise base of IDEONAMICS is ideomotor theory which provides principles of how the fields shall work together. The main idea of IDEONAMICS is that imperative stimuli can activate representations of sensory consequences (effects). Effect representations are connected to actions via bidirectional (ideomotor) connections build through learning. Consequently, the activation of effect codes pre-activates those actions (responses)<sup>1</sup> to which effects codes are linked. However, stimuli can be linked to effects in two ways. First, because stimuli and effects resemble each other or are even identical to each other (i.e. are “ideomotor compatible”, Greenwald, 1970). Second, because stimuli are mapped to effects by instruction. Typical experiments vary whether stimuli do or do not converge to the same effect representations. 

The model permits approaching ideomotor theory from a robotics point of view and help understanding the underlying mechanisms of ideomotor experiments. It provides a biologically plausible inspection of processes occurring in effect-based action planning and control. Additionally, it allows for simulations of a large spectrum of ideomotor experiments and supplementary experimental conditions. Run performance parameters, such as RTs, errors, response frequencies, activation patterns of nodes and fields, connection weights etc. and their trend over time, help understanding elementary model mechanisms and can be used to make further predictions. As model parameters and the model architecture can be flexibly adjusted, new experimental conditions can easily be implemented. This facilitates generating new hypotheses and encourages further research.

<sup>1</sup> Activity in the action field is here supposed to represent efferent activity which, if strong enough, results in observable body movements. However, this motor activity is almost indistinguishably linked to interoceptive reafferences. So in principle the action field can also be construed as a field representing interoceptive effects that come with this efferent activity (cf. Pfister, 2019).

## References

Greenwald, A. G. (1970). Sensory feedback mechanisms in performance control: With special reference to the ideo-motor mechanism. *Psychological Review, 77*(2), 73–99. https://doi.org/10.1037/h0028689<br>
Pfister, R. (2019). Effect-based action control with body-related effects: Implications for empirical approaches to ideomotor action control. *Psychological Review, 126*(1), 153–161. https://doi.org/10.1037/rev0000140
