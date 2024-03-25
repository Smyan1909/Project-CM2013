EOG artefact detection: a discussion
====================================

Concept 1. A first attempt with thresholds on an epoch-based measure of signal power
---------------------------------------------------------------------------

As described in [EOG.md](EOG.md), the main artefact that can be clearly distinguished is amplifier saturation due to
likely loss of electrode contact. This can be reliably detected by taking a measure of the signal power averaged over
some period of time, such as e.g. by `rms(...)` in MATLAB.

Making use of this feature, one may try to use a simple thresholding method to reject epochs where amplifier saturation
(and resulting waveform clipping) occurs.

The chief problem lies in the determination of such thresholds, and how to do this not arbitrarily.

Based on a visual analysis of signals and the corresponding RMS amplitudes, it appears that some high activity regions
(see R6.edf @ 1800-1960 s, R7.edf beginning) that are not apparently (purely) artefact reach as much as
90 μV RMS amplitude, which makes it challenging to establish a sensitive yet specific threshold.


Concept 2. Integrating artefact detection into the machine learning algorithm
-----------------------------------------------------------------------------

Instead of treating artefact detection as a separate process in the overall pipeline,
perhaps it would be better to instead integrate it into the feature engineering, model training and classification
elements.

1. Add an "artefact" label to epochs, as determined manually.
   - Probably better to add another binary variable "artefact yes/no" rather
   than just another "sleep stage" category, as artefacts could possibly blend
   into different sleep stages.
   Even if this turns out unnecessary, then the extra binary
   variable can be easily collapsed into a separate category of "sleep stage".
2. *(potentially)* self-supervised learning in a crude way by using this to automatically find other epochs that look
"artefact-like", then correct the labels manually as fit to broaden the training set.
3. Exclusion of artefact-marked regions from use for sleep stage prediction – at least as long as the ML method used can tolerate missing data.