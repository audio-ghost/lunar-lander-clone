class_name Player extends CharacterBody2D

const EXPLOSION_EFFECT = preload("uid://dsyvdfxal0syu")

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

@onready var screen_size = get_viewport_rect().size
@onready var starting_position = global_position
@onready var hud: HUD = get_tree().current_scene.get_node("HUD")

var ScorePopup = preload("res://Objects/ScorePopup/score_popup.tscn")

var landing_checked = false

func _ready() -> void:
	ship_collider_area.body_entered.connect(_on_ship_collider_body_entered)
	landing_area.body_entered.connect(_on_landing_body_entered)
	rockets_a_sprite_2d.hide()
	call_deferred("_connect_to_hud")

func _connect_to_hud():
	stats.fuel_changed.connect(_on_fuel_changed)
	_on_fuel_changed(stats.fuel)
	stats.score_changed.connect(_on_score_changed)

func _physics_process(delta: float) -> void:
	landing_checked = false
	if is_on_floor():
		velocity = Vector2.ZERO
		
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
	else:
		rockets_a_sprite_2d.hide()

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

func handle_landing_attempt(landingPad: LandingPad):
	if !is_speed_safe():
		crash_and_reset("Moving too fast")
	elif !is_angle_safe():
		crash_and_reset("Not straight")
	elif !both_feet_on_pad():
		crash_and_reset("Edge of Landing Pad")
	else:
		landing_succesful(landingPad)

func is_speed_safe() -> bool:
	return get_real_velocity().length() < safe_landing_speed

func is_angle_safe() -> bool:
	return abs(rotation_degrees) < max_safe_landing_angle 

func both_feet_on_pad() -> bool:
	# TODO: Check if both feet are on the Landing Pad
	#print("Is colliding:", ray_cast_2d_right.is_colliding())
	#var left_hit = ray_cast_2d_left.get_collider()
	#print(left_hit)
	#var right_hit = ray_cast_2d_right.get_collider()
	#print(right_hit)
	#return left_hit is LandingPad and right_hit is LandingPad
	#return ray_cast_2d_left.is_colliding() and ray_cast_2d_right.is_colliding()
	return true

func crash_and_reset(message = null) -> void:
	update_points(crash_penalty)
	play_explosion_effect()
	hud.display_message("Ship Crashed!", Color.RED, message)
	if stats.is_fuel_empty():
		pass
	else:
		reset_player_position()

func landing_succesful(landingPad: LandingPad) -> void:
	update_points(landingPad.score_value)
	hud.display_message("Landing Successful!", Color.GREEN)
	if stats.is_fuel_empty():
		pass
	else:
		pass

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
