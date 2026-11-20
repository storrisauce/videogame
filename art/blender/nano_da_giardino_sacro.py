"""Prova di illustrazione: Nano da Giardino Sacro (struttura del Cratere).

Uso: /opt/blender-venv/bin/python -I art/blender/nano_da_giardino_sacro.py <output.png>
Rendering senza schermo: Cycles su CPU, contorni cartoon con Freestyle, palette del DNA tematico.
"""
import math
import sys

import bpy
from mathutils import Vector

OUT = sys.argv[-1] if sys.argv[-1].endswith(".png") else "/tmp/nano.png"

# Palette del DNA tematico
VERDE_RADIO = (0.25, 1.0, 0.15)
RUGGINE = (0.55, 0.22, 0.08)
FANGO = (0.23, 0.15, 0.08)
GIALLO_ALLARME = (1.0, 0.78, 0.05)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene


def mat(name, color, rough=0.75, metal=0.0, emit=None, strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*emit, 1)
        b.inputs["Emission Strength"].default_value = strength
    return m


def finish(m, smooth=True):
    o = bpy.context.object
    o.data.materials.append(m)
    if smooth and o.type == "MESH":
        bpy.ops.object.shade_smooth()
    return o


M_FANGO = mat("fango", FANGO, rough=0.95)
M_TUNICA = mat("tunica", (0.08, 0.25, 0.75))
M_PELLE = mat("pelle", (0.95, 0.62, 0.48))
M_BARBA = mat("barba", (0.95, 0.95, 0.92))
M_CAPPELLO = mat("cappello", (0.85, 0.08, 0.06))
M_NASO = mat("naso", (0.95, 0.4, 0.4))
M_NERO = mat("nero", (0.02, 0.02, 0.02), rough=0.3)
M_GLOW = mat("glow", (0.1, 0.6, 0.05), emit=(0.2, 0.9, 0.05), strength=3.0)
M_POZZA = mat("pozza", (0.1, 0.4, 0.05), rough=0.1, emit=(0.2, 0.9, 0.05), strength=1.2)
M_LATTA = mat("latta", (0.7, 0.7, 0.72), rough=0.3, metal=1.0)
M_ETICHETTA = mat("etichetta", RUGGINE)
M_LEGNO = mat("legno", (0.45, 0.3, 0.15), rough=0.9)
M_CARTELLO = mat("cartello", (0.88, 0.8, 0.6), rough=0.95)
M_SCRITTA = mat("scritta", (0.05, 0.03, 0.02))

# Terreno crepato e pozza radioattiva
bpy.ops.mesh.primitive_cylinder_add(radius=1.7, depth=0.2, location=(0, 0, -0.1), vertices=64)
finish(M_FANGO)
bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=0.02, location=(-0.7, -0.5, 0.005), vertices=48)
o = finish(M_POZZA)
o.scale = (1.3, 0.8, 1)

# Corpo del nano
bpy.ops.mesh.primitive_cone_add(radius1=0.42, radius2=0.24, depth=0.7, location=(0, 0, 0.35), vertices=48)
finish(M_TUNICA)
bpy.ops.mesh.primitive_cylinder_add(radius=0.33, depth=0.07, location=(0, 0, 0.42), vertices=48)
finish(M_NERO)
bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0, -0.33, 0.42))
finish(mat("fibbia", GIALLO_ALLARME, metal=1.0, rough=0.3), smooth=False)

# Testa, barba, naso
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.26, location=(0, 0, 0.86), segments=48, ring_count=24)
finish(M_PELLE)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(0, -0.13, 0.62), segments=48, ring_count=24)
o = finish(M_BARBA)
o.scale = (0.95, 0.6, 1.25)
bpy.ops.mesh.primitive_cone_add(radius1=0.16, radius2=0.0, depth=0.3, location=(0, -0.2, 0.4), vertices=48)
o = finish(M_BARBA)
o.rotation_euler = (math.pi - 0.2, 0, 0)
o.scale = (1, 0.6, 1)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.075, location=(0, -0.27, 0.86))
finish(M_NASO)

# Occhi: due normali e un terzo occhio radioattivo in fronte
for x in (-0.095, 0.095):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.032, location=(x, -0.225, 0.95))
    finish(M_NERO)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.05, location=(0, -0.21, 1.04))
finish(M_GLOW)

# Cappello a punta, un po' storto
bpy.ops.mesh.primitive_cone_add(radius1=0.28, radius2=0.0, depth=0.75, location=(0.04, 0.02, 1.38), vertices=48)
o = finish(M_CAPPELLO)
o.rotation_euler = (0.12, 0.18, 0)

# Aureola sacra fosforescente
bpy.ops.mesh.primitive_torus_add(major_radius=0.3, minor_radius=0.025, location=(0.12, 0.05, 1.86))
o = finish(M_GLOW)
o.rotation_euler = (0.35, 0.2, 0)

