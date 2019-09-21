~iris.set(\wet30, 0);
~iris[30] = \filter -> { |in| (in * 0.5) + (in * 0.5 * SinOsc.kr(SinOsc.kr(1/16).range(1, 8)).range(0,1)) };
~iris.set(\wet30, 0.25);

~iris.set(\wet40, 0);
~iris[40] = \filter -> { |in| RLPF.ar(in, SinOsc.kr(1/16).range(600, 30000), 0.5) };
~iris.set(\wet40, 0.5);

~iris.set(\wet60, 0);
~iris[60] = \filter -> { |in| JPverb.ar(in, t60: 3) };
~iris.set(\wet60, 0.3);

//~iris[99] = \filter -> f;
//~iris[99] = nil;
