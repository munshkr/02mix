// Part 2
~jack.stop;

(
~pfq = {1/8};
~pwm = {2};
~amp = {0.25};
)

~jackfx.play;
~jackfx[10] = \filter -> { |in| in * 0.7 * Pulse.ar(~pfq, SinOsc.kr(~pwm).range(0.01, 0.99)) };

(
~pwm = { SinOsc.kr(1/32).range(0.125, 0.875) };
~pfq = { 7 };
)

~leftAmp = { SinOsc.kr(0.0125).range(0, 1)}
~rightAmp = { SinOsc.kr(0.125, 0.5).range(0, 1)}
~jackfx[20] = \filter -> { |in| var sig = Mix(in); [sig * ~leftAmp, sig * ~rightAmp] };

(
~pfq = \setsrc -> Pbind(
	\source, Pseq([2, 20, 0.5, 0.7, 40, 7, 4, 90], inf),
	\dur, Prand([1/8],inf)
);
)

~jackfx.set(\wet10, 0.5);
~jackfx[11] = \filter -> { |in| JPverb.ar(in, t60: 0.25) }

~jackfx[11] = nil;

~jackfx[11] = \filter -> { |in| Resonz.ar(in, SinOsc.kr(1/8).range(300, 2800), 0.9) }
~jackfx.set(\wet11, 0.7)

~jackfx[12] = \filter -> { |in| Ringz.ar(in, 70.midicps, 0.1) }
~jackfx.set(\wet12, 0.1)

~jackfx.set(\wet12, 0.75);
~jackfx[12] = \filter -> { |in| RLPF.ar(in, SinOsc.kr(1/32).range(440, 4000), LFTri.kr(1/4).range(0.1, 1.0)) };

////

~j2[0] = { Pan2.ar(Mix(SoundIn.ar([0,1]))) };
~j2[100] = \filter -> { |in| Limiter.ar(in) };

~j2[10] = \filter -> { |in| Resonz.ar(in, MouseX.kr(1000, 4000), MouseY.kr(0.01, 0.9)) }

~j2.set(\wet11, 0.01);
~j2[11] = \filter -> { |in| DynKlank.ar(`[[880, 440, 110, Array.rand(12, 800.0, 2000.0)], nil, [1, 1, 1, 1]], in) }

~j2[20] = \filter -> { |in| 0.3 * Limiter.ar((RLPF.ar(in, SinOsc.kr(1/8).range(200, 2200), 0.8)).tanh) }
~j2[30] = \filter -> { |in| JPverb.ar(in, damp: 0, t60: 5, lowcut: 400, highcut: 3000) }

