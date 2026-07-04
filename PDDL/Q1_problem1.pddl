;; PROBLEM 1 - simple instance with a single degraded component
;; Antenna bracket is cracked and needs to be replaced by the robot using a grasping tool and a spare bracket.
;; The robot starts at the docking port, the antenna bracket is at the antenna site, and the visual camera and torque wrench are at the ESP storage.

(define (problem Q1-problem1)
  (:domain Q1)

  (:objects
    ;; Robot
    robot-1 - robot
    
    ;; Locations
    docking-port esp-storage antenna-site radiator-site - location
    
    ;; Components
    antenna-bracket-1 - antenna-bracket
    
    ;; Sensor
    visual-camera-1 - visual-camera

    ;; Tool
    grasping-tool-1 - grasping-tool
    
    ;; Spare
    spare-bracket-1 - spare-bracket
    
    ;; Slot (3 slot)
    slot-1 slot-2 slot-3 - slot
  )
  
  (:init
    ;; Locations
    (connected docking-port esp-storage)
    (connected esp-storage docking-port)
    (connected esp-storage antenna-site)
    (connected antenna-site esp-storage)
    (connected antenna-site radiator-site)
    (connected radiator-site antenna-site)
    (connected esp-storage radiator-site) 
    (connected radiator-site esp-storage) 
    
    ;; Robot
    (robot-at robot-1 docking-port)
    (handempty robot-1)
    (slot-free robot-1 slot-1)
    (slot-free robot-1 slot-2)
    (slot-free robot-1 slot-3)
    
    ;; Components
    (component-at antenna-bracket-1 antenna-site)
    (cracked-bracket antenna-bracket-1)   ;; damage
    (controlled antenna-bracket-1)    ;; state
    
    ;; Storage
    (tool-at grasping-tool-1 esp-storage)
    (sensor-at visual-camera-1 esp-storage)
    (spare-at spare-bracket-1 esp-storage)
  )
  
  (:goal (verified antenna-bracket-1))
)