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
	
	drawJuliaPostProcessing_fs4x.glsl
	Output Fractal onto scene using post processing inputs
*/

#version 410
//done
// ****TO-DO: 
//	1) declare varyings (attribute data) to receive from vertex shader
//	2) declare g-buffer render targets
//	3) pack attribute data into outputs

layout(location = 0) out vec4 rtFragColor; //position // (2)
layout(location = 1) out vec4 rtFragColor1; //normal
layout(location = 2) out vec4 rtFragColor2; //texcoord


in vPassDataBlock
{
	vec4 vPassPosition;
	vec4 vPassNormal;


	vec4 vPassTexcoord;

} vPassData;

void main()
{
	//zac
	//Passing in the variables to the FSQ
	rtFragColor = vPassData.vPassPosition;
	rtFragColor1 = normalize(vPassData.vPassNormal);
	rtFragColor2 = vPassData.vPassTexcoord;
}
