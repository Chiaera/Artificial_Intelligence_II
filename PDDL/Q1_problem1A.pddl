(define (problem Q1-problem1A)
  (:domain Q1A)

  (:objects
    robot-1 - robot
    docking-port esp-storage antenna-site - location
    antenna-bracket-1 - antenna-bracket
    visual-camera-1 - visual-camera
    torque-wrench-1 - torque-wrench 
    slot-1 slot-2 slot-3 - slot
  )
  
  (:init
    (connected docking-port esp-storage)
    (connected esp-storage docking-port)
    (connected esp-storage antenna-site)
    (connected antenna-site esp-storage)
    
    (robot-at robot-1 docking-port)
    (handempty robot-1)
    (slot-free robot-1 slot-1)
    (slot-free robot-1 slot-2)
    (slot-free robot-1 slot-3)
    
    (component-at antenna-bracket-1 antenna-site)
    (is-loose antenna-bracket-1)
    (controlled antenna-bracket-1)
    
    (tool-at torque-wrench-1 esp-storage)
    (sensor-at visual-camera-1 esp-storage)
  )
  
  (:goal (verified antenna-bracket-1))
)