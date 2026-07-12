(define (problem Q1-Testingproblem)
  (:domain Q1)

  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

    ;; --- ANTENNA
    antenna1 - antenna-bracket
        ;; is-loose:
    cam1 - visual-camera
    twrench1 - torque-wrench   
        ;; cracked-bracket:
    grasper1 - grasping-tool
    spare-bracket1 - spare-bracket
    antenna1-debris - unload

    ;; --- RADIATOR
    radiator1 - radiator
    profilometer1 - profilometer
        ;; coolant-leak:
    cbypass1 - coolant-bypass
    creserver1 - coolant-reservoir
        ;; structural-deformation:
    aextruder1 - additive-extruder
  )
  
  (:init
    ;; Maps connections
    (connected docking-port esp-storage)
    (connected esp-storage docking-port)
    (connected esp-storage antenna-site)
    (connected antenna-site esp-storage)
    (connected esp-storage radiator-site)
    (connected radiator-site esp-storage)

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
    
    ;;RADIATOR
    (component-at radiator1 radiator-site)
    (state radiator1 unknown)
    ;;(healthy radiator1)  ;;nominal antenna
    (component-damaged radiator1 structural-deformation)  ;;damaged antenna
    

    ;; Equipment in esp-storage
        ;; sensor:
    (equipment-at cam1 esp-storage)
    (equipment-at profilometer1 esp-storage)
        ;; tool:
    (equipment-at grasper1 esp-storage)
    (equipment-at twrench1 esp-storage)
    (equipment-at cbypass1 esp-storage)
        ;; part
    (equipment-at spare-bracket1 esp-storage)
    (is-new spare-bracket1)
    (equipment-at creserver1 esp-storage)
    (is-new creserver1)
    (equipment-at aextruder1 esp-storage)
    (is-new aextruder1)


    ;; --- Compatibility

    ;; ANTENNA
    (sensor-compatible antenna1 cam1) 
        ;; is-loose     
    (damage-sensor-compatible is-loose cam1)
    (damage-tool-compatible is-loose twrench1)
        ;; cracked-bracket
    (damage-sensor-compatible cracked-bracket cam1)  
    (damage-tool-compatible cracked-bracket grasper1) 

    ;; RADIATOR 
    (sensor-compatible radiator1 profilometer1)     
        ;; coolant-leak
    (damage-sensor-compatible coolant-leak profilometer1)
    (damage-tool-compatible coolant-leak cbypass1)
        ;; structural-deformation
    (damage-sensor-compatible structural-deformation profilometer1)
  )
  
  (:goal (state radiator1 verified))    
)