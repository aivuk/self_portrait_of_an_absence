q = q ? ();

q.myMode = nil;

(
q.myGui = Window.new("Grazieles_GUI", Rect(20, 20, 160, 180) );

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



