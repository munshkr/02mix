// Part 1
~jack.play;

~jack.stop;

(
~j1.clear;
~j1.fadeTime = 2;
~j1[0] = { Pan2.ar(Mix(SoundIn.ar([0,1]))) };
)

(
~j1.set(\wet10, 0.5);
~j1[10] = \filter -> { |in| DelayN.ar(in, 10, [1/3, 1/2, 2, 3]) };
~j1.play;
)

~j1[10] = nil;

~j1[12] = \filter -> { |in| IFFT(PV_BinScramble(Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i])}), SinOsc.kr(1/16), 0.1, SinOsc.kr(1/4) > 0.5 )) }
~j1.set(\wet12, 0.5);
~j1[12] = nil

~j1[13] = \filter -> { |in| IFFT(PV_MagSmear(Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i])}), SinOsc.kr(1/16).range(0, 10))) }
~j1.set(\wet13, 0.25);
~j1[13] = nil

~j1[99] = \filter -> f
~angle = { SinOsc.kr(LFTri.kr(1/8).range(0.125, 4)).range(pi/2, 0) };
~azim = { SinOsc.kr(1/8).range(pi, -pi) };
~j1[99] = nil

~j1[20] = \filter -> { |in| JPverb.ar(in, t60: 5) }
~j1[20] = nil
~j1[30] = \filter -> { |in| (in * 0.5) + (in * 0.5 * SinOsc.kr(SinOsc.kr(1/32)*8).range(0,1)) }
~j1[30] = nil

~j1[40] = \filter -> { |in| IFFT(PV_MagFreeze(Array.fill(in.size, { |i| FFT(LocalBuf(4096), in[i])}), SinOsc.kr(1/4) > 0.75)) };
// ~j1.set(\wet40, 1);

~j1g = { MouseX.kr(0,1) > 0.5 };
~j1[60] = \filter -> { |in| in * EnvGen.ar(Env.adsr(2, release: 16), ~j1g) };

~j1.clear(5);
