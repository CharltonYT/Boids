extends Node2D
class_name Boid

# warning-ignore:unused_signal
signal inventory_to_aquarium_slot(index)

@onready var visual_range = $"Visual Range/CollisionShape2D"
@onready var protected_range = $"Protected Range/CollisionShape2D"
@onready var boids = FishPaths.boidsInAquarium

var neighbors = []
var visualNeighbors = []
var avoidFactor = .0005
var turnFactor = .1
var xVelo = 1
var yVelo = 1
var screensize : Vector2
var maxSpeed = 5
var minSpeed = 1
var matchingFactor = .05
var centeringFactor = .0005 #unused varaible, enable if want to use cohesion

func ready():
	screensize = get_viewport().size
func _physics_process(_delta):
	separation()
	alignment()
	check_speed()
	move()

func _on_Protected_Range_area_entered(area):
	if area != self:
		neighbors.append(area)


func _on_Protected_Range_area_exited(area):
	neighbors.erase(area)


func separation():
	if neighbors:
		var close_dx = 0
		var close_dy = 0
		for n in neighbors:
			close_dx+= global_position.x - n.global_position.x
			close_dy+= global_position.y - n.global_position.y
		xVelo += close_dx * avoidFactor
		yVelo += close_dy * avoidFactor
	pass
func move():
	screensize = get_viewport().size
	if global_position.x < 200:
		xVelo = xVelo + turnFactor
	if global_position.x > screensize.x - 200:
		xVelo = xVelo - turnFactor
	if global_position.y > screensize.y - 200:
		yVelo = yVelo - turnFactor
	if global_position.y < 200:
		yVelo = yVelo + turnFactor
	
	var velo = Vector2(xVelo, yVelo).normalized()
	rotation = lerp_angle(rotation, velo.angle_to_point(Vector2.ZERO), 0.4)
	global_position += Vector2(xVelo,yVelo)

func check_speed():
	var speed = sqrt(xVelo*xVelo + yVelo*yVelo)
	if speed>maxSpeed:
		xVelo = (xVelo/speed)*maxSpeed
		yVelo = (yVelo/speed)*minSpeed
	if speed<minSpeed:
		xVelo = (xVelo/speed)*minSpeed
		yVelo = (yVelo/speed)*minSpeed


func _on_Visual_Range_area_entered(area):
		if area != self:
			visualNeighbors.append(area.get_parent())

func _on_Visual_Range_area_exited(area):
	visualNeighbors.erase(area.get_parent())

func alignment():
	if visualNeighbors:
		var xAvg = 0
		var yAvg = 0
		for n in visualNeighbors:
			xAvg += n.xVelo
			yAvg += n.yVelo
		xAvg = xAvg/visualNeighbors.size()
		yAvg = yAvg/visualNeighbors.size()
		
		xVelo += (xAvg - xVelo)*matchingFactor
		yVelo += (yAvg - yVelo)*matchingFactor

func cohesion():
	if visualNeighbors:
		var xPosAvg = 0
		var yPosAvg = 0
		for n in visualNeighbors:
			xPosAvg += n.global_position.x
			yPosAvg += n.global_position.y
		xPosAvg = xPosAvg/visualNeighbors.size()
		yPosAvg = yPosAvg/visualNeighbors.size()
		xVelo += (xPosAvg - global_position.x) * centeringFactor
		yVelo += (yPosAvg - global_position.y) * centeringFactor
