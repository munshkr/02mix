/*
 clicks and ambience. click clack tooot.....
   partly loud clicks...

 i tried to practice granular synthesis but failed in the end to make
 real nice randomized modulation envelopes.

 flo.huth

*/

s.boot;

(
~r=Routine{
	1.do{

		~hall = Bus.audio(s,2);
		~main = Bus.audio(s,2);


		~a = Routine{ var n,i,a,b;

			n= 3;

			~arrays = Array.new(n);

			i = 0;

			n.do{

				i=i+1;

				a = Buffer.alloc(s,512);
				b = Array.fill(i,{1/i});


				a.sine1(b);

				~arrays.add(a);

			}
		}.play;

		0.5.wait;

		SynthDef(\mainOut,
			{
				arg gate,amp,ffreq=24000,q=0,dist=1;

				var in,mix,out;

				in = In.ar(~main,2);

				mix = in*amp;


				mix = CompanderD.ar(mix,0.92,0.9,1,0.1,0.1);

				mix = Limiter.ar(mix,1);

				OffsetOut.ar(0,mix);
				//OffsetOut.ar(3,mix);
			}
		).add;

		SynthDef(\hall,
			{
				arg t_gate=1,amp,size,t60,att,dec;

				var in,efx,mix,env;

				in = In.ar(~hall)*amp;

				//efx = FreeVerb1.ar(in,size);
				efx = JPverb.ar(in,t60,0,size);

				//env = EnvGen.kr(Env.asr(att,1,dec),gate:t_gate,doneAction:0);

				efx = efx;

				Out.ar(~main,efx);

			}
		).add;

		SynthDef(\fmGrain,
			{
				arg gate=1,trigger,dense,offset,freq,modFreq,size,wave,mul,index=1,
				gAtt=0.001,gDec=0.4,


				bPoints = #[0,1,1,1,1,1,1,1,1,1,1,0],
				bTimes = #[1,1,1,1,1,1,1,1,1,1,0],

				mPoints1 = #[1,1,1,1,1], mTimes1 = #[1,1,1,1],

				mPoints2 = #[1,1,1,1,1], mTimes2 = #[1,1,1,1];


				var rand1,rand2,imp, osc, win, env, mix;

				rand1 = EnvGen.kr(Env.new(mPoints1,mTimes1,\exp),gate:gate);

				rand2 = EnvGen.kr(Env.new(mPoints2,mTimes2,\exp),gate:gate);

				imp = Select.ar(K2A.ar(trigger),
					[
						Impulse.ar(dense*rand1,[0,offset]),
						Dust.ar(dense*rand1)
				]);

				win = EnvGen.ar(Env.new([0,1,0],[((dense.reciprocal/size)*rand1)*gAtt,
					((dense.reciprocal/size)*rand1)*gDec]),gate:imp);

				osc = Osc.ar(wave,modFreq);

				osc = Osc.ar(wave,freq,(osc*index*rand2));

				//osc = Mix.ar(osc);

				//osc = BPF.ar(osc,TRand.ar(60,12000,imp),LFNoise2.kr(1).linlin(-1,1,0.5,1));

				osc = Pan2.ar(osc,LFNoise2.kr(TRand.kr(0,4.0,gate)));

				env = EnvGen.ar(Env.new(bPoints,bTimes),gate:gate,doneAction:2);

				mix = (osc*win)*env;

				mix = HPF.ar(mix,90);


				OffsetOut.ar(~main,mix.scope);
				OffsetOut.ar(~hall,mix*0.2);
			}
		).add;

		0.5.wait;


		~c = Group.new;

		Synth(\mainOut,[\gate,1,\amp,0.2],~c,\addToTail);


		~verbos=Pmono(\hall,
			\gate,1,
			\amp,Pexprand(0.1,0.7,inf),
			\size,Pwhite(0.1,0.9,inf),
			\t60,Pexprand(0.1,12,inf),

			\dur,Pwhite(0.1,7.0,inf),

			\att,Pkey(\dur)/2,
			\dec,Pkey(\dur)/2,

			\group,~c,
			//\addAction,1
		).play;

		~tones=Routine{
			inf.do{

				var freq = ([0,2,3,7,9,10,12,15,19].choose+22).midicps;
				var dense =exprand(12,120);

				Synth(\fmGrain,
					[
						\trigger,2.rand,

						\gate,1,
						\freq,freq,

						\modFreq,freq*rrand(1,4)+rrand(-0.1,0.1),
						\index,1.0.rand,

						\dense,dense,
						\size,rrand(2,8.0),
						\offset,0.5,

						\gAtt,rrand(0.1,1),
						\gDec,1,

						\wave,~arrays[3.rand],
						\mul,exprand(0.2,1.0),


						//global Env
						\bPoints,Array.fill(9,{|a| a=a+rrand(-0.2,0.2); a.sin})++0,
						\bTimes,Array.exprand(10,3.01,1.0),

						//dense env
						\mPoints1, Array.exprand(5,0.01,16.0), //no zeroes
						\mTimes1, Array.exprand(4,0.01,6.0),        //no zeroes

						//index env
						\mPoints2, Array.exprand(4,0.01,6.0)++0, //no zeroes
						\mTimes2, Array.exprand(4,0.01,6.0),        //no zeroes

					],~c,\addToHead
				);

				8.wait;
			}
		}.play;
	}
};

AppClock.play(~r);
)


//kill the mess

[~verbos,~tones].stop;s.freeAll;

~arrays[0].plot