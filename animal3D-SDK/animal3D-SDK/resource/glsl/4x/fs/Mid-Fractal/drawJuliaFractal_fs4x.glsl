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
	
	drawJuliaFractal_fs4x.glsl
	Output julia fractal to FBO
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

const int max_iter = 400;

uniform vec2 uComplexNumber;
uniform vec2 uCenter;
uniform double uScale;
uniform double uTime;

uniform sampler2D uTex_julia_ramp;

in vPassDataBlock
{
	vec4 vPassPosition;
	vec3 vPassNormal;


	vec2 vPassTexcoord;

} vPassData;

void main()
{
	
	vec2 center = uCenter;
	double scale = 1.0;

	//vec2 complexNumber = vec2(-1.4793,0.002);
	//vec2 complexNumber = vec2(0.365,0.36);
	vec2 complexNumber =uComplexNumber;

	vec2 c = (complexNumber * float(scale)) + center;

	int iter = 0;
	const float threshold_squared = 8.0f;
	vec2 z;
	z = vPassData.vPassTexcoord.xy  + vec2(-0.500, -0.500);

	while(iter < max_iter && dot(z,z) < threshold_squared)
	{
		vec2 z_squared;
		z_squared.x = (z.x * z.x - z.y * z.y);//+ scale;
		z_squared.y = (2.0 * z.x *z.y);// + scale;
		z = z_squared + c;
		iter++;
			
	}

	if(iter == max_iter)
	{
		rtFragColor = vec4(0.0, 0.5, 0.5, 1.0);	
	}
	else
	{
		rtFragColor = texture2D(uTex_julia_ramp, vec2(float(iter) / float(max_iter)));
	}


	//rtFragColor = vec4(float(uScale), 0.0, 0.0, 1.0);
	//rtFragColor = vec4(sin(float(uTime)), 0.0, 0.0, 1.0);
	

}
