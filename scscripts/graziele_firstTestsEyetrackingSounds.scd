//s.boot;
s.waitForBoot{
	(
		q = q ? ();

		q.myMode = nil;


		//organize all samples first:

		q.mySamples = ();

		//samples mode #0
		q.mySamples.add(\VoiceIntro -> Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/VoiceIntro.wav"));


		q.mySamples.add(\VoiceGoodbye -> Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/VoiceGoodbye.wav"));



		//samples mode #2
		q.mySamples.add(\birds -> Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/bird.wav"));


		//sample constant background sound
		q.mySamples.add(\BackgroundSound -> Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/BackgroundSound.wav"));

		/*
		put more here in this style:
		q.mySamples.add(\anothersound -> Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/anothersound.wav"));
		*/


		//q.mySamples[\VoiceGoodbye].play



		//SOUND MODE #0&#4: play Buffers welcome and farewell
		SynthDef("tutorial-PlayBuf",{arg out = 0, bufnum;
			Out.ar( out,
				PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2)
			)
		}).add;



		SynthDef("backgroundLoop",{arg out = 0, bufnum;
			Out.ar( out,
				PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop:1)
			)
		}).add;

		{ Synth("backgroundLoop", [\bufnum, q.mySamples[\BackgroundSound].bufnum ]);}.defer(8);

		/*
		start playing a sample once and wait for mode switch

		#1
		Synth("tutorial-PlayBuf", [\bufnum, q.mySamples[\VoiceIntro].bufnum ]);

		#5
		Synth("tutorial-PlayBuf", [\bufnum, q.mySamples[\VoiceGoodbye].bufnum ]);

		*/


		//SOUND MODE #1: Percussion melody
		(
			q.myFreqs = [262, 410, 786, 1245, 1309, 1830, 2071];
			q.myAmps = [-20, -29, -40, -48, -46.7, -54, -55].dbamp;
			Spec.add(\rel, [0.01, 0.6, \lin]);
			Spec.add(\atk, [0.001, 0.2, \lin]);
			Spec.add(\detune, [0.2,4,\exp]);
			Spec.add(\blend, [0,1,\lin]);
			Spec.add(\rate, [0.2, 10, \lin]);
			Spec.add(\deviation, [0, 0.99, \lin]);
		);
		(
			Ndef(\secondSound, {|rel = 0.3, atk = 0.01, amp = 1, detune = 1,
				blend = 0, rate = 1, deviation = 0 |

				var freqs, amps, son, sonEnv, trig, noise, noiseEnv, ramp, fbkIn, fbkOut, randomTrig, highLow;
				freqs = q.myFreqs * detune;
				amps = q.myAmps;

				fbkIn = LocalIn.ar(1, 1);
				ramp =( 1 - (Phasor.ar(0, rate / s.sampleRate * fbkIn, 0, 1, 0) < 0.9));
				trig = ramp;

				highLow = [1 - deviation, 1 + deviation];
				randomTrig = TRand.ar(highLow[0], highLow[1], trig);
				fbkOut = LocalOut.ar(randomTrig);

				noiseEnv = EnvGen.ar(Env.perc(atk * 0.5, atk * 0.5, 1, [-4, 4]), trig);
				sonEnv = EnvGen.ar(Env.perc(atk, rel, 1, -4), trig);

				son = SinOsc.ar(freqs, 0, amps).sum  * sonEnv;
				noise = PinkNoise.ar() * noiseEnv * 0.5;
				(son + noise) * amp ! 2;

			});
			//Ndef(\secondSound).edit
			/*
			Ndef(\secondSound).play; //.resume???
			map values from camera
			wait for mode switch and
			Ndef(\secondSound).stop;
			unmap values from camera

			*/
		);


		//SOUND MODE #2: Downsampling and bitcrushing effect


		Spec.add(\bits, [16, 1]);
		Spec.add(\downsamp, [1, 100, \exp]);
		Spec.add(\blend, [0, 1, \lin]);
       		Spec.add(\mod, [0, 4, \lin]);

		Ndef(\samplePlayerA, {|amp = 1, bufnum = 0,  bits=8, downsamp=50, blend = 0 |

			var son = PlayBuf.ar(2, bufnum, 1, 1, 0,1);
			var bitReduc = son.round(0.5 ** bits);
			var down = Latch.ar(bitReduc, Impulse.ar(SampleRate.ir / downsamp.max(2)));
			var mix = SelectX.ar(blend, [son,down]);
			mix * amp;

		});

		Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\birds].bufnum);
		/*
		Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\anothersound].bufnum);

		*/

		/*
		Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\birds].bufnum);
		Ndef(\samplePlayerA).play; //
		map values from camera
		wait for mode switch and
		Ndef(\samplePlayerA).stop;
		unmap values from camera

		change this from outside later
		Ndef(\samplePlayerA).set(\bits, 8, \downsamp, 4);

		Ndef(\samplePlayerA).edit;
		*/


		//SOUND MODE #3: Tones + vibrato


		SynthDef(\tones, {|amp = 0.1, rel = 2, t_trig = 1, freq = 440, bits = 8, downsamp = 4, mod = 2|


			var son = LFPulse.ar(freq, 0);
			var env = Env.perc(0.0001, rel, 1, -2);
			var volEnv = EnvGen.ar(env, t_trig, doneAction: 2);
			var filt = RLPF.ar(son, freq) ;


			var bitReduc = (filt + HPF.ar(PinkNoise.ar(0.09), 2500)).round(0.5 ** bits);
			var down = Latch.ar(bitReduc, Impulse.ar(SampleRate.ir / downsamp.max(2)));
			//var mix = SelectX.ar(blend, [son,down]);
			var panMod = LFTri.ar(mod, [0, 1]);
			var pan = down* volEnv * panMod;
			Out.ar(0, (pan * amp ));

		}).add;

		Tdef(\playNotesRandomly).set(\mod, 2.5);
		Tdef(\playNotesRandomly).set(\rel, 3);
		Tdef(\playNotesRandomly).set(\bits, 8);
		Tdef(\playNotesRandomly).set(\downsamp, 4);


		Tdef(\playNotesRandomly, {|envir|

			var myMelody = [65,60,68];


			inf.do{|index|
				Synth(\tones,
					[
						\freq, myMelody.choose.midicps,
						\amp, 0.4,
						\bits, envir.bits,
						\downsamp, envir.downsamp,
						\rel,  envir.rel,
						\mod, envir.mod]
				);
				[0.25,0.5,1].choose.wait;

			};


		});

		/* start from outside later
		Tdef(\playNotesRandomly).play;

		*/



		/////////////////////
		//turn off func///
		q.switchAllOffFunc = {
			q.mode1synth.free;
			Ndef(\secondSound).stop;
			Ndef(\samplePlayerA).stop;
			Tdef(\playNotesRandomly).stop;
			q.mode5synth.free;

		};

		q.newModeSwitchFunc = {|ev, mode|

			var onFuncs = [
				{q.mode1synth = Synth("tutorial-PlayBuf", [\bufnum, q.mySamples[\VoiceIntro].bufnum ])},
				{Ndef(\secondSound).play},
				{Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\birds].bufnum).play},
				{Tdef(\playNotesRandomly).play},
				{q.mode5synth = Synth("tutorial-PlayBuf", [\bufnum, q.mySamples[\VoiceGoodbye].bufnum ])}

			];

			q.switchAllOffFunc.value;
			onFuncs[mode].value;

		};

		q.map1Func = {|ev, val0, val1, val2, val3, val4|
			Ndef(\secondSound).set(\detune, \detune.asSpec.map(val1));
			Ndef(\secondSound).set(\rate, \rate.asSpec.map(val2));
			Ndef(\secondSound).set (\deviation, \deviation.asSpec.map(val4));

		};

		q.map2Func = {|ev, val0, val1, val2, val3, val4, val5|
			Ndef(\samplePlayerA).set(\bits, \bits.asSpec.map(val1));
			Ndef(\samplePlayerA).set(\downsamp, \downsamp.asSpec.map(val1));
			Ndef(\samplePlayerA).set(\blend, \blend.asSpec.map(val0));

		};

		q.map3Func = {|ev, val0, val1, val2, val3, val4, val5|

			Tdef(\playNotesRandomly).set(\mod, \mod.asSpec.map(val1));
			Tdef(\playNotesRandomly).set(\rel, \rel.asSpec.map(val0));
			Tdef(\playNotesRandomly).set(\bits, \bits.asSpec.map(val4));
			Tdef(\playNotesRandomly).set(\downsamp, \downsamp.asSpec.map(val2));

		};

	);


	//OSC FUNCTION: Updating Ndef and pushbuttons //


	(
		OSCFunc( { | msg, time, addr, port|

			var diff_eyes, eyes_cosine;
			var mean_left_vel_x, mean_right_vel_x, mean_left_vel_y, mean_right_vel_y;

			diff_eyes  = msg[1].asFloat; //compared means of matrix from movements in left and right
			eyes_cosine =  msg[2].asFloat; //cosine of angle between two eyes movement
			mean_left_vel_x =  msg[3].asFloat; // if -1 to 1 -> (val+1) /2     val.linlin(
			mean_right_vel_x =  msg[4].asFloat;
			mean_left_vel_y =  msg[5].asFloat;
			mean_right_vel_y =  msg[6].asFloat;


			/*
			("Diff_eyes is" + diff_eyes).postln;
			("Eyes_cosine is" + eyes_cosine).postln;
			("Mean_left_vel_x is" + mean_left_vel_x).postln;
			("Mean_right_vel_x is" + mean_right_vel_x).postln;
			("Mean_left_vel_y is" + mean_left_vel_y).postln;
			("Mean_right_vel_y is" + mean_right_vel_y).postln;
			*/

			if(q.myMode == 1){
				//q.map1Func(0.1,1.0,0.1).value;
				q.map1Func(diff_eyes, eyes_cosine, mean_left_vel_x, mean_right_vel_x, mean_left_vel_y, mean_right_vel_y).value;
			};
			if(q.myMode == 2){
				//q.map2Func(0.1,1.0,0.1).value;
				q.map2Func(diff_eyes, eyes_cosine, mean_left_vel_x, mean_right_vel_x, mean_left_vel_y, mean_right_vel_y).value;
			};
			if(q.myMode == 3){
				//q.map3Func(0.1,1.0,0.1).value;

				q.map3Func(diff_eyes, eyes_cosine, mean_left_vel_x, mean_right_vel_x, mean_left_vel_y, mean_right_vel_y).value;
			};



		}, '/tracking');
	);

	(
		OSCFunc( { | msg, time, addr, port|


			var newBut = msg[1].asInteger;

			("Button pressed! change to mode: " ++ newBut).postln;
			q.myMode = newBut;
			q.newModeSwitchFunc(newBut).value; // put 0-4 as modes



		}, '/buttons');
	);


};




