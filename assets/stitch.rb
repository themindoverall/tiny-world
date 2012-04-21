require 'rmagick'
include Magick

filename = "render"

images = Hash.new

min_x = min_y = 1024
max_x = max_y = -1024

Dir.glob(filename + "_*.png").each do |file|
	m = /_(-?\d+)x(-?\d+)/.match(file)

	if m
		x = m[1].to_i
		y = m[2].to_i
		if x < min_x
			min_x = x
		end
		if y < min_y
			min_y = y
		end
		if x > max_x
			max_x = x
		end
		if y > max_y
			max_y = y
		end
		images[[x,y]] = Image.read(file)[0]
	end
end

width = max_x - min_x
height = max_y - min_y

result = Image.new(512 * (width + 1), 512 * (height + 1)) {
	self.background_color = '#0000'
}


(0..height).each do |iy|
	(0..width).each do |ix|
		img = images[[min_x + ix, max_y - iy]]
		result.composite!(img, ix * 512, iy * 512, OverCompositeOp)
		#puts img.inspect
	end
end

result.write("#{filename}_out_#{min_x}x#{min_y}=#{max_x}x#{max_y}.png")