s.boot;

/*
s.latency = 0.02;

Ndef(\tones, {|amp = 0.1, rel = 2, t_trig = 0, freq = 440, bits = 8, downsamp = 4|


	var son = LFPulse.ar(freq, 0);
	var env = Env.perc(0.0001, rel);
	var volEnv = EnvGen.ar(env, t_trig);
	var filt = RLPF.ar(son, freq) ;


	var bitReduc = (filt + HPF.ar(PinkNoise.ar(0.05), 2500)).round(0.5 ** bits);
	var down = Latch.ar(bitReduc, Impulse.ar(SampleRate.ir / downsamp.max(2)));
	//var mix = SelectX.ar(blend, [son,down]);

	((down* volEnv) ) * amp ! 2;



}).play;


Ndef(\tones).set(\t_trig, 1, \freq, (65 + 10.rand).midicps, \amp, 0.4, \downsamp, 2);

*/


///////////////////////////////////////////////////

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

//play single sound
Synth(\tones, [\freq, 65.midicps, \amp, 0.4, \downsamp, 4, \rel,  3, \modFQ, 2.8])
//single sound with random pitch
Synth(\tones, [\freq, (65 + 10.rand).midicps, \amp, 0.4, \downsamp, 4, \rel,  3, \modFQ, 2.8])
//single sound with choosing a pitch out of a list of notes
Synth(\tones, [\freq, [65,60,68].choose.midicps, \amp, 0.4, \downsamp, 4, \rel,  3, \modFQ, 2.8])

//play a task that starts notes with random wait times in between
Tdef(\playNotes, {

	10.do{
		Synth(\tones, [\freq, [65,60,68].choose.midicps, \amp, 0.4, \downsamp, 4, \rel,  3, \modFQ, 2.8]);
		[0.25,0.5,1].choose.wait;

	};

}).play;


//starts notes from a given list (array) in the given order by using an index (counter)
Tdef(\playNotesInOrder, {

	var myMelody = [65,60,68,65,65,60,68,65,60,68];

	10.do{|index|
		Synth(\tones, [\freq, myMelody[index].midicps, \amp, 0.4, \downsamp, 4, \rel,  3, \modFQ, 2.8]);
		[0.25,0.5,1].choose.wait;

	};


}).play;

//see all executed tasks and restart them by pushing the button marked ( I ) (if it is playing the mark is ( _ ) and in green
TdefAllGui();


Tdef(\test,{

	100.do{|index|

		index.postln;
		Synth(\tones, [\freq, (65+(index % 6)).midicps, \amp, 0.4, \downsamp, 4, \rel,  0.2, \modFQ, 2.8]);
		0.1.wait;

	}

}).play;
