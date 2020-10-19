
Bread Loaf Model by: https://poly.google.com/user/4lZfAdz3x3X

Knife Model by: https://poly.google.com/user/0PJrSBAZRLL

Sound Effects by: http://soundbible.com/

Polygon Cutting:
The important part of the Bread cutter game, slicing the model into pieces based on user input. 
Assumptions: 
1) You are trying to cut along x-axis of the object. 
2) There is no scale applied to the 3D models you are trying to cut. 
3) Doesn't handle curves in y direction very well. (no spherical stuff, it works but the pieces will be wierd.)

This is written in GeometrySplit.gd (which also has rest of the game code, sorry) in the <b> handle_mesh_cutting() </b> function. 
This is responsible for splitting the mesh into two pieces across the x-axis at origin. 

Confetti:
I've searched a lot to figure out how to create confetti for godot but was unable to find anything out there. 
I took inspiration from the MultiInstance fish tutorial on the Godot documentation website and wrote a shader that would
create a spiral from a plane. Then i used that as material for the particles from the CPUParticle system. With little bit of 
tweaking on the speed and scale i was able to get a reasonable looking confetti FX. Hope this helps somebody :)
Where to Look:
1) Gameplay.tscn > ConfettiFX 
2) materials/confetti.shader
3) materials/ConfettiFx.material