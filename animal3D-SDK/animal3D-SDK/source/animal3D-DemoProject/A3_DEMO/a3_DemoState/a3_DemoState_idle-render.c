/*
	Copyright 2011-2019 Daniel S. Buckstein
	�This file was modified by Kelly Herstine and Zachary Taylor with permission of the author.�
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
	
	a3_DemoState_idle-render.c/.cpp
	Demo state function implementations.

	****************************************************
	*** THIS IS ONE OF YOUR DEMO'S MAIN SOURCE FILES ***
	*** Implement your demo logic pertaining to      ***
	***     RENDERING THE STATS in this file.        ***
	****************************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_DemoState.h"


// OpenGL
#ifdef _WIN32
#include <Windows.h>
#include <GL/GL.h>
#else	// !_WIN32
#include <OpenGL/gl3.h>
#endif	// _WIN32


//-----------------------------------------------------------------------------
// SETUP UTILITIES

// blending state for composition
inline void a3demo_enableCompositeBlending()
{
	// result = ( new*[new alpha] ) + ( old*[1 - new alpha] )
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

// set default GL state
void a3demo_setDefaultGraphicsState()
{
	const a3f32 lineWidth = 2.0f;
	const a3f32 pointSize = 4.0f;

	// lines and points
	glLineWidth(lineWidth);
	glPointSize(pointSize);

	// backface culling
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);

	// textures
	glEnable(GL_TEXTURE_2D);

	// background
	glClearColor(0.0f, 0.0f, 0.0, 0.0f);

	// alpha blending
	a3demo_enableCompositeBlending();
}


//-----------------------------------------------------------------------------
// GENERAL UTILITIES

inline a3real4x4r a3demo_quickInverseTranspose_internal(a3real4x4p m_out, const a3real4x4p m_in)
{
	// the basis for this calculation is "inverse transpose" which 
	//	will result in the scale component inverting while rotation 
	//	stays the same
	// expanding the formula using fundamendal matrix identities 
	//	yields this optimized version
	// translation column is untouched
	a3real4ProductS(m_out[0], m_in[0], a3real3LengthSquaredInverse(m_in[0]));
	a3real4ProductS(m_out[1], m_in[1], a3real3LengthSquaredInverse(m_in[1]));
	a3real4ProductS(m_out[2], m_in[2], a3real3LengthSquaredInverse(m_in[2]));
	a3real4SetReal4(m_out[3], m_in[3]);
	return m_out;
}

inline a3real4x4r a3demo_quickInvertTranspose_internal(a3real4x4p m_inout)
{
	a3real4MulS(m_inout[0], a3real3LengthSquaredInverse(m_inout[0]));
	a3real4MulS(m_inout[1], a3real3LengthSquaredInverse(m_inout[1]));
	a3real4MulS(m_inout[2], a3real3LengthSquaredInverse(m_inout[2]));
	return m_inout;
}

inline a3real4x4r a3demo_quickTransposedZeroBottomRow(a3real4x4p m_out, const a3real4x4p m_in)
{
	a3real4x4GetTransposed(m_out, m_in);
	m_out[0][3] = m_out[1][3] = m_out[2][3] = a3realZero;
	return m_out;
}


// forward declare text render functions
void a3demo_render_controls(const a3_DemoState *demoState);
void a3demo_render_data(const a3_DemoState *demoState);


//-----------------------------------------------------------------------------
// RENDER SUB-ROUTINES

void a3demo_stencilTest(const a3_DemoState *demoState)
{
	const a3_DemoStateShaderProgram *currentDemoProgram;
	const a3f32 testColor[4] = { 1.0f, 0.5f, 0.0f, 1.0f };
	a3mat4 testMat = {
		4.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 4.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 4.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f
	};
	a3real4x4ConcatR(demoState->camera->viewProjectionMat.m, testMat.m);
	
	// drawing "lens" object using simple program
	currentDemoProgram = demoState->prog_transform;
	a3shaderProgramActivate(currentDemoProgram->program);
	a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, testMat.mm);

	// draw to stencil buffer: 
	//	- render first sphere to the stencil buffer to set drawable area
	//		- don't want values for the shape to actually be drawn to 
	//			color or depth buffers, so apply a MASK for this object
	//	- enable stencil test for everything else
	glEnable(GL_STENCIL_TEST);
	glStencilFunc(GL_ALWAYS, 1, 0xff);	// any stencil value will be set to 1
	glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);	// replace stencil value if S&D tests pass
	glStencilMask(0xff);	// write to stencil buffer

	// clear stencil buffer
	glClear(GL_STENCIL_BUFFER_BIT);

	// disable drawing this object to color or depth
	glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	glDepthMask(GL_FALSE);

	// inverted small sphere in solid transparent color
	// used as our "lens" for the depth and stencil tests
	glCullFace(GL_FRONT);
	a3vertexDrawableActivateAndRender(demoState->draw_sphere);
	glCullFace(GL_BACK);

	// enable drawing following objects to color and depth
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glDepthMask(GL_TRUE);

	// reset stencil options
	glStencilFunc(GL_EQUAL, 1, 0xff);	// stencil test passes if equal to 1
	glStencilMask(0x00);	// don't write to stencil buffer
}


//-----------------------------------------------------------------------------
// RENDER

void a3demo_render(const a3_DemoState *demoState)
{
	const a3_VertexDrawable *currentDrawable;
	const a3_DemoStateShaderProgram *currentDemoProgram;
	const a3_Framebuffer *writeFBO, *readFBO;
	const a3_FramebufferDouble *writeDFBO, *readDFBO;

	a3ui32 i, j, k;

	// RGB
	const a3vec4 rgba4[] = {
		{ 1.0f, 0.0f, 0.0f, 1.0f },	// red
		{ 0.0f, 1.0f, 0.0f, 1.0f },	// green
		{ 0.0f, 0.0f, 1.0f, 1.0f },	// blue
		{ 0.0f, 1.0f, 1.0f, 1.0f },	// cyan
		{ 1.0f, 0.0f, 1.0f, 1.0f },	// magenta
		{ 1.0f, 1.0f, 0.0f, 1.0f },	// yellow
		{ 1.0f, 0.5f, 0.0f, 1.0f },	// orange
		{ 0.0f, 0.5f, 1.0f, 1.0f },	// sky blue
		{ 0.5f, 0.5f, 0.5f, 1.0f },	// solid grey
		{ 0.5f, 0.5f, 0.5f, 0.5f },	// translucent grey
	};
	const a3real 
		*const red = rgba4[0].v, *const green = rgba4[1].v, *const blue = rgba4[2].v,
		*const cyan = rgba4[3].v, *const magenta = rgba4[4].v, *const yellow = rgba4[5].v,
		*const orange = rgba4[6].v, *const skyblue = rgba4[7].v,
		*const grey = rgba4[8].v, *const grey_t = rgba4[9].v;


	// bias matrix
	const a3mat4 bias = {
		0.5f, 0.0f, 0.0f, 0.0f,
		0.0f, 0.5f, 0.0f, 0.0f,
		0.0f, 0.0f, 0.5f, 0.0f,
		0.5f, 0.5f, 0.5f, 1.0f,
	};

	// final model matrix and full matrix stack
	a3mat4 modelViewProjectionMat = a3identityMat4, modelViewMat = a3identityMat4;
	a3mat4 modelViewProjectionBiasMat[demoStateMaxCount_sceneObject];

	// camera used for drawing
	const a3_DemoCamera *camera = demoState->camera + demoState->activeCamera;
	const a3_DemoSceneObject *cameraObject = camera->sceneObject;

	// current scene object being rendered, for convenience
	const a3_DemoSceneObject *currentSceneObject, *endSceneObject;

	// display mode for current pipeline
	// ensures we don't go through the whole pipeline if not needed
	const a3ui32 demoMode = demoState->demoMode, demoPipelineCount = demoState->demoModeCount;
	const a3ui32 demoSubMode = demoState->demoSubMode[demoMode], demoPassCount = demoState->demoSubModeCount[demoMode];
	const a3ui32 demoOutput = demoState->demoOutputMode[demoMode][demoSubMode], demoOutputCount = demoState->demoOutputCount[demoMode][demoSubMode];


	// temp light data
	a3vec4 lightPos_eye[demoStateMaxCount_lightObject];
	a3vec4 lightCol[demoStateMaxCount_lightObject];
	a3f32 lightSz[demoStateMaxCount_lightObject];


	// temp texture pointers for scene objects
	const a3_Texture *tex_dm[] = {
		demoState->tex_stone_dm,
		demoState->tex_earth_dm, 
		demoState->tex_stone_dm, 
		demoState->tex_mars_dm,
		demoState->tex_checker,
	};
	const a3_Texture *tex_sm[] = {
		demoState->tex_stone_dm,
		demoState->tex_earth_sm,
		demoState->tex_stone_dm,
		demoState->tex_mars_sm,
		demoState->tex_checker,
	};

	// temp atlas transform pointers
	const a3mat4 *atlasTransformPtr[] = {
		demoState->atlas_stone,
		demoState->atlas_earth,
		demoState->atlas_stone,
		demoState->atlas_mars,
		demoState->atlas_checker,
	};


	// compositing programs
	const a3_DemoStateShaderProgram *pipelineCompositeProgram[] = {
		demoState->prog_drawTexture,
		demoState->prog_drawPhongMulti_deferred,
		demoState->prog_drawDeferredLightingComposite,
	};


	// other tmp data
	a3vec2 pixelSzInv = a3zeroVec2;

	// pass index
	a3ui32 passIndex;


	//-------------------------------------------------------------------------
	// 0) PRE-PROCESSING PASS: render scene for pre-processing 
	//	(e.g. acquire shadow map)
	//	- activate pre-processing framebuffer
	//	- draw scene
	//		- clear buffers
	//		- render shapes using appropriate shaders
	//		- capture whatever data is needed

	// enter shadow pass (pre-processing pass)
	passIndex = demoStateRenderPass_fractal;

	// activate framebuffer ("notebook") for this pass
	//writeFBO = demoState->fbo_shadowmap;
	writeFBO = demoState->fbo_fractal;
	a3framebufferActivate(writeFBO);

	//currentDemoProgram = demoState->prog_drawJuliaFractal;
	//a3shaderProgramActivate(currentDemoProgram->program);


	// clear buffers
	glClear(GL_DEPTH_BUFFER_BIT);

	// shadow mapping: render shadow-casters (inverted helps)
	//currentDemoProgram = demoState->prog_transform;
	//a3shaderProgramActivate(currentDemoProgram->program);
	currentDemoProgram = demoState->prog_drawJuliaFractal;
	a3shaderProgramActivate(currentDemoProgram->program);

	a3mat4 testMat = {
		4.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 4.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 4.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f
	};
	a3real4x4ConcatR(demoState->camera->viewProjectionMat.m, testMat.m);



	//glCullFace(GL_FRONT);
	//for (k = 0, currentDrawable = demoState->draw_plane,
	//	currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject;
	//	currentSceneObject <= endSceneObject;
	//	++k, ++currentDrawable, ++currentSceneObject)
	//{
	//	// calculate and use projector MVP, save for later (no bias yet)
	//	//a3real4x4Product(modelViewProjectionBiasMat[k].m, demoState->projectorLight->viewProjectionMat.m, currentSceneObject->modelMat.m);
	//	//a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionBiasMat[k].mm);
	//	//a3vertexDrawableActivateAndRender(currentDrawable);
	//}
	a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uComplexNumber, 1, demoState->complexNumber.v);
	//a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uScale, 1, &demoState->scaleNumber);
	a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uScale, 1, &demoState->zoom);
	a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);
	//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uCenter, 1, demoState->centerNumber.v);
	a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, a3identityMat4.mm);
	a3shaderUniformSendInt(a3unif_single, currentDemoProgram->uWidth, 1, &demoState->windowWidth);
	a3shaderUniformSendInt(a3unif_single, currentDemoProgram->uHeight, 1, &demoState->windowHeight);

	//a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV, 1, testMat.mm);

	//a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uCenter, 1, demoState->camera->sceneObject->position.v);
	//a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, skyblue);	// for ambient

	//a3textureActivate(demoState->tex_ramp_dm, a3tex_unit04);
	a3textureActivate(demoState->tex_ramp_julia, a3tex_unit08);

	currentDrawable = demoState->draw_unitquad;
	a3vertexDrawableActivateAndRender(currentDrawable);
	//glCullFace(GL_BACK);


	//-------------------------------------------------------------------------
	// 1) SCENE PASS: render scene with desired shader
	//	- activate scene framebuffer
	//	- draw scene
	//		- clear buffers
	//		- render shapes using appropriate shaders
	//		- capture color and depth

	// enter scene pass
	passIndex = demoStateRenderPass_scene;

	// activate framebuffer
	writeFBO = demoState->fbo_scene;
	a3framebufferActivate(writeFBO);
	
	// clear buffers
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


	// optional stencil test
	glDisable(GL_STENCIL_TEST);
	if (demoState->stencilTest)
		a3demo_stencilTest(demoState);


	// draw grid aligned to world
	if (demoState->displayGrid)
	{
		currentDemoProgram = demoState->prog_drawColorUnif;
		a3shaderProgramActivate(currentDemoProgram->program);
		currentDrawable = demoState->draw_grid;
		modelViewProjectionMat = camera->viewProjectionMat;
		a3real4x4ConcatL(modelViewProjectionMat.m, demoState->gridTransform.m);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, demoState->gridColor.v);
		a3vertexDrawableActivateAndRender(currentDrawable);
	}


	// copy temp light data
	for (k = 0; k < demoState->forwardLightCount; ++k)
	{
		lightPos_eye[k] = demoState->forwardPointLight[k].viewPos;
		lightCol[k] = demoState->forwardPointLight[k].color;
		lightSz[k] = demoState->forwardPointLight[k].radiusInvSq;
	}


	// draw objects: 
	//	- correct "up" axis if needed
	//	- calculate proper transformation matrices
	//	- move lighting objects' positions into object space as needed
	//	- send uniforms
	//	- draw

	//a3vec2 complexNumber;
	//a3real2Set(complexNumber.v, 0.365f, 0.36f);

	// support multiple geometry passes
	for (i = 0, j = 1; i < j; ++i)
	{
		// select forward algorithm
		switch (i)
		{
			// forward pass
		case 0:
			// pipeline
			switch (demoState->lightingPipelineMode)
			{
				// forward
			case demoStatePipelineMode_forward:
				// select program based on settings
				//if (demoState->shadowMapping && demoState->projectiveTexturing)
				//	currentDemoProgram = demoState->prog_drawPhongMulti_shadowmap_projtex;
				//else if (demoState->shadowMapping)
				//	currentDemoProgram = demoState->prog_drawPhongMulti_shadowmap;
				//else if (demoState->projectiveTexturing)
				//	currentDemoProgram = demoState->prog_drawPhongMulti_projtex;
				//else
				currentDemoProgram = demoState->prog_drawCel;
				//currentDemoProgram = demoState->prog_drawJuliaFractal;
				a3shaderProgramActivate(currentDemoProgram->program);

				// send shared data: 
				//	- projection matrix
				//	- light data
				//	- activate shared textures including atlases if using
								
				a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP, 1, camera->projectionMat.mm);
				a3shaderUniformSendInt(a3unif_single, currentDemoProgram->uLightCt, 1, &demoState->forwardLightCount);
				a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightPos, demoState->forwardLightCount, lightPos_eye->v);
				a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightCol, demoState->forwardLightCount, lightCol->v);
				a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uLightSz, demoState->forwardLightCount, lightSz);
				a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, skyblue);	// for ambient
				a3textureActivate(demoState->tex_ramp_dm, a3tex_unit04);
				//a3textureActivate(demoState->tex_ramp_julia, a3tex_unit08);
				a3textureActivate(demoState->tex_ramp_sm, a3tex_unit05);
				//a3textureActivate(demoState->tex_earth_dm, a3tex_unit06);
				//a3framebufferBindDepthTexture(demoState->fbo_shadowmap, a3tex_unit07);
				//a3framebufferBindTexture(demoState->fbo_fractal, a3tex_unit06);
				a3framebufferBindColorTexture(demoState->fbo_fractal, a3tex_unit06, 0);
				

				//a3textureActivate(demoState->)

				// individual object requirements: 
				//	- modelviewprojection
				//	- modelview
				//	- modelview for normals
				for (k = 0, currentDrawable = demoState->draw_plane,
					currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject;
					currentSceneObject <= endSceneObject;
					++k, ++currentDrawable, ++currentSceneObject)
				{
					// send data
					a3real4x4Product(modelViewMat.m, cameraObject->modelMatInv.m, currentSceneObject->modelMat.m);
					a3real4x4Product(modelViewProjectionMat.m, camera->projectionMat.m, modelViewMat.m);
					a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV, 1, modelViewMat.mm);
					a3demo_quickInvertTranspose_internal(modelViewMat.m);
					modelViewMat.v3 = a3zeroVec4;
					a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV_nrm, 1, modelViewMat.mm);
					a3real4x4ConcatR(bias.m, modelViewProjectionBiasMat[k].m);
					//a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVPB_proj, 1, modelViewProjectionBiasMat[k].mm);

					// activate textures
					a3textureActivate(tex_dm[k], a3tex_unit00);
					a3textureActivate(tex_sm[k], a3tex_unit01);

					// draw
					a3vertexDrawableActivateAndRender(currentDrawable);
				}
				break;

				// deferred shading and lighting
			case demoStatePipelineMode_deferredShading:
			case demoStatePipelineMode_deferredLighting:
				// g-buffers
				currentDemoProgram = demoState->prog_drawGBuffers;
				a3shaderProgramActivate(currentDemoProgram->program);

				// send shared data: 
				//	- projection matrix
				a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP, 1, camera->projectionMat.mm);

				// individual object requirements: 
				//	- modelviewprojection
				//	- modelview
				//	- modelview for normals
				for (k = 0, currentDrawable = demoState->draw_plane,
					currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject;
					currentSceneObject <= endSceneObject;
					++k, ++currentDrawable, ++currentSceneObject)
				{
					// send data
					a3real4x4Product(modelViewMat.m, cameraObject->modelMatInv.m, currentSceneObject->modelMat.m);
					a3real4x4Product(modelViewProjectionMat.m, camera->projectionMat.m, modelViewMat.m);
					a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV, 1, modelViewMat.mm);
					a3demo_quickInvertTranspose_internal(modelViewMat.m);
					modelViewMat.v3 = a3zeroVec4;
					a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV_nrm, 1, modelViewMat.mm);
					a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uAtlas, 1, atlasTransformPtr[k]->mm);

					// draw
					a3vertexDrawableActivateAndRender(currentDrawable);
				}
				break;
			}
			// end geometry pass
			break;


			// additional geometry passes
		case 1:

			// end geometry pass
			break;
		}
	}


	//-------------------------------------------------------------------------
	// 1B) LIGHTING PRE-PASS: render light volumes to do deferred lighting

	//if (demoState->lightingPipelineMode == demoStatePipelineMode_deferredLighting)
	//{
	//	passIndex = demoStateRenderPass_deferred_volumes;
	//
	//	// draw to appropriate fbo or double fbo
	//	writeDFBO = demoState->fbo_dbl_nodepth + 0;
	//	a3framebufferDoubleActivate(writeDFBO);
	//
	//	// clear
	//	glClear(GL_COLOR_BUFFER_BIT);
	//
	//	// use additive blending so lighting accumulates realistically
	//	glEnable(GL_BLEND);
	//	glBlendFunc(GL_ONE, GL_ONE);
	//
	//	// reverse culling
	//	glCullFace(GL_FRONT);
	//
	//	// read g-buffers from scene pass
	//	readFBO = demoState->fbo_scene;
	//	a3framebufferBindColorTexture(readFBO, a3tex_unit04, 0);	// position output
	//	a3framebufferBindColorTexture(readFBO, a3tex_unit05, 1);	// normal output
	//	a3framebufferBindDepthTexture(readFBO, a3tex_unit07);		// depth buffer
	//	a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP_inv, 1, camera->projectionMatInv.mm);
	//
	//	// draw volumes, instanced; update and upload lighting data		// activate program
	//	currentDemoProgram = demoState->prog_drawPhong_volume;
	//	a3shaderProgramActivate(currentDemoProgram->program);
	//	currentDrawable = demoState->draw_pointlight;
	//	a3vertexDrawableActivate(currentDrawable);
	//	for (i = 0; i < demoState->deferredLightBlockCount; ++i)
	//	{
	//		// render light volumes
	//		a3shaderUniformBufferActivate(demoState->ubo_transformMVP + i, 0);
	//		a3shaderUniformBufferActivate(demoState->ubo_transformMVPB + i, 1);
	//		a3shaderUniformBufferActivate(demoState->ubo_pointLight + i, 2);
	//		a3vertexDrawableRenderActiveInstanced(demoState->deferredLightCountPerBlock[i]);
	//	}
	//
	//	// revert culling
	//	glCullFace(GL_BACK);
	//
	//	// end pass
	//	a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);
	//}


	//-------------------------------------------------------------------------
	// 2) COMPOSITE PASS: display framebuffer on full-screen quad (FSQ); 
	//		opportunity to add foreground and background objects
	//		NOTE: this may also be considered the first post-processing pass!
	//	- deactivate framebuffer
	//	- draw common background
	//		- if your clear color has zero alpha, scene will overlay correctly
	//	- activate render texture(s)
	//	- draw FSQ with appropriate program (simple texture or post)
	//	- repeat for foreground elements as needed

	// enter composite pass
	passIndex = demoStateRenderPass_composite;

	// draw to appropriate fbo or double fbo
	writeDFBO = demoState->fbo_dbl_nodepth + 1;
	a3framebufferDoubleActivate(writeDFBO);

	// BACKGROUND: SKYBOX
	// display skybox or clear
	// - disable blending whether or not skybox is drawn
	//	-> don't need to test for skybox, and if it's not drawn, no clearing
	glDisable(GL_BLEND);
	if (demoState->displaySkybox)
	{
		// draw solid color box, inverted
		currentDrawable = demoState->draw_skybox;
		currentSceneObject = demoState->skyboxObject;
		a3real4x4Product(modelViewProjectionMat.m, camera->viewProjectionMat.m, currentSceneObject->modelMat.m);

		currentDemoProgram = demoState->prog_drawTexture;
		a3shaderProgramActivate(currentDemoProgram->program);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3textureActivate(demoState->tex_skybox_clouds, a3tex_unit00);

		// draw inverted box
		glCullFace(GL_FRONT);
		a3vertexDrawableActivateAndRender(currentDrawable);
		glCullFace(GL_BACK);

		// enable blending to ensure proper composition
		a3demo_enableCompositeBlending();
	}
	else
	{
		// clearing is expensive!
		// nothing do do here because FSQ will draw over everything; disabled 
		//	blending means the transparency from prior clear doesn't matter
	}


	// MIDGROUND: SCENE
	// draw FSQ with texturing or some compositing/post effect shader
	// this is also considered the first post-processing pass
	
	// activate program
	currentDemoProgram = pipelineCompositeProgram[demoState->lightingPipelineMode];
	a3shaderProgramActivate(currentDemoProgram->program);
	a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, a3identityMat4.mm);

	// prepare to draw using active program
	switch (demoState->lightingPipelineMode)
	{
		// forward: just draw result of scene
	case demoStatePipelineMode_forward:
		// bind scene texture
		readFBO = demoState->fbo_scene;
		a3framebufferBindColorTexture(readFBO, a3tex_unit00, 0);
		break;

		// deferred shading: do lighting on fsq
	case demoStatePipelineMode_deferredShading:
		// bind atlases and scene g-buffers
		readFBO = demoState->fbo_scene;
		a3textureActivate(demoState->tex_atlas_dm, a3tex_unit00);	// diffuse atlas
		a3textureActivate(demoState->tex_atlas_sm, a3tex_unit01);	// specular atlas
		a3framebufferBindColorTexture(readFBO, a3tex_unit04, 0);	// position output
		a3framebufferBindColorTexture(readFBO, a3tex_unit05, 1);	// normal output
		a3framebufferBindColorTexture(readFBO, a3tex_unit06, 2);	// texcoord output
		a3framebufferBindDepthTexture(readFBO, a3tex_unit07);		// depth buffer

		// send lighting data
		a3shaderUniformSendInt(a3unif_single, currentDemoProgram->uLightCt, 1, &demoState->forwardLightCount);
		a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightPos, demoState->forwardLightCount, lightPos_eye->v);
		a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightCol, demoState->forwardLightCount, lightCol->v);
		a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uLightSz, demoState->forwardLightCount, lightSz);
		a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, skyblue);	// for ambient
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP_inv, 1, camera->projectionMatInv.mm);
		break;

		// deferred lighting: composite
	//case demoStatePipelineMode_deferredLighting:
	//	// bind atlases and result of light pre-pass
	//	readDFBO = demoState->fbo_dbl_nodepth + 0;
	//	readFBO = demoState->fbo_scene;
	//	a3textureActivate(demoState->tex_atlas_dm, a3tex_unit00);		// diffuse atlas
	//	a3textureActivate(demoState->tex_atlas_sm, a3tex_unit01);		// specular atlas
	//	a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit04, 0);	// diffuse output (lights)
	//	a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit05, 1);	// specular output (lights)
	//	a3framebufferBindColorTexture(readFBO, a3tex_unit06, 2);		// texcoord output (scene)
	//
	//	// send lighting data
	//	a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, skyblue);	// for ambient
	//	break;
	}

	// start using unit quad as FSQ drawable
	//	(remains until end of post unless changed for foreground objects)
	currentDrawable = demoState->draw_unitquad;
	a3vertexDrawableActivateAndRender(currentDrawable);


	// FOREGROUND: HUD
	// ****TO-DO (optional): ANY OTHER HUD, FOREGROUND OR OVERLAY COMPOSITING 
	//	TO BE INCLUDED IN POST-PROCESSING SHOULD BE CONSIDERED HERE
	//	- this excludes axes and debug text, they are not post-processed!


	// PREPARE FOR POST-PROCESSING
	//	- double buffer swap
	//	- ensure blending is disabled
	//	- re-activate FSQ drawable IF NEEDED (i.e. changed in previous step)
	a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);
	glDisable(GL_BLEND);
	currentDrawable = demoState->draw_unitquad;
	a3vertexDrawableActivate(currentDrawable);


	//-------------------------------------------------------------------------
	// 3) POST-PROCESSING: process final image further; you can render FSQ 
	//		straight to back buffer with post-processing program activated, or 
	//		continue the pipeline by adding multiple FSQ passes... try one!
	//	- EACH POST-PROCESSING PASS HAS THE FOLLOWING STEPS: 
	//		- pre-pass tasks (e.g. setup)
	//			- activate post effect program
	//			- set up and send uniforms
	//		- pass core tasks (e.g. rendering)
	//			- activate framebuffer for writing
	//			- bind texture(s) for reading
	//			- draw geometry (e.g. FSQ)
	//		- post-pass tasks (e.g. cleanup)
	//			- double buffer swap

	// can skip post-processing if we're not there yet
	if (demoSubMode > demoStateRenderPass_composite)
	{
		// set up post-processing pass
		//passIndex = demoStateRenderPass_bloom_bright_2;

		// select post-processing program
		//	(if you have uniforms to send, send 'em!)
		currentDemoProgram = demoState->prog_drawBlendComposite;
		a3shaderProgramActivate(currentDemoProgram->program);

		// activate post-processing framebuffer
		writeDFBO = demoState->fbo_dbl_nodepth_2 + 0;
		a3framebufferDoubleActivate(writeDFBO);

		// bind textures required for active post effect
		//	(e.g. output from previous pass, check which "notebook" has it)
		readDFBO = demoState->fbo_dbl_nodepth + 1;
		a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);

		// draw FSQ
		a3vertexDrawableRenderActive();

		// end pass: double buffer swap
		a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// set up next pass
		//passIndex = demoStateRenderPass_bloom_blurH_2;

		// the program for this pass is a bit different: needs some uniforms
		//currentDemoProgram = demoState->prog_drawBlurGaussian;
		//a3shaderProgramActivate(currentDemoProgram->program);
		//pixelSzInv.x = +a3recip(readDFBO->frameWidth);
		//pixelSzInv.y = +a3recip(readDFBO->frameHeight);	// a3realZero;
		//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);

		// buffers
		//writeDFBO = demoState->fbo_dbl_nodepth_2 + 1;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_2 + 0;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);

		// draw and swap
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_blurV_2;

		// is it possible to remove redundant code, e.g. program already activated?
		//	(its actual behavior can be modified by the uniforms!)
	//	currentDemoProgram = demoState->prog_drawBlurGaussian;
	//	a3shaderProgramActivate(currentDemoProgram->program);
		//pixelSzInv.x = -a3recip(readDFBO->frameWidth);	// a3realZero;
		//pixelSzInv.y = +a3recip(readDFBO->frameHeight);
		//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);

		// double framebuffers can be used for r/w simultaneously
		//writeDFBO = demoState->fbo_dbl_nodepth_2 + 1;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_2 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);

		// draw and swap
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_bright_4;
		//
		//currentDemoProgram = demoState->prog_drawBrightPass;
		//a3shaderProgramActivate(currentDemoProgram->program);
		//writeDFBO = demoState->fbo_dbl_nodepth_4 + 0;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_2 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_blurH_4;
		//
		//currentDemoProgram = demoState->prog_drawBlurGaussian;
		//a3shaderProgramActivate(currentDemoProgram->program);
		//pixelSzInv.x = +a3recip(readDFBO->frameWidth);
		//pixelSzInv.y = +a3recip(readDFBO->frameHeight);	// a3realZero;
		//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);
		//writeDFBO = demoState->fbo_dbl_nodepth_4 + 1;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_4 + 0;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_blurV_4;

		//	currentDemoProgram = demoState->prog_drawBlurGaussian;
		//	a3shaderProgramActivate(currentDemoProgram->program);
		//pixelSzInv.x = -a3recip(readDFBO->frameWidth);	// a3realZero;
		//pixelSzInv.y = +a3recip(readDFBO->frameHeight);
		//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);
		//writeDFBO = demoState->fbo_dbl_nodepth_4 + 1;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_4 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_bright_8;

		//currentDemoProgram = demoState->prog_drawBrightPass;
		//a3shaderProgramActivate(currentDemoProgram->program);
		//writeDFBO = demoState->fbo_dbl_nodepth_8 + 0;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_4 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_blurH_8;

		//currentDemoProgram = demoState->prog_drawBlurGaussian;
		//a3shaderProgramActivate(currentDemoProgram->program);
		//pixelSzInv.x = +a3recip(readDFBO->frameWidth);
		//pixelSzInv.y = +a3recip(readDFBO->frameHeight);	// a3realZero;
		//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);
		//writeDFBO = demoState->fbo_dbl_nodepth_8 + 1;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_8 + 0;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// next
		//passIndex = demoStateRenderPass_bloom_blurV_8;

		//	currentDemoProgram = demoState->prog_drawBlurGaussian;
		//	a3shaderProgramActivate(currentDemoProgram->program);
		//pixelSzInv.x = -a3recip(readDFBO->frameWidth);	// a3realZero;
		//pixelSzInv.y = +a3recip(readDFBO->frameHeight);
		//a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);
		//writeDFBO = demoState->fbo_dbl_nodepth_8 + 1;
		//a3framebufferDoubleActivate(writeDFBO);
		//readDFBO = demoState->fbo_dbl_nodepth_8 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);


		// final
		//passIndex = demoStateRenderPass_bloom_blend;

		//currentDemoProgram = demoState->prog_drawBlendComposite;
		//a3shaderProgramActivate(currentDemoProgram->program);
		//writeDFBO = demoState->fbo_dbl_nodepth + 1;
		//a3framebufferDoubleActivate(writeDFBO);

		// final pass has multiple texture inputs: 
		//	composited scene, half blur, quarter blur, eighth blur
		//	(need to check which "notebooks" contain the correct "pages")
		//readDFBO = demoState->fbo_dbl_nodepth + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, 0);
		//readDFBO = demoState->fbo_dbl_nodepth_2 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit01, 0);
		//readDFBO = demoState->fbo_dbl_nodepth_4 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit02, 0);
		//readDFBO = demoState->fbo_dbl_nodepth_8 + 1;
		//a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit03, 0);

		// draw and swap
		//a3vertexDrawableRenderActive();
		//a3framebufferDoubleSwap((a3_FramebufferDouble *)writeDFBO);
	}

	//-------------------------------------------------------------------------
	// DISPLAY: final pass, perform and present final composite
	//	- finally draw to back buffer
	//	- select display texture(s)
	//	- activate final pass program
	//	- draw final FSQ

	// draw to back buffer with depth disabled
	a3framebufferDeactivateSetViewport(a3fbo_depthDisable,
		-demoState->frameBorder, -demoState->frameBorder, demoState->frameWidth, demoState->frameHeight);

	// select read fbo ("notebook") to use for display
	switch (demoSubMode)
	{
	case demoStateRenderPass_scene:
		readFBO = demoState->fbo_scene;
		break;
	case demoStateRenderPass_deferred_volumes:
		readDFBO = demoState->fbo_dbl_nodepth + 0;
		break;
	case demoStateRenderPass_composite:
		readDFBO = demoState->fbo_dbl_nodepth + 1;
		break;
	case demoStateRenderPass_bloom_bright_2:
		readDFBO = demoState->fbo_dbl_nodepth_2 + 0;
		break;
	case demoStateRenderPass_bloom_blurH_2:
	case demoStateRenderPass_bloom_blurV_2:
		readDFBO = demoState->fbo_dbl_nodepth_2 + 1;
		break;
	case demoStateRenderPass_bloom_bright_4:
		readDFBO = demoState->fbo_dbl_nodepth_4 + 0;
		break;
	case demoStateRenderPass_bloom_blurH_4:
	case demoStateRenderPass_bloom_blurV_4:
		readDFBO = demoState->fbo_dbl_nodepth_4 + 1;
		break;
	case demoStateRenderPass_bloom_bright_8:
		readDFBO = demoState->fbo_dbl_nodepth_8 + 0;
		break;
	case demoStateRenderPass_bloom_blurH_8:
	case demoStateRenderPass_bloom_blurV_8:
		readDFBO = demoState->fbo_dbl_nodepth_8 + 1;
		break;
	case demoStateRenderPass_bloom_blend:
		readDFBO = demoState->fbo_dbl_nodepth + 1;
		break;
	case demoStateRenderPass_shadow:
		readFBO = demoState->fbo_shadowmap;
		break;
	case demoStateRenderPass_fractal:
		readFBO = demoState->fbo_fractal;
		break;
	}

	// select render texture(s) ("page(s)") to use for display
	// select color if FBO has color and either no depth or less than max output
	switch (demoSubMode)
	{
		// single framebuffers
	case demoStateRenderPass_scene:
	case demoStateRenderPass_fractal:
	case demoStateRenderPass_shadow:
		if (readFBO->color && (!readFBO->depthStencil || demoOutput < demoOutputCount - 1))
			a3framebufferBindColorTexture(readFBO, a3tex_unit00, demoOutput);
		else
			a3framebufferBindDepthTexture(readFBO, a3tex_unit00);
		break;

		// double framebuffers
		// some of them need to swap before binding (omit 'break')
	case demoStateRenderPass_bloom_blurH_2:
	case demoStateRenderPass_bloom_blurH_4:
	case demoStateRenderPass_bloom_blurH_8:
		a3framebufferDoubleSwap((a3_FramebufferDouble *)readDFBO);
		// DO NOT 'BREAK'!
	default:
		if (readDFBO->color && (!readDFBO->depthStencil || demoOutput < demoOutputCount - 1))
			a3framebufferDoubleBindColorTexture(readDFBO, a3tex_unit00, demoOutput);
		else
			a3framebufferDoubleBindDepthTexture(readDFBO, a3tex_unit00);
		break;
	}

	
	// final display: activate desired final program and draw FSQ
	if (demoState->additionalPostProcessing) // && demoSubMode != demoStateRenderPass_shadow
	{
		// bind appropriate framebuffer textures
		readFBO = demoState->fbo_scene;
		a3framebufferBindColorTexture(readFBO, a3tex_unit06, 1);
		a3framebufferBindDepthTexture(readFBO, a3tex_unit07);

		// activate additional post-processing program
		//currentDemoProgram = demoState->prog_drawCustom_post;
		currentDemoProgram = demoState->prog_drawJuliaPostProcess;
		a3shaderProgramActivate(currentDemoProgram->program);

		// send uniforms
		pixelSzInv.x = a3recip(readFBO->frameWidth);
		pixelSzInv.y = a3recip(readFBO->frameHeight);
		a3shaderUniformSendFloat(a3unif_vec2, currentDemoProgram->uPixelSz, 1, pixelSzInv.v);
		a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);
	}
	else
	{
		// simply display texture
		currentDemoProgram = demoState->prog_drawTexture;
		a3shaderProgramActivate(currentDemoProgram->program);
	}
	a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, a3identityMat4.mm);
	a3vertexDrawableRenderActive();


	//-------------------------------------------------------------------------
	// OVERLAYS: done after FSQ so they appear over everything else
	//	- disable depth testing
	//	- draw overlays appropriately

	// camera to use for overlay
	switch (demoSubMode)
	{
	//case demoStateRenderPass_shadow:
	//	camera = demoState->projectorLight;
	//	break;
	default:
		camera = demoState->sceneCamera;
		break;
	}

	// hidden volumes
	if (demoState->displayHiddenVolumes)
	{
		currentDemoProgram = demoState->prog_drawColorUnif;
		a3shaderProgramActivate(currentDemoProgram->program);

		// projector point light
		currentDrawable = demoState->draw_pointlight;
		a3real4x4Product(modelViewProjectionMat.m, camera->viewProjectionMat.m, demoState->projectorLight->sceneObject->modelMat.m);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, lightCol[0].v);
		a3vertexDrawableActivateAndRender(currentDrawable);
	}

	// superimpose axes
	// draw coordinate axes in front of everything
	glDisable(GL_DEPTH_TEST);

	currentDemoProgram = demoState->prog_drawColorAttrib;
	a3shaderProgramActivate(currentDemoProgram->program);
	currentDrawable = demoState->draw_axes;
	a3vertexDrawableActivate(currentDrawable);

	// center of world from current viewer
	// also draw other viewer/viewer-like object in scene
	if (demoState->displayWorldAxes)
	{
		modelViewProjectionMat = camera->viewProjectionMat;
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3vertexDrawableRenderActive();
	}

	// individual objects
	if (demoState->displayObjectAxes)
	{
		// scene objects
		for (k = 0, 
			currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject; 
			currentSceneObject <= endSceneObject; 
			++k, ++currentSceneObject)
		{
			a3real4x4Product(modelViewProjectionMat.m, camera->viewProjectionMat.m, currentSceneObject->modelMat.m);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
			a3vertexDrawableRenderActive();
		}

		// other objects
		a3real4x4Product(modelViewProjectionMat.m, camera->viewProjectionMat.m, demoState->projectorLight->sceneObject->modelMat.m);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3vertexDrawableRenderActive();
	}

	// pipeline
	if (demoState->displayPipeline)
	{
		// ****TO-DO (optional): prepare and display pipeline overlay

	}

	glEnable(GL_DEPTH_TEST);
	


	// deactivate things
	a3vertexDrawableDeactivate();
	a3shaderProgramDeactivate();
	a3textureDeactivate(a3tex_unit00);


	// text
	if (demoState->textInit)
	{
		// set viewport to window size and disable depth
		glViewport(0, 0, demoState->windowWidth, demoState->windowHeight);
		glDisable(GL_DEPTH_TEST);

		// choose text render mode
		switch (demoState->textMode)
		{
		case 1:
			a3demo_render_controls(demoState);
			break;
		case 2: 
			a3demo_render_data(demoState);
			break;
		}

		// re-enable depth
		glEnable(GL_DEPTH_TEST);
	}
}


//-----------------------------------------------------------------------------
// RENDER TEXT

// controls
void a3demo_render_controls(const a3_DemoState *demoState)
{
	// display mode info
	const a3byte *modeText[demoStateMaxModes] = {
		"Lighting & post-processing pipeline",
	};
	const a3byte *subModeText[demoStateMaxModes][demoStateMaxSubModes] = {
		{
			"Scene",
			"Phong light volumes",
			"Full composite (skybox, lighting, UI)",
			"Bright pass 1/2",
			"Blur pass H 1/2",
			"Blur pass V 1/2",
			"Bright pass 1/4",
			"Blur pass H 1/4",
			"Blur pass V 1/4",
			"Bright pass 1/8",
			"Blur pass H 1/8",
			"Blur pass V 1/8",
			"Blending (bloom composite)",
			"Shadow map (supplementary)",
			"Fractal",
		},
	};
	const a3byte *outputText[demoStateMaxModes][demoStateMaxSubModes][demoStateMaxOutputModes] = {
		{
			{
				"Color buffer 0 (scene): position g-buffer or forward shading",
				"Color buffer 1 (scene): normal g-buffer",
				"Color buffer 2 (scene): texcoord g-buffer",
				"Depth buffer (scene)",
			},
			{
				"Color buffer 0 (lighting): diffuse shading",
				"Color buffer 1 (lighting): specular shading",
			},
			{
				"Color buffer (compositing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Color buffer (post-processing)",
			},
			{
				"Depth buffer (shadow map)",
			},
		},
	};
	const a3byte *pipelineName[] = {
		"Forward lighting",
		"Deferred shading",
		"Deferred lighting",
	};

	// current modes
	const a3ui32 demoMode = demoState->demoMode, demoPipelineCount = demoState->demoModeCount;
	const a3ui32 demoSubMode = demoState->demoSubMode[demoMode], demoPassCount = demoState->demoSubModeCount[demoMode];
	const a3ui32 demoOutput = demoState->demoOutputMode[demoMode][demoSubMode], demoOutputCount = demoState->demoOutputCount[demoMode][demoSubMode];

	// text color
	const a3vec4 col = { a3realOne, a3realZero, a3realOne, a3realOne };

	// amount to offset text as each line is rendered
	a3f32 textAlign = -0.98f;
	a3f32 textOffset = 1.00f;
	a3f32 textDepth = -1.00f;
	const a3f32 textOffsetDelta = -0.08f;

	// modes
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Demo mode (%u / %u) (',' prev | next '.'): %s", demoMode + 1, demoPipelineCount, modeText[demoMode]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"    Sub-mode (%u / %u) ('<' | '>'): %s", demoSubMode + 1, demoPassCount, subModeText[demoMode][demoSubMode]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"        Output (%u / %u) ('{' | '}'): %s", demoOutput + 1, demoOutputCount, outputText[demoMode][demoSubMode][demoOutput]);

	// toggles
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"ACTIVE CAMERA ('c' | 'v'): %d / %d", demoState->activeCamera + 1, demoStateMaxCount_cameraObject);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"GRID in scene (toggle 'g') %d | SKYBOX backdrop ('b') %d", demoState->displayGrid, demoState->displaySkybox);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"WORLD AXES (toggle 'x') %d | OBJECT AXES ('z') %d", demoState->displayWorldAxes, demoState->displayObjectAxes);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"HIDDEN VOLUMES (toggle 'h') %d ", demoState->displayHiddenVolumes);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"ANIMATION updates (toggle 'm') %d", demoState->updateAnimation);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"ADDITIONAL POST-PROCESSING (toggle 'n') %d", demoState->additionalPostProcessing);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"PREVIEW POST-PROCESSING PASSES (toggle 'r') %d", demoState->previewIntermediatePostProcessing);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"PIPELINE overlay (toggle 'o') %d", demoState->displayPipeline);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"STENCIL TEST (toggle 'i') %d", demoState->stencilTest);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"PIPELINE MODE (toggle 'p') %s", pipelineName[demoState->lightingPipelineMode]);

	if (demoState->lightingPipelineMode != demoStatePipelineMode_deferredLighting)
	{
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    LIGHT COUNT (toggle 'l') %d", demoState->forwardLightCount);
		if (demoState->lightingPipelineMode == demoStatePipelineMode_forward)
			a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
				"PROJECTIVE (toggle 'j') %d | SHADOW MAPPING (toggle 'k') %d", demoState->projectiveTexturing, demoState->shadowMapping);
	}
	else
	{
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    LIGHT COUNT (+/- 'L'/'l') %d", demoState->deferredLightCount);
	}


	//  move down
	textOffset = -0.5f;

	// display controls
	if (a3XboxControlIsConnected(demoState->xcontrol))
	{
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"Xbox controller camera control: ");
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    Left joystick = rotate | Right joystick, triggers = move");
	}
	else
	{
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"Keyboard/mouse camera control: ");
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    Left click & drag = rotate | WASDEQ = move | wheel = zoom");
	}

	// global controls
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Toggle text display:        't' (toggle) | 'T' (alloc/dealloc) ");
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Reload all shader programs: 'P' ****CHECK CONSOLE FOR ERRORS!**** ");
}

// scene data (HUD)
void a3demo_render_data(const a3_DemoState *demoState)
{
	// text color
	const a3vec4 col = { a3realOne, a3realZero, a3realOne, a3realOne };

	// amount to offset text as each line is rendered
	a3f32 textAlign = -0.98f;
	a3f32 textOffset = 1.00f;
	a3f32 textDepth = -1.00f;
	const a3f32 textOffsetDelta = -0.08f;

	// move down
	textOffset = +0.9f;

	// display some data
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"t_render = %+.4lf ", demoState->renderTimer->totalTime);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"dt_render = %.4lf ", demoState->renderTimer->previousTick);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"fps_actual = %.4lf ", __a3recipF64(demoState->renderTimer->previousTick));
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"fps_target = %.4lf ", (a3f64)demoState->renderTimer->ticks / demoState->renderTimer->totalTime);
}


//-----------------------------------------------------------------------------