# Offerte: scatolette di fagioli
for i, (x, y) in enumerate([(-0.45, -0.75), (-0.15, -0.85), (0.2, -0.8), (0.5, -0.65)]):
    bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.16, location=(x, y, 0.08), vertices=32)
    o = finish(M_LATTA)
    o.rotation_euler = (0, 0, i * 0.7)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.102, depth=0.08, location=(x, y, 0.08), vertices=32)
    finish(M_ETICHETTA)
# una scatoletta rovesciata, per il caos
bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.16, location=(0.8, -0.35, 0.1), vertices=32)
o = finish(M_LATTA)
o.rotation_euler = (0, math.pi / 2, 0.6)

# Cartello scritto a mano
bpy.ops.mesh.primitive_cylinder_add(radius=0.025, depth=1.1, location=(0.85, 0.25, 0.55))
o = finish(M_LEGNO)
o.rotation_euler = (0, 0.08, 0)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.85, 0.2, 1.05))
o = finish(M_CARTELLO, smooth=False)
o.scale = (0.62, 0.04, 0.24)
o.rotation_euler = (0, 0.08, -0.1)
bpy.ops.object.text_add(location=(0.85, 0.155, 1.01))
t = bpy.context.object
t.data.body = "PREGATELO"
t.data.align_x = "CENTER"
t.data.align_y = "CENTER"
t.data.size = 0.1
t.data.extrude = 0.005
t.rotation_euler = (math.pi / 2, 0.08, -0.1)
t.data.materials.append(M_SCRITTA)

# Contorni cartoon: guscio invertito (Freestyle non funziona senza schermo)
M_CONTORNO = bpy.data.materials.new("contorno")
M_CONTORNO.use_nodes = True
nt = M_CONTORNO.node_tree
nt.nodes.clear()
out = nt.nodes.new("ShaderNodeOutputMaterial")
mix = nt.nodes.new("ShaderNodeMixShader")
geo = nt.nodes.new("ShaderNodeNewGeometry")
black = nt.nodes.new("ShaderNodeEmission")
black.inputs["Color"].default_value = (0.03, 0.02, 0.01, 1)
transp = nt.nodes.new("ShaderNodeBsdfTransparent")
lp = nt.nodes.new("ShaderNodeLightPath")
mul = nt.nodes.new("ShaderNodeMath")
mul.operation = "MULTIPLY"
inv = nt.nodes.new("ShaderNodeMath")
inv.operation = "SUBTRACT"
inv.inputs[0].default_value = 1.0
nt.links.new(geo.outputs["Backfacing"], inv.inputs[1])          # 1 = faccia rivolta verso la camera
nt.links.new(inv.outputs["Value"], mul.inputs[0])
nt.links.new(lp.outputs["Is Camera Ray"], mul.inputs[1])         # solo la camera vede il contorno, la luce no
nt.links.new(mul.outputs["Value"], mix.inputs["Fac"])
nt.links.new(transp.outputs["BSDF"], mix.inputs[1])
nt.links.new(black.outputs["Emission"], mix.inputs[2])
nt.links.new(mix.outputs["Shader"], out.inputs["Surface"])
for o in list(scene.objects):
    if o.type in ("MESH", "FONT") and o.data.materials and o.data.materials[0] not in (M_POZZA,):
        if o.type == "FONT":
            continue
        o.data.materials.append(M_CONTORNO)
        sol = o.modifiers.new("contorno", "SOLIDIFY")
        sol.thickness = 0.022
        sol.offset = 1.0
        sol.use_flip_normals = True
        sol.material_offset = len(o.data.materials) - 1
        sol.use_rim = False

# Cielo giallo-verde
world = bpy.data.worlds.new("cielo")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes["Background"]
bg.inputs["Color"].default_value = (0.62, 0.7, 0.22, 1)
bg.inputs["Strength"].default_value = 0.9

# Luci: sole caldo e riempimento verde
bpy.ops.object.light_add(type="SUN", location=(3, -3, 5))
sun = bpy.context.object
sun.data.energy = 3.5
sun.data.color = (1.0, 0.92, 0.7)
sun.rotation_euler = (math.radians(50), 0, math.radians(35))
bpy.ops.object.light_add(type="AREA", location=(-2.5, -1.5, 2))
fill = bpy.context.object
fill.data.energy = 120
fill.data.color = (0.6, 1.0, 0.5)
fill.data.size = 3
fill.rotation_euler = (math.radians(60), 0, math.radians(-60))

# Camera puntata sul nano
bpy.ops.object.camera_add(location=(2.0, -3.6, 1.7))
cam = bpy.context.object
direction = Vector((0.05, 0, 0.8)) - cam.location
cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
cam.data.lens = 45
scene.camera = cam

# Rendering
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 600
scene.render.resolution_y = 800
scene.view_settings.view_transform = "Standard"
scene.render.filepath = OUT
bpy.ops.render.render(write_still=True)
print("Salvato:", OUT)
