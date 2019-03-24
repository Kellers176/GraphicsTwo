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
	
	drawCel_fs4x.glsl
	Output Cel shading 
*/

#version 410
//done
// ****TO-DO: 
//	1) declare varyings (attribute data) to receive from vertex shader
//	2) declare g-buffer render targets
//	3) pack attribute data into outputs
const int MAX_LIGHTS = 10;

layout(location = 0) out vec4 rtFragColor; //position // (2)
//layout(location = 1) out vec4 rtFragColor1; //normal
//layout(location = 2) out vec4 rtFragColor2; //texcoord


//Diffuse Texture
uniform sampler2D uTex_dm; //(2)
uniform sampler2D uImage6;
//Specular Texture
uniform sampler2D uTex_sm;
//Ramp Diffuse Texture
uniform sampler2D uTex_dm_ramp;
//Ramp Specular Texture
uniform sampler2D uTex_sm_ramp;

uniform int uLightCt; //(8)
uniform vec4  uLightPos[MAX_LIGHTS]; //position
uniform vec4  uLightCol[MAX_LIGHTS]; //intensity aka color
uniform float uLightSz[MAX_LIGHTS]; //attenuation

in vPassDataBlock
{
	vec4 vPassPosition;
	vec3 vPassNormal;
	vec2 vPassTexcoord;

} vPassData;

void main()
{

	//use phong lighting from previous assignment
	//add the fractal that we create in the drawJuliaFractal fragment shader
	vec4 FractalTex = texture(uImage6, vPassData.vPassTexcoord);
	vec4 DiffuseTex = texture(uTex_dm, vPassData.vPassTexcoord);
	vec4 SpecularTex = texture(uTex_sm, vPassData.vPassTexcoord);


	vec3 returnColor;
	vec4 lightDiffuse;
	for (int i = 0; i < uLightCt; i++)
	{
		vec3 N = normalize(vPassData.vPassNormal);
		vec3 L = normalize(uLightPos[i].xyz - vPassData.vPassPosition.xyz);
		vec3 V = normalize(-vPassData.vPassPosition.xyz);
		vec3 R = reflect(-L, N);
	
		//assign the diffuse ramp using the ramp texture that we created
		float diffuseRamp = max(dot(N, L) * 0.5 + 0.5, 0.0f);
		diffuseRamp = texture(uTex_dm_ramp, vec2(diffuseRamp, 0.0)).x;
		vec3 diffuse = diffuseRamp *  uLightCol[i].xyz * DiffuseTex.xyz;
		
		//assign the specular ramp using the ramp texture that we created
		float specularRamp = pow(max(dot(R, V) * 0.5 + 0.5, 0.0f), 1.0);
		specularRamp = texture(uTex_sm_ramp, vec2(specularRamp, 0.0)).x;	
		vec3 specular = specularRamp *  uLightCol[i].xyz* SpecularTex.xyz;


		float distanceToLight = length(uLightPos[i] - vPassData.vPassPosition); 
		float attenuation = 1.0 / (1.0 + uLightSz[i] * pow(distanceToLight, 2));

		//add all values at the end to get cel shading
		returnColor += attenuation * (diffuse + specular);

	}
	//add the fractal to the cell shading
	rtFragColor = vec4(returnColor + FractalTex.xyz, 1.0);

}
