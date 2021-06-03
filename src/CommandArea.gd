extends Area
class_name CommandArea

enum CommandType {
	NONE,
	SET_STEER
}

export var command_type: int = CommandType.NONE
export var amount: Vector3 = Vector3.ZERO

func _ready():
	pass

func what_do():
	return {
		"command_type": command_type,
		"amount": amount
	}
