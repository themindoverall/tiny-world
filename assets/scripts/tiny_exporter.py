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

def 

class ExportTinyGame(bpy.types.Operator, ExportHelper):
	"""Export the TinyGame level"""
	bl_idname = "export.tinygame"
	bl_label = "Export TinyGame"

	filename_ext = ".json"

	filter_glob = StringProperty(
		default = "*.txt",
		options = {'HIDDEN'}
	)

	@classmethod
	def poll(cls, context):
		return context.active_object is not None

	def execute(self, context):
		return write_some_data(context, self.filepath, self.use_setting)

def menu_func_export(self, context):
	self.layout.operator(ExportTinyGame.bl_idname, text="Export Tiny Game Operator")

def register():
	bpy.utils.register_class(ExportTinyGame)
	bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
	bpy.utils.unregister_class(ExportTinyGame)
	bpy.types.INFO_MT_file_export.remove(menu_func_export)


if __name__ == "__main__":
	register()

	# test call
	bpy.ops.export.some_data('INVOKE_DEFAULT')
