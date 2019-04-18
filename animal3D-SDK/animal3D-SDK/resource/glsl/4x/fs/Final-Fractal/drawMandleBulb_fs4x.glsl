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
	
	drawMandleBulb_fs4x.glsl
	Output julia fractal to FBO
*/

#version 410
//done
// ****TO-DO: 
//	1) declare varyings (attribute data) to receive from vertex shader
//	2) declare g-buffer render targets
//	3) pack attribute data into outputs

layout(location = 0) out vec4 rtFragColor; //position // (2)

const int max_iter = 400;

uniform vec2 uComplexNumber;
uniform vec2 uCenter;
uniform double uScale;
uniform double uTime;

uniform sampler2D uTex_julia_ramp;


in vec2 vPassTexCoord;

//https://lodev.org/cgtutor/juliamandelbrot.html
//http://nuclear.mutantstargoat.com/articles/sdr_fract/
void main()
{
	
	vec2 center = uCenter;
	double scale = 1.0;

	//get the complex number from the uniform
	vec2 complexNumber = uComplexNumber;

	vec2 c = (complexNumber * float(scale)) + center;

	int iter = 0;
	const float threshold_squared = 8.0f;
	vec2 z;
	z = vPassTexCoord.xy  + vec2(-0.500, -0.500);

	//used the books algorithm to help with this
	//iterate through and assign different values for the square of the z
	while(iter < max_iter && dot(z,z) < threshold_squared)
	{
		vec2 z_squared;
		z_squared.x = (z.x * z.x - z.y * z.y);//+ scale;
		z_squared.y = (2.0 * z.x *z.y);// + scale;
		z = z_squared + c;
		iter++;
			
	}
	//if we are at the max, output a color
	if(iter == max_iter)
	{
		rtFragColor = vec4(0.0, 0.5, 0.5, 1.0);	
	}
	//output the ramp that we have
	else
	{
		rtFragColor = texture2D(uTex_julia_ramp, vec2(float(iter) / float(max_iter)));
	}	

}
