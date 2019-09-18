// Part 1
~jack.play;
~jack.stop

~jackfx.clear;
~jackfx[0] = { Pan2.ar(Mix(SoundIn.ar([0,1]))) };

~jackfx.set(\wet10, 0.5);
~jackfx[10] = \filter -> { |in| DelayN.ar(in, 30, 1/3) };
~jackfx.play;

~jackfx[10] = nil;

~jackfx[12] = \filter -> { |in| IFFT(PV_BinScramble(Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i])}), SinOsc.kr(1/16), 0.1, SinOsc.kr(1/4) > 0.5 )) }
~jacfx[12] = nil

~jackfx[13] = \filter -> { |in| IFFT(PV_MagSmear(Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i])}), SinOsc.kr(1/16).range(0, 10))) }
~jackfx[13] = nil

~jackfx[99] = \filter -> f
~angle = { SinOsc.kr(LFTri.kr(1/8).range(0.125, 4)).range(pi/2, 0) };
~azim = { SinOsc.kr(1/8).range(pi, -pi) };

~jackfx[20] = \filter -> { |in| JPverb.ar(in, t60: 3) }
~jackfx[20] = nil
~jackfx[30] = \filter -> { |in| (in * 0.5) + (in * 0.5 * SinOsc.kr(SinOsc.kr(1/16)*8).range(0,1)) }
~jackfx[30] = nil

~jackfx[40] = \filter -> { |in| IFFT(PV_MagFreeze(Array.fill(in.size, { |i| FFT(LocalBuf(4096), in[i])}), SinOsc.kr(1/4) > 0.75)) };
// ~jackfx.set(\wet40, 1);

// ~jackfx[40] = \filter -> { |in| in * EnvGen.kr(Env.adsr(releaseTime: 3), Onsets.kr(Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i], wintype: 1)}), 0.02)) };
// ~jackfx[40] = nil;
