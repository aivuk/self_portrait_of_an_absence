s.boot;
s.quit;

s.waitForBoot{


	/* Push buttons trigger sound modes:
	0: sound mode #1: voices: welcome and farewell
	2: sound mode #2: percussion melody, with breaks according to deviation
	3: sound mode #3: audio files are altered with downsampling and bitcrushing effect
	4: sound mode #4: tones are synthetised and vibrato is applied according to deviation


q = q ? ();

q.myMode = nil;

(
q.myGui = Window.new("PushButtonsStatus", Rect(20, 20, 160, 180) );

q.but0 =
Button(q.myGui, Rect(10, 10, 140, 40))
        .states_([
	            ["mode 0 inactive", Color.white, Color.black],
	            ["mode 0 active", Color.white, Color.red],

        ])
        .action_({ arg butt;

	butt.value.postln;
	if(butt.value == 1){
		q.myMode = 0;
		q.but1.value = 0;
		q.but2.value = 0;
		q.but3.value = 0;
	}{ q.myMode = nil};

	("current mode is: " ++ q.myMode).postln;
        });
q.but1 =

Button(q.myGui, Rect(10, 50, 140, 40))
.states_([
	["mode 1 inactive", Color.white, Color.black],
	["mode 1 active", Color.white, Color.red],

])
.action_({ arg butt;

	butt.value.postln;
	if(butt.value == 1){
		q.myMode = 1;
		q.but0.value = 0;
		q.but2.value = 0;
		q.but3.value = 0;
	}{q.myMode = nil};
	("current mode is: " ++ q.myMode).postln;


});
q.but2 =
Button(q.myGui, Rect(10, 90, 140, 40))
.states_([
	["mode 2 inactive", Color.white, Color.black],
	["mode 2 active", Color.white, Color.red],

])
.action_({ arg butt;
	butt.value.postln;
	if(butt.value == 1){
		q.myMode = 2;
		q.but0.value = 0;
		q.but1.value = 0;
		q.but3.value = 0;
	}{q.myMode = nil};
	("current mode is: " ++ q.myMode).postln;

});
q.but3 =
Button(q.myGui, Rect(10, 130, 140, 40))
.states_([
	["mode 3 inactive", Color.white, Color.black],
	["mode 3 active", Color.white, Color.red],

])
.action_({ arg butt;
	butt.value.postln;
	if(butt.value == 1){
		q.myMode = 3;
		q.but0.value = 0;
		q.but1.value = 0;
		q.but2.value = 0;
	}{q.myMode = nil};
	("current mode is: " ++ q.myMode).postln;

});

q.myGui.front;

//set initial state
q.but0.value = 1;
q.but1.value = 0;
q.but2.value = 0;
q.but3.value = 0;
)



// How would I connect myMode with the pushButtons?

	(OSCFunc( { | msg, time, addr, port |

		var pb0, pb1, p2, p3;

		pb0 = msg[1].asBoolean;
        pb1 = msg[2].asBoolean;
		pb2 = msg[3].asBoolean;
		pb3 = msg[4].asBoolean;

        q.but0.set (pb0);
		q.but1.set (pb1);
		q.but2.set (pb2);
		q.but3.set (pb3);

    }, myMode);
    )

	*/


//SOUND MODE #1: Buffers welcome and farewell


	//Welcome
	b = Buffer.alloc(s, 100, 2);    // allocate 2 channels, and 100 frames
	b.free;                         // free the memory (when you're finished using it)
	b = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/VoiceIntro.wav");

	x = SynthDef("tutorial-PlayBuf",{arg out = 0, bufnum;
		Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
    )
	}).play(s,[\bufnum, b]);


	//Farewell
	c = Buffer.alloc(s, 100, 2);    // allocate 2 channels, and 100 frames
	c.free;                         // free the memory (when you're finished using it)
	c = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "../audio/VoiceGoodbye.wav");
	x = SynthDef("tutorial-PlayBuf",{arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
    )
	}).play(s,[\bufnum, c]);



//SOUND MODE #2: Percussion melody


    //Dictionary
    (
    q = ();
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
    Ndef(\secondSound, {|rel = 0.3, atk = 0.01, amp = 0.5, detune = 1,
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

    }).play;

    Ndef(\secondSound).edit

    );

/*
//SOUND MODE #3: Downsampling and bitcrushing effect

	q = ();

	q.mySamples = ();

	q.mySamples.add(\birds -> Buffer.read(s, "/Users/grazielelautenschlaeger/self_portrait_of_an_absence/audio/bird.wav"));

	q.mySamples[\birds].play
	//?? running this part is kiling the server!
	// It works at Dominik's code, but not here.

	/*
	add more:

	q.mySamples.add(\anothersound -> Buffer.read(s,"/Users/grazielelautenschlaeger/self_portrait_of_an_absence/audio/anothersound.wav"));

	q.mySamples[\anothersound].play

	*/

	Spec.add(\bits, [16, 1]);
	Spec.add(\downsamp, [1, 100, \exp]);
	Spec.add(\blend, [0, 1, \lin]);


Ndef(\samplePlayerA, {|amp = 0.1, bufnum = 0,  bits=16, downsamp=2, blend = 0 |

	var son = PlayBuf.ar(2, bufnum, 1, 1, 0,1);
	var bitReduc = son.round(0.5 ** bits);
	var down = Latch.ar(bitReduc, Impulse.ar(SampleRate.ir / downsamp.max(2)));
	var mix = SelectX.ar(blend, [son,down]);
	mix * amp;

}).play;

Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\birds].bufnum);
/*
Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\anothersound].bufnum);

*/

Ndef(\samplePlayerA).set(\bits, 8, \downsamp, 4);

Ndef(\samplePlayerA).edit;

*/


//SOUND MODE #4: Tones + vibrato


SynthDef(\tones, {|amp = 0.1, rel = 2, t_trig = 1, freq = 440, bits = 8, downsamp = 4, modFQ = 2|


	var son = LFPulse.ar(freq, 0);
	var env = Env.perc(0.0001, rel, 1, -2);
	var volEnv = EnvGen.ar(env, t_trig, doneAction: 2);
	var filt = RLPF.ar(son, freq) ;


	var bitReduc = (filt + HPF.ar(PinkNoise.ar(0.09), 2500)).round(0.5 ** bits);
	var down = Latch.ar(bitReduc, Impulse.ar(SampleRate.ir / downsamp.max(2)));
	//var mix = SelectX.ar(blend, [son,down]);
	var panMod = LFTri.ar(modFQ, [0, 1]);
	var pan = down* volEnv * panMod;
	Out.ar(0, (pan * amp ));

}).add;

Tdef(\playNotesInOrder, {

	var myMelody = [65,60,68,65,65,60,68,65,60,68];

	10.do{|index|
		Synth(\tones, [\freq, myMelody[index].midicps, \amp, 0.4, \downsamp, 4, \rel,  3, \modFQ, 2.8]);
		[0.25,0.5,1].choose.wait;

	};


}).play;



//OSC FUNCTION: Updating Ndef and pushbuttons


	(OSCFunc( { | msg, time, addr, port |
        var pyDetune, pyRate;
        pyDetune = msg[1].asFloat;
        pyRate =  msg[2].asFloat;
        ( "Detune is " + pyDetune ).postln;
        ( "Rate is" + pyRate).postln;
        Ndef(\secondSound).set(\detune, pyDetune);
        Ndef(\secondSound).set(\rate, pyRate);
    }, '/secondSound' );
    )
};


