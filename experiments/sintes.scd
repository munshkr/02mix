
// todo: pasarlo a proxyspace
(
play {
    x = {|i|
		r = [ 3, 5, 8, 9 ] / 8;
		// r = [1,2,3,4,5]/8;
        d = rrand(0.25*i, 3*i).round(0.25);
        f = i % 3 + 1 * 440 * r.wrapAt(i);

        Env.sine(12).ar(0, TDelay.ar(Impulse.ar(1/12), d))
		* Resonz.ar(WhiteNoise.ar(0.5), f, 0.01);
    } ! 8;

    HPF.ar(Limiter.ar(55 * GVerb.ar(Splay.ar(x), 99, 10).flop.sum), 30).sanitize;
}
)

// todo: usar pbind para disparar sonidos
(
~s = {
	Limiter.ar(
		8 * [
			GVerb.ar(SinOsc.ar(999) * Decay.ar(Impulse.ar(1/8)), 99, 10),
		].sum.sin
	)
};
~s.play;
)