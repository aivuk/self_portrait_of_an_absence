/* visual readouts from looking at the sampled sound in audacity
duration: 0.3

262Hz -> -20db
410Hz -> -29db
786 -> -40db
1245 -> -48db
1309 -> -46.7db
1830 -> -54db
2071 -> -55db

*/

s.boot;

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
Ndef(\firstSound, {|rel = 0.3, atk = 0.01, amp = 0.5, detune = 1|

	var freqs, amps, son, sonEnv, trig, noise, noiseEnv;
	freqs = q.myFreqs * detune;
	amps = q.myAmps;

	//trig = Impulse.ar(2); //
	trig = Dust.ar(2);
	noiseEnv = EnvGen.ar(Env.perc(atk * 0.5, atk * 0.5, 1, [-4, 4]), trig);
	sonEnv = EnvGen.ar(Env.perc(atk, rel, 1, -4), trig);

	son = SinOsc.ar(freqs, 0, amps).sum  * sonEnv;
	noise = PinkNoise.ar() * noiseEnv * 0.5;
	(son + noise) * amp ! 2;

}).play;

Ndef(\firstSound).edit;
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