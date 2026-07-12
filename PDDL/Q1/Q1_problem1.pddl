;; Problem1: simple instance with a simple degraded component.
;;      The broken component is the loose antenna, that requires a torque-wrench tool.
;;      To identify the damage it is necessary the vision-camera.
    
(define (problem Q1-problem1)
  (:domain Q1)

  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

    ;; ANTENNA is-loose
    antenna1 - antenna-bracket
    cam1 - visual-camera
    twrench1 - torque-wrench   
  )
  
  (:init
    ;; Maps connections
    (connected docking-port esp-storage)
    (connected esp-storage docking-port)
    (connected esp-storage antenna-site)
    (connected antenna-site esp-storage)

    ;; Original state R
    (robot-at R docking-port)
    (handempty R)
    (slot-free R slot1)
    (slot-free R slot2)
    (slot-free R slot3)

    ;; Damaged component
    (component-at antenna1 antenna-site)
    (state antenna1 unknown)
    (component-damaged antenna1 is-loose)     

    ;; Equipment in esp-storage
        ;; sensor:
    (equipment-at cam1 esp-storage)
        ;; tool:
    (equipment-at twrench1 esp-storage)

    ;; --- Compatibility

    (sensor-compatible antenna1 cam1) 
    (damage-sensor-compatible is-loose cam1)
    (damage-tool-compatible is-loose twrench1)
  )
  
  (:goal (state antenna1 verified))    
)