(define (problem Q2-TestingProblem)
  (:domain Q2)
  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 slot4 - slot

    ;; --- ANTENNA
    antenna1 - antenna-bracket
    cam1 - visual-camera
    twrench1 - torque-wrench   
    gtool1 - grasping-tool
    spare1 - spare-bracket
    unload1 - unload

    ;; --- RADIATOR
    radiator1 - radiator
    profilometer1 - profilometer
    tape - thermal-tape
    printmat1 - print-material
    aextruder1 - additive-extruder
  )
  (:init
    ;; Maps connections: direct route to speed up the planner
    (connected docking-port esp-storage)
    (connected esp-storage antenna-site)
    (connected antenna-site radiator-site)
    

    ;; Robot start 
    (robot-at R esp-storage)
    (handempty R)
    (in-slot R cam1 slot1)
    (in-slot R twrench1 slot2)
    (in-slot R profilometer1 slot3)
    (in-slot R tape slot4)
    (is-new tape)

    ;; Gli attrezzi inutilizzati restano in magazzino
    (equipment-at gtool1 esp-storage)
    (equipment-at aextruder1 esp-storage)
    (equipment-at spare1 esp-storage)
    (is-new spare1)
    (equipment-at printmat1 esp-storage)
    (is-new printmat1)

    ;; Componenti e i loro stati
    (component-at antenna1 antenna-site)
    (component-at radiator1 radiator-site)
    (state antenna1 uninspected)   
    (state radiator1 uninspected)   

    ;; --- Compatibility 
    (sensor-compatible antenna1 cam1) 
    (damage-sensor-compatible is-loose cam1)
    (damage-tool-compatible is-loose twrench1)
    (become-unload antenna1 unload1)

    (sensor-compatible radiator1 profilometer1)   
    (damage-sensor-compatible thermal-bowing profilometer1)
    (damage-tool-compatible thermal-bowing tape)
    (damage-sensor-compatible structural-deformation profilometer1)
    (damage-tool-compatible structural-deformation aextruder1)

    ;; --- DEGRADATION (LA CORSA CONTRO IL TEMPO!) ---
    (= (vibration_level docking-port) 0)
    (= (vibration_level esp-storage) 0)
    (= (vibration_level antenna-site) 0.05) 
    (= (vibration_level radiator-site) 0)
        
    ;; ANTENNA - Parte a 0.09, si rompe (is-loose) a 0.1
    (= (phase_error antenna1) 0.09)
        
    ;; RADIATORE - Parte a 9.8, si piega (thermal-bowing) a 10.0
    (= (thermal_strain radiator1) 9.8) 
    (= (strain_rate radiator1) 0.1)
  )
  
  (:goal (and 
      (state antenna1 verified)
      (state radiator1 verified)))
)