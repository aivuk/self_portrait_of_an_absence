s.boot;

q = ();

q.mySamples = ();

q.mySamples.add(\birds -> Buffer.read(s, "/Users/himalo/Desktop/Graziele/bird.wav"));

q.mySamples[\birds].play


/*
add more:

q.mySamples.add(\hh -> Buffer.read(s,"/Users/himalo/Desktop/PushPull_course/pushPullOSC-perfBarebones/resources/samples/drums/HIHAT3.wav"));

q.mySamples[\hh].play

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
Ndef(\samplePlayerA).set(\bufnum, q.mySamples[\hh].bufnum);

*/

Ndef(\samplePlayerA).set(\bits, 8,  \downsamp, 4);

Ndef(\samplePlayerA).edit;

