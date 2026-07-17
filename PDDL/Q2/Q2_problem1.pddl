(define (problem Q2-problem1)
  (:domain Q2)

  (:objects
    R - robot
    docking-port antenna-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

    ;; ANTENNA is-loose
    antenna1 - antenna-bracket
    cam1 - visual-camera
    twrench1 - torque-wrench   

    ;; ANTENNA cracked
    gtool1 - grasping-tool
    spare1 - spare-bracket
    unload1 - unload
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
    (state antenna1 uninspected)   

    ;; Equipment in esp-storage
        ;; sensor:
    (equipment-at cam1 esp-storage)
        ;; tool:
    (equipment-at twrench1 esp-storage)
    (equipment-at gtool1 esp-storage)
        ;; spare:
    (equipment-at spare1 esp-storage)
    (is-new spare1)

    ;; --- Compatibility 
    ;; ANTENNA
    (sensor-compatible antenna1 cam1) 
        ;; is loose:
    (damage-sensor-compatible is-loose cam1)
    (damage-tool-compatible is-loose twrench1)
        ;; cracked:
    (damage-sensor-compatible cracked-bracket cam1)
    (damage-tool-compatible cracked-bracket gtool1)
    (become-unload antenna1 unload1)

    ;; --- Degradation
    (= (phase_error antenna1) 0.2)
    (= (vibration_level antenna-site) 0.005)
  )
  
  (:goal (and (state antenna1 verified)))
)