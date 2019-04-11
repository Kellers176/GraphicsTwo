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
	
	a3_DemoSceneObject.c
	Example of demo utility source file.
*/

#include "a3_DemoSceneObject.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-----------------------------------------------------------------------------

// scene object setup and manipulation
extern inline void a3demo_initSceneObject(a3_DemoSceneObject *sceneObject)
{
	a3real4x4SetIdentity(sceneObject->modelMat.m);
	a3real4x4SetIdentity(sceneObject->modelMatInv.m);
	a3real3Set(sceneObject->euler.v, a3realZero, a3realZero, a3realZero);
	a3real3Set(sceneObject->position.v, a3realZero, a3realZero, a3realZero);
}

extern inline void a3demo_updateSceneObject(a3_DemoSceneObject *sceneObject, const a3boolean useZYX)
{
	if (useZYX)
		a3real4x4SetRotateZYX(sceneObject->modelMat.m, sceneObject->euler.x, sceneObject->euler.y, sceneObject->euler.z);
	else
		a3real4x4SetRotateXYZ(sceneObject->modelMat.m, sceneObject->euler.x, sceneObject->euler.y, sceneObject->euler.z);
	sceneObject->modelMat.v3.xyz = sceneObject->position;
	a3real4x4TransformInverseIgnoreScale(sceneObject->modelMatInv.m, sceneObject->modelMat.m);
}

extern inline a3i32 a3demo_rotateSceneObject(a3_DemoSceneObject *sceneObject, const a3real speed, const a3real deltaX, const a3real deltaY, const a3real deltaZ)
{
	if (speed && (deltaX || deltaY || deltaZ))
	{
		// validate angles so they don't get zero'd out (trig functions have a limit)
		sceneObject->euler.x = a3trigValid_sind(sceneObject->euler.x + speed * deltaX);
		sceneObject->euler.y = a3trigValid_sind(sceneObject->euler.y + speed * deltaY);
		sceneObject->euler.z = a3trigValid_sind(sceneObject->euler.z + speed * deltaZ);

		return 1;
	}
	return 0;
}

extern inline a3i32 a3demo_moveSceneObject(a3_DemoSceneObject *sceneObject, const a3real speed, const a3real deltaX, const a3real deltaY, const a3real deltaZ)
{
	if (speed && (deltaX || deltaY || deltaZ))
	{
		a3real3 delta[3];
		a3real3ProductS(delta[0], sceneObject->modelMat.m[0], deltaX);	// account for orientation of object
		a3real3ProductS(delta[1], sceneObject->modelMat.m[1], deltaY);
		a3real3ProductS(delta[2], sceneObject->modelMat.m[2], deltaZ);
		a3real3Add(delta[0], delta[1]);									// add the 3 deltas together
		a3real3Add(delta[0], delta[2]);
		a3real3MulS(delta[0], speed * a3real3LengthInverse(delta[0]));	// normalize and scale by speed
		a3real3Add(sceneObject->position.v, delta[0]);					// add delta to current

		return 1;
	}
	return 0;
}


extern inline void a3demo_setCameraSceneObject(a3_DemoCamera *camera, a3_DemoSceneObject *sceneObject)
{
	camera->sceneObject = sceneObject;
}

extern inline void a3demo_initCamera(a3_DemoCamera *camera)
{
	a3real4x4SetIdentity(camera->projectionMat.m);
	a3real4x4SetIdentity(camera->projectionMatInv.m);
	a3real4x4SetReal4x4(camera->viewProjectionMat.m, camera->sceneObject->modelMatInv.m);
	camera->perspective = a3false;
	camera->fovy = a3realTwo;
	camera->aspect = a3realOne;
	camera->znear = -a3realOne;
	camera->zfar = +a3realOne;
	camera->ctrlMoveSpeed = a3realZero;
	camera->ctrlRotateSpeed = a3realZero;
	camera->ctrlZoomSpeed = a3realZero;
}

extern inline void a3demo_updateCameraProjection(a3_DemoCamera *camera)
{
	if (camera->perspective)
		a3real4x4MakePerspectiveProjection(camera->projectionMat.m, camera->projectionMatInv.m,
			camera->fovy, camera->aspect, camera->znear, camera->zfar);
	else
		a3real4x4MakeOrthographicProjection(camera->projectionMat.m, camera->projectionMatInv.m,
			camera->fovy * camera->aspect, camera->fovy, camera->znear, camera->zfar);
}

extern inline void a3demo_updateCameraViewProjection(a3_DemoCamera *camera)
{
	a3real4x4Product(camera->viewProjectionMat.m, camera->projectionMat.m, camera->sceneObject->modelMatInv.m);
}
//-------------------------------------------------------------------------------
//this is where the hierarchy stuff will go :)


inline a3ret a3hierarchyDemoStateInternalGetIndex(const a3_DemoSceneHierarchy *hierarchy, const a3byte name[a3DemoScenenode_nameSize])
{
	a3ui32 i;
	for (i = 0; i < hierarchy->numNodes; ++i)
		if (!strncmp(hierarchy->nodes[i].name, name, a3DemoScenenode_nameSize))
			return i;
	return -1;
}

inline void a3hierarchyDemoStateInternalSetNode(a3_DemoSceneHierarchyNode *node, const a3ui32 index, const a3i32 parentIndex, const a3byte name[a3DemoScenenode_nameSize])
{
	strncpy(node->name, name, a3DemoScenenode_nameSize);
	node->name[a3DemoScenenode_nameSize - 1] = 0;
	node->index = index;
	node->parentIndex = parentIndex;
}

extern inline a3i32 a3hierarchyDemoStateCreate(a3_DemoSceneHierarchy *hierarchy_out, const a3ui32 numNodes, const a3byte **names_opt)
{
	if (hierarchy_out && numNodes)
	{
		if (!hierarchy_out->nodes)
		{
			const a3ui32 dataSize = sizeof(a3_DemoSceneHierarchyNode) * numNodes;
			a3ui32 i;
			const a3byte *tmpName;
			hierarchy_out->nodes = (a3_DemoSceneHierarchyNode *)malloc(dataSize);
			memset(hierarchy_out->nodes, 0, dataSize);
			hierarchy_out->numNodes = numNodes;
			if (names_opt)
			{
				for (i = 0; i < numNodes; ++i)
					if (tmpName = *(names_opt + i))
					{
						if (a3hierarchyDemoStateInternalGetIndex(hierarchy_out, tmpName) < 0)
						{
							strncpy(hierarchy_out->nodes[i].name, tmpName, a3DemoScenenode_nameSize);
							hierarchy_out->nodes[i].name[a3DemoScenenode_nameSize - 1] = 0;
						}
						else
							printf("\n A3 Warning: Ignoring duplicate name string passed to hierarchy allocator.");
					}
					else
						printf("\n A3 Warning: Ignoring invalid name string passed to hierarchy allocator.");
			}
			return numNodes;
		}
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateSaveBinary(const a3_DemoSceneHierarchy *hierarchy, const a3_FileStream *fileStream)
{
	FILE *fp;
	a3ui32 ret = 0;
	if (hierarchy && fileStream)
	{
		if (hierarchy->nodes)
		{
			fp = fileStream->stream;
			if (fp)
			{
				ret += (a3ui32)fwrite(&hierarchy->numNodes, 1, sizeof(a3ui32), fp);
				ret += (a3ui32)fwrite(hierarchy->nodes, 1, sizeof(a3_DemoSceneHierarchyNode) * hierarchy->numNodes, fp);
			}
			return ret;
		}
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateLoadBinary(a3_DemoSceneHierarchy *hierarchy, const a3_FileStream *fileStream)
{
	FILE *fp;
	a3ui32 ret = 0;
	a3ui32 dataSize = 0;
	if (hierarchy && fileStream)
	{
		if (!hierarchy->nodes)
		{
			fp = fileStream->stream;
			if (fp)
			{
				ret += (a3ui32)fread(&hierarchy->numNodes, 1, sizeof(a3ui32), fp);

				dataSize = sizeof(a3_DemoSceneHierarchyNode) * hierarchy->numNodes;
				hierarchy->nodes = (a3_DemoSceneHierarchyNode *)malloc(dataSize);
				ret += (a3ui32)fread(hierarchy->nodes, 1, dataSize, fp);
			}
			return ret;
		}
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateSetNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 index, const a3i32 parentIndex, const a3byte name[a3DemoScenenode_nameSize])
{
	a3_DemoSceneHierarchyNode *node;
	if (hierarchy)
	{
		if (hierarchy->nodes && index < hierarchy->numNodes)
		{
			if ((a3i32)index > parentIndex)
			{
				node = hierarchy->nodes + index;
				a3hierarchyDemoStateInternalSetNode(node, index, parentIndex, name);
				return index;
			}
			else
				printf("\n A3 ERROR: Hierarchy node\'s index must be greater than its parent\'s.");
		}
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateGetNodeIndex(const a3_DemoSceneHierarchy *hierarchy, const a3byte name[a3DemoScenenode_nameSize])
{
	if (hierarchy)
		if (hierarchy->nodes)
			return a3hierarchyDemoStateInternalGetIndex(hierarchy, name);
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateIsParentNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 parentIndex, const a3ui32 otherIndex)
{
	if (hierarchy && hierarchy->nodes && otherIndex < hierarchy->numNodes && parentIndex < hierarchy->numNodes)
		return (hierarchy->nodes[otherIndex].parentIndex == parentIndex);
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateIsChildNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 childIndex, const a3ui32 otherIndex)
{
	return a3hierarchyDemoStateIsParentNode(hierarchy, otherIndex, childIndex);
}

extern inline a3i32 a3hierarchyDemoStateIsSiblingNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 siblingIndex, const a3ui32 otherIndex)
{
	if (hierarchy && hierarchy->nodes && otherIndex < hierarchy->numNodes && siblingIndex < hierarchy->numNodes)
		return (hierarchy->nodes[otherIndex].parentIndex == hierarchy->nodes[siblingIndex].parentIndex);
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateIsAncestorNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 ancestorIndex, const a3ui32 otherIndex)
{
	a3ui32 i = otherIndex;
	if (hierarchy && hierarchy->nodes && otherIndex < hierarchy->numNodes && ancestorIndex < hierarchy->numNodes)
	{
		while (i > ancestorIndex)
			i = hierarchy->nodes[i].parentIndex;
		return (i == ancestorIndex);
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateIsDescendantNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 descendantIndex, const a3ui32 otherIndex)
{
	return a3hierarchyDemoStateIsAncestorNode(hierarchy, otherIndex, descendantIndex);
}

extern inline a3i32 a3hierarchyDemoStateCopyToString(const a3_DemoSceneHierarchy *hierarchy, a3byte *str)
{
	const a3byte *const start = str;
	if (hierarchy && str)
	{
		if (hierarchy->nodes)
		{
			str = (a3byte *)((a3ui32 *)memcpy(str, &hierarchy->numNodes, sizeof(a3ui32)) + 1);
			str = (a3byte *)((a3_DemoSceneHierarchy *)memcpy(str, hierarchy->nodes, sizeof(a3_DemoSceneHierarchy) * hierarchy->numNodes) + hierarchy->numNodes);

			// done
			return (a3i32)(str - start);
		}
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateCopyFromString(a3_DemoSceneHierarchy *hierarchy, const a3byte *str)
{
	const a3byte *const start = str;
	a3ui32 dataSize = 0;
	if (hierarchy && str)
	{
		if (!hierarchy->nodes)
		{
			memcpy(&hierarchy->numNodes, str, sizeof(a3ui32));
			str += sizeof(a3ui32);

			dataSize = sizeof(a3_DemoSceneHierarchy) * hierarchy->numNodes;
			hierarchy->nodes = (a3_DemoSceneHierarchyNode *)malloc(dataSize);
			memcpy(hierarchy->nodes, str, dataSize);
			str += dataSize;

			// done
			return (a3i32)(str - start);
		}
	}
	return -1;

}

extern inline a3i32 a3hierarchyDemoStateGetStringSize(const a3_DemoSceneHierarchy *hierarchy)
{
	if (hierarchy)
	{
		if (hierarchy->nodes)
		{
			const a3ui32 dataSize
				= sizeof(a3ui32)
				+ sizeof(a3_DemoSceneHierarchy) * hierarchy->numNodes;
			return dataSize;
		}
	}
	return -1;
}

extern inline a3i32 a3hierarchyDemoStateRelease(a3_DemoSceneHierarchy *hierarchy)
{
	if (hierarchy)
	{
		if (hierarchy->nodes)
		{
			free(hierarchy->nodes);
			hierarchy->nodes = 0;
			hierarchy->numNodes = 0;
			return 1;
		}
	}
	return -1;
}

//-----------------------------------------------------------------------------
