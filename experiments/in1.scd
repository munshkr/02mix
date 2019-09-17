// para investigar:
// 1. como conectar In a efectos (usando Ndef primero, luego con ProxySpace)
// 2. probar efectos de SuperDirt (FFT, etc.)
// 3. como usar Pbind con Ndef para parametrizar efectos

// default parameters for all ndefs:
Ndef(\x).proxyspace.quant = 1;
Ndef(\x).proxyspace.fadeTime = 1;

// test 1 2 3
Ndef(\a, { SinOsc.ar(440).dup * 0.1 });
Ndef(\a).play;

Ndef(\a, Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350)));
Ndef(\a).clear(3);

Ndef(\lfo2).fadeTime = 2;
Ndef(\lfo2, { LFNoise1.kr(LFNoise1.kr(0.1).exprange(1, 300) ! 2, 400, 800) });
Ndef(\lfo2, { SinOsc.kr(10).exprange(1,100).dup })

Ndef(\sound, { Blip.ar(Ndef.kr(\lfo2), 2) * 0.2 }).play;

Ndef(\lfo3, { LFNoise1.kr(3).exprange(1,2000) });

Ndef(\sound, { Blip.ar(Ndef.kr(\lfo2), Ndef.kr(\lfo3)) * 0.2 }).play;

//
// using ndef
//
(
Ndef(\in).clear;
Ndef(\in, { SoundIn.ar(0).dup });
// do not play Ndef(\in)
)

(
Ndef(\rlpf, { RLPF.ar(Ndef(\in), LFNoise2.kr(1).exprange(100, 10000), 0.1) });
Ndef(\rlpf).play;
)

Ndef.clear(3);

//
// using proxyspace
//
p = ProxySpace.push(s);
p.fadeTime = 2; // crossfade

// setup input
(
~in.clear;
~in = { SoundIn.ar(0).dup };
)
~in.play;

~in.stop;

(
~rlpf = { RLPF.ar(~in, LFNoise2.kr(1).exprange(100, 10000), 0.1) };
~rlpf.play;
)

~sq = { Squiz.ar(~rlpf, 1) }
~sq.play;

~rlpf.stop

~sq.play; ~rlpf.stop;
~sq.stop

~freeze = { IFFT(PV_Freeze(Array.fill(~sq.size, { |i| FFT(LocalBuf(256), ~sq[i])}), SinOsc.kr(4).range(0,1) > 0.5)) }

p.clear(2);

//
// with proxyspaces and node proxy roles (filters):
//
(
~in.clear;
~in[0] = { SoundIn.ar(0).dup };
)

~in.play;

~in[1] = \filter -> { |in| RLPF.ar(in, LFNoise2.kr(1).exprange(100, 10000), 0.1) };

~in.set(\wet1, 1);

~lfn1 = { LFNoise2.kr(0.5).exprange(1, 20) };
~in[1] = \filter -> { |in| RLPF.ar(in, LFNoise2.kr(10).exprange(400, 10000), 0.1) };
~in[1] = nil

// ~in[2] = \filter -> { |in| WaveLoss.ar(in, SinOsc.kr(0.25).exprange(1, 80), outof: 100, mode: 2) };
~in[2] = nil
~in[2] = \filter -> { |in| Squiz.ar(in, 1) };
~in[3] = \filter -> { |in| FreqShift.ar(in, SinOsc.kr(LFNoise2.kr(1).range(0.5,2)).exprange(200,400) * 3 + 400, 0.5) };
~in.set(\wet3, 0.025);

~in[3] = nil

~in[4] = \filter -> { |in| IFFT(PV_Freeze(Array.fill(in.size, { |i| FFT(LocalBuf(256), in[i])}), SinOsc.kr(4).range(0,1) > 0.5)) };
~in.set(\wet4, 1);
~in[4] = nil

~teeth = { 256 };
~comb = { 1 };
~in[5] = \filter -> { |in| IFFT(PV_RectComb(Array.fill(in.size, { |i| FFT(LocalBuf(2048), in[i])}), numTeeth: ~teeth * ~comb, width: 1 - ~comb)) };
~in.set(\wet5, 0.25);

~in[10] = \filter -> { |in| CombL.ar(in, 0.5, 0.5, 3) }
~in[10] = nil

p.clear(2);

//
// use synthdefs as node proxy sources
//

(
f = { |key=\default| SynthDescLib.global.at(key).def.func };
)

// todo...