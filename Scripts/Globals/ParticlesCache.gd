extends CanvasLayer

##NOTE Script used from tutorial: 
## https://www.youtube.com/watch?v=kbDj9V2MZvw

var dashParticles = preload("res://Materials/dash_particles.tres")

var materials = [
	dashParticles,
	]

var frames = 0
var loaded = false

func _ready() -> void:
	for material in materials:
		var particles_instance = GPUParticles2D.new()
		particles_instance.set_process_material(material)
		particles_instance.one_shot = true
		particles_instance.modulate = Color(1,1,1,0)
		particles_instance.emitting = true
		self.add_child(particles_instance)

func _physics_process(_delta: float) -> void:
	if frames >= 3:
		set_physics_process(false)
		loaded = true
	frames += 1
