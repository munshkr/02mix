s.boot;

// basic SynthDef suited for pitch-shift and time-stretch
// buffer position given relatively (posLo and posHi between 0 and 1)
// posDev: maximum amount of deviation from (moving) grain center position
// posDev = 0 can lead to comb filter effects (which may be nice sometimes)

// passing control specs as metadata allows for VarGui shortcut build method sVarGui
// metadata specs can be overwritten by arg ctrReplace
// alternatively control specs may be passed as synthCtr arg to a build with VarGui( ... )

(
SynthDef(\gran_1a, { arg out = 0, bufNum = 0, posLo = 0.0, posHi = 1.0,
    posRate = 1, posDev = 0.01, trigRate = 100, granDur = 0.1, rate = 1.0,
    panMax = 1, amp = 0.1, interp = 4;

    var trig, pan, pos, bufDur, bufDurSection, posDif;

    posDif = posHi - posLo;
    bufDur = BufDur.kr(bufNum);
    bufDurSection = bufDur * posDif;
    trig = Impulse.kr(trigRate);
    pos = posLo * bufDur +
        (Phasor.ar(0, BufRateScale.kr(bufNum) * posRate / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
        (TRand.kr(-0.5 * posDev, 0.5 * posDev, trig) * bufDur)).mod(bufDurSection);
    pan = Demand.kr(trig, 0, Dseq([panMax, panMax.neg],inf) * 0.999);
    Out.ar(out, TGrains.ar(2, trig, bufNum, rate, pos, granDur, pan, 1, interp) * amp);
    }, metadata: (
        specs: (
            posLo: [0.01, 0.99, \lin, 0.01, 0],
            posHi: [0.01, 0.99, \lin, 0.01, 1],
            posRate: [0.1, 2, \lin, 0.01, 1],
            posDev: [0, 0.2, 5, 0, 0.01],
            granDur: [0.01, 0.3, \lin, 0.01, 0.1],
            trigRate: [1, 200, \lin, 0.01, 100],
            rate: [0.1, 2, \lin, 0.01, 1],
            panMax: [0.0, 1, \lin, 0.005, 0.8],
            amp: [0.0, 0.5, \lin, 0.005, 0.25]
        )
    )
).add;

b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// This searches the most likely extension places for the miSCellaneous folder.
// In case of an extraordinary install situation or a removed sound file, pass the concerned path.

)


// start from GUI

\gran_1a.sVarGui([\bufNum, b.bufnum]).gui;