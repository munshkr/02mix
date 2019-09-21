// Part 2
~jack.stop;

(
~pfq = {1};
~pwm = {1/4};
~amp = {0.2};
~leftAmp = { SinOsc.kr(0.0125).range(0.5, 1)};
~rightAmp = { SinOsc.kr(0.125, 0.5).range(0.5, 1)};

~ritmoAmp[0] = {
	var in = Pan2.ar(Mix(SoundIn.ar([0,1])));
	var p = Pulse.ar(~pfq, SinOsc.kr(~pwm).range(0.1, 0.9));
	var sig = in * EnvGen.kr(Env.perc(0.01, 1/8), gate: p) * ~amp;
	//var sig = in * p  * ~amp;
	[sig * ~leftAmp, sig * ~rightAmp];
};
~ritmoAmp[99] = \filter -> { |in| Limiter.ar(in) };
)
~ritmoAmp.play;

//~foo[1] = \filter -> { |in| FreqShift.ar(in, freq: SinOsc.kr(2).range(0, 100), phase: 0.25) }
//~foo.set(\wet1, 0.75)
//~foo[1] = nil

//~foo2[2] = \filter -> { |in| DelayC.ar(in, 5, [1/2, 1/3]) };
//~foo2[2] = nil

//~foo2[3] = \filter -> { |in| Pan2.ar(in, SinOsc.kr(8).range(0, 1)) };
//~foo2[3] = nil

//~foo2[10] = \filter -> { |in| (in * 0.5) + (in * SinOsc.kr(SinOsc.kr(1/8).range(0.125, 16)).range(0,1) * 0.5) };

//~iris[10] = nil

(
~pwm = { SinOsc.kr(1/32).range(0.125, 0.875) };
~pfq = { SinOsc.kr(1/16).range(0.25, 2) };
)

~pwm = { 0.5 };
~pfq = { 1 };

(
~pfq = \setsrc -> Pbind(
	\source, Pseq([2, 20, 0.5, 0.7, 40, 7, 4, 90], inf),
	\dur, Prand([1/8],inf)
);
)

~ritmoAmp.clear(3)

~ritmoAmp.set(\wet10, 0.3);
~ritmoAmp[10] = \filter -> { |in| JPverb.ar(in, t60: 1) };
~ritmoAmp.set(\wet11, 0.4);
~ritmoAmp[11] = \filter -> { |in| RLPF.ar(in, SinOsc.kr(10).range(500, 6000), rq: 0.8) };


/*
~j1.set(\wet10, 0.5);
~j1[11] = \filter -> { |in| JPverb.ar(in, t60: 1) }
~j1[11] = nil;

~j1.set(\wet11, 0.7)
~j1[11] = \filter -> { |in| Resonz.ar(in, SinOsc.kr(1/8).range(300, 2800), 0.9) }

~j1.set(\wet12, 0.02)
~j1[12] = \filter -> { |in| Ringz.ar(in, 70.midicps, 0.1) }

~j1.set(\wet12, 0.5);
~j1[12] = \filter -> { |in| RLPF.ar(in, SinOsc.kr(1/32).range(440, 4000), LFTri.kr(1/4).range(0.1, 1.0)) };
*/


// resonant fx

~j2[0] = { Pan2.ar(Mix(SoundIn.ar([0,1]))) };
~j2[100] = \filter -> { |in| Limiter.ar(in) };

~j2[10] = \filter -> { |in| Resonz.ar(in, MouseX.kr(1000, 4000), MouseY.kr(0.01, 0.9)) }

~j2[20] = \filter -> { |in| 0.3 * Limiter.ar((RLPF.ar(in, SinOsc.kr(1/8).range(200, 2200), 0.8)).tanh) }
~j2[30] = \filter -> { |in| JPverb.ar(in, damp: 0, t60: 5, lowcut: 400, highcut: 3000) }

~j2.set(\wet11, 0.01);
//~j2[11] = \filter -> { |in| DynKlank.ar(`[[Array.rand(12, 800.0, 2000.0)], nil, [1, 1, 1, 1]], in) }
//~j2[11] = \filter -> { |in| DynKlank.ar(`[[32.70320, 123.4708, 130.8128, 138.5909, 155.5635, 164.8138], nil, [1, 1, 1, 1]], in) }
~j2[11] = nil


~j2g = { MouseX.kr(0,1) > 0.5 };
~j2[50] = \filter -> { |in| in * EnvGen.ar(Env.adsr(attack: 0, release: 8), ~j2g) };
~j2[50] = nil

~j2.fadeTime = 5;
~j2.play;

~j2.clear(5);


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
