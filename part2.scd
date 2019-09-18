// Part 2
~jack.stop;

(
SynthDef.new(\uno, { |in = 0, out = 0|
	var sig, cut, pulse, filteredPulse;
	pulse = Pulse.ar(~pfq, SinOsc.kr(~pwm).range(0.01, 0.99));
	// pulse = Pulse.ar(~pfq, SinOsc.kr(1/2).range(0.2,0.8));
	sig = SoundIn.ar(in!2, 0.7) * pulse;
	Out.ar(out, [sig * ~leftAmp, sig * ~rightAmp]);
}).add;

~pfq = {1/8};
~pwm = {2};
~amp = {0.25};
)

~uno[0] = \uno;
~uno.play;

~uno[100] = \filter -> {|in| Limiter.ar(in) };

~pwm = { SinOsc.kr(0.25).range(0.25, 0.75)}
~pfq = { 7 }
~leftAmp = { SinOsc.kr(0.0125).range(0, 1)}
~rightAmp = { SinOsc.kr(0.125, 0.5).range(0, 1)}

(
~pfq = \setsrc -> Pbind(
	\source, Pseq([2, 20, 0.5, 0.7, 40, 7, 4, 90], inf),
	\dur, Prand([1/8],inf)
);
)

~uno.set(\wet10, 0.5);
~uno[10] = \filter -> { |in| JPverb.ar(in, t60: 1) }

~uno[10] = nil;

~uno.set(\wet11, 0.5);
~uno[11] = \filter -> { |in| Resonz.ar(in, SinOsc.kr(1/8).range(300, 2800), 0.3) }

~uno.set(\wet20, 0.75);
~uno[20] = \filter -> { |in| RLPF.ar(in, SinOsc.kr(1/32).range(440, 4000), LFTri.kr(1/4).range(0.1, 1.0)) };

~uno.clear(5);