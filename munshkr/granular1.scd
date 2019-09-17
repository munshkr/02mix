p = ProxySpace.push(s);
p.pop;

(
SynthDef(\gran_2a, { |out = 0, pos = 0, sndBuf = 0, windowBuf = 1, granDur = 0.1,
    rate = 1, loop = 1, panMax = 0, amp = 1, bpFreq = 500, bpRQ = 0.5, bpWet = 1|
    var window, granSrc, src;
	granSrc = PlayBuf.ar(1, sndBuf, BufRateScale.kr(sndBuf) * Lag.kr(rate),
        1, round(pos * BufFrames.kr(sndBuf)), loop, 2);
    window = BufRd.ar(1, windowBuf,
        EnvGen.ar(Env([0, BufFrames.kr(windowBuf)], [granDur]),
        doneAction: 2), loop, 4);
	// do amplitude compensation, estimation like in Wavesets example by Alberto de Campo
    src = (BPF.ar(granSrc, bpFreq, bpRQ, mul: (bpRQ ** -1) * (400 / bpFreq ** 0.5)) *
        bpWet + (granSrc * (1 - bpWet)));
    OffsetOut.ar(out, Pan2.ar(src, panMax, amp) * window);
}).add;

b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// This searches the most likely extension places for the miSCellaneous folder.
// In case of an extraordinary install situation or a removed sound file, pass the concerned path.

w = Buffer.sendCollection(s, Signal.hanningWindow(1024));
)

Synth(\gran_2a, [\sndBuf, b, \windowBuf, w])

b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");

(
var samplesPath = Platform.userHomeDir +/+ "Samples" +/+ "granular";
b = Buffer.read(s, samplesPath +/+ "325235__psychopancake__rubbing-metal.wav");
)

// Determining the correct buffer position depending on
// posRate, posLo and posHi needs a little calculation.
// In 1a this was done inside the ugen by a Phasor.
// See Ex.3b, 3c for doing position movement with a separate Synth.

// PL placeholder patterns used, could also be Pfunc { ~ ... }



(
Pdef(\g1, Pbind(
    \instrument, \gran_2a,
    \sndBuf, b,
    \windowBuf, w,

	\trigRate, Pseq([10], inf),
	\dur, 1/32,
	\granDur, Pseq([0.1, 0.3, 0.2], inf) / 1,
    \time, Ptime(),
	\posRate, 0.8,
	\posLo, 0,
	\posHi, 1,
	\posDev, 0.5,
    \pos, Pfunc { |e|
		var relTime, relDif;
		// e.postln;
		relTime = e.posRate * e.time / e.sndBuf.duration;
		relDif = e.posHi - e.posLo;
		relTime + rand2(e.posDev) % relDif + e.posLo;
    },
	\bpFreqLo, Pwhite(50, 2000, inf),
	\bpFreqHi, Pwhite(50, 10000, inf),
	// \bpFreqD, Pwhite(0, 7, inf),
	\bpRQ, Pwhite(0.01, 0.4, inf),
	\bpWet, 0.8,
	\rate, Pwhite(0.47, 0.5, inf),
	\amp, Pwhite(0.6, 0.9, inf),
    \panMax, Pseq([-1,1], inf) * 0.75,
    \out, 0
));

/*
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
*/
)

Pdef(\g1).stop