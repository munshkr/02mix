/*********************
Ambisonics
*********************/

(
s.options.device = "UMC404HD 192k";
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 4;
s.boot;
)

p = ProxySpace.push(s);

(
d = FoaDecoderKernel.newUHJ;
// d = FoaDecoderMatrix.newQuad;

~foa.reshaping = \elastic;
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

s.scope

~s = nil

// ~s[0] = { PinkNoise.ar(-6.dbamp) };
~s[0] = { Dust.ar(10, 0.4) };
~s[10] = \filter -> { |in| CombN.ar(Decay.ar(in, 0.15, WhiteNoise.ar), 0.2, 0.2, 3) }
~s.play(numChannels: 4)

~s[100] = \filter -> f;

~s = nil

~s.numChannels

~angle = {MouseY.kr(pi/2, 0)}
~azim = {MouseX.kr(pi, -pi)};
// ~angle <>>.angle ~foa <<>.azim ~azim

~distance = {0.04};

~foa.play
~foa.stop



NodeProxy