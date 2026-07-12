(define (domain Q1)
  (:requirements :strips :typing :negative-preconditions)
  (:types robot location slot component state equipment damage - object
      ;;physical object
      tool sensor part - equipment
      antenna-bracket radiator - component
      torque-wrench grasping-tool coolant-bypass - tool 
      visual-camera profilometer - sensor
      spare-bracket unload coolant-reservoir additive-extruder - part
      storage - location)
  (:constants   ;;state global concepts
      unknown inspected nominal degraded repaired verified - state
      is-loose cracked-bracket coolant-leak structural-deformation - damage)
  (:predicates  
    ;; Component state
    (state ?c - component ?s - state)

    ;; Robot state
    (robot-at ?r - robot ?loc - location)           ;;robot position
    (component-at ?c - component ?loc - location)   ;;component position
    (equipment-at ?e - equipment ?loc - location)   ;;equipment position
    (slot-free ?r - robot ?sl - slot)                        ;;robot has free slot
    (in-slot ?r - robot ?e - equipment ?sl - slot)      ;;equipment is in slot
    (handempty ?r - robot)                      ;;robot has no tool in hand
    (has-equipment ?r - robot ?e - equipment)   ;;robot has equipment in hand      
    (sensor-compatible ?c - component ?s - sensor)       ;;sensor compatibility with the component

    ;; Location state
    (connected ?loc1 - location ?loc2 - location)   ;;NO symmetry

    ;; Ispection
    (data-stored ?c - component ?s - sensor)

    ;; Diagnosis
    (healthy ?c - component)
    (component-damaged ?c - component ?d - damage)
    (damage-sensor-compatible ?d - damage ?s - sensor) 

    ;; Repair
    (damage-tool-compatible ?d - damage ?t - tool)
    (is-new ?sp - part)    ;;spare part to insert
    (is-broken ?sp - part) ;;component substituted
    (become-unload ?c - component ?u - unload)  ;;the substituted componend become unload
  )

  ;;-----------------------------------------------

  ;; EQUIPMENT (tool/sensor/part) MOVEMENT
  ;; take equipment (tool or sensor) from storage 
  (:action unstore-equipment
      :parameters (?r - robot ?loc - storage ?e - equipment)      
      :precondition (and   
          (robot-at ?r ?loc)
          (equipment-at ?e ?loc)
          (handempty ?r))
      :effect (and                
          (not (equipment-at ?e ?loc))
          (not (handempty ?r))
          (has-equipment ?r ?e)))
  
  ;; put equipment (tool/sensor/part) in storage
  (:action store-equipment
      :parameters (?r - robot ?loc - storage ?e - equipment)      
      :precondition (and   
          (robot-at ?r ?loc)
          (has-equipment ?r ?e)
          (not (handempty ?r)))
      :effect (and                
          (equipment-at ?e ?loc)
          (handempty ?r)
          (not (has-equipment ?r ?e))))

  ;; take equipment (tool/sensor/part) from storage 
  (:action take-from-slot
      :parameters (?r - robot ?s - slot ?e - equipment)      
      :precondition (and   
          (in-slot ?r ?e ?s)
          (handempty ?r))
      :effect (and                
          (not (in-slot ?r ?e ?s))
          (slot-free ?r ?s)
          (not (handempty ?r))
          (has-equipment ?r ?e)))

  ;; put equipment (tool/sensor/part) in slot
  (:action put-in-slot
      :parameters (?r - robot ?e - equipment ?s - slot)      
      :precondition (and 
          (slot-free ?r ?s)
          (not (handempty ?r))
          (has-equipment ?r ?e))
      :effect (and            
          (handempty ?r)
          (not (slot-free ?r ?s))
          (in-slot ?r ?e ?s)
          (not (has-equipment ?r ?e)))
  )


  ;;------------------------------------------
  ;; MOVE ROBOT
  (:action move 
      :parameters (?r - robot ?from ?to - location)      
      :precondition (and
          (robot-at ?r ?from) 
          (connected ?from ?to))
      :effect (and
          (not (robot-at ?r ?from))
          (robot-at ?r ?to)))
  ;;---------------------------------------------

  ;; INSPECTION
  ;; sensor collects data on the component and active the 'inspected' state

  (:action inspect-component
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor)
      :precondition (and
          (state ?c unknown)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?s)
          (sensor-compatible ?c ?s)
      )  
      :effect(and
          (not (state ?c unknown))
          (state ?c inspected)
          (data-stored ?c ?s)))
  ;;--------------------------------------------- 

  ;; DIAGNOSIS
  ;; used inspected dato to detect the component problem and active the 'diagnosed' state
  (:action degraded-diagnosis
      :parameters (?c - component ?d - damage ?s - sensor)
      :precondition (and
          (state ?c inspected)
          (data-stored ?c ?s)
          (component-damaged ?c ?d)
          (damage-sensor-compatible ?d ?s))
      :effect (and
          (not (state ?c inspected))
          (not (data-stored ?c ?s))
          (state ?c degraded)))

  ;; if the component is not degraded, active 'nominal' state
  (:action nominal-diagnosis
      :parameters (?c - component ?s - sensor)
      :precondition (and
          (state ?c inspected)
          (data-stored ?c ?s)            
          (healthy ?c))
      :effect (and
          (not (state ?c inspected))
          (not (data-stored ?c ?s))      
          (state ?c nominal)))
  ;;-----------------------------------------------------

  ;; REPAIR
  ;; every component has its own way to be repaired, based on tools

  ;; Loose ANTENNA
  ;; repaired with a torque-wrench tool
  (:action loose-antenna-reparation
      :parameters (?r - robot ?loc - location ?c - antenna-bracket ?t - torque-wrench)
      :precondition (and
          (state ?c degraded)
          (component-damaged ?c is-loose)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?t)
          (damage-tool-compatible is-loose ?t))
      :effect (and
          (not (component-damaged ?c is-loose))
          (not (state ?c degraded))
          (state ?c repaired))) 

  ;; cracked ANTENNA
  ;; repaired with a substitution thru grasping-tool
  (:action cracked-bracket-reparation
      :parameters (?r - robot ?loc - location ?c - antenna-bracket ?t - grasping-tool ?sp - spare-bracket ?sl - slot ?u - unload)
      :precondition (and
          (state ?c degraded)
          (component-damaged ?c cracked-bracket)
          (damage-tool-compatible cracked-bracket ?t)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?t)
          (in-slot ?r ?sp ?sl)
          (is-new ?sp)
          (become-unload ?c ?u))
      :effect (and
          (not (component-damaged ?c cracked-bracket))
          (not (state ?c degraded))
          (not (in-slot ?r ?sp ?sl))    
          (in-slot ?r ?u ?sl)      
          (is-broken ?u)
          (state ?c repaired)))

  ;; coolant-leak RADIATOR
  ;; repaired with an addiction of coolant thru coolant-bypass-tool
  (:action coolant-radiator-reparation
      :parameters (?r - robot ?loc - location ?c - radiator ?t - coolant-bypass ?p - coolant-reservoir ?sl - slot)
      :precondition (and
          (state ?c degraded)
          (component-damaged ?c coolant-leak)
          (damage-tool-compatible coolant-leak ?t)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (in-slot ?r ?p ?sl)
          (has-equipment ?r ?t)
          (is-new ?p))
      :effect (and
          (not (component-damaged ?c coolant-leak))
          (not (is-new ?p))
          (not (state ?c degraded))  
          (state ?c repaired)))

  ;; structural-deformation RADIATOR
  ;; repaired with an addiction of extrusion materials
  (:action structural-deformation-reparation
      :parameters (?r - robot ?loc - location ?c - radiator ?p - additive-extruder)
      :precondition (and
          (state ?c degraded)
          (component-damaged ?c structural-deformation)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?p)
          (is-new ?p))
      :effect (and
          (not (component-damaged ?c structural-deformation))
          (not (is-new ?p))
          (is-broken ?p)
          (not (state ?c degraded))  
          (state ?c repaired)))
  ;;---------------------------------------------------------------

  ;; VERIFIED
  ;; convalidate the nominal status of the component
  (:action repaired-verify
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor)
      :precondition (and
          (state ?c repaired)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?s)
          (sensor-compatible ?c ?s)
      )  
      :effect(and
          (not (state ?c repaired))
          (state ?c verified)))

  ;; formal verification
  (:action nominal-verify
      :parameters (?c - component)
      :precondition (state ?c nominal)
      :effect (and
          (not (state ?c nominal))     
          (state ?c verified)))
)