(define (problem Q1-Testingproblem)
  (:domain Q1)

  (:objects
    R - robot
    docking-port antenna-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

    ;; --- ANTENNA
    antenna1 - antenna-bracket
    
    ;; is-loose:
    cam1 - visual-camera
    twrench1 - torque-wrench   

    ;; cracked-bracket:
    profilometer1 - profilometer
    grasper1 - grasping-tool
    spare-bracket1 - spare-bracket
    antenna1-debris - unload
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

    ;; --- Damaged component:
    ;;ANTENNA
    (component-at antenna1 antenna-site)
    (state antenna1 unknown)
    (become-unload antenna1 antenna1-debris)
    ;;(healthy antenna1)  ;;nominal antenna
    (component-damaged antenna1 cracked-bracket)  ;;damaged antenna

    ;; Equipment in esp-storage
    (equipment-at cam1 esp-storage)
    (equipment-at profilometer1 esp-storage)
    (equipment-at grasper1 esp-storage)
    (equipment-at twrench1 esp-storage)
    (equipment-at spare-bracket1 esp-storage)
    (is-new spare-bracket1)

    ;; --- Compatibility

    ;; ANTENNA is-loose
    (sensor-compatible antenna1 cam1)      
    (damage-sensor-compatible is-loose cam1)
    (damage-tool-compatible is-loose twrench1)

    ;; ANTENNA cracked-bracket
    (damage-sensor-compatible cracked-bracket cam1)  
    (damage-tool-compatible cracked-bracket grasper1) 
  )
  
  (:goal (state antenna1 verified))    
)