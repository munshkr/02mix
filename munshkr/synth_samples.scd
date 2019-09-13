// fragment: 2018-10-02
(
play {
    n = 8;
    e = Env.perc(0.001, 0.1).ar(0, Impulse.ar(1));
    x = n.collect {|i|
        o = e * Pulse.ar(222*4*e, e*(i+1/n/2));
        DelayC.ar(o, 1, round(i/n ** SinOsc.ar(1/30, 0.5pi).range(0.25,1), 0.125));
    };
    x = x + Klank.ar(`[111*(1..n)*[1,1,9/8], 1/n!n, 0.3!n], x*0.2 + WhiteNoise.ar(0.02!n));
    Limiter.ar(4*Splay.ar(x.sin))
}
)


// fragment: 2018-09-16
(
play {
    o = SinOsc;
    d = Decay;
    x = (0..2).collect {|i|
        TDuty.ar(1/8, 0, Dseq(scramble([1, 1] ++ (0!(9+i))), inf))
    };

    k = d.ar(x[0], 2);
    m = d.ar(x[1]);

    Limiter.ar(
        9 * [
			// o.ar(80*k).tanh * k,
			// o.ar(2*80*m).sin * m,
			GVerb.ar(o.ar(440) * d.ar(Impulse.ar(1/8)),99,10),
			// (BPF.ar(WhiteNoise.ar(2))).sin * d.ar(x[2],0.5)
        ].sum.sin
    )
}
)


// fragment: 2018-09-10
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


// fragment: 2018-09-07
(
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");
play {
    t = Impulse.ar([10, 10.1]);
    o = PlayBuf.ar(
        1,
        b,
        BufRateScale.kr(b),
        t,
        Sweep.ar(0, Rand(1,999)),
        1
    ) * Decay.ar(t, SinOsc.ar(1/[7, 7.1]).range(0.1, 1));
    o = o + GVerb.ar(o.mean * 0.5, 99, 10);
    Limiter.ar(HPF.ar(o.tanh, 30));
}
)


// fragment: 2018-09-06
(
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");
play {
    g = Warp1.ar(1, b, LFSaw.ar(1/5).range(0, 1), LFDNoise0.ar(1/3).range(0.25, 1).round(0.25)).softclip;
    RecordBuf.ar(tanh(HPF.ar(DelayN.ar(g, 0.25, 0.25), 30)), b);
    Limiter.ar(HPF.ar(GVerb.ar(g, 99, 10), 30)).sanitize
}
)