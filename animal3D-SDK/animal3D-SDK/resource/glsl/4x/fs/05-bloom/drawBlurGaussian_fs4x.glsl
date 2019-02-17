/*
	Copyright 2011-2019 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawBlurGaussian_fs4x.glsl
	Implements and performs Gaussian blur algorithms.
*/

#version 410

// ****TO-DO: 
//	1) declare uniforms used in this algorithm (see blur pass in render)
//	2) implement one or more 1D Gaussian blur functions
//	3) output result as blurred image

in vec2 vPassTexcoord;

uniform sampler2D uImage0;

uniform vec2 uPixelSz; //(1)

layout (location = 0) out vec4 rtFragColor;


// Zac and Kelly
// In class implemetation of gaussian blur
// Gaussian blur with 1D kernel about given axis
//	weights are selected by rows in Pascal's triangle
//		2^0 = 1:		1
//		2^1 = 2:		1	1
//		2^2 = 4:		1	2	1
//		2^3 = 8:		1	3	3	1
//		2^4 = 16:		1	4	6	4	1
//		2^5 = 32		1   5   10	10	5	1
//		2^6	= 64		1	6	15	20	15	6	1
//		2^7
//		2^8	= 256		1	8	28	56	70	56	28	8	1

//https://github.com/cansik/processing-bloom-filter
vec4 calcGaussianBlur1D_4(in sampler2D image, in vec2 center, in vec2 axis)	// (2)
{
	vec4 color = vec4(0.0);

	color += texture(image, center + axis * 2.0);
	color += texture(image, center + axis) * 4.0;
	color += texture(image, center) * 6.0;
	color += texture(image, center - axis) * 4.0;
	color += texture(image, center - axis * 2.0);


	return color / 16.0;
	// dummy: sample image at center
//	return texture(image, center);
}

//Zac and Kelly
//Slightly more indepth gaussian blur, hard coded using expanded Pascal's triangle
vec4 calcGaussianBlur1D_6(in sampler2D image, in vec2 center, in vec2 axis)	
{
	vec4 color = vec4(0.0);

	color += texture(image, center + axis * 3.0);
	color += texture(image, center + axis * 2.0) * 6.0;
	color += texture(image, center + axis) * 15.0;
	color += texture(image, center) * 20.0;
	color += texture(image, center - axis) * 15.0;
	color += texture(image, center - axis * 2.0) * 6.0;
	color += texture(image, center - axis * 3.0);
	
	return color / 64.0;
}
vec4 calcGaussianBlur1D_8(in sampler2D image, in vec2 center, in vec2 axis)	// (2)
{
	vec4 color = vec4(0.0);

	color += texture(image, center + axis * 4.0);
	color += texture(image, center + axis * 3.0) * 8.0;
	color += texture(image, center + axis * 2.0) * 28.0;
	color += texture(image, center + axis) * 56.0;
	color += texture(image, center) * 70.0;
	color += texture(image, center - axis) * 56.0;
	color += texture(image, center - axis * 2.0) * 28.0;
	color += texture(image, center - axis * 3.0) * 8.0;
	color += texture(image, center - axis * 4.0);
	
	return color / 256.0;
}

//https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch40.html
//Zac
//This is a function that takes an input sigma anc dynamically calcuates the gausian blur using it.
//It does this by first figuring out the normal based on the sigma. This will be used to normalize the final result before outputing
//Next the size is calculated as being three times the passed sigma
//Finaly a loop is run for all the bluring to be done. Each run of the loop a new coeff is calculated based on the index and the sigma
vec4 calcIncrementalGausianBlur1D(in sampler2D image, in vec2 center, in vec2 axis, in float sigma)
{
	float norm = 1/(sqrt(2*3.14)*sigma); //normalized sigma
	int size = int(sigma * 3.0); //Size based on sigma

	vec4 color = vec4(0.0);
	color = texture(image, center);

	for(int i = 1; i <= size; i++)
	{
		//Calculate the coefficent based on 
		float coeff = exp(-0.5 * float(i) * float(i) / (sigma * sigma));

		color += (texture(image, center - float(i) * axis)) * coeff;
		color += (texture(image, center + float(i) * axis)) * coeff;
	}

	color *= norm;

	return color;
}

void main()
{
	float sigma = 5.0f;

	rtFragColor = calcIncrementalGausianBlur1D(uImage0,vPassTexcoord, uPixelSz, sigma);
	
	// DUMMY OUTPUT: all fragments are LIME
	//rtFragColor = vec4(0.0, 1.0, 0.5, 1.0);
	// DEBUGGING
	//rtFragColor = calcGaussianBlur1D_8(uImage0,vPassTexcoord, uPixelSz);// *calcGaussianBlur1D_4(uImage0,vPassTexcoord, uPixelSz);
	//vec4 sample0 = texture(uImage0, vPassTexcoord);
	//rtFragColor = vec4(vPassTexcoord, 0.0, 1.0);
	//rtFragColor = 1.0 - sample0;
	//vec2 blurMultiplyVec = 0 < horizontalPass ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
}
