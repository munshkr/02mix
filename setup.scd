//
// Audio setup
//

(
// for OSX:
//s.options.device = "UMC404HD 192k";
s.options.memSize_(65536 * 4);
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 4;

s.waitForBoot {
	s.scope;
	// FreqScope.new;

	NdefMixer(s);

	// function for referencing synthdefs with nodeproxies
	// f = { |key=\default| SynthDescLib.global.at(key).def.func };
};
)

Ndef(\test, { PinkNoise.ar });
Ndef(\test).clear;

// set up nodeproxies
(
// mix Jack input into a single channel
~makeJack = { |id="", amp=0.5|
	var key = ("jack" ++ id).asSymbol;

	Ndef(key).clear;
	Ndef(key)[0] = { Pan2.ar(SoundIn.ar(0)) };
	Ndef(key)[100] = \filter -> { |in| Limiter.ar(in) };
	Ndef(key);
};
~jack = ~makeJack.().play(vol: 0.3);

// stereo input
~iris = Ndef(\iris);
~iris.clear;
~iris[0] = { SoundIn.ar([2,3]) };
~iris[100] = \filter -> { |in| Limiter.ar(in) };
~iris.play(vol: 1);
)

//
// Global ambisonics setup
//

(
// (use this if on earphones)
d = FoaDecoderKernel.newUHJ(kernelSize: 256);
// pantophonic decoder
//d = FoaDecoderMatrix.newPanto(numChans: 4, orientation: 'flat', k: 'single');

//~foa.reshaping = \elastic;
Ndef(\angle, { 0 });
Ndef(\azim, { 0 });
Ndef(\distance, { 0.5 });

f = { |in|
	var foa, encoder, angle, azim;
	// angle ---> top        = push to plane wave
	//            bottom     = omni-directional
	angle = Lag.kr(Ndef(\angle), 0.1);
	// azimuth -> hard left  = back
	//            centre     = centre
	//            hard right = back
	azim = Lag.kr(Ndef(\azim), 0.1);
	encoder = FoaEncoderMatrix.newOmni;
	// Encode into our foa signal
	foa = FoaEncode.ar(in, encoder);
	// Push transform
	foa = FoaTransform.ar(foa, \push, angle, azim);
	// Proximity effect
	foa = HPF.ar(foa, 10);
	foa = FoaTransform.ar(foa, 'proximity', Ndef(\distance));
	// Decode
	foa = FoaDecode.ar(foa, d);
	//foa = LeakDC.ar(foa);
	foa;
};
)

// test ambisonics on jack input

(
~jack[90] = \filter -> f;
Ndef(\angle, { SinOsc.kr(1).range(pi/2, 0) });
Ndef(\azim, { SinOsc.kr(1/8).range(pi, -pi) });
)

// another example
(
Ndef(\angle, { SinOsc.kr(LFTri.kr(1/8).range(0.125, 4)).range(pi/2, 0) });
Ndef(\azim, { SinOsc.kr(1/8).range(pi/2, -pi/2) });
)

~jack[90] = nil;