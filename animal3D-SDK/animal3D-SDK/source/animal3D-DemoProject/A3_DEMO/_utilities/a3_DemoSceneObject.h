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
	
	a3_DemoSceneObject.h
	Example of demo utility header file.
*/

#ifndef __ANIMAL3D_DEMOSCENEOBJECT_H
#define __ANIMAL3D_DEMOSCENEOBJECT_H


// math library
#include "animal3D-A3DM/animal3D-A3DM.h"
#include "animal3D/a3/a3types_integer.h"
#include "animal3D/a3utility/a3_Stream.h"


//-----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C"
{
#else	// !__cplusplus
	typedef struct a3_DemoSceneObject	a3_DemoSceneObject;
	typedef struct a3_DemoCamera		a3_DemoCamera;
	typedef struct a3_DemoPointLight	a3_DemoPointLight;
	typedef struct a3_DemoSceneHierarchy		a3_DemoSceneHierarchy;
	typedef struct a3_DemoSceneHierarchyNode	a3_DemoSceneHierarchyNode;
#endif	// __cplusplus

	
//-----------------------------------------------------------------------------

	// A3: Node name string max length (including null terminator).
	enum a3_HierarchyDemoSceneNodeNameSize
	{
		a3DemoScenenode_nameSize = 4
	};


	// A3: Hierarchy node, a single link in a hierarchy tree.
	//	member name: name of node (defaults to a3node_[index])
	//	member index: index of node in hierarchy
	//	member parentIndex: index of parent in hierarchy (-1 if root)
	struct a3_DemoSceneHierarchyNode
	{
		a3byte name[a3DemoScenenode_nameSize];
		a3i32 index;
		a3i32 parentIndex;
	};


	// A3: Hierarchy node container, the hierarchy itself.
	//	member nodes: array of nodes (null if unused)
	//	member numNodes: maximum number of nodes in hierarchy (zero if unused)
	struct a3_DemoSceneHierarchy
	{
		a3_DemoSceneHierarchyNode *nodes;
		a3ui32 numNodes;
	};

//-----------------------------------------------------------------------------
	// general scene objects
	struct a3_DemoSceneObject
	{
		a3mat4 modelMat;	// model matrix: transform relative to scene
		a3mat4 modelMatInv;	// inverse model matrix: scene relative to this
		a3vec3 euler;		// euler angles for direct rotation control
		a3vec3 position;	// scene position for direct control
		a3vec3 scale;		// scale (not accounted for in update)
		a3i32 scaleMode;		// 0 = off; 1 = uniform; other = non-uniform (nightmare)
	};

	// camera/viewer
	struct a3_DemoCamera
	{
		a3_DemoSceneObject *sceneObject;	// pointer to scene object
		a3mat4 projectionMat;				// projection matrix
		a3mat4 projectionMatInv;			// inverse projection matrix
		a3mat4 viewProjectionMat;			// concatenation of view-projection
		a3boolean perspective;				// perspective or orthographic
		a3real fovy;						// persp: vert field of view/ortho: vert size
		a3real aspect;						// aspect ratio
		a3real znear, zfar;					// near and far clipping planes
		a3real ctrlMoveSpeed;				// how fast controlled camera moves
		a3real ctrlRotateSpeed;				// control rotate speed (degrees)
		a3real ctrlZoomSpeed;				// control zoom speed (degrees)
	};

	// simple point light
	struct a3_DemoPointLight
	{
		a3vec4 worldPos;					// position in world space
		a3vec4 viewPos;						// position in viewer space
		a3vec4 color;						// RGB color with padding
		a3real radius;						// radius (distance of effect from center)
		a3real radiusInvSq;					// radius inverse squared (attenuation factor)
		a3real pad[2];						// padding
	};


//-----------------------------------------------------------------------------

	// scene object initializers and updates
	inline void a3demo_initSceneObject(a3_DemoSceneObject *sceneObject);
	inline void a3demo_updateSceneObject(a3_DemoSceneObject *sceneObject, const a3boolean useZYX);
	inline a3i32 a3demo_rotateSceneObject(a3_DemoSceneObject *sceneObject, const a3real speed, const a3real deltaX, const a3real deltaY, const a3real deltaZ);
	inline a3i32 a3demo_moveSceneObject(a3_DemoSceneObject *sceneObject, const a3real speed, const a3real deltaX, const a3real deltaY, const a3real deltaZ);

	inline void a3demo_setCameraSceneObject(a3_DemoCamera *camera, a3_DemoSceneObject *sceneObject);
	inline void a3demo_initCamera(a3_DemoCamera *camera);
	inline void a3demo_updateCameraProjection(a3_DemoCamera *camera);
	inline void a3demo_updateCameraViewProjection(a3_DemoCamera *camera);


//-----------------------------------------------------------------------------
	// A3: Allocate hierarchy with maximum node count, names optional.
	//	param hierarchy_out: non-null pointer to uninitialized hierarchy
	//	param numNodes: non-zero node count to initialize
	//	param names_opt: optional pointer to a list of names to set immediately
	//	return: numNodes if success
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateCreate(a3_DemoSceneHierarchy *hierarchy_out, const a3ui32 numNodes, const a3byte **names_opt);

	// A3: Set a hierarchy node's info; overwrites existing node at index.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param index: non-negative index of node in hierarchy
	//	param parentIndex: index of parent node in hierarchy; -1 if this node 
	//		is a root node; *parent index is LESS THAN node index!!!*
	//	param name: name of node
	//	return: index if success
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateSetNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 index, const a3i32 parentIndex, const a3byte name[a3DemoScenenode_nameSize]);

	// A3: Get node index by name.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param name: name to search for in hierarchy
	//	return: index if success
	//	return: -1 if invalid params or node not found
	inline a3i32 a3hierarchyDemoStateGetNodeIndex(const a3_DemoSceneHierarchy *hierarchy, const a3byte name[a3DemoScenenode_nameSize]);
	// A3: Check if node is a parent of another.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param parentIndex: non-negative possible parent node index
	//	param otherIndex: non-negative index of node to check for relationship
	//	return: boolean, 1 if the node is a parent of the other; 0 if not
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateIsParentNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 parentIndex, const a3ui32 otherIndex);

	// A3: Check if a node is a child of another.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param childIndex: non-negative possible child node index
	//	param otherIndex: non-negative index of node to check for relationship
	//	return: boolean, 1 if the node is a child of the other; 0 if not
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateIsChildNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 childIndex, const a3ui32 otherIndex);

	// A3: Check if a node is a sibling of another.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param siblingIndex: non-negative possible sibling node index
	//	param otherIndex: non-negative index of node to check for relationship
	//	return: boolean, 1 if the node is a parent of the other; 0 if not
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateIsSiblingNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 siblingIndex, const a3ui32 otherIndex);

	// A3: Check if a node is an ancestor of another.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param ancestorIndex: non-negative possible ancestor node index
	//	param otherIndex: non-negative index of node to check for relationship
	//	return: boolean, 1 if the node is a parent of the other; 0 if not
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateIsAncestorNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 ancestorIndex, const a3ui32 otherIndex);

	// A3: Check if a node is a descendant of another.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param descendantIndex: non-negative possible descendant node index
	//	param otherIndex: non-negative index of node to check for relationship
	//	return: boolean, 1 if the node is a parent of the other; 0 if not
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateIsDescendantNode(const a3_DemoSceneHierarchy *hierarchy, const a3ui32 descendantIndex, const a3ui32 otherIndex);
	// A3: Store hierarchy in string.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	param str: non-null byte array to stream into
	//	return: number of bytes copied if success
	//	return: 0 if failed
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateCopyToString(const a3_DemoSceneHierarchy *hierarchy, a3byte *str);

	// A3: Read hierarchy from string.
	//	param hierarchy: non-null pointer to unused hierarchy
	//	param str: non-null byte array to stream from
	//	return: number of bytes copied if success
	//	return: 0 if failed
	//	return: -1 if invalid params
	inline a3i32 a3hierarchyDemoStateCopyFromString(a3_DemoSceneHierarchy *hierarchy, const a3byte *str);

	// A3: Get hierarchy stream size.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	return: number of bytes required to store hierarchy in string
	//	return: -1 if invalid param
	inline a3i32 a3hierarchyDemoStateGetStringSize(const a3_DemoSceneHierarchy *hierarchy);

	// A3: Release hierarchy.
	//	param hierarchy: non-null pointer to initialized hierarchy
	//	return: 1 if success
	//	return: -1 if invalid param
	inline a3i32 a3hierarchyDemoStateRelease(a3_DemoSceneHierarchy *hierarchy);

#ifdef __cplusplus
}
#endif	// __cplusplus


#endif	// !__ANIMAL3D_DEMOSCENEOBJECT_H