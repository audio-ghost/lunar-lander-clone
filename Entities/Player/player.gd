class_name Player extends CharacterBody2D

const EXPLOSION_EFFECT = preload("uid://dsyvdfxal0syu")

const ALL_PADS_BONUS = 500
const NO_CRASH_BONUS = 500
const MAX_SPEED_BONUS = 500
const FUEL_BONUS_MULT = 1.5

@export var max_speed := 1000.0
@export var rotation_speed := 125.0
@export var acceleration := 75.0
@export var gravity_scale := 0.025
@export var safe_landing_speed := 25.0
@export var max_safe_landing_angle := 15.0
@export var main_thruster_fuel_use_rate := 25
@export var rotation_thruster_fuel_use_rate := 10
@export var crash_penalty := -5

@export var stats: Stats

@onready var rockets_a_sprite_2d: AnimatedSprite2D = $RocketsASprite2D
@onready var ship_collider_area: Area2D = $ShipColliderArea
@onready var landing_area: Area2D = $LandingArea
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight

@onready var crash_audio_stream_player: AudioStreamPlayer2D = $CrashAudioStreamPlayer
@onready var thrusters_audio_stream_player: AudioStreamPlayer2D = $ThrustersAudioStreamPlayer
@onready var landing_audio_stream_player: AudioStreamPlayer2D = $LandingAudioStreamPlayer

@onready var screen_size = get_viewport_rect().size
@onready var starting_position = global_position
@onready var hud: HUD = get_tree().current_scene.get_node("HUD")

var ScorePopup = preload("res://Objects/ScorePopup/score_popup.tscn")

var landing_checked := false
var received_all_pads_bonus := false
var received_max_speed_bonus := false
var crash_counter := 0
var last_successful_landing_pad : LandingPad = null

signal player_game_over
signal player_level_complete

func _ready() -> void:
	ship_collider_area.body_entered.connect(_on_ship_collider_body_entered)
	landing_area.body_entered.connect(_on_landing_body_entered)
	rockets_a_sprite_2d.hide()
	call_deferred("_connect_to_hud")
	call_deferred("_connect_to_landing_pads")

func _connect_to_hud():
	stats.fuel_changed.connect(_on_fuel_changed)
	_on_fuel_changed(stats.fuel)
	stats.score_changed.connect(_on_score_changed)

func _connect_to_landing_pads():
	for pad in LandingPadManager.pads:
		pad.landed.connect(_on_landing_pad_landed)

func _physics_process(delta: float) -> void:
	landing_checked = false
	if is_on_floor():
		velocity = Vector2.ZERO
		if stats.is_fuel_empty():
			handle_game_over()
		
	apply_gravity(delta)
	apply_rotation(delta)
	handle_acceleration(delta)
	move_and_slide()
	screen_wrap()

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func apply_rotation(delta):
	var input_axis := Input.get_axis("rotate_left", "rotate_right")
	if not is_on_floor() and input_axis != 0 and !stats.is_fuel_empty():
		rotation_degrees = rotation_degrees + input_axis * rotation_speed * delta
		burn_fuel(rotation_thruster_fuel_use_rate, delta)

func handle_acceleration(delta):
	if Input.is_action_pressed("fire_thruster") and !stats.is_fuel_empty():
		var direction = Vector2.UP.rotated(rotation)
		var thrust = direction * acceleration
		velocity += thrust * delta
		burn_fuel(main_thruster_fuel_use_rate, delta)
		rockets_a_sprite_2d.show()
		if !thrusters_audio_stream_player.playing:
			thrusters_audio_stream_player.play()
		elif thrusters_audio_stream_player.get_playback_position() > 0.3:
			thrusters_audio_stream_player.seek(0.1)
		print(velocity.length())
		if velocity.length() > max_speed and not received_max_speed_bonus:
			award_max_speed_bonus()
			
	else:
		rockets_a_sprite_2d.hide()

func disable_player_input():
	set_process_input(false)
	set_physics_process(false)

