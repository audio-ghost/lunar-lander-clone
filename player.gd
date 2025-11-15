class_name Player extends CharacterBody2D

const EXPLOSION_EFFECT = preload("uid://dsyvdfxal0syu")

@export var max_speed := 1000.0
@export var rotation_speed := 125.0
@export var acceleration := 75.0
@export var gravity_scale := 0.025
@export var safe_landing_speed := 25.0
@export var max_safe_landing_angle := 15.0
@export var max_fuel := 1000.0

@onready var rockets_a_sprite_2d: AnimatedSprite2D = $RocketsASprite2D
@onready var ship_collider_area: Area2D = $ShipColliderArea
@onready var landing_right_area: Area2D = $LandingRightArea
@onready var landing_left_area: Area2D = $LandingLeftArea
@onready var ray_cast_2d_left: RayCast2D = $RayCast2DLeft
@onready var ray_cast_2d_right: RayCast2D = $RayCast2DRight

@onready var screen_size = get_viewport_rect().size
@onready var starting_position = global_position

var landing_checked = false

func _ready() -> void:
	ship_collider_area.body_entered.connect(_on_ship_collider_body_entered)
	landing_right_area.body_entered.connect(_on_landing_body_entered)
	landing_left_area.body_entered.connect(_on_landing_body_entered)
	rockets_a_sprite_2d.visible = false

func _physics_process(delta: float) -> void:
	landing_checked = false
	if is_on_floor():
		velocity = Vector2.ZERO
	if not is_on_floor():
		apply_gravity(delta)
		apply_rotation(delta)
	if Input.is_action_pressed("fire_thruster"):
		handle_acceleration(delta)
		rockets_a_sprite_2d.visible = true
	else:
		rockets_a_sprite_2d.visible = false
	move_and_slide()
	screen_wrap()

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func apply_rotation(delta):
	var input_axis := Input.get_axis("rotate_left", "rotate_right")
	if input_axis != 0:
		rotation_degrees = rotation_degrees + input_axis * rotation_speed * delta

func handle_acceleration(delta):
	var direction = Vector2.UP.rotated(rotation)
	var thrust = direction * acceleration
	velocity += thrust * delta

func screen_wrap():
	position.x = wrapf(position.x, 0, screen_size.x)

func _on_ship_collider_body_entered(body) -> void:
	print("Ship collider entered!")
	if body is PhysicsBody2D:
		crash_and_reset()
	
func _on_landing_body_entered(body) -> void:
	if landing_checked:
		return
	landing_checked = true
	print("Landing collider entered!")
	if body is LandingPad:
		handle_landing_attempt()
	elif body is StaticBody2D:
		crash_and_reset()

func handle_landing_attempt():
	if is_speed_safe() and is_angle_safe() and both_feet_on_pad():
		landing_succesful()
	else:
		crash_and_reset()

func is_speed_safe() -> bool:
	print("Landing Speed: ")
	print(get_real_velocity().length())
	return get_real_velocity().length() < safe_landing_speed

func is_angle_safe() -> bool:
	print("Landing Angle: ")
	print(rotation_degrees)
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

func crash_and_reset() -> void:
	play_explosion_effect()
	reset_player_position()

func landing_succesful() -> void:
	print("Landed on Landing Pad")

func play_explosion_effect():
	var explosion_effect = EXPLOSION_EFFECT.instantiate()
	get_tree().current_scene.add_child(explosion_effect)
	explosion_effect.global_position = global_position

func reset_player_position():
	global_position = starting_position
	velocity = Vector2.ZERO
	rotation = 0
