v = cp.v

drawCircle = (ctx, scale, point2canvas, c, radius) ->
  c = point2canvas(c)
  ctx.beginPath()
  ctx.arc c.x, c.y, scale * radius, 0, 2 * Math.PI, false
  ctx.fill()
  ctx.stroke()

drawLine = (ctx, point2canvas, a, b) ->
  a = point2canvas(a)
  b = point2canvas(b)
  ctx.beginPath()
  ctx.moveTo a.x, a.y
  ctx.lineTo b.x, b.y
  ctx.stroke()

springPoints = [ v(0.00, 0.0), v(0.20, 0.0), v(0.25, 3.0), v(0.30, -6.0), v(0.35, 6.0), v(0.40, -6.0), v(0.45, 6.0), v(0.50, -6.0), v(0.55, 6.0), v(0.60, -6.0), v(0.65, 6.0), v(0.70, -3.0), v(0.75, 6.0), v(0.80, 0.0), v(1.00, 0.0) ]
drawSpring = (ctx, scale, point2canvas, a, b) ->
  a = point2canvas(a)
  b = point2canvas(b)
  ctx.beginPath()
  ctx.moveTo a.x, a.y
  delta = v.sub(b, a)
  len = v.len(delta)
  rot = v.mult(delta, 1 / len)
  i = 1

  while i < springPoints.length
    p = v.add(a, v.rotate(v(springPoints[i].x * len, springPoints[i].y * scale), rot))
    ctx.lineTo p.x, p.y
    i++
  ctx.stroke()

cp.PolyShape::draw = (ctx, scale, point2canvas) ->
  ctx.beginPath()
  verts = @tVerts
  len = verts.length
  lastPoint = point2canvas(new cp.Vect(verts[len - 2], verts[len - 1]))
  ctx.moveTo lastPoint.x, lastPoint.y
  i = 0

  while i < len
    p = point2canvas(new cp.Vect(verts[i], verts[i + 1]))
    ctx.lineTo p.x, p.y
    i += 2
  ctx.fill()
  ctx.stroke()

cp.SegmentShape::draw = (ctx, scale, point2canvas) ->
  oldLineWidth = ctx.lineWidth
  ctx.lineWidth = Math.max(1, @r * scale * 2)
  drawLine ctx, point2canvas, @ta, @tb
  ctx.lineWidth = oldLineWidth

cp.CircleShape::draw = (ctx, scale, point2canvas) ->
  drawCircle ctx, scale, point2canvas, @tc, @r
  drawLine ctx, point2canvas, @tc, cp.v.mult(@body.rot, @r).add(@tc)

cp.PinJoint::draw = (ctx, scale, point2canvas) ->
  a = @a.local2World(@anchr1)
  b = @b.local2World(@anchr2)
  ctx.lineWidth = 2
  ctx.strokeStyle = "grey"
  drawLine ctx, point2canvas, a, b

cp.SlideJoint::draw = (ctx, scale, point2canvas) ->
  a = @a.local2World(@anchr1)
  b = @b.local2World(@anchr2)
  midpoint = v.add(a, v.clamp(v.sub(b, a), @min))
  ctx.lineWidth = 2
  ctx.strokeStyle = "grey"
  drawLine ctx, point2canvas, a, b
  ctx.strokeStyle = "red"
  drawLine ctx, point2canvas, a, midpoint

cp.PivotJoint::draw = (ctx, scale, point2canvas) ->
  a = @a.local2World(@anchr1)
  b = @b.local2World(@anchr2)
  ctx.strokeStyle = "grey"
  ctx.fillStyle = "grey"
  drawCircle ctx, scale, point2canvas, a, 2
  drawCircle ctx, scale, point2canvas, b, 2

cp.GrooveJoint::draw = (ctx, scale, point2canvas) ->
  a = @a.local2World(@grv_a)
  b = @a.local2World(@grv_b)
  c = @b.local2World(@anchr2)
  ctx.strokeStyle = "grey"
  drawLine ctx, point2canvas, a, b
  drawCircle ctx, scale, point2canvas, c, 3

cp.DampedSpring::draw = (ctx, scale, point2canvas) ->
  a = @a.local2World(@anchr1)
  b = @b.local2World(@anchr2)
  ctx.strokeStyle = "grey"
  drawSpring ctx, scale, point2canvas, a, b

randColor = ->
  Math.floor Math.random() * 256

styles = []
i = 0

while i < 100
  styles.push "rgb(" + randColor() + ", " + randColor() + ", " + randColor() + ")"
  i++
cp.Shape::style = ->
  body = undefined
  if @sensor
    "rgba(255,255,255,0)"
  else
    body = @body
    if body.isSleeping()
      "rgb(50,50,50)"
    else if body.nodeIdleTime > @space.sleepTimeThreshold
      "rgb(170,170,170)"
    else
      styles[@hashid % styles.length]