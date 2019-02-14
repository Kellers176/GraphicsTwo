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


// Gaussian blur with 1D kernel about given axis
//	weights are selected by rows in Pascal's triangle
//		2^0 = 1:		1
//		2^1 = 2:		1	1
//		2^2 = 4:		1	2	1
//		2^3 = 8:		1	3	3	1
//		2^4 = 16:		1	4	6	4	1
//		2^5 = 32		1   5   10  10  5  1
//		2^6	= 64		1   6   15  20  15 6  1
//		2^7
//		2^8	= 256			1   8   28  56  70 56 28 8 1
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

vec4 calcGaussianBlur1D_6(in sampler2D image, in vec2 center, in vec2 axis)	// (2)
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

void main()
{
	// DUMMY OUTPUT: all fragments are LIME
//	rtFragColor = vec4(0.0, 1.0, 0.5, 1.0);

	rtFragColor = calcGaussianBlur1D_8(uImage0,vPassTexcoord, uPixelSz);// *calcGaussianBlur1D_4(uImage0,vPassTexcoord, uPixelSz);



	// DEBUGGING
//	vec4 sample0 = texture(uImage0, vPassTexcoord);
//	rtFragColor = vec4(vPassTexcoord, 0.0, 1.0);
//	rtFragColor = 1.0 - sample0;
}
