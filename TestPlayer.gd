extends Spatial

onready var pathToFollow: Path = $"../Path"
var t = 0.0
onready var curve: Curve3D = pathToFollow.curve

func _ready() -> void:
    print(pathToFollow)

func _process(delta: float) -> void:
    t += delta / 10
    var percentCleared = t * curve.get_baked_length()
    var test2 = curve.interpolate_baked(percentCleared, true)
    var test3 = curve.interpolate_baked_up_vector(percentCleared, true)
    self.rotate(Vector3.FORWARD, test3)
    self.transform.origin = test2
