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
	
	drawCustom_fs4x.glsl
	Custom effects for MRT.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of other fragment shader to start, or start from scratch: 
//		-> declare varyings to read from vertex shader
//		-> *test all varyings by outputting them as color
//	1) declare at least four render targets
//	2) implement four custom effects, outputting each one to a render target
const int MAX_LIGHTS = 10;

layout(location = 0) out vec4 rtFragColor;  
layout(location = 1) out vec4 rtFragColor1;	
layout(location = 2) out vec4 rtFragColor2;	
layout(location = 3) out vec4 rtFragColor3;	

uniform int uLightCt; //(8)
uniform vec4  uLightPos[MAX_LIGHTS]; //position
uniform vec4  uLightCol[MAX_LIGHTS]; //intensity aka color
uniform float uLightSz[MAX_LIGHTS]; //attenuation


uniform sampler1D uColor; //(2)
uniform sampler1D uTex_dm; //(2)
uniform sampler1D uTex_sm;


in vPassDataBlock //(1)
{
	vec4 vPassPosition;
	vec3 vPassNormal;

	vec2 vPassTexcoord;

} vPassData;

//kelly
vec3 rimShading()
{
	vec3 returnVec;
	vec3 N = normalize(vPassData.vPassNormal);
	vec3 V = normalize(-vPassData.vPassPosition.xyz);

	//this is the rim shading
	float vdn = 1.0 - max(dot(V, N), 0.0);

	returnVec += vec3(0.6, 0.0, 0.0);
	//return the rim shader
	return returnVec.xyz = vec3(smoothstep(0.1, 1.0, vdn));

}

//kelly
vec4 ToonShading()
{
	//http://www.lighthouse3d.com/tutorials/glsl-12-tutorial/toon-shader-version-ii/
	vec4 returnColor;
	vec4 lightDiffuse;
	for (int i = 0; i < uLightCt; i++)
	{
		vec3 lightDirection = normalize(uLightPos[i].xyz - vPassData.vPassPosition.xyz);
		float intense = dot(lightDirection, normalize(vPassData.vPassNormal));
		if (intense > 0.95)
		{
			//clamp, lerp, mix?
			returnColor = vec4(1.0, 0.5, 0.5, 1.0);
		}
		else if (intense > 0.5)
		{
			returnColor = vec4(0.2, 0.6, 0.6, 1.0);
		}
		else if (intense > 0.25)
		{
			returnColor = vec4(0.1, 0.1, 0.1, 1.0);
		}
		else
		{
			returnColor = vec4(0.0, 0.0, 0.0, 1.0);
		}
		lightDiffuse += returnColor;
	}
	return lightDiffuse;
	
}

//kelly
vec4 StripesGalore()
{
	//http://www.lighthouse3d.com/tutorials/glsl-tutorial/texture-coordinates/
	vec4 returnColor;
	vec4 color1 = vec4(1.0, 0.5, 0.5, 1.0);
	vec4 color2 = vec4(0.4, 0.8, 0.9, 1.0);

	vec2 modifiedTexcoord = vPassData.vPassTexcoord * 8.0;

	float fraction = fract(modifiedTexcoord.x);

	if (fraction < 0.5)
		returnColor = color1;
	else
		returnColor = color2;

	return returnColor;
}

//kelly
vec3 RGBToHSL(vec3 colorVector)
{
	//http://www.niwa.nu/2013/05/math-behind-colorspace-conversions-rgb-hsl/
	vec3 returnVector;


	//min value of the rgb vector
	float mMin = min(min(colorVector.x, colorVector.y), colorVector.z);
	//max value of the rgb vector
	float mMax = max(max(colorVector.x, colorVector.y), colorVector.z);
	float mDelta = mMin - mMax;

	//brightness/Luminance
	returnVector.z = (mMin + mMax) / 2.0;

	//need to check the luminance in order to make sure it is the right formula
	if(returnVector.z < 0.5)
	{
		returnVector.y = mDelta / (mMax + mMin);
	}
	else
	{
		returnVector.y = mDelta / (2.0 - mMax - mMin);
	}

	//calculates the hue by checking creating the hue formula now so that we can use it later
	float mDeltaRed = (((mMax - colorVector.x) / 6.0) + (mDelta / 2.0)) / mDelta;
	float mDeltaGreen = (((mMax - colorVector.y) / 6.0) + (mDelta / 2.0)) / mDelta;
	float mDeltaBlue = (((mMax - colorVector.z) / 6.0) + (mDelta / 2.0)) / mDelta;

	//if the color is equal to the max, we want to use it
	if(colorVector.x == mMax)
		//the hue for yell and magenta
		returnVector.x = mDeltaBlue / mDeltaGreen;
	else if(colorVector.y == mMax)
		//the hue the color for cyan and yellow
		returnVector.x = (1.0/3.0) + mDeltaRed - mDeltaBlue;
	else if(colorVector.z == mMax)
		//nother bit of half //the hue for magenta and cyan
		returnVector.z = (2.0/3.0) + mDeltaGreen - mDeltaRed;

		//get the degrees
	returnVector.x = returnVector.x * 60.0;
	if(returnVector.x < 0.0)
		returnVector.x = returnVector.x + 360.0;
	else	//dont know if i need
		returnVector.x = returnVector.x - 360.0;


	return returnVector;

}

void main()
{
	// DUMMY OUTPUT: all fragments are FADED CYAN
	//rtFragColor = vec4(0.5, 1.0, 1.0, 1.0);
	rtFragColor = vec4(RGBToHSL(vPassData.vPassNormal.xyz),1.0);
	rtFragColor1 = ToonShading();
	rtFragColor2 = StripesGalore();
	rtFragColor3 = vec4(rimShading(),1.0);
	//rtFragColor = vec4(vPassData.vPassNormal.xyz,1.0);
	
}
