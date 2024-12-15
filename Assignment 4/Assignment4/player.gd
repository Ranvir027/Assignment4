extends Node3D

@export var rotateSpeed = 5.0
var idle = true # Weather the player can control the arm ( is the arm free?)
var carrying = false # Weather is arm is caryying the ball

func _animation_changed(name):
	if name == 'grab':
		# If grab animation is playing, call grab() function
		$AnimationTree.set('parameters/conditions/grab', false)
		# Attempt to grab
		grab()
	elif name == "letgo":
		# If letgo animation is playing, call drop90 function
		$AnimationTree.set('parameters/conditions/drop', false)
		if carrying:
			drop()
		carrying = false
		idle = true
	elif name == "pickup":
		# If pickup animation is playing, set idle to true again
		idle = true

func grab():
	# Get bodies inside the grabbing area
	var bodies = $Armature/Skeleton3D/BoneAttachment3D/areaTrigger.get_overlapping_bodies()
	for body in bodies:
		# Check if the body is a ball
		if body.is_in_group('ball'):
			# Change parent from origin to grabAnchor
			body.get_parent().remove_child(body)
			# Stop ball movement
			body.freeze = true
			body.position = Vector3.ZERO
			$Armature/Skeleton3D/BoneAttachment3D/grabAnchor.add_child(body)
			carrying = true

func drop():
	# Change parent from grabAnchor to origin
	var body = $Armature/Skeleton3D/BoneAttachment3D/grabAnchor.get_children()[0]
	$Armature/Skeleton3D/BoneAttachment3D/grabAnchor.remove_child(body)
	get_tree().root.add_child(body)
	body.freeze = false

func _process(delta):
	#Assigning all controls here
	if !idle:
		return
	var rot = rotation_degrees
	# Handle input 
	if Input.is_action_pressed('left'):
		# rotate counterclockwise
		rot.y += rotateSpeed * delta
	if Input.is_action_pressed('right'):
		# rotate clockwise
		rot.y -= rotateSpeed * delta
	if Input.is_action_just_pressed('action'):
		idle = false
		# Drop or grab the ball
		if carrying:
			# Set animation tree condition
			$AnimationTree.set('parameters/conditions/drop', true)
		else:
			# Set animation tree condition
			$AnimationTree.set('parameters/conditions/grab', true)
	
	rotation_degrees = rot
