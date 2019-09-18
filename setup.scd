//
// Audio setup
//

(
// for OSX:
//s.options.device = "UMC404HD 192k";
s.options.memSize_(65536 * 4);
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 4;
s.boot;
s.scope;

// function for referencing synthdefs with nodeproxies
// f = { |key=\default| SynthDescLib.global.at(key).def.func };
)

p = ProxySpace.push(s);

// mix Jack input into a single channel
~jack[0] = { Pan2.ar(Mix(SoundIn.ar([0,1]))) * 0.3 };
~jack.play;
~jack.stop;

~jackfx[0] = { Pan2.ar(Mix(SoundIn.ar([0,1]))) };
~jackfx.play;
~jackfx.stop;

// stereo input
~iris[0] = { SoundIn.ar([2,3]) };
~iris.play;
~iris.stop;

~irisfx[0] = { SoundIn.ar([2,3]) };
~irisfx.play;
~irisfx.stop;

//
// Ambisonics setup
//

(
// (use this if on earphones)
d = FoaDecoderKernel.newUHJ;
// pantophonic decoder
//d = FoaDecoderMatrix.newPanto(numChans: 4, orientation: 'flat', k: 'single')

//~foa.reshaping = \elastic;
~angle = { 0 };
~azim = { 0 };
~distance = { 0.5 };

f = { |in|
	var foa, encoder, angle, azim;
	// angle ---> top        = push to plane wave
	//            bottom     = omni-directional
	angle = Lag.kr(~angle, 0.1);
	// azimuth -> hard left  = back
	//            centre     = centre
	//            hard right = back
	azim = Lag.kr(~azim, 0.1);
	encoder = FoaEncoderMatrix.newOmni;
	// Encode into our foa signal
	foa = FoaEncode.ar(in, encoder);
	// Push transform
	foa = FoaTransform.ar(foa, 'push', angle, azim);
	// Proximity effect
	foa = HPF.ar(foa, 10);
	foa = FoaTransform.ar(foa, 'proximity', ~distance);
	// Decode
	foa = FoaDecode.ar(foa, d);
	//foa = LeakDC.ar(foa);
	foa;
};
)

// test ambisonics on jack input
(
~jackfx[99] = \filter -> f;
~angle = { SinOsc.kr(1).range(pi/2, 0) };
~azim = { SinOsc.kr(1/8).range(pi, -pi) };
)

// another example
(
~jackfx[99] = \filter -> f;
~angle = { SinOsc.kr(LFTri.kr(1/8).range(0.125, 4)).range(pi/2, 0) };
~azim = { SinOsc.kr(1/8).range(pi, -pi) };
)
