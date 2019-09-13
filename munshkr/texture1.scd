p = ProxySpace.push(s);

~in[0] = { SoundIn.ar(0).dup }
~in.play

~in[10] = \filter -> { |in| Resonz.ar(in, MouseX.kr(1000, 4000), MouseY.kr(0.1, 0.9)) }

~in[11] = \filter -> { |in| DynKlank.ar(`[[880, 440, 110, Array.rand(12, 800.0, 2000.0)], nil, [1, 1, 1, 1]], in) }
~in[20] = \filter -> { |in| 0.3 * Limiter.ar((RLPF.ar(in, SinOsc.kr(1/8).range(200, 2200), 0.8)).tanh) }
~in[30] = \filter -> { |in| JPverb.ar(in, damp: 0, t60: 10, lowcut: 400, highcut: 3000) }

~in.clear(10)

// overlap texture
(
SynthDef("klanktex1", { |out=0, freqs=#[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings=#[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk=5, sus=8, rel=5, pan=0|
	var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction: Done.freeSelf);
	var i = BrownNoise.ar(0.0012);
	var z = Klank.ar(
		`[freqs, nil, rings],     // specs
		i                    // input
	);
	Out.ar(out, Pan2.ar(z*e, pan));
}).add;
)

(
var sustain = 6, transition = 4, overlap = 5;
var dur = transition*2 + sustain / overlap;
~tex[0] = Pbind(\instrument, \klanktex1,
	\atk, transition,
	\sus, sustain,
	\rel, transition,
	\pan, Pfunc { 1.0.rand2 },
	\freqs, Pfunc { {6000.0.linrand+80}.dup(12) },
	\rings, Pfunc { {0.1.rrand(3)}.dup(12) },
	\dur, dur
);
)
~tex.play;

~tex[10] = \filter -> { |in| JPverb.ar(in, t60: 5, lowcut: 14000, highcut: 15000) }

~tex.stop(5)


s.record
s.stopRecording