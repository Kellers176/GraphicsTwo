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
	
	drawFinalPostProcessing_fs4x.glsl
	Output Fractal onto scene using post processing inputs
*/

#version 410
//done

layout(location = 0) out vec4 rtFragColor; //position // (2)
layout(location = 1) out vec4 rtFragColor1; //normal
layout(location = 2) out vec4 rtFragColor2; //texcoord

uniform double uTime;

uniform sampler2D uTex_dm;
in vec2 vPassTexCoord; 

//get the pixel threshold
float getPixelThreshold(float threshold1, float threshold2, float value)
{
	if (value < threshold1)
	{
		return 0.0;
	}
	if (value > threshold2)
	{
		return 1.0;
	}
	return value;
}

vec4 getPixelCoord(vec2 mycoords, float x, float y)
{
	//get the pixel coordinates
	return texture2D(uTex_dm, mycoords + vec2(x, y));
}

float getAverageOfPixel(vec4 pixel)
{
	//return the pixel average
	return (pixel.r + pixel.g + pixel.b) / 5.0;
}

//https://coding-experiments.blogspot.com/2010/06/edge-detection.html?fbclid=IwAR2f9O5PaObEQUkavEp5in01lSgtiwZXw2EVjMS-_z_najXIOdOuyCx3bvg
float CheckEdgeDetection(in vec2 mycoords) {
	// initializing the variables
	float texWidth = 1.0 / 512.0;  //image width
	float texHeight = 1.0 / 512.0;	//image height
	float surroundingPixel[9];
	int k = -1;

	// read neighboring pixel intensities
	for (int i = -1; i < 2; i++)
	{
		for (int j = -1; j < 2; j++)
		{
			k++;
			surroundingPixel[k] = getAverageOfPixel(getPixelCoord(mycoords, float(i)*texWidth, float(j)*texHeight));
		}
	}

	// average color around surrounding pixels
	float delta = (abs(surroundingPixel[1] - surroundingPixel[7]) + abs(surroundingPixel[5] - surroundingPixel[3]) +
		abs(surroundingPixel[0] - surroundingPixel[8]) + abs(surroundingPixel[2] - surroundingPixel[6])) / 4;

	//return the line color
	return getPixelThreshold(0.0, 0.5, clamp(5.0*delta, 0.0, 1.0));
}

void main()
{
	//output the color
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	//fluctuate through time
	color = vec4(CheckEdgeDetection(vPassTexCoord.xy) * (1.0 + cos(float(uTime))), CheckEdgeDetection(vPassTexCoord.xy) * (1.0 + sin(float(uTime))), CheckEdgeDetection(vPassTexCoord.xy) * (0.5 + 0.5 * sin(float(uTime))), 1.0);
	rtFragColor = color;
}
