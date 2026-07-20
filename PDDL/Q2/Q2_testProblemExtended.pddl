;; Testing problem
;;      Problem for studying the continuous repair process related to the structural deformation of the radiator

(define (problem Q2-TestingExtendedProblem)
  (:domain Q2)

  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

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
    (component-at radiator1 radiator-site)
    (state radiator1 uninspected)   

    ;; Equipment in esp-storage
        ;; sensor:
    (equipment-at profilometer1 esp-storage)
        ;; tool:
    (equipment-at tape esp-storage)
    (is-new tape)
    (equipment-at aextruder1 esp-storage)
        ;; spare:
    (equipment-at printmat1 esp-storage)
    (is-new printmat1)

    ;; --- Compatibility 
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
        
    ;; RADIATOR
    ;; structural-deformation 
    (= (thermal_strain radiator1) 20.0)
    (= (strain_rate radiator1) 0)   

    (= (layers_printed radiator1) 0)
    (= (layers_to_print radiator1) 5.0)
  )
  
  (:goal (and 
      (state radiator1 verified)))
)