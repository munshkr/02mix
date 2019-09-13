p = ProxySpace.push(s);

~in = { SoundIn.ar(0)!2 }

(
~in.clear;
~in[0] = { SoundIn.ar(0).dup };
)

~in.play;

~in[1] = \filter -> { |in| RLPF.ar(in, LFNoise2.kr(1).exprange(100, 10000), 0.1) };

~in.set(\wet1, 1);

// para probar:
// 1. resonz
// 2. klank
// 3. limiter
// 4. grainbuf


// 4. grainbuf

p = ProxySpace.push;


// figure 16.14 - GrainBuf and control proxies

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");
(
~grain.set(\wavebuf, b.bufnum);
~trig = { |dens=10| Impulse.kr(dens) };
~graindur = 0.1;
~filepos = {LFNoise2.kr(0.2).range(0, 1) };
~rate = { LFNoise1.kr.range(0.5, 1.5) };

~grain = { arg envbuf = -1, wavebuf = 0;
	GrainBuf.ar(2, ~trig.kr, ~graindur.kr, wavebuf,
	~rate.kr, ~filepos.kr, 2, WhiteNoise.kr, envbuf) * 0.2
};
~grain.play;
)

	// experiment with control proxies
~trig = { |dens=20| Impulse.kr(dens) };
~rate = { LFNoise1.kr.range(0.99, 1.01) };
~filepos = { MouseX.kr + LFNoise0.kr(100, 0.03) };
~graindur = 0.07;
~trig = { |dens=10| Dust.kr(dens) };

c = Buffer.sendCollection(s, Env.perc(0.01, 0.99).discretize, 1);
~grain.set(\envbuf, c.bufnum);
~grain.set(\envbuf, -1);

~trig = { |dens=50| Impulse.kr(dens) }; ~graindur = 0.05;


// ahora probamos esto mismo con el sampler