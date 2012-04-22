import bpy
import os,subprocess

from bpy_extras.io_utils import ExportHelper
from bpy.props import StringProperty, BoolProperty, EnumProperty
from math import fabs

RESO = 16

def write_some_data(ctx, filepath):
	cam = bpy.context.scene.camera
	rnd = bpy.context.scene.render
	obj = bpy.context.active_object
	verts = obj.data.vertices
	d = os.path.dirname(filepath)
	print("Hi world! %s" % filepath)
	aabb = [100000, 100000, -100000, -100000]
	diff = [0, 0]
	for v in verts:
		if fabs(v.co.x) > diff[0]:
			diff[0] = fabs(v.co.x)
		if fabs(v.co.y) > diff[1]:
			diff[1] = fabs(v.co.y)

		if not aabb[0] or aabb[0] > v.co.x:
			aabb[0] = v.co.x
		if not aabb[1] or aabb[1] > v.co.y:
			aabb[1] = v.co.y
		if not aabb[2] or aabb[2] < v.co.x:
			aabb[2] = v.co.x
		if not aabb[3] or aabb[3] < v.co.y:
			aabb[3] = v.co.y

	bb = [aabb[0], aabb[1], aabb[2] - aabb[0], aabb[3] - aabb[1]]
	print(bb)
	rnd.resolution_x = diff[0] * 2 * RESO
	rnd.resolution_y = diff[1] * 2 * RESO
	cam.location.x = obj.location.x
	cam.location.y = obj.location.y
	cam.data.ortho_scale = diff[0] * 2
	rnd.filepath = filepath
	bpy.ops.object.hide_render_set(unselected = True)
	bpy.ops.render.render(write_still = True)

	return {'FINISHED'}

class ExportTinyEntity(bpy.types.Operator, ExportHelper):
	"""Export the TinyGame entity"""
	bl_idname = "export.tinyentity"
	bl_label = "Export TinyGame Entity"

	filename_ext = ".png"

	filter_glob = StringProperty(
		default = "*.png",
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
	bpy.utils.register_class(ExportTinyEntity)
#	bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
	bpy.utils.unregister_class(ExportTinyEntity)
#	bpy.types.INFO_MT_file_export.remove(menu_func_export)


if __name__ == "__main__":
	register()

	# test call
	#bpy.ops.export.tinyentity('INVOKE_DEFAULT')