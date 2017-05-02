
//: record test buffer

{
	var sound;
	Server.default.prepareForRecord;
	0.1.wait;
	Server.default.record;
	0.1.wait;

	(0..10) do: { | degree |
		(degree: degree, dur: 0.1).play;
		0.1.wait;
	};
	
	Server.default.stopRecording;
}.fork;
//: load test buffer

~buffer = Buffer.read(Server.default, "./sample.aiff");

//: Test buffer
~buffer.play;

//: start with simple BufRd synth
// From help file

{ BufRd.ar(2, ~buffer, Phasor.ar(0, BufRateScale.kr(~buffer), 0, BufFrames.kr(~buffer))) }.play;

//: mod 1: Use line instead of phasor
{ BufRd.ar(2, ~buffer,
	Line.ar(0, BufFrames.kr(~buffer) * 0.75, 0.7
		5))
}.play;

//: mod 2: Use envelope
// stage 1: Start from help file
// From: http://danielnouri.org/docs/SuperColliderHelp/UGens/Synth%20control/Envelopes/EnvGen.html
SynthDef("env", { arg i_outbus=0;
	var env, envctl;
	
	// make a dummy 8 segment envelope
	env = Env.newClear(8);
	
	// create a control argument array
	envctl = Control.names([\env]).kr( env.asArray );
	
	ReplaceOut.kr(i_outbus, EnvGen.kr(envctl, doneAction: 2));
}).send(s);

//:	

SynthDef("sine", {
	Out.ar(0, SinOsc.ar(In.kr(0), 0, 0.2));
}).send(s);
//:

s.sendMsg(\c_set, 0, 800);

s.sendMsg(\s_new, \sine, 1001, 1, 0);

e = Env([700,900,900,800], [1,1,1]*0.4, \exp).asArray;
s.sendBundle(nil,[\s_new, \env, 1002, 2, 1001],[\n_setn, 1002, \env, e.size] ++ e);

f = Env([1000,1000,800,1000,900,1000], [1,1,1,1,1]*0.3, \step).asArray;
s.sendBundle(nil,[\s_new, \env, 1003, 2, 1001],[\n_setn, 1003, \env, f.size] ++ f);

s.sendMsg(\n_free, 1001);





