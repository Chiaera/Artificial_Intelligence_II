(define (domain Q2)
  (:requirements :strips :typing :negative-preconditions :numeric-fluents :durative-actions :continuous-effects :time)
  (:types robot location slot component status equipment damage - object
      ;;physical object
      tool sensor part - equipment
      antenna-bracket radiator - component
      torque-wrench grasping-tool additive-extruder thermal-tape - tool 
      visual-camera profilometer - sensor
      spare-bracket unload print-material - part
      storage - location)
  (:constants   ;;state global concepts
      uninspected inspected nominal degraded repaired verified failed - status     ;; unknown chaged to 'uninspected' wrt Q1 for the new parser
      is-loose cracked-bracket thermal-bowing structural-deformation - damage)
  (:predicates  
    ;; Component state
    (state ?c - component ?s - status)
    (paint_is_degraded ?r - radiator)

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

  ;; FUNCTIONS
  ;; to determine the levels for the diagnosis of the component
  (:functions  
    ;; ANTENNA for thermic variation and thermical variations
    (phase_error ?a - antenna-bracket)    ;;cumulative phase error 
    (vibration_level ?loc - location)     ;;mechanics stress

    ;; RADIATOR structural-deformation from thermical variations
    (thermal_strain ?r - radiator)  ;;cumulative structural stress 
    (strain_rate ?r - radiator)        ;;semplification: constant stress increased velocity
  )

  ;;--------------------------------------------------------

  ;; PROCESS
  ;; continuous ANTENNA degradation phase-error(thermic variation/mechanic stress) --> loose --> cracked --> failed
  (:process degrade_antenna_phase
      :parameters (?a - antenna-bracket ?loc - location)
      :precondition (and 
          (component-at ?a ?loc)
          (> (vibration_level ?loc) 0) 
          (not (state ?a failed))
          (< (phase_error ?a) 1)) ;; limit for paser
      :effect (and (increase (phase_error ?a) (* #t (vibration_level ?loc))))) ;;linearization of the formula for the structural deformation

  ;; continuous RADIATOR degradation for thermal variations and paint degradation
  (:process increased_thermal_strain
      :parameters (?r - radiator)
      :precondition (and 
          (not (state ?r failed))
          (< (thermal_strain ?r) 40.0)) ;;parser limitation
      :effect (increase (thermal_strain ?r) (* #t (strain_rate ?r))))
  ;;--------------------------------------------------------

  ;; EVENT 
  ;; phase-error that brings to loose ANTENNA
  (:event antenna_becomes_loose
      :parameters (?a - antenna-bracket)
      :precondition (and 
          ;; (state ?a nominal) NO because it tell directly to parser that component is degraded (without inspection)
          (>= (phase_error ?a) 0.1) ;;Loose threshold
          (not (component-damaged ?a is-loose))
          (not (component-damaged ?a cracked-bracket))
          (not (state ?a failed)))
      :effect (and 
          (component-damaged ?a is-loose)
          (not (healthy ?a))))

  ;; loose ANTENNA can bring to cracked
  (:event antenna-becomes-cracked
      :parameters (?a - antenna-bracket)
      :precondition (and 
          (component-damaged ?a is-loose)
          (>= (phase_error ?a) 0.2)) ;;Cracked threshold
    :effect (and 
        (not (component-damaged ?a is-loose))
        (component-damaged ?a cracked-bracket)))

  ;; cracked ANTENNA can bring to failed state
  (:event antenna_failed
      :parameters (?a - antenna-bracket)
      :precondition (and 
          (component-damaged ?a cracked-bracket)
          (>= (phase_error ?a) 0.3))
      :effect (and 
          (state ?a failed)
          (not (component-damaged ?a cracked-bracket))))

  ;; cumulative stres can bring to bowing RADIATOR
  (:event radiator_starts_bowing
      :parameters (?r - radiator)
      :precondition (and 
          (>= (thermal_strain ?r) 10.0)     
          (not (component-damaged ?r thermal-bowing))
          (not (component-damaged ?r structural-deformation))
          (not (state ?r failed)))
      :effect (and 
          (component-damaged ?r thermal-bowing)
          (not (healthy ?r))))
  
  ;; bowed RADIATOR can bring to a permanent structural deformation
  (:event radiator_structural_failure
    :parameters (?r - radiator)
    :precondition (and 
          (component-damaged ?r thermal-bowing)
          (>= (thermal_strain ?r) 20.0))
    :effect (and 
        (not (component-damaged ?r thermal-bowing))
        (component-damaged ?r structural-deformation)))

  ;; RADIATOR structural deformation can bring to failed state
  (:event radiator_failed
      :parameters (?r - radiator)
      :precondition (and 
          (component-damaged ?r structural-deformation)
          (>= (thermal_strain ?r) 30))
      :effect (and 
          (state ?r failed)
          (not (component-damaged ?r structural-deformation))))

  ;;--------------------------------------------------------

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
          (robot-at ?r ?to)
          (increase (vibration_level ?to) 0.05))) ;;movements in space increase mechanics vibration
  ;;---------------------------------------------

  ;; INSPECTION
  ;; sensor collects data on the component and active the 'inspected' state

  (:action inspect-component
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor)
      :precondition (and
          (state ?c uninspected)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?s)
          (sensor-compatible ?c ?s)
      )  
      :effect(and
          (not (state ?c uninspected))
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
  (:action nominal-diagnosis-radiator
      :parameters (?c - radiator ?s - sensor)
      :precondition (and
          (state ?c inspected)
          (data-stored ?c ?s)   
          (healthy ?c)
          (< (thermal_strain ?c) 10.0))
      :effect (and
          (not (state ?c inspected))
          (not (data-stored ?c ?s))      
          (state ?c nominal)))
        
  (:action nominal-diagnosis-antenna
      :parameters (?a - antenna-bracket ?s - sensor)
      :precondition (and
          (state ?a inspected)
          (data-stored ?a ?s)    
          (healthy ?a)
          (< (phase_error ?a) 0.1)) 
      :effect (and
          (not (state ?a inspected))
          (not (data-stored ?a ?s))      
          (state ?a nominal)))
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
          (state ?c repaired)
          (assign (phase_error ?c) 0)
          (assign (vibration_level ?loc) 0)))

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
          (state ?c repaired)
          (assign (phase_error ?c) 0)
          (assign (vibration_level ?loc) 0)))

  ;; bowing RADIATOR
  ;; repaired by applying thermal tape
  (:action bowing-radiator-reparation
      :parameters (?r - robot ?loc - location ?c - radiator ?t - thermal-tape)
      :precondition (and
          (state ?c degraded)
          (component-damaged ?c thermal-bowing)
          (damage-tool-compatible thermal-bowing ?t)
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-equipment ?r ?t)
          (is-new ?t)) 
      :effect (and
          (not (component-damaged ?c thermal-bowing))
          (not (is-new ?t))
          (not (has-equipment ?r ?t))
          (handempty ?r) 
          (not (state ?c degraded))  
          (state ?c repaired)
          (assign (thermal_strain ?c) 0)
          (assign (strain_rate ?c) 0.05) 
          (not (paint_is_degraded ?c))))

  ;; structural-deformation RADIATOR
  ;; repaired with an addiction of print-material thru extrusion materials
  (:action structural-deformation-reparation
    :parameters (?r - robot ?loc - location ?c - radiator ?t - additive-extruder ?m - print-material ?sl - slot)
    :precondition (and
        (state ?c degraded)
        (component-damaged ?c structural-deformation)
        (damage-tool-compatible structural-deformation ?t)
        (robot-at ?r ?loc)
        (component-at ?c ?loc)
        (has-equipment ?r ?t)
        (in-slot ?r ?m ?sl)
        (is-new ?m))
    :effect (and
        (not (component-damaged ?c structural-deformation))
        (not (is-new ?m))
        (not (state ?c degraded))
        (state ?c repaired)
        (assign (thermal_strain ?c) 0)
          (assign (strain_rate ?c) 0.05)
        (not (paint_is_degraded ?c))))
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