
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

//https://github.com/niavok/glsl-factory/tree/master/shaders/mandelbulb
//https://softologyblog.wordpress.com/category/mandelbulbs/

layout(location = 0) out vec4 rtFragColor; //position // (2)

uniform mat4 uMV; //(1)
uniform mat4 uP;

in vPassDataBlock
{
	vec4 vPassPosition;
	vec4 vPassNormal;

	vec4 vPassTexcoord;

} vPassData;

//const int max_iter = 400;
//
//uniform vec2 uComplexNumber;
//uniform vec2 uCenter;
//uniform double uScale;
//uniform double uTime;

//uniform sampler2D uTex_julia_ramp;


//in vec2 vPassTexCoord;

//https://lodev.org/cgtutor/juliamandelbrot.html
//http://nuclear.mutantstargoat.com/articles/sdr_fract/
//http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
//https://www.shadertoy.com/view/XsfGR8
// Distance Estimator
// returns 0 if the test point is inside the MB, and the distance 0.5*r*logr/rD otherwise
float DistanceEstimator(vec3 pos)
{
	vec3 z = pos;
	float bail = 4;
	float iterations = 6;
	float dr = 1.0;
	float r = 0.0;
	float power = 2;
	for (int i = 0; i < iterations; i++)
	{
		r = length(z);
		if (r > bail)
		{
			break;
		}

		//polar coordinates
		float theta = acos(z.z / r);
		float phi = atan(z.y, z.x);
		dr = pow(r, power -1.0) * power * dr + 1.0;

		//scale and roation
		float zr = pow(r, power);
		theta = theta * power;
		phi = phi * power;


		//convert back to cartesian coord
		z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
		z += pos;


	}

	return 0.5 * log(r) *  r / dr;
}
void main()
{
	
	//vec2 center = uCenter;
	//double scale = 1.0;
	//
	////get the complex number from the uniform
	//vec2 complexNumber = uComplexNumber;
	//
	//vec2 c = (complexNumber * float(scale)) + center;
	//
	//int iter = 0;
	//const float threshold_squared = 8.0f;
	//vec2 z;
	//z = vPassTexCoord.xy  + vec2(-0.500, -0.500);
	//
	////used the books algorithm to help with this
	////iterate through and assign different values for the square of the z
	//while(iter < max_iter && dot(z,z) < threshold_squared)
	//{
	//	vec2 z_squared;
	//	z_squared.x = (z.x * z.x - z.y * z.y);//+ scale;
	//	z_squared.y = (2.0 * z.x *z.y);// + scale;
	//	z = z_squared + c;
	//	iter++;
	//		
	//}
	////if we are at the max, output a color
	//if(iter == max_iter)
	//{
	//	rtFragColor = vec4(0.0, 0.5, 0.5, 1.0);	
	//}
	////output the ramp that we have
	//else
	//{
	//	rtFragColor = texture2D(uTex_julia_ramp, vec2(float(iter) / float(max_iter)));
	//}	

	//rtFragColor = vec4(1.0f, 0.5f, 0.0f, 1.0f);


	float t = 0.0;
	float d = 200.0;

	vec3 ro = vPassData.vPassPosition.xyz;
	vec3 la = vec3(0.0, 0.0, 1.0);

	vec3 cameraDir = normalize(la - ro);

	vec3 rd = normalize(cameraDir + vec3(vPassData.vPassPosition.xy, 0.0));

	vec3 r;
	for (int i = 0; i < 100; i++)
	{
		if (d > .001)
		{
			r = ro  + t;
			//r = ro + rd * t;
			//float distanceToLight = length(uLightPos[i] - vPassData.vPassPosition); //vec4(vPassData.vPassNormal, 1.0f));
			d = DistanceEstimator(r);
			t += d;
		}
	}

	//r -= vec3(1.0, 1.0, 1.0);
	//float r = DistanceEstimator(vPassData.vPassPosition.xyz);
	//rtFragColor = vPassData.vPassPosition;
	rtFragColor = vec4(r, 1.0f);
	//rtFragColor = vec4(t,t,t, 1.0f);

}
