
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

in vec2 vPassTexCoord; //(4)
//need mvp matrix to mess around with the 3d coord
uniform vec4 uCenter;
uniform vec2 uComplexNumber;
uniform double uTime;
uniform mat3 uMV;


//https://lodev.org/cgtutor/juliamandelbrot.html
//http://nuclear.mutantstargoat.com/articles/sdr_fract/
//http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
//https://www.shadertoy.com/view/XsfGR8
// Distance Estimator
// returns 0 if the test point is inside the MB, and the distance 0.5*r*logr/rD otherwise

vec3 rotateMatrix(vec3 pos, float x, float y, float z)
{
	mat3 rotX = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), -sin(x), 0.0, sin(x), cos(x) );
	mat3 rotY = mat3( cos(y), 0.0, sin(y), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y) );
	mat3 rotZ = mat3( cos(z), -sin(z), 0.0, sin(z), cos(z), 0.0, 0.0, 0.0, 1.0 );
	return rotX * rotY * rotZ * pos;
}
vec3 rotate(vec3 pos, float x, float y)
{
	mat3 rotX = mat3( 1.0, 0.0, 0.0, 0.0, cos(x), sin(x), 0.0, -sin(x), cos(x) );
	mat3 rotY = mat3( cos(y), 0.0, -sin(y), 0.0, 1.0, 0.0, sin(y), 0.0, cos(y) );
	//mat3 rotZ = mat3( cos(z), sin(z), 0.0, -sin(z), cos(z), 0.0, 0.0, 0.0, 1.0 );
	return rotX * rotY * pos;
}

float DistanceEstimator(vec3 pos)
{
	pos = rotate(pos, float(uComplexNumber.y * 200), float(uComplexNumber.x * 200));
	//pos = uMV * pos;
	vec3 z = pos;
	float bail = 2;
	float iterations = 10;
	float dr = 1.0;
	float r = 0.0;
	float returnVal = 0.0;
	float power = 7;
	for (int i = 0; i < iterations; i++)
	{
		r = length(z);
		if (r > bail)
		{
			break;
		}
		else
		{
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
	}

	return 0.5 * log(r) *  r / dr;
	//return returnVal;
}


void main()
{
	vec3 offset = vec3(-1.0, -1.0, -0.5);
	float t = 0.0;
	float d = 200.0;

	vec3 ro = vec3(vPassTexCoord, -1.5);
	vec3 la = vec3(0.0, 0.0, 1.0);
	   
	vec3 cameraDir = normalize(la - ro);
	   
	vec3 rd = normalize(cameraDir + vec3(vPassTexCoord.xy, 0.0));
	   
	vec3 r;
	for (int i = 0; i < 100; i++)
	{
		if (d > 0.0001)
		{
			r = ro + rd * t;
			d = DistanceEstimator(r + offset);
			t += d;
		}
	}



	vec3 color = vec3(0.25, 0.5, 0.25);

	if(r.x >= 1.0 && r.y >= 1.0 && r.z >= 1.0 )
	{
		r = vec3(0.0);
	}

	color *= r;

	//rtFragColor = vec4(r, 1.0f);
	rtFragColor = vec4(color, 1.0f);
}
