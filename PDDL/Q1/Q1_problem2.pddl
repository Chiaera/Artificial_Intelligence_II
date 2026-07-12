;; Problem2: non-trivial instance with multiple components and limited resources.
;;      Damaged parts are the cracked-bracket antenna and the coolant-leak radiator.
;;      The cracked antenna is repaired with a substituion(spare-bracket1) of the part helped by grasping tool. It generated a trash part(antenna1-debris).
;;      The coolant-leak requires the coolant-bypass tool(cbypass1) and a consumable resource (creserver1) that will be 'emptied'.
;;      Therefore, the robot can use only 3-slots.

(define (problem Q1-Testingproblem)
  (:domain Q1)

  (:objects
    R - robot
    docking-port antenna-site radiator-site - location
    esp-storage - storage
    slot1 slot2 slot3 - slot

    ;; ANTENNA cracked-bracket
    antenna1 - antenna-bracket
    cam1 - visual-camera
    grasper1 - grasping-tool
    spare-bracket1 - spare-bracket
    antenna1-debris - unload

    ;; RADIATOR coolant-leak
    radiator1 - radiator
    profilometer1 - profilometer
    cbypass1 - coolant-bypass
    creserver1 - coolant-reservoir
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
    (component-damaged antenna1 cracked-bracket)  
    
    ;;RADIATOR
    (component-at radiator1 radiator-site)
    (state radiator1 unknown)
    (component-damaged radiator1 coolant-leak)  
    

    ;; Equipment in esp-storage
        ;; sensor:
    (equipment-at cam1 esp-storage)
    (equipment-at profilometer1 esp-storage)
        ;; tool:
    (equipment-at grasper1 esp-storage)
    (equipment-at cbypass1 esp-storage)
        ;; part
    (equipment-at spare-bracket1 esp-storage)
    (is-new spare-bracket1)
    (equipment-at creserver1 esp-storage)
    (is-new creserver1)


    ;; --- Compatibility

    ;; ANTENNA
    (sensor-compatible antenna1 cam1) 
    (damage-sensor-compatible cracked-bracket cam1)  
    (damage-tool-compatible cracked-bracket grasper1) 

    ;; RADIATOR 
    (sensor-compatible radiator1 profilometer1)     
    (damage-sensor-compatible coolant-leak profilometer1)
    (damage-tool-compatible coolant-leak cbypass1)
  )
  
  (:goal (and (state antenna1 verified) (state radiator1 verified)))    
)