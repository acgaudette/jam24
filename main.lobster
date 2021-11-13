import std
import vec
import color
import gl

fatal(gl_window("jam24", 600, 800))
ph_initialize(xy_f { 0, -16 })

let scale_const = .04
let ground = ph_create_box(xy { 0.0, 0.0 }, xy { .25 / scale_const, 0.0 })
var squares = []
var squares_big = []

def reset():
	squares = []
	squares_big = []

var t_crash = 0.
var alpha = 0.

def crash(w: float, h: float):
	if gl_time() - t_crash > .5:
		let sq_scale = .33 * h / (w * scale_const)
		let sq = ph_create_box(
			xy   { -1 / scale_const, sq_scale * 2 },
			xy_f { sq_scale, sq_scale }
		)
		ph_set_color(sq, color_grey)
		ph_dynamic(sq, true)
		ph_set_linear_velocity(sq, xy_f { 48, 4 })
		squares_big.push(sq)
		t_crash = gl_time()
		alpha = min(1, alpha + max(0.1, alpha) * .1)

while gl_frame():
	gl_clear(color_dark_grey)

	let dt = gl_delta_time()

	let w = gl_window_size().x
	let w_half = w * .5
	let h = gl_window_size().y
	let h_half = w * .5
	let scale = w * scale_const
	let scale_xy = xy_f { scale, -scale }

	gl_translate(xy { w_half, 0 }):
		gl_scale(scale)
		gl_translate(xy_f { 0, 2 })
		var col = color_grey

		var pos = xy_f { 0, (h - 2 * scale) / scale }

		var min = 2. * h
		var best = nil

		for (squares) sq:
			let sqpos = ph_get_position(sq)
			let dist = magnitude(sqpos - pos)
			ph_set_color(sq, color_white)
			if dist < min:
				min = dist
				best = sq
		if best:
			if min < 2:
				// ph_set_color(best, color_red)
				col = color_green
			if min < 4:
				crash(w, h)
		gl_color(col)
		gl_circle(1, 128)

	gl_translate(xy { w_half, h * .5 }):
		gl_scale(scale)
		gl_translate(xy_f { -8, 0 })
		var col = color { .75, .75, .75, alpha }

		var pos = xy_f { -8, h * .5 / scale }

		var min = 2. * h
		var best = nil

		for (squares) sq:
			let sqpos = ph_get_position(sq)
			let dist = magnitude(sqpos - pos)
			ph_set_color(sq, color_white)
			if dist < min:
				min = dist
				best = sq
		if best:
			if min < 2:
				// ph_set_color(best, color_red)
				col = color_green
		gl_color(col)
		gl_circle(1, 128)

	gl_translate(xy { w_half, h }):
		gl_scale(scale_xy)
		let mouse = gl_local_mouse_pos(0)

		gl_translate(mouse):
			gl_color(color { .5, .5, .5, .5 })
			gl_open_circle(1, 128, .1)

		if gl_button("mouse1") == 1:
			let sq = ph_create_box(mouse, xy { 1., 1. })
			ph_dynamic(sq, true)
			squares.push(sq)

		ph_step(dt, 8, 3)
		ph_render()
