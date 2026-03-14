@tool # Needed so it runs in editor.
extends EditorScenePostImport

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	iterate(scene)
	return scene # Remember to return the imported scene

func iterate(node:Node):
	if node != null:
		if node as MeshInstance3D: create_collision_shape(node)
		
		for child in node.get_children():
			iterate(child)

func create_collision_shape(mesh:MeshInstance3D):
	mesh.create_trimesh_collision()
