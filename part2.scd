// Part 2
(
~j2 = ~makeJack.(2).play(vol: 0.04).stop;
)

(
~j2[10] = \filter -> { |in|
	Resonz.ar(in,
		MouseX.kr(1000, 4000),
		MouseY.kr(0.01, 0.9)
	)
};
)

(
~j2[20] = \filter -> { |in|
	0.3 * Limiter.ar(
		(
			RLPF.ar(in,
				SinOsc.kr(1/8).range(200, 2200),
				0.8
			)
		).tanh
	)
};
)

(
~j2[30] = \filter -> { |in|
	JPverb.ar(in, damp: 0, t60: 5, lowcut: 400, highcut: 3000)
};
)

(
~j2.set(\wet11, 0.01);
~j2[11] = \filter -> { |in|
	DynKlank.ar(`[[Array.rand(12, 800.0, 2000.0)], nil, [1, 1, 1, 1]], in)
	* SinOsc.kr(1/32).range(0, 1)
};
)

//~j2[11] = \filter -> { |in| DynKlank.ar(`[[32.70320, 123.4708, 130.8128, 138.5909, 155.5635, 164.8138], nil, [1, 1, 1, 1]], in) }
// ~j2[11] = nil

// ~j2g = { MouseX.kr(0,1) > 0.5 };
// ~j2[50] = \filter -> { |in| in * EnvGen.ar(Env.adsr(attack: 0, release: 8), ~j2g) };
// ~j2[50] = nil

~j2.play;

~j2.stop(5);



/// iris fx

~iris.set(\wet30, 0);
~iris[30] = \filter -> { |in| (in * 0.5) + (in * 0.5 * SinOsc.kr(SinOsc.kr(1/16).range(1, 8)).range(0,1)) };
~iris.set(\wet30, 0.25);

~iris.set(\wet40, 0);
~iris[40] = \filter -> { |in| RLPF.ar(in, SinOsc.kr(1/16).range(600, 30000), 0.5) };
~iris.set(\wet40, 0.5);

~iris.set(\wet60, 0);
~iris[60] = \filter -> { |in| JPverb.ar(in, t60: 3) };
~iris.set(\wet60, 0.3);

///

// grains
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
//b = Buffer.read(s, Platform.userHomeDirectory +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// This searches the most likely extension places for the miSCellaneous folder.
// In case of an extraordinary install situation or a removed sound file, pass the concerned path.

w = Buffer.sendCollection(s, Signal.hanningWindow(1024));
)

//Synth(\gran_2a, [\sndBuf, b, \windowBuf, w, \granDur, 1]);

(
~g1[0] = Pbind(
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
	\posDev, 0.7,
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
	\rate, Pwhite(0.47, 0.47, inf),
	\amp, Pwhite(0.6, 0.9, inf),
    \panMax, Pseq([-1,1], inf) * 0.75,
    \out, 1
)
);


~g1g = { MouseX.kr(0,1) > 0.5 };
~g1[50] = \filter -> { |in| in * SinOsc.kr(1/8).range(0, 1) * EnvGen.ar(Env.adsr(2, release: 16), ~g1g) };

~g1[50] = \filter -> { |in| in * SinOsc.kr(1/4).range(0, 1) };

~g1[60] = \filter -> { |in| JPverb.ar(in, t60: 1) };
~g1.play;

~g1.stop
