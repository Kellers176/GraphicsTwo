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
	
	manipTriangle_Julia_gs4x.glsl
	Manipulate a single input triangle as a julia fractal.
*/

#version 410

// ****TO-DO: 
//	1) declare input and output varying data
//	2) either copy input directly to output for each vertex, or 
//		do something with the vertices first (e.g. explode, invert)

//no more variables for this shader
layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 uP;

//(1)
//recieved passPhongAttribs
in vbPassDataBlock
{
	vec4 vPosition;
	vec4 vNormal;
	vec2 vTexcoord;

} vPassData_in[];
//pass to drawPhongMulti
out vbPassDataBlock
{
	vec4 vPosition;
	vec4 vNormal;
	vec2 vTexcoord;

} vPassData_out;


void main()
{
	//Kelly and zac and class
	//add the explode size
	const float explodeSz = 0.5f;
	//use for loop
	for (int i = 2; i >= 0; i--)
		//for(int i = 0; i < 3; i++)
	{
		//change the geometry for the objects (this was done in class, zac did the for loop)
		vPassData_out.vPosition = vPassData_in[i].vPosition
			+ normalize(vPassData_in[i].vNormal) * explodeSz;

		vPassData_out.vNormal = vPassData_in[i].vNormal;

		vPassData_out.vTexcoord = vPassData_in[i].vTexcoord;

		gl_Position = uP * vPassData_out.vPosition;

		EmitVertex();
	}

	//End the primitive
	EndPrimitive();
}

