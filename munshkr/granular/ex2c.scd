// This example needs SynthDef \gran_2b and Function d to be taken from Ex. 2b

(
b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// This searches the most likely extension places for the miSCellaneous folder.
// In case of an extraordinary install situation or a removed sound file, pass the concerned path.

w = Buffer.sendCollection(s, Signal.hanningWindow(1024));
)

// A simple form of Pspawner is used to generate phrases.
// Phrase length params are taken a bit roughly as sustain and
// rest times also depend on randomly varying grain lengths.
// spSustain controls medium sustain time (without grain length overhead)
// spLegato controls medium legato factor (disregarding reduction by grain length overhead)
// spDev is causing separate random deviation of spSustain and spLegato
// between 1/(1+spDev) and 1+spDev

// random distribution switching is restricted here to
// types 6 and 7 (random walks of first and second order)
// to force individual sound qualities of phrases.

(
// declare var here as pattern is repeatedly evaluated from within the Pspawner,
// interpreter variable would be unsafe if running examples in parallel

var p = Pbind(
    \instrument, \gran_2b,
    \sndBuf, b,
    \windowBuf, w,

    \dur, 1 / PLswitch1(d.(\trigRateLo, \trigRateHi), \trigRateD),
    \granDur, PLswitch1(d.(\granDurLo, \granDurHi), \granDurD),
    \time, Ptime(),
    \posRate, PL(\posRate),

    // random timeOffset added with each spawning
    \pos, Pfunc { |e|
        var relTime = ~posRate * e.time / e.sndBuf.duration + e.timeOffset, relDif;
        relDif = ~posHi - ~posLo;
        relTime + rand2(~posDev) % relDif + ~posLo;
    },
    \rate, PLswitch1(d.(\rateLo, \rateHi), \rateD),
    \bpFreq, PLswitch1(d.(\bpFreqLo, \bpFreqHi), \bpFreqD),
    \bpRQ, PL(\bpRQ),
    \bpWet, PL(\bpWet),

    \amp, PL(\amp),
    \panMax, PLseq([-1,1]) * PL(\panMax),
    \out, 0
);

q = Pspawner({ |sp|
    var randomizer = { |x| var y = rand(x); 0.5.coin.if { 1 + y }{ 1 / (1 + y) } },
        sus, legato, delta;

    loop {
        sus = ~spSustain * randomizer.(~spDev);
        legato = ~spLegato * randomizer.(~spDev);

        // take random offset for each phrase
        sp.par(Pfindur(sus, Psetpre(\timeOffset, 5.0.rand, p)));
        delta = sus / (~spLegato * randomizer.(~spDev));
        sp.wait(delta)
    }
});

VarGui([
    \posLo, [0.0, 0.99, \lin, 0.01, 0.16],
    \posHi, [0.0, 0.99, \lin, 0.01, 0.41],
    \posRate, [0.1, 2, \lin, 0.01, 1.4],
    \posDev, [0, 0.2, 5, 0, 0.0017],

    \trigRateLo, [1, 200, \lin, 0.01, 70],
    \trigRateHi, [1, 200, \lin, 0.01, 150],
    \trigRateD, [6, 7, \lin, 1, 7],

    \granDurLo, [0.01, 0.6, \exp, 0.0, 0.02],
    \granDurHi, [0.01, 0.6, \exp, 0.0, 0.11],
    \granDurD, [6, 7, \lin, 1, 6],

    \rateLo, [0.1, 3, \lin, 0.01, 0.2],
    \rateHi, [0.1, 3, \lin, 0.01, 1.86],
    \rateD, [6, 7, \lin, 1, 7],

    \bpFreqLo, [50, 10000, \exp, 0.1, 67],
    \bpFreqHi, [50, 10000, \exp, 0.1, 5885],
    \bpFreqD, [6, 7, \lin, 1, 6],
    \bpRQ, [0.01, 0.99, \lin, 0.0, 0.17],
    \bpWet, [0.0, 1, \linear, 0.0, 0.38],

    \spSustain, [0.2, 2, \linear, 0.0, 0.884],
    \spLegato, [0.6, 1.2, \linear, 0.0, 0.996],
    \spDev, [0.0, 1, \linear, 0.0, 0.41],

    \panMax, [0.0, 1, \lin, 0.0, 0.85],
    \amp, [0.0, 1, \lin, 0.01, 0.35]
    ], stream: q
).gui(varColorGroups: (0..22).clumps([4,3,3,3,5,3,1,1]) )
)