// Control parameters like in Ex.1a, but implemented with a SynthDef for
// playing single grains and an appropriate Pbind,
// OffsetOut used for exact timing.

(
SynthDef(\gran_2a, { |out = 0, pos = 0, sndBuf = 0, windowBuf = 1, granDur = 0.1,
    rate = 1, loop = 1, panMax = 0, amp = 1|
    var window, src;
    src = PlayBuf.ar(1, sndBuf, BufRateScale.kr(sndBuf) * rate,
        1, round(pos * BufFrames.kr(sndBuf)), loop, 2);
    window = BufRd.ar(1, windowBuf,
        EnvGen.ar(Env([0, BufFrames.kr(windowBuf)], [granDur]),
        doneAction: 2), loop, 4);
    OffsetOut.ar(out, Pan2.ar(src, panMax, amp) * window);
}).add;

b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// This searches the most likely extension places for the miSCellaneous folder.
// In case of an extraordinary install situation or a removed sound file, pass the concerned path.

w = Buffer.sendCollection(s, Signal.hanningWindow(1024));
)


// Determining the correct buffer position depending on
// posRate, posLo and posHi needs a little calculation.
// In 1a this was done inside the ugen by a Phasor.
// See Ex.3b, 3c for doing position movement with a separate Synth.

// PL placeholder patterns used, could also be Pfunc { ~ ... }

(
p = Pbind(
    \instrument, \gran_2a,
    \sndBuf, b,
    \windowBuf, w,

    \dur, 1 / PL(\trigRate),
    \granDur, PL(\granDur),
    \time, Ptime(),
    \pos, Pfunc { |e|
        var relTime = ~posRate * e.time / e.sndBuf.duration, relDif;
        relDif = ~posHi - ~posLo;
        relTime + rand2(~posDev) % relDif + ~posLo;
    },
    \rate, PL(\rate),
    \amp, PL(\amp),
    \panMax, PLseq([-1,1]) * PL(\panMax),
    \out, 0
);

VarGui([
    \posLo, [0.0, 0.99, \lin, 0.01, 0],
    \posHi, [0.0, 0.99, \lin, 0.01, 1],
    \posRate, [0.1, 2, \lin, 0.01, 1],
    \posDev, [0, 0.2, 5, 0, 0.01],
    \trigRate, [1, 200, \lin, 0.01, 120],
    \granDur, [0.01, 0.3, \lin, 0.005, 0.06],
    \rate, [0.1, 3, \lin, 0.01, 1],
    \panMax, [0.0, 1, \lin, 0.0, 0.8],
    \amp, [0.0, 1, \lin, 0.01, 0.25]
    ], stream: p
).gui(varColorGroups: (0..8).clumps([4,1,1,1,1,1]))
)

// 1. make some tests with pbind only and proxyspace
p = ProxySpace.push(s);

~g1 = Pbind(
    \instrument, \gran_2a,
    \sndBuf, b,
    \windowBuf, w,

	\trigRate, Pseq([1, 10, 50, 150, 200], inf),
    \dur, 1 / Pkey(\trigRate),
    \granDur, Pkey(\granDur),
    \time, Ptime(),
    \pos, Pfunc { |e|
        var relTime = ~posRate * e.time / e.sndBuf.duration, relDif;
        relDif = ~posHi - ~posLo;
        relTime + rand2(~posDev) % relDif + ~posLo;
    },
    \rate, PL(\rate),
    \amp, PL(\amp),
    \panMax, PLseq([-1,1]) * PL(\panMax),
    \out, 0
);

// 2. send output to another audio bus, and pass through synthdef with ADSR env

