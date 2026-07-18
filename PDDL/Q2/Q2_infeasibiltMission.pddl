(define (problem Q2-Infeasible)
  (:domain Q2)
  (:objects
    R - robot
    docking-port esp-storage antenna-site radiator-site - location
    slot1 slot2 slot3 slot4 slot5 - slot

    antenna1 - antenna-bracket
    cam1 - visual-camera
    twrench1 - torque-wrench   
    unload1 - unload

    radiator1 - radiator
    profilometer1 - profilometer
    printmat1 - print-material
    aextruder1 - additive-extruder
  )
  (:init
    ;; Maps connections: direct route to speed up the planner
    ;; storage --> antenna-site --> radiator-site
    (connected docking-port esp-storage)
    (connected esp-storage antenna-site)
    (connected antenna-site radiator-site)

    ;; Solver semplification: robot starts with full slots
    (robot-at R docking-port)
    (handempty R)
    (in-slot R cam1 slot1)
    (in-slot R twrench1 slot2)
    (in-slot R profilometer1 slot3)
    (in-slot R aextruder1 slot4)
    (in-slot R printmat1 slot5)
    (is-new printmat1)

    ;; other part in the magazine
    (component-at antenna1 antenna-site)
    (component-at radiator1 radiator-site)
    (state antenna1 uninspected)   
    (state radiator1 uninspected)   
    (sensor-compatible antenna1 cam1) 
    (damage-sensor-compatible is-loose cam1)
    (damage-tool-compatible is-loose twrench1)
    (sensor-compatible radiator1 profilometer1)   
    (damage-sensor-compatible structural-deformation profilometer1)
    (damage-tool-compatible structural-deformation aextruder1)

    ;; --- Degradation
    (= (vibration_level docking-port) 0)
    (= (vibration_level esp-storage) 0)
    (= (vibration_level radiator-site) 0)
    (= (vibration_level antenna-site) 0.05) 
        
    ;; ANTENNA healty
    (= (phase_error antenna1) 0.05)
        
    ;; RADIATOR almost failed
    (= (thermal_strain radiator1) 29.0) 
    (= (strain_rate radiator1) 2.0)
  )
  
  (:goal (and 
      (state antenna1 verified)
      (state radiator1 verified)))
)