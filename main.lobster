import std
import vec
import color
import gl

fatal(gl_window("jam24", 600, 800, 0, 4))
ph_initialize(xy_f { 0, -16 })

/*
import imgui
im_init(false)
assert im_add_font("data/fonts/Droid_Sans/DroidSans.ttf", 20.0)
*/

let scale_const = .04
let ground = ph_create_box(xy { 0.0, 0.0 }, xy { .25 / scale_const, 0.0 })
var squares = []
var squares_big = []

class Palette:
	bg    = color { .745, .098, .216, 1 }
	// goal = color { 1, .790, 0, 1 }
	goal = color { 1, .075, .249, 1 }
	block = color { .067, .822, .473, 1 }
	crash = color { .442, .076, .143, 1}
	// link = color { 1, .977, .726, 1 }
	link = color { 1, .814, .749, 1 }
	mouse = color { 1, 1, 1, .125 }
	// goal_short = color { .75, .75, .75, 1 }
var palette = Palette {}

def reset():
	squares = []
	squares_big = []

var t_crash = 0.
var t_close = 0.
var alpha = 0.

def crash(w: float, h: float):
	if gl_time() - t_crash > .5:
		let sq_scale = .33 * h / (w * scale_const)
		let sq = ph_create_box(
			xy   { -1 / scale_const, sq_scale * 2 },
			xy_f { sq_scale, sq_scale }
		)
		ph_set_color(sq, palette.crash)
		ph_dynamic(sq, true)
		ph_set_linear_velocity(sq, xy_f { 48, 4 })
		squares_big.push(sq)
		t_crash = gl_time()
		alpha = min(1, alpha + max(0.1, alpha) * .2)

while gl_frame():
	gl_clear(palette.bg)
/*
	im_frame():
		im_window("palette", im_window_always_autoresize):
			palette = im_edit_anything(palette)
*/
	let dt = gl_delta_time()
	let  t = gl_time()

	let w = gl_window_size().x
	let w_half = w * .5
	let h = gl_window_size().y
	let h_half = w * .5
	let scale = w * scale_const
	let scale_xy = xy_f { scale, -scale }

	gl_translate(xy { w_half, 0 }):
		gl_scale(scale)
		gl_translate(xy_f { 0, 2 })
		var col = palette.goal

		var pos = xy_f { 0, (h - 2 * scale) / scale }
		let size = max(0, min(3, 3 - pow(t, .5) * .2))

		var min = 2. * h
		var best = nil

		for (squares) sq:
			let sqpos = ph_get_position(sq)
			let dist = magnitude(sqpos - pos)
			ph_set_color(sq, palette.block)
			if dist < min:
				min = dist
				best = sq
		if best:
			if min < size + 1:
				// ph_set_color(best, color_red)
				col = palette.link
			if min < size * 2:
				if t - t_close > 1:
					crash(w, h)
			else:
				t_close = t
		else:
			t_close = t
		gl_color(col)
		gl_circle(size, 128)

	gl_translate(xy { w_half, h * .5 }):
		gl_scale(scale)
		gl_translate(xy_f { -8, 0 })
		var col = color {
			// palette.goal_short.red,
			// palette.goal_short.green,
			// palette.goal_short.blue,
			   palette.goal.red,
			   palette.goal.green,
			   palette.goal.blue,
			alpha,
		}

		var pos = xy_f { -8, h * .5 / scale }
		let size = max(0, min(2, 2 - pow(t, .5) * .15))

		var min = 2. * h
		var best = nil

		for (squares) sq:
			let sqpos = ph_get_position(sq)
			let dist = magnitude(sqpos - pos)
			ph_set_color(sq, palette.block)
			if dist < min:
				min = dist
				best = sq
		if best:
			if min < size + 1:
				// ph_set_color(best, color_red)
				col = palette.link
		gl_color(col)
		gl_circle(size, 128)

	gl_translate(xy { w_half, h }):
		gl_scale(scale_xy)
		let mouse = gl_local_mouse_pos(0)

		gl_translate(mouse):
			gl_color(palette.mouse)
			gl_open_circle(1, 128, .1)

		if gl_button("mouse1") == 1:
			let sq = ph_create_box(mouse, xy { 1., 1. })
			ph_dynamic(sq, true)
			squares.push(sq)

		ph_step(dt, 8, 3)
		ph_render()
