extends Spatial
class_name Player

var distanceTravelled = 0.0

var speed_control = 0.0 setget set_speed_control
var thrust = 0.0 setget ,get_thrust
var brake = 0.0 setget ,get_brake
onready var throttleProgressBar = $UI/ThrottleProgressBar
onready var brakeProgressBar = $UI/BrakeProgressBar

onready var area: Area = $Area

var speed: float = 0 setget set_speed
var steer_angle: Vector3 = Vector3(0,0,0)

var curve: Curve3D
var nextPos: Vector3

var currentCommand

func init() -> Player:
	return self

func _ready() -> void:
	area.connect("area_entered", self, "handle_area")

func _process(delta: float) -> void:
	if (speed + speed_control >= 0):
		speed += (speed_control if speed_control > 0 else speed_control * 2) * 2
		
	handle_current_command(delta)
	
	var forward = -get_global_transform().basis.z
	nextPos = self.transform.origin + (speed / 1000000/2) * forward
	self.transform.origin = nextPos


# Haha this isn't mine xd
func look_towards(node: Object, vector, delta: float, smooth_speed:= 1.0, return_only:= false):
	var smooth: bool
	if smooth_speed == 0:
		smooth = false
	else:
		smooth = true
	if vector is Object:
		vector = vector.global_transform.origin
	elif !vector is Vector3:
		print("No target to look towards")
		get_tree().paused = true
		return
	var looker = Spatial.new()
	node.add_child(looker)
	looker.look_at(vector, Vector3.UP)
	var finalRot = node.rotation_degrees + looker.rotation_degrees
	if return_only == true:
		return finalRot
	elif smooth == false:
		node.rotation_degrees = finalRot
	else:
		looker.look_at(vector, Vector3.UP)
		finalRot = node.rotation_degrees + looker.rotation_degrees
		node.rotation_degrees = lerp(node.rotation_degrees, finalRot, delta * smooth_speed)
	looker.queue_free()

func _input(event):
	if event.is_action("raise_speed"):
		self.speed_control += 10 if self.speed_control > 0 else 15
	elif event.is_action("lower_speed"):
		self.speed_control -= 10 if self.speed_control > 0 else 15
	elif event.is_action_pressed("reset_speed"):
		self.speed_control = 0

func set_speed(new_value: float):
	speed = clamp(new_value, 0, 100)

func set_speed_control(new_value: float) -> void:
	speed_control = clamp(new_value, -100, 100)
	throttleProgressBar.value = clamp(speed_control, 0, 100)
	brakeProgressBar.value = -clamp(speed_control, -100, 0)
	print("speed: %f, throttle: %f, brake: %f" % [speed_control, clamp(speed_control, 0, 100), -clamp(speed_control, -100, 0)])

func get_thrust() -> float:
	return clamp(speed_control, 0, 100)

func get_brake() -> float:
	return clamp(speed_control, -100, 0)

func handle_area(area: Area):
	if area.has_method("what_do"):
		var what_do = area.what_do()
		currentCommand = what_do

func handle_current_command(delta: float):
	if not currentCommand: return
	
	if currentCommand.command_type == CommandArea.CommandType.SET_STEER:
		self.rotation_degrees += currentCommand.amount * speed/100000 * delta