func burn_fuel(fuel_use_rate, delta):
	stats.fuel -= fuel_use_rate * delta

func screen_wrap():
	position.x = wrapf(position.x, 0, screen_size.x)

func _on_ship_collider_body_entered(body) -> void:
	if body is PhysicsBody2D:
		crash_and_reset()
	
func _on_landing_body_entered(body) -> void:
	if landing_checked:
		return
	if body is LandingPad:
		handle_landing_attempt(body)
	elif body is StaticBody2D:
		crash_and_reset()

func _on_fuel_changed(new_fuel: float) -> void:
	hud.set_fuel(new_fuel, stats.max_fuel)

func _on_score_changed(new_score: int) -> void:
	hud.set_score(new_score)

func handle_landing_attempt(landing_pad: LandingPad):
	if !is_speed_safe():
		crash_and_reset("Moving too fast!")
	elif !is_angle_safe():
		crash_and_reset("Not straight!")
	elif !both_feet_on_pad():
		crash_and_reset("Edge of Landing Pad!")
	else:
		landing_succesful(landing_pad)

func is_speed_safe() -> bool:
	return get_real_velocity().length() < safe_landing_speed

func is_angle_safe() -> bool:
	return abs(rotation_degrees) < max_safe_landing_angle 

func both_feet_on_pad() -> bool:
	return ray_cast_2d_left.is_colliding() and ray_cast_2d_right.is_colliding()

func crash_and_reset(message = null) -> void:
	crash_audio_stream_player.play()
	crash_counter += 1
	update_points(crash_penalty)
	play_explosion_effect()
	hud.display_message(message if message != null else "Ship Crashed!", Color.RED)
	if stats.is_fuel_empty():
		handle_game_over()
	else:
		LandingPadManager.enable_all_pads()
		reset_player_position()

func landing_succesful(landing_pad: LandingPad) -> void:
	starting_position = global_position
	if landing_pad != last_successful_landing_pad and landing_pad.can_score:
		landing_audio_stream_player.play()
		update_points(landing_pad.get_score_value())
		hud.display_message("Landing Successful!", Color.GREEN)
		landing_pad.process_landing()
	if stats.is_fuel_empty():
		handle_game_over()
	elif LandingPadManager.all_pads_landed():
		handle_level_complete()
	last_successful_landing_pad = landing_pad

func update_points(points: int) -> void:
	stats.score += points
	
	var popup = ScorePopup.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position
	popup.show_points(points)

func play_explosion_effect():
	var explosion_effect = EXPLOSION_EFFECT.instantiate()
	get_tree().current_scene.add_child(explosion_effect)
	explosion_effect.global_position = global_position
	hide()

func reset_player_position():
	global_position = starting_position
	velocity = Vector2.ZERO
	rotation = 0
	show()

func _on_landing_pad_landed(_pad: LandingPad) -> void:
	if not received_all_pads_bonus and LandingPadManager.all_pads_landed():
		award_all_pads_bonus()

func award_all_pads_bonus():
	received_all_pads_bonus = true
	update_points(ALL_PADS_BONUS)
	hud.display_message("ALL PADS BONUS! +" + str(ALL_PADS_BONUS), Color.GREEN)
	
	if crash_counter == 0:
		update_points(NO_CRASH_BONUS)
		hud.display_message("NO CRASH BONUS! +" + str(NO_CRASH_BONUS), Color.GREEN)
	
	var fuel_bonus = int(stats.fuel * FUEL_BONUS_MULT)
	update_points(fuel_bonus)
	hud.display_message("FUEL BONUS! +" + str(fuel_bonus), Color.GREEN)

func award_max_speed_bonus():
	received_max_speed_bonus = true
	update_points(MAX_SPEED_BONUS)
	hud.display_message("MAX SPEED BONUS! +" + str(MAX_SPEED_BONUS), Color.GREEN)

func handle_game_over():
	disable_player_input()
	emit_signal("player_game_over", stats.score)

func handle_level_complete():
	disable_player_input()
	emit_signal("player_level_complete", stats.score)
