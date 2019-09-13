p = ProxySpace.push(s);

~in = { SoundIn.ar(0)!2 }

// put up a low pass filter
~rlpf = { RLPF.ar(~in, MouseX.kr(0,1).exprange(300,20000), 0.05) }
~rlpf.play

// parameterize frequency and resonance
~freq = { 200 }
~res = { 0.5 }
~rlpf = { RLPF.ar(~in, ~freq, ~res) }

// model freq and res with a pattern :)
(
~freq = \setsrc -> Pbind(\source,
 Pseq([300, 200, 600, 500, 10000], inf),
 \dur, Prand([1/4, 1/8, 1/8],inf)
);
)

(
~res = \setsrc -> Pbind(\source,
 Pseq([0.05, 0.1, 0.4, 1], inf),
 \dur, Pseq([1/3, 1/6, 1/8], inf)
);
)

{ SinOsc.ar(440) * 0.1 }.play