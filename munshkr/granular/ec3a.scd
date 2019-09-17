// Here the trigger for the TGrains ugen comes from a Pbind
// which also generates rates like a step sequencer


(
SynthDef(\gran_3a, { arg out = 0, posLo = 0.0, posHi = 1.0,
    posRate = 1, posDev = 0.01, bufNum = 0, t_trig = 0,
    granDur = 0.1, t_rate = 1.0, rateDev = 0,
    panMax = 1, amp = 0.1, interp = 4;

    var pan, pos, bufDur, bufDurSection, posDif;

    posDif = posHi - posLo;
    bufDur = BufDur.kr(bufNum);
    bufDurSection = bufDur * posDif;
    pos = posLo * bufDur +
        (Phasor.ar(0, BufRateScale.kr(bufNum) * posRate / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
        (TRand.kr(-0.5, 0.5, t_trig) * posDev * bufDur)).mod(bufDurSection);
    pan = Demand.kr(t_trig, 0, Dseq([panMax, panMax.neg], inf) * 0.999);
    Out.ar(out, TGrains.ar(2, t_trig, bufNum, t_rate, pos, granDur, pan, 1, interp) * amp);
    }, metadata: (
        specs: (
            posLo: [0.01, 0.99, \lin, 0.01, 0],
            posHi: [0.01, 0.99, \lin, 0.01, 1],
            posRate: [0.1, 2, \lin, 0.01, 1],
            posDev: [0, 0.2, 5, 0, 0.01],
            panMax: [0.0, 1, \lin, 0.005, 0.8],
            amp: [0.0, 1, \lin, 0.005, 0.5]
        )
    )
).add;

b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// This searches the most likely extension places for the miSCellaneous folder.
// In case of an extraordinary install situation or a removed sound file, pass the concerned path.
)


// As the setting Pbind needs to know the Synth's nodeID
// the Synth has to be started explicitely and passed to the VarGui later on
// (VarGui takes Synths as well as SynthDefs, passing a SynthDef is recommended in general).
// The Synth starts silently as t_trig defaults to 0.


(
x = Synth(\gran_3a, [\bufNum, b]).register;

p = Pbind(
    \type, \set,
    \id, x,
    \args, [\t_trig, \t_rate, \granDur],

    \dur, PL(\dur),
    \granDur, Pkey(\dur) * PL(\legato),
    \t_trig, 1,
    \t_rate, PLseq(\midi).midiratio
);
)

// Do start and pause with the Pbind (EventStreamPlayer) player.
// If you stop the Synth you cannot resume audio with a new Synth
// as the EventStreamPlayer has lost the correct nodeID
// (however the Synth can be paused and resumed).

(
VarGui(varCtr: [
    \dur, [0.01, 0.1, \lin, 0, 0.05],
    \legato, [0.3, 3, \lin, 0, 1],
    \midi, [-12, 12, \lin, 1, 1] ! 8
    ], synth: x, stream: p
).gui;
)