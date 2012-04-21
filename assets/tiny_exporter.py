import bpy
import os,subprocess

bl_info = {
    'name': 'Export TinyGame',
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

def write_some_data(ctx, filepath):
	cam = bpy.context.scene.camera
	rnd = bpy.context.scene.render
	d = os.path.dirname(filepath)
	print("Hi world! %s" % filepath)
	
	for y in range(-1, 1):
		for x in range(-1, 1):
			cam.location.x = 16 + x * 32
			cam.location.y = 16 + y * 32
			rnd.filepath = os.path.join(d, "render_%dx%d" % (x, y))
			bpy.ops.render.render(write_still = True)
			print("Writing image at %dx%d" % (x, y))


	return {'FINISHED'}

class ExportTinyGame(bpy.types.Operator, ExportHelper):
	"""Export the TinyGame level"""
	bl_idname = "export.tinygame"
	bl_label = "Export TinyGame"

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
	bpy.utils.register_class(ExportTinyGame)
#	bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
	bpy.utils.unregister_class(ExportTinyGame)
#	bpy.types.INFO_MT_file_export.remove(menu_func_export)


if __name__ == "__main__":
	register()

	# test call
	bpy.ops.export.tinygame('INVOKE_DEFAULT')
