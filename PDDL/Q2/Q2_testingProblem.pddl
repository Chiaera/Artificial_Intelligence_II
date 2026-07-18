(define (problem Q2-TestingProblem)
  (:domain Q2)

  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

    ;; --- ANTENNA
    antenna1 - antenna-bracket
    cam1 - visual-camera
        ;; is-loose
    twrench1 - torque-wrench   
        ;; cracked
    gtool1 - grasping-tool
    spare1 - spare-bracket
    unload1 - unload
    
    ;; --- RADIATOR
    radiator1 - radiator
    profilometer1 - profilometer
        ;; thermal-bowing
    tape - thermal-tape
        ;; structural-deformation
    printmat1 - print-material
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

    ;; Damaged component
    (component-at antenna1 antenna-site)
    (component-at radiator1 radiator-site)
    (state antenna1 uninspected)   
    (state radiator1 uninspected)   

    ;; Equipment in esp-storage
        ;; sensor:
    (equipment-at cam1 esp-storage)
    (equipment-at profilometer1 esp-storage)
        ;; tool:
    (equipment-at twrench1 esp-storage)
    (equipment-at gtool1 esp-storage)
    (equipment-at tape esp-storage)
    (is-new tape)
    (equipment-at aextruder1 esp-storage)
        ;; spare:
    (equipment-at spare1 esp-storage)
    (is-new spare1)
    (equipment-at printmat1 esp-storage)
    (is-new printmat1)

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

    ;; RADIATOR
    (sensor-compatible radiator1 profilometer1)   
        ;; bowing:
    (damage-sensor-compatible thermal-bowing profilometer1)
    (damage-tool-compatible thermal-bowing tape)
        ;; structural-deformation
    (damage-sensor-compatible structural-deformation profilometer1)
    (damage-tool-compatible structural-deformation aextruder1)

    ;; --- Degradation
    ;; location vibration
    (= (vibration_level docking-port) 0)
    (= (vibration_level esp-storage) 0)
    (= (vibration_level antenna-site) 0.01) 
    (= (vibration_level radiator-site) 0)
        
    ;; ANTENNA
    (= (phase_error antenna1) 0.09)
        
    ;; RADIATOR
    (= (thermal_strain radiator1) 10)
    (= (strain_rate radiator1) 0.05)
  )
  
  (:goal (and 
      (state radiator1 verified)))
)