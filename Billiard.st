Morph subclass: #CueStickMorph
	instanceVariableNames: 'attachedBall angle power isCharging isShooting'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Billiard'!

!CueStickMorph methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
initialize
    super initialize.
    self extent: 150@5.
    self color: Color brown.
    angle := 0.
    power := 0.
    isCharging := false.
    isShooting := false.
    
    self rotationCenter: 0@0.  
! !


!CueStickMorph methodsFor: 'attachment' stamp: 'arade 3/9/2025 19:21'!
attachToBall: aBall
    attachedBall := aBall.
    self updatePosition.! !


!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
handlesMouseDown: evt
    ^false! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
handlesMouseMove: evt
    ^false! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
handlesMouseUp: evt
    ^false! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
isShooting
    ^isShooting.! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
isShooting: bool
    isShooting := bool.
! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
mouseDown: evt
    power := 0.
    isCharging := true.
    self updateStrength: evt.
! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/29/2025 19:40'!
mouseMove: evt
    | mousePos ballCenter dx dy |

    isCharging ifTrue: [self visible ifTrue:[self updateStrength: evt]]
    ifFalse: [
        mousePos := evt cursorPoint.
        ballCenter := attachedBall center.

        dx := (ballCenter x) - (mousePos x).
        dy := (ballCenter y) - (mousePos y).
        
        angle := CueStickMorph direction: dx dY: dy.
        " self rotationCenter: ballCenter. "
        self heading: (angle radiansToDegrees).
        " self updatePosition.  "
    ]
! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/29/2025 19:41'!
mouseUp: evt
    | force |
    isShooting ifTrue: [^false] ifFalse: [self isShooting: true].
    isCharging := false.
    
    "Calculate the force vector based on angle and power"
    force := Point x: (power * (angle + Float pi) cos) y: (power * (angle + Float pi) sin).
    
    attachedBall velocity: force.
    
    power := 0.
    self visible: false.
! !

!CueStickMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
updateStrength: evt
    | mousePos ballCenter dx dy |
    mousePos := evt cursorPoint.
    ballCenter := attachedBall center.

    dx := (ballCenter x) - (mousePos x).
    dy := (ballCenter y) - (mousePos y).
    
    power := ((dx * dx) + (dy * dy)) sqrt.
    power := power min: 1000.
    power := power max: 0.
    power := power / 10.
! !


!CueStickMorph methodsFor: 'private' stamp: 'arade 3/9/2025 19:21'!
updatePosition
    | ballCenter stickTipPos |
    
    attachedBall ifNil: [^self].
    ballCenter := attachedBall center.
    
    "Calculate position where the tip of the stick should be (touching the ball)"
    stickTipPos := ballCenter + (Point r: 0 degrees: angle radiansToDegrees).
    
    self position: stickTipPos.
    
    "Set the rotation angle"
    self rotationDegrees: angle radiansToDegrees.
! !

CueStickMorph class
	instanceVariableNames: ''!

!CueStickMorph class methodsFor: 'as yet unclassified' stamp: 'arade 3/29/2025 19:40'!
direction: dx dY: dy
	|res|

	res := Float new.
	
	(dx abs < 0.05) ifTrue:[ res := Float pi / 2. "90" ]
					 ifFalse:[ res := (dy/dx) abs arcTan. "direction of vector" ].
					
	(dx <0) ifTrue:[ res := Float pi - res. "change in 180" ].
	
	(dy < 0) ifTrue:[ res := -1 * res. "opposite direction". ].

	^res.! !


CircleMorph subclass: #PoolBall
	instanceVariableNames: 'velocity isCueBall'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Billiard'!

!PoolBall methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
initialize
    super initialize.
    self extent: 20@20.
    velocity := 0@0.
    isCueBall := false.! !


!PoolBall methodsFor: 'accessing' stamp: 'arade 3/9/2025 19:21'!
isCueBall
    ^isCueBall! !

!PoolBall methodsFor: 'accessing' stamp: 'arade 3/9/2025 19:21'!
isCueBall: aBoolean
    isCueBall := aBoolean! !

!PoolBall methodsFor: 'accessing' stamp: 'arade 3/9/2025 19:21'!
velocity
    ^velocity! !

!PoolBall methodsFor: 'accessing' stamp: 'arade 3/9/2025 19:21'!
velocity: aPoint
    velocity := aPoint! !


!PoolBall methodsFor: 'physics' stamp: 'arade 3/9/2025 19:21'!
updatePosition
    "Update position based on velocity and apply friction"
    self position: self position + velocity.
    "Apply friction"
    velocity := velocity * 0.98.
    
    "Stop completely if moving very slowly"
    (velocity r < 0.1) ifTrue: [velocity := 0@0].! !


!PoolBall methodsFor: 'geometry' stamp: 'arade 3/9/2025 19:21'!
center
    ^ self position + (self extent // 2)! !


RectangleMorph subclass: #PoolTableMorph
	instanceVariableNames: 'balls pockets cueStick score'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Billiard'!

!PoolTableMorph methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
createBallAt: aPoint color: aColor
    "Helper method to create a ball at the specified position"
    | ball |
    ball := PoolBall new.
    ball extent: 20@20.
    ball color: aColor.
    ball position: aPoint - (10@10).  "Center the ball on the point"
    balls add: ball.
    self addMorph: ball.
    ^ball! !

!PoolTableMorph methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
createBalls
    "Create the pyramid of 15 colored balls and the white cue ball"
    | ballSize spacing startX startY cueBall |
    ballSize := 20.
    spacing := ballSize + 2.  "2 pixel gap between balls"
    
    "Position the rack towards the right side of the table"
    startX := self width - 250.  "Moved more to the left"
    startY := self height // 2.
    
    "Create white cue ball on the left"
    cueBall := PoolBall new.
    cueBall extent: ballSize@ballSize.
    cueBall color: Color white.
    cueBall position: 200 @ startY.
    cueBall isCueBall: true.
    balls add: cueBall.
    self addMorph: cueBall.
    
    "Create colored balls in pyramid formation - tip pointing left (toward cue ball)"
    
    "Row 1 - tip (leftmost)"
    self createBallAt: startX @ startY color: Color red.
    
    "Row 2"
    self createBallAt: (startX + spacing) @ (startY - (spacing // 2)) color: Color blue.
    self createBallAt: (startX + spacing) @ (startY + (spacing // 2)) color: Color green.
    
    "Row 3"
    self createBallAt: (startX + (2 * spacing)) @ (startY - spacing) color: Color yellow.
    self createBallAt: (startX + (2 * spacing)) @ startY color: Color orange.
    self createBallAt: (startX + (2 * spacing)) @ (startY + spacing) color: Color magenta.
    
    "Row 4"
    self createBallAt: (startX + (3 * spacing)) @ (startY - (3 * spacing // 2)) color: Color cyan.
    self createBallAt: (startX + (3 * spacing)) @ (startY - (spacing // 2)) color: Color brown.
    self createBallAt: (startX + (3 * spacing)) @ (startY + (spacing // 2)) color: Color magenta darker.
    self createBallAt: (startX + (3 * spacing)) @ (startY + (3 * spacing // 2)) color: Color blue darker.
    
    "Row 5 - base (rightmost)"
    self createBallAt: (startX + (4 * spacing)) @ (startY - (2 * spacing)) color: Color brown lighter.
    self createBallAt: (startX + (4 * spacing)) @ (startY - spacing) color: Color red darker.
    self createBallAt: (startX + (4 * spacing)) @ startY color: Color green darker.
    self createBallAt: (startX + (4 * spacing)) @ (startY + spacing) color: Color magenta lighter.
    self createBallAt: (startX + (4 * spacing)) @ (startY + (2 * spacing)) color: Color orange darker.! !

!PoolTableMorph methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
createCueStick
    "Create and attach the cue stick to the white ball"
    | cueBall |
    cueBall := balls detect: [:b | b isCueBall].
    cueStick := CueStickMorph new.
    cueStick attachToBall: cueBall.
    self addMorph: cueStick.
    cueStick updatePosition.! !

!PoolTableMorph methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
createPockets
    "Create 6 pockets at the corners and middle sides"
    | pocketSize halfPocket |
    pocketSize := 30.
    halfPocket := pocketSize // 2.
    
    {(0 @ 0). 
     (self width // 2 @ 0). 
     (self width @ 0).
     (0 @ self height).
     (self width // 2 @ self height).
     (self width @ self height)} do: [:pos |
        | pocket |
        pocket := CircleMorph new.
        pocket extent: pocketSize @ pocketSize.
        pocket color: Color black.
        pocket position: pos - (halfPocket @ halfPocket).
        pockets add: pocket.
        self addMorph: pocket
    ].! !

!PoolTableMorph methodsFor: 'initialization' stamp: 'arade 3/9/2025 19:21'!
initialize
    "Initialize the pool table with green felt color and proper dimensions"
    super initialize.
    self extent: 800@400.
    self color: (Color green darker darker).
    balls := OrderedCollection new.
    pockets := OrderedCollection new.
    score := 0.
    
    "Enable mouse tracking on the table"
    self on: #mouseMove send: #mouseMove: to: self;
        on: #mouseDown send: #mouseDown: to: self;
        on: #mouseUp send: #mouseUp: to: self.
    
    "Make sure the morph handles these events"
    self stopStepping.
    
    self createPockets.
    self createBalls.
    self createCueStick.
    
    "Start the physics loop"
    self startPhysicsLoop.
    
    positionX := (World width // 2) - (self width // 2).
	positionY := (World height // 2) - (self height // 2).
	self position:(positionX@positionY).
    "Explicitly bring forward to ensure mouse events"
	self openInWorld.
    self comeToFront.
    Transcript clear; show: 'PoolTable initialized'; cr.
! !


!PoolTableMorph methodsFor: 'game loop' stamp: 'arade 3/9/2025 19:21'!
startPhysicsLoop
    "Start the game physics loop"
    [
        [
            self updateBalls.
            self checkPocketCollisions.
            (Delay forMilliseconds: 16) wait.
        ] repeat
    ] fork.! !

!PoolTableMorph methodsFor: 'game loop' stamp: 'arade 3/9/2025 19:21'!
updateBalls
    "Update all ball positions and handle collisions"
    balls do: [:ball | ball updatePosition].
    self handleBallCollisions.
    self handleWallCollisions.
    
    "Create new cue stick if cue ball has stopped"
    ((cueStick isNil or: [cueStick visible not]) and: [balls anySatisfy: [:b | b isCueBall]]) ifTrue: [
        | cueBall |
        cueBall := balls detect: [:b | b isCueBall].
        cueBall velocity r < 0.1 ifTrue: [
            self createCueStick.  "Create a new cue stick if conditions are met"
        ].
    ].
! !


!PoolTableMorph methodsFor: 'collisions' stamp: 'arade 3/9/2025 19:21'!
checkCollisionBetween: ball1 and: ball2
    "Check if two balls are colliding"
    | distance |
    distance := (ball1 center - ball2 center) r.
    ^ distance < ball1 width! !

!PoolTableMorph methodsFor: 'collisions' stamp: 'arade 3/9/2025 19:21'!
checkPocketCollisions
    "Check if any balls have fallen into pockets"
    | ballsToRemove |
    ballsToRemove := OrderedCollection new.
    
    balls do: [:ball |
        pockets do: [:pocket |
            ((ball center - pocket center) r < 15) ifTrue: [
                ball isCueBall ifFalse: [
                    ballsToRemove add: ball.
                    score := score + 1.
                    Transcript show: 'current score: ', score printString; cr.
                ]
            ]
        ]
    ].
    
    ballsToRemove do: [:ball |
        ball delete.
        balls remove: ball
    ].! !

!PoolTableMorph methodsFor: 'collisions' stamp: 'arade 3/9/2025 19:21'!
handleBallCollisions
    "Check and handle collisions between balls"
    1 to: balls size do: [:i |
        (i + 1) to: balls size do: [:j |
            | ball1 ball2 |
            ball1 := balls at: i.
            ball2 := balls at: j.
            (self checkCollisionBetween: ball1 and: ball2) ifTrue: [
                self resolveBallCollision: ball1 with: ball2
            ]
        ]
    ].! !

!PoolTableMorph methodsFor: 'collisions' stamp: 'arade 3/9/2025 19:21'!
handleWallCollisions
    "Check and handle collisions with the edges of the pool table"
    balls do: [:ball |
        | pos |
        pos := ball position.
        
        "Left/Right edges"
        (pos x <= self position x or: [pos x >= (self position x + self extent x - ball width)]) ifTrue: [
            ball velocity: (ball velocity x negated @ ball velocity y)
        ].
        
        "Top/Bottom edges"
        (pos y <= self position y or: [pos y >= (self position y + self extent y - ball height)]) ifTrue: [
            ball velocity: (ball velocity x @ ball velocity y negated)
        ].
    ].! !

!PoolTableMorph methodsFor: 'collisions' stamp: 'arade 3/9/2025 19:21'!
resolveBallCollision: ball1 with: ball2
    "Resolve collision between two balls using elastic collision"
    | normal relativeVelocity |
    normal := (ball2 center - ball1 center) normalized.
    relativeVelocity := ball2 velocity - ball1 velocity.
    
    "Simple elastic collision response"
    ball1 velocity: ball1 velocity + (normal * relativeVelocity dotProduct: normal).
    ball2 velocity: ball2 velocity - (normal * relativeVelocity dotProduct: normal).! !


!PoolTableMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
handlesMouseDown: evt
    "Make sure we handle mouse down events"
    ^true
! !

!PoolTableMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
handlesMouseMove: evt
    "Make sure we handle mouse move events"
    ^true
! !

!PoolTableMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
handlesMouseUp: evt
    "Make sure we handle mouse up events"
    ^true
! !

!PoolTableMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
mouseDown: evt
    "Click to shoot"
    | cueBall |
    
    "Only process if we have a cue stick"
    cueStick ifNil: [^self].
    cueStick mouseDown: evt.

    " cueBall := balls detect: [:b | b isCueBall] ifNone: [^self]. "
    
    "If cue ball is not moving, shoot"
    " cueBall velocity r < 0.1 ifTrue: [
        cueStick shoot.
        cueStick := nil.
    ]. "
! !

!PoolTableMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
mouseMove: evt
    | mousePos cueBall tableMousePos |
    
    "Only process if we have a cue stick"
    cueStick ifNil: [^self].
    
    "Get mouse position in table's coordinate system"
    " mousePos := evt cursorPoint. "
    " tableMousePos := self globalPointToLocal: mousePos. "
    
    " cueBall := balls detect: [:b | b isCueBall] ifNone: [^self]. "
    
    " send mousemove event to cuestick with mouse event "
    cueStick mouseMove: evt.
! !

!PoolTableMorph methodsFor: 'event handling' stamp: 'arade 3/9/2025 19:21'!
mouseUp: evt
    cueStick mouseUp: evt.
    "Do nothing on mouse up"
! !
