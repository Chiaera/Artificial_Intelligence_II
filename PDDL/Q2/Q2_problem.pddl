;; Q2-Problem: solvable instance with continuous degradation already in progress.
;;      The antenna starts with an accumulated phase_error (0.15), already in the is-loose state.
;;      The radiator starts with a high thermal_strain (25.0) but a low strain_rate (0.25),
;;      leaving a wide time margin before reaching the failure threshold (30.0).

;;      The robot starts with all 5 slots pre-equipped with the required tools.

(define (problem Q2-Problem)
  (:domain Q2)
  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 slot4 slot5 - slot

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
    ;; Maps connections
    (connected docking-port esp-storage)
    (connected esp-storage antenna-site)
    (connected antenna-site radiator-site)
    
    ;; Solver simplification: 5 Slots with the needed parts
    (robot-at R docking-port)
    (handempty R)
    (in-slot R cam1 slot1)
    (in-slot R twrench1 slot2)
    (in-slot R profilometer1 slot3)
    (in-slot R printmat1 slot4)
    (in-slot R aextruder1 slot5)
    (is-new printmat1)
    (state antenna1 uninspected) 
    (state radiator1 uninspected) 
    
    ;; Other parts left in the magazine
    (equipment-at tape esp-storage)
    (is-new tape)
    (equipment-at gtool1 esp-storage)
    (equipment-at spare1 esp-storage)
    (is-new spare1)

    (component-at antenna1 antenna-site)
    (component-at radiator1 radiator-site)

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

    ;; --- Degradation
    (= (vibration_level docking-port) 0)
    (= (vibration_level esp-storage) 0)
    (= (vibration_level antenna-site) 0.05) 
    (= (vibration_level radiator-site) 0)
        
    ;; ANTENNA already loose
    (= (phase_error antenna1) 0.15) 
    (component-damaged antenna1 is-loose) 
        
    ;; RADIATOR already structural-deformation
    (= (thermal_strain radiator1) 25.0) 
    (component-damaged radiator1 structural-deformation)
    (= (strain_rate radiator1) 0.25)
    (paint_is_degraded radiator1)
    (= (layers_printed radiator1) 0)
    (= (layers_to_print radiator1) 5.0)
  )
  
  (:goal (and 
      (state antenna1 verified)
      (state radiator1 verified)))
)