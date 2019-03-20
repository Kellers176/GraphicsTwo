/*
***************************************************

Zachary Taylor 0979233
Kelly Herstine 1015592
Inter Graphics and Animation EGP-300-02
Certificate of authenticity
We certify that this work is entirely our own. The assessor of this project may reproduce this project
and provide copies to other academic staff, and/or communicate a copy of this project to a
plagiarism-checking service, which may retain a copy of the project on its database.

***************************************************
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	passJuliaFractal_vs4x.glsl
	Passes inputs for julia fractal shader
*/

#version 410
//done
// ****TO-DO: 
//	1) declare uniform blocks
//		-> transformations
//	2) declare varyings for info to be passed to FS
//		-> biased clip-space position, index
//	3) transform input position appropriately
//	4) write to outputs

//Kelly and Zac
//We got the variables in class and added them in.

layout (location = 0) in vec4 aPosition;
layout(location = 8) in vec2 aTexcoord; // (3) in a3_VertexDescriptor.h



uniform mat4 uMVP;
//uniform mat4 uP;

out vPassDataBlock
{
	vec4 vPassPosition;
	vec4 vPassNormal;


	vec4 vPassTexcoord;

} vPassData;

void main()
{

	vPassData.vPassTexcoord = vec4(aTexcoord, 0.0, 1.0);

	
	gl_Position = uMVP * aPosition; 
}
