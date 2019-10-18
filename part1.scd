~j1 = ~makeJack.(1).play(vol: 0.4).stop;

~j1.set(\wet10, 0.5);
(
~j1[10] = \filter -> { |in|
	DelayN.ar(in, 10, [1/3, 1/2, 2, 3])
};
// ~j1[10] = nil;
)

~j1.set(\wet12, 0.5);
(
~j1[12] = \filter -> { |in|
	IFFT(
		PV_BinScramble(
			Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i]) }),
			SinOsc.kr(1/16),
			0.1,
			SinOsc.kr(1/4) > 0.75
		)
	)
};
)
~j1[12] = nil;

~j1.set(\wet13, 0.125);
(
~j1[13] = \filter -> { |in|
	IFFT(
		PV_MagSmear(
			Array.fill(in.size, { |i| FFT(LocalBuf(512), in[i])}),
			SinOsc.kr(1/16).range(0, 10)
		)
	)
};
)
// ~j1[13] = nil;

(
~j1[90] = \filter -> f;
Ndef(\angle, {
	SinOsc.kr(
		LFTri.kr(1/8).range(0.125, 4)
	).range(pi/2, 0)
});
Ndef(\azim, { SinOsc.kr(1/8).range(pi, -pi) });
)
// ~j1[90] = nil

~j1.set(\wet20, 1.0);
//~j1[20] = \filter -> { |in| JPverb.ar(in, t60: LFSaw.kr(1/16).range(0.25, 6)) };
~j1[20] = \filter -> { |in| JPverb.ar(in, t60: 0.5) };
~j1[20] = nil

~j1.set(\wet30, 1.0);
~j1[30] = \filter -> { |in| (in * 0.5) + (in * 0.5 * SinOsc.kr(SinOsc.kr(1/32)*2).range(0,1)) };
~j1[30] = nil

~j1.set(\wet40, 1.0);
(
~j1[40] = \filter -> { |in|
	IFFT(
		PV_MagFreeze(
			Array.fill(in.size, { |i| FFT(LocalBuf(4096), in[i])}),
			SinOsc.kr(1/2) > 0.5
		)
	)
};
)
~j1[40] = nil;

(
~j1[50] = \filter -> { |in|
	DelayN.ar(in, 10, [1/2, 1/3])
};
)
~j1[50] = nil

//Ndef(\j1x, { SinOsc.kr(1).range(-1, 1) });
//~j1.set(\x, Ndef(\j1x));

~j1.play;

~j1.stop(5);
