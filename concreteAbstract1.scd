
s.boot;
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "sounds/SeaSample.wav");
c = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+ "sounds/Intro.wav");



// MonoMeep

Ndef(\monoMeep).ar(2);

Ndef(\monoMeep).addSpec(\myKey, [0, 15, \lin, 1]);
Ndef(\monoMeep).addSpec(\baseKey, [30, 100, \lin, 1]);

(
Ndef(\monoMeep, {|amp = 0.1, baseKey = 50, myKey = 12 |

	var freq, osc;
	myKey = MouseY.kr(0,15).round(1);
	freq = (baseKey + myKey).midicps;
	osc = VarSaw.ar(freq);
	osc*amp!2;

}).play;

);

Ndef(\monoMeep).edit;
Ndef(\monoMeep).stop;




// BUFFALOOOOFER


Ndef(\nBuffer).set(\bufsea, b);
(
Ndef(\nBuffer, { arg amp = 0.3, bufsea=0, bufvoice=0;

	var sea = PlayBuf.ar(2, bufsea, BufRateScale.kr(bufsea),1,0,1,2);
//	var voice = PlayBuf.ar(2, [\bufvoice, c], BufRateScale.kr([\bufvoice, c]),1,0,0,2);

	sea*amp;

});

)
Ndef(\nBuffer).play;
Ndef(\nBuffer).stop;



//Arquivo 2
(
x = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
    )
}).play(s,[\bufnum, c]);
)

(
Ndef(\Geral, { arg amp = 1;

	var crossfade = XFade2.ar(Ndef(\nBuffer).ar, Ndef(\monoMeep).ar, MouseX.kr(-1,1), 1);
 //Ringz.ar(Dust.ar(3, 0.3), MouseY, 2);

crossfade*amp;

});
);

Ndef(\Geral).play;
Ndef(\Geral).stop;



//Mais experimento:
(
    {
        var freq;
        freq = Duty.kr(
                Drand([0.01, 0.2, 0.4], inf), // demand ugen as durations
                0,
                Dseq([204, 400, 201, 502, 300, 200], inf)
            );
        SinOsc.ar(freq * [1, 1.01]) * 0.1

    }.play;
)

(
    {
        var freq;
        freq = Duty.kr(
                MouseX.kr(0.001, 2, 1), // control rate ugen as durations
                0,
                Dseq([204, 400, 201, 502, 300, 200], inf)
            );
        SinOsc.ar(freq * [1, 1.01]) * 0.1

    }.play;
)

