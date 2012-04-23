import bpy, json
import os,subprocess

from math import pi

bl_info = {
    'name': 'Export TinyGame Level',
    'author': 'Chris Serino <themindoverall@gmail.com>',
    'version': (0,1),
    'blender': (2, 6, 2),
    'location': 'File > Export > Export TinyGame (.json)',
    'description': 'Export a JSON representation of the geometry and render PNG chunks',
    'wiki_url': '',
    'tracker_url': '',
    'category': 'Import-Export'
}

from bpy_extras.io_utils import ExportHelper
from bpy.props import StringProperty, IntProperty, BoolProperty, EnumProperty

RESO = 16
CHUNK = 512

def write_some_data(ctx, filepath, min_x, min_y, max_x, max_y):
	cam = bpy.context.scene.camera
	rnd = bpy.context.scene.render
	d = os.path.dirname(filepath)
	f = os.path.splitext(os.path.basename(filepath))[0]

	rnd.resolution_x = CHUNK
	rnd.resolution_y = CHUNK
	cam.data.ortho_scale = CHUNK / RESO
	
	dmin = [min_x, min_y]
	dmax = [max_x, max_y]
	for y in range(dmin[0], dmax[0] + 1):
		for x in range(dmin[0], dmax[0] + 1):
			cam.location.x = RESO + x * CHUNK / RESO
			cam.location.y = RESO + y * CHUNK / RESO
			rnd.filepath = os.path.join(d, "%s_%dx%d" % (f, x, y))
			bpy.ops.render.render(write_still = True)
			print("Wrote image at %dx%d" % (x, y))

	write_json(ctx, filepath, dmin, dmax)

	return {'FINISHED'}

def write_json(context, filepath, dmin, dmax):
	print("running write_json...")
	output_file = open(filepath, 'w')

	objs = [obj for obj in bpy.data.objects if obj.type in ['MESH', 'EMPTY']]
	output_objects = {}
	for obj in objs:
		output = {'name': obj.name}

		pos = obj.location
		output['position'] = [pos.x, pos.y]
		output['rotation'] = obj.rotation_euler[2] * 180 / pi

		#props = dict([(k, obj[k]) for k in obj.keys() if k[0] != '_']) 
		#jobj['props'] = props
		for k in obj.keys():
			if k[0] != '_':
				output[k] = obj[k]

		if obj.type == 'MESH':
			o_vertices = []
			o_faces = []
			for v in obj.data.vertices:
				vert = v.co
				o_vertices.append([vert.x, vert.y]) 
			for f in obj.data.faces:
				o_faces.append([v for v in f.vertices])
			if 'dataType' not in obj:
				output['dataType'] = 'Mesh'
			output['vertices'] = o_vertices
			output['faces'] = o_faces
		elif obj.type == 'EMPTY':
			if 'dataType' not in obj:
				output['dataType'] = 'Point'

		if obj.parent and obj.parent.type == 'CURVE':
			path = []
			for c in obj.parent.data.splines[0].bezier_points:
				path.append([c.co.x, c.co.y])
			output['path'] = path
			pos = obj.parent.location
			output['position'] = [pos.x, pos.y]

		output_objects[output['name']] = output;

	json.dump({
		'name': bpy.context.scene.name,
		'bounds': [dmin[0], dmin[1], dmax[0], dmax[1]],
		'dataType': 'LevelData',
		'objects': output_objects}, output_file, indent=2)
	output_file.close()

class ExportTinyLevel(bpy.types.Operator, ExportHelper):
	"""Export the TinyGame level"""
	bl_idname = "export.tinylevel"
	bl_label = "Export TinyGame Level"

	filename_ext = ".json"

	filter_glob = StringProperty(
		default = "*.json",
		options = {'HIDDEN'}
	)

	min_x = bpy.props.IntProperty(
		name = "Min X",
		default = -1
	)

	min_y = bpy.props.IntProperty(
		name = "Min Y",
		default = -1
	)

	max_x = bpy.props.IntProperty(
		name = "Max X",
		default = 0
	)	

	max_y = bpy.props.IntProperty(
		name = "Max Y",
		default = 0
	)

	@classmethod
	def poll(cls, context):
		return context.active_object is not None

	def execute(self, context):
		return write_some_data(context, self.filepath, self.min_x, self.min_y, self.max_x, self.max_y)

#def menu_func_export(self, context):
#	self.layout.operator(ExportTinyGame.bl_idname, text="Export Tiny Game Operator")

def register():
	bpy.utils.register_class(ExportTinyLevel)
#	bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
	bpy.utils.unregister_class(ExportTinyLevel)
#	bpy.types.INFO_MT_file_export.remove(menu_func_export)


if __name__ == "__main__":
	register()

	# test call
	#bpy.ops.export.tinylevel('INVOKE_DEFAULT')
