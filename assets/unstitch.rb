require 'rmagick'
include Magick

def parse_dim(d)
	m = /(-?\d+)x(-?\d+)/.match(d)

	if m
		[m[1].to_i, m[2].to_i]
	else
		nil
	end
end

filename = ARGV[0]

file, dims = filename.split('.')[0].split('_out_')

dims_tl, dims_br = dims.split('=').collect {|x| parse_dim(x)}

orig = Image.read(filename)[0]

width = dims_br[0] - dims_tl[0]
height = dims_br[1] - dims_tl[1]

(0..height).each do |y|
	(0..width).each do |x|
		img = Image.new(512, 512) {
			self.background_color = '#0000'
		}
		img.composite!(orig, 512 * -x, 512 * -y, OverCompositeOp)
		img.write("#{file}_test_#{dims_tl[0] + x}x#{dims_br[1] - y}.png")
	end
end