import bpy
import os,subprocess

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
from bpy.props import StringProperty, BoolProperty, EnumProperty

RESO = 16
CHUNK = 512

def write_some_data(ctx, filepath):
	cam = bpy.context.scene.camera
	rnd = bpy.context.scene.render
	d = os.path.dirname(filepath)
	f = os.path.splitext(os.path.basename(filepath))[0]

	rnd.resolution_x = CHUNK
	rnd.resolution_y = CHUNK
	cam.data.ortho_scale = CHUNK / RESO
	
	for y in range(-1, 1):
		for x in range(-1, 1):
			cam.location.x = RESO + x * CHUNK / RESO
			cam.location.y = RESO + y * CHUNK / RESO
			rnd.filepath = os.path.join(d, "%s_%dx%d" % (f, x, y))
			bpy.ops.render.render(write_still = True)
			print("Wrote image at %dx%d" % (x, y))

	for 

	return {'FINISHED'}

class ExportTinyLevel(bpy.types.Operator, ExportHelper):
	"""Export the TinyGame level"""
	bl_idname = "export.tinylevel"
	bl_label = "Export TinyGame Level"

	filename_ext = ".json"

	filter_glob = StringProperty(
		default = "*.json",
		options = {'HIDDEN'}
	)

	@classmethod
	def poll(cls, context):
		return context.active_object is not None

	def execute(self, context):
		return write_some_data(context, self.filepath)

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
	bpy.ops.export.tinylevel('INVOKE_DEFAULT')
