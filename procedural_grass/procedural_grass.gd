@tool
extends MeshInstance3D

# Copyright (c) 2024 Julian Müller (ChaoticByte)


# points of a leaf
const VERTS: Array[Vector3] = [
	Vector3(-0.5, 0.0, -0.5), # 0: left  base back
	Vector3(0.5, 0.0, -0.5),  # 1: right base back
	Vector3(-0.5, 0.5, -0.5), # 2: left  middle back
	Vector3(0.5, 0.5, -0.5),  # 3: right middle back
	Vector3(-0.5, 0.0, 0.5),  # 4: left  base front
	Vector3(0.5, 0.0, 0.5),   # 5: right base front
	Vector3(-0.5, 0.5, 0.5),  # 6: left  middle front
	Vector3(0.5, 0.5, 0.5),   # 7: right middle front
	Vector3(0.0, 1.0, 0.0)    # 8: tip
]


# triangles of a leaf
var TRIS: Array[PackedVector3Array] = [
	([VERTS[2], VERTS[8], VERTS[6]]), # tip left
	([VERTS[8], VERTS[3], VERTS[7]]), # tip right
	([VERTS[6], VERTS[8], VERTS[7]]), # tip front
	([VERTS[2], VERTS[3], VERTS[8]]), # tip back
	([VERTS[0], VERTS[4], VERTS[5]]), # base abc
	([VERTS[0], VERTS[5], VERTS[1]]), # base acd
	([VERTS[6], VERTS[4], VERTS[0]]), # left abc
	([VERTS[6], VERTS[0], VERTS[2]]), # left acd
	([VERTS[3], VERTS[1], VERTS[5]]), # right abc
	([VERTS[3], VERTS[5], VERTS[7]]), # right acd
	([VERTS[7], VERTS[5], VERTS[4]]), # front abc
	([VERTS[7], VERTS[4], VERTS[6]]), # front acd
	([VERTS[2], VERTS[0], VERTS[1]]), # back abc
	([VERTS[2], VERTS[1], VERTS[3]]), # back acd
]


@export_category("Procedural Grass")

@export var click_to_update: bool:
	set(_val):
		generate_grass()

@export var color_base: Color
@export var color_tip: Color

@export var leaf_width: float = 0.03
@export var leaf_height_min: float = 0.1
@export var leaf_height_max: float = 1.0
@export var leaf_height_add: float = 0.0
@export var leaf_height_mult: float = 0.75

@export var offset_mult: float = 0.15

@export var num_leafs: Vector2 = Vector2(40, 40)
@export var leafs_gap: float = 0.1

# I wanna use noise directly instead of an texture
# - If using FastNoiseLite: use a frequency around 0.1 and SimplexSmooth
@export var height_noise_abs: bool = true
@export var height_noise: Noise
# - If using FastNoiseLite: use a frequency around 0.2 and SimplexSmooth
@export var offset_noise: Noise

var st = SurfaceTool.new()
var shader = preload("res://procedural_grass/procedural_grass.gdshader")
var shader_mat = ShaderMaterial.new()
var rotation_rng = RandomNumberGenerator.new()

func generate_leaf(leaf_height: float, offset_xz: Vector2) -> void:
	# create leaf
	var rot = rotation_rng.randf_range(0.0, 2*PI)
	var leaf_size = Vector3(leaf_width, leaf_height, leaf_width)
	var leaf_offset = Vector3(offset_xz.x, 0.0, offset_xz.y)
	for tri_ in TRIS:
		var tri = PackedVector3Array()
		var colors = PackedColorArray()
		for v in tri_:
			tri.append((
					v.rotated(Vector3.UP, rot)
					* leaf_size
				) + leaf_offset
			)
			if v.y < 0:
				colors.append(color_base)
			else:
				colors.append(color_tip)
		st.add_triangle_fan(tri, PackedVector2Array(), colors)

func generate_grass() -> void:
	assert(
		height_noise != null and offset_noise != null,
		"generate_grass was called, but height_noise or offset_noise is null"
	)
	var m = ArrayMesh.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1) # !
	for x in range(-num_leafs.x/2, num_leafs.x/2):
		for y in range(-num_leafs.y/2, num_leafs.y/2):
			var h = height_noise.get_noise_2d(x, y) + leaf_height_add
			if height_noise_abs:
				h = abs(h)
			if h > 0:
				h = clamp(h, leaf_height_min, leaf_height_max)
				var o = Vector2(
					offset_noise.get_noise_2d(x, y),
					offset_noise.get_noise_2d(x + num_leafs.x, y + num_leafs.y) # reuse
				) * offset_mult
				generate_leaf(
					leaf_height_mult * h,
					o + (Vector2(x, y) * leafs_gap)
				)
	st.generate_normals(false)
	st.commit(m)
	# set material
	if shader_mat.shader == null:
		shader_mat.shader = shader
	m.surface_set_material(0, shader_mat)
	# set mesh
	self.set_mesh(m)
