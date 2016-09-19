
s.boot;
s.quit;

b = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "audio/SeaSample.wav");
c = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "audio/Intro.wav");



// Exploring

Ndef(\exploring).ar(2);

Ndef(\exploring).addSpec(\amp, [0, 1, \exp]);
//Ndef(\exploring).addSpec(\amp, [30, 100, \lin, 1]);

(
Ndef(\exploring, {|amp = 0.1|

	var freq;
        freq = Duty.kr(
                Drand([0.01, 0.2, 0.4], inf)* MouseX.kr(0.001, 2, 1),
                0,
                Dseq([204, 400, 201, 502, 300, 200], inf)
            );
        SinOsc.ar(freq * [1, 1.01]) * amp

});

);

Ndef(\exploring).edit;



// BUFFALOOOOFER


Ndef(\nBuffer).set(\bufsea, b);
//Ndef(\nBuffer).set(\bufvoice, c);

(
Ndef(\nBuffer, { arg amp = 0.3, bufsea=0, bufvoice=0;

	var sea = PlayBuf.ar(2, bufsea, BufRateScale.kr(bufsea),1,0,1,2);
	//var voice = PlayBuf.ar(2, bufvoice, BufRateScale.kr(bufvoice),1,0,0,2);

	sea*amp;

});

);
//Ndef(\nBuffer).play;
//Ndef(\nBuffer).stop;


(
Ndef(\geral, { arg amp = 1;

	var crossfade = XFade2.ar(Ndef(\nBuffer).ar, Ndef(\exploring).ar, MouseX.kr(-1,1), 1);
 //Ringz.ar(Dust.ar(3, 0.3), MouseY, 2);

crossfade*amp;

});
);

Ndef(\geral).play;
Ndef(\geral).stop;


