(define (domain Q1)
  (:requirements :strips :typing :negative-preconditions)
  (:types robot location tool sensor slot component spare-component - object
      antenna-bracket radiator - component
      torque-wrench grasping-tool coolant-bypass-tool additive-extruder - tool 
      visual-camera profilometer-3d ultrasonic-sensor thermal-camera - sensor 
      spare-bracket coolant-reservoir - spare-component)
  (:predicates
    ;; Component state
    (unknown ?c - component)
    (inspected ?c - component)
    (diagnosed ?c - component)
    (repaired ?c - component)
    (verified ?c - component)
    (nominal ?c - component)

    ;; Robot state
    (robot-at ?r - robot ?loc - location)     ;;robot position
    (component-at ?c - component ?loc - location)    ;;component position
    (tool-at ?t - tool ?loc - location)        ;;tool position
    (sensor-at ?s - sensor ?loc - location)    ;;sensor position
    (spare-at ?sp - spare-component ?loc - location) ;;spare part position
    (slot-free ?r - robot ?s - slot)                 ;;robot has free slot
    (in-slot-tool ?r - robot ?t - tool ?slot - slot) ;;tool is in the slot of robot
    (in-slot-sensor ?r - robot ?s - sensor ?slot - slot)  ;;sensor is in the slot of robot  
    (handempty ?r - robot)                    ;;robot has no tool in hand
    (has-tool ?r - robot ?t - tool)            ;;robot has tool in hand
    (has-sensor ?r - robot ?s - sensor)      ;;robot has sensor in hand
    (has-spare ?r - robot ?sp - spare-component) ;;robot carries a spare part/consumable

    ;; Location state
    (connected ?loc1 - location ?loc2 - location) ;;locations are connected

    ;; Component damage 
    (is-loose ?c - antenna-bracket)
    (cracked-bracket ?c - antenna-bracket)
    (coolant-leak ?c - radiator)
    (structural-deformation ?c - radiator)
  )

  ;; TOOL
  ;; take tool from storage
  (:action unstore-tool
      :parameters (?r - robot ?loc - location ?t - tool)      ;; RIMOZIONE: ?s - slot non usato
      :precondition (and   
          (robot-at ?r ?loc)
          (tool-at ?t ?loc)
          (handempty ?r))
      :effect (and                
          (not (tool-at ?t ?loc))
          (not (handempty ?r))
          (has-tool ?r ?t))
  )

  ;; put tool in storage
  (:action store-tool
      :parameters (?r - robot ?loc - location ?t - tool)      ;; RIMOZIONE: ?s - slot non usato
      :precondition (and   
          (robot-at ?r ?loc)
          (has-tool ?r ?t))
      :effect (and                
          (tool-at ?t ?loc)
          (handempty ?r)
          (not (has-tool ?r ?t)))
  )

  ;; take tool from slot
  (:action take-tool-from-slot
      :parameters (?r - robot ?t - tool ?s - slot)      
      :precondition (and   
          (not (slot-free ?r ?s))
          (handempty ?r)
          (in-slot-tool ?r ?t ?s))
      :effect (and                
          (slot-free ?r ?s)
          (not (handempty ?r))
          (has-tool ?r ?t)      
          (not (in-slot-tool ?r ?t ?s)))    
  )

  ;; put tool in slot
  (:action put-tool-in-slot
      :parameters (?r - robot ?t - tool ?s - slot)      
      :precondition (and   
          (slot-free ?r ?s)
          (has-tool ?r ?t)    
          (not (handempty ?r)))
      :effect (and            
          (handempty ?r)
          (not (slot-free ?r ?s))
          (in-slot-tool ?r ?t ?s)
          (not (has-tool ?r ?t)))     
  )

  ;;----------------------------------------

  ;; SENSOR
  ;; take sensor from storage
  (:action unstore-sensor
      :parameters (?r - robot ?loc - location ?s - sensor)      ;; RIMOZIONE: ?slot - slot non usato
      :precondition (and   
          (robot-at ?r ?loc)
          (sensor-at ?s ?loc)
          (handempty ?r))
      :effect (and                
          (not (sensor-at ?s ?loc))
          (not (handempty ?r))
          (has-sensor ?r ?s))
  )

  ;; put sensor in storage
  (:action store-sensor
      :parameters (?r - robot ?loc - location ?s - sensor)      ;; RIMOZIONE: ?slot - slot non usato
      :precondition (and   
          (robot-at ?r ?loc)
          (has-sensor ?r ?s))
      :effect (and                
          (sensor-at ?s ?loc)
          (handempty ?r)
          (not (has-sensor ?r ?s)))
  )

  ;; take sensor from slot
  (:action take-sensor-from-slot
      :parameters (?r - robot ?s - sensor ?slot - slot)      
      :precondition (and   
          (not (slot-free ?r ?slot))
          (handempty ?r)
          (in-slot-sensor ?r ?s ?slot))
      :effect (and                
          (slot-free ?r ?slot)
          (not (handempty ?r))
          (has-sensor ?r ?s)      
          (not (in-slot-sensor ?r ?s ?slot)))      
  )

  ;; put sensor in slot
  (:action put-sensor-in-slot
      :parameters (?r - robot ?s - sensor ?slot - slot)      
      :precondition (and   
          (slot-free ?r ?slot)
          (has-sensor ?r ?s)     
          (not (handempty ?r)))
      :effect (and            
          (handempty ?r)
          (not (slot-free ?r ?slot))
          (in-slot-sensor ?r ?s ?slot)
          (not (has-sensor ?r ?s)))     
  ) 

  ;;----------------------------------------

  ;; SPARE COMPONENTS
  ;; take spare part from esp-storage (when taken -> used-up)
  (:action unstore-spare
      :parameters (?r - robot ?loc - location ?sp - spare-component)      
      :precondition (and   
          (robot-at ?r ?loc)
          (spare-at ?sp ?loc)
          (handempty ?r))
      :effect (and                
          (not (spare-at ?sp ?loc))
          (not (handempty ?r))
          (has-spare ?r ?sp))
  )

  ;; put spare part back in storage
  (:action store-spare
      :parameters (?r - robot ?loc - location ?sp - spare-component)      
      :precondition (and   
          (robot-at ?r ?loc)
          (has-spare ?r ?sp))
      :effect (and                
          (spare-at ?sp ?loc)
          (handempty ?r)
          (not (has-spare ?r ?sp)))
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
          (robot-at ?r ?to))
  )
  ;;---------------------------------------------

  ;; INSPECTION
  (:action inspect-component
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor)
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (unknown ?c))  
      :effect (and
          (not (unknown ?c))
          (inspected ?c)
          (not (has-sensor ?r ?s))     
          (handempty ?r))      
  )
  ;;--------------------------------------------- 

  ;; DIAGNOSIS

  ;; ANTENNA-BRACKET can be diagnosed as loose, cracked, or nominal
  (:action diagnose-loose-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?s - sensor)      ;; RIMOZIONE: ?t - tool → ?s - sensor
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (inspected ?c)
          (is-loose ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (not (has-sensor ?r ?s))      
          (handempty ?r))     
  )
  (:action diagnose-cracked-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?s - sensor)      ;; RIMOZIONE: ?t - tool → ?s - sensor
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (inspected ?c)
          (cracked-bracket ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (not (has-sensor ?r ?s))     
          (handempty ?r))     
  )
  ;; if there is no problem the antenna-bracket is diagnosed as nominal
  (:action diagnose-nominal-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?s - sensor)      ;; RIMOZIONE: ?t - tool → ?s - sensor
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (inspected ?c)
          (not (is-loose ?c))
          (not (cracked-bracket ?c)))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (nominal ?c)
          (not (has-sensor ?r ?s))      
          (handempty ?r))     
  )

  ;; RADIATOR can be diagnosed as coolant-leak, structural-deformation, or nominal
  (:action diagnose-coolant-leak
      :parameters (?r - robot ?c - radiator ?loc - location ?s - sensor)      ;; RIMOZIONE: ?t - tool → ?s - sensor
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (inspected ?c)
          (coolant-leak ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (not (has-sensor ?r ?s))     
          (handempty ?r))     
  )
  (:action diagnose-structural-deformation
      :parameters (?r - robot ?c - radiator ?loc - location ?s - sensor)      ;; RIMOZIONE: ?t - tool → ?s - sensor
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (inspected ?c)
          (structural-deformation ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (not (has-sensor ?r ?s))      
          (handempty ?r))     
  )
  (:action diagnose-nominal-radiator
      :parameters (?r - robot ?c - radiator ?loc - location ?s - sensor)      ;; RIMOZIONE: ?t - tool → ?s - sensor
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (inspected ?c)
          (not (coolant-leak ?c))
          (not (structural-deformation ?c)))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (nominal ?c)
          (not (has-sensor ?r ?s))     
          (handempty ?r))     
  )
  ;;---------------------------------------------

  ;; REPAIR

  ;; ANTENNA-BRACKET
  ;; loose antenna is repaired by torque-wrench tool (mechanical tightening, no consumable)
  (:action repair-loose-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?t - torque-wrench)      ;; RIMOZIONE: ?t - tool → ?t - torque-wrench
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-tool ?r ?t)
          (diagnosed ?c)
          (is-loose ?c))  
      :effect (and
          (not (diagnosed ?c))
          (not (is-loose ?c))
          (repaired ?c)
          (not (has-tool ?r ?t))      
          (handempty ?r))      
  )

  ;; cracked antenna bracket is repaired by 
  ;; - substitution: grasping tool 
  ;; - removes the cracked bracket 
  ;; - installs the spare-bracket (consumable) 
  (:action repair-cracked-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?t - grasping-tool ?sp - spare-bracket)      ;; RIMOZIONE: ?t - tool → ?t - grasping-tool
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-tool ?r ?t)
          (has-spare ?r ?sp)
          (diagnosed ?c)
          (cracked-bracket ?c))  
      :effect (and
          (not (diagnosed ?c))
          (not (cracked-bracket ?c))
          (not (has-spare ?r ?sp))
          (repaired ?c)
          (not (has-tool ?r ?t))     
          (handempty ?r))     
  )

  ;; RADIATOR
  ;; coolant leak is repaired by 
  ;; - the bypass tool 
  ;; - recharge from a coolant-reservoir (consumable)
  (:action repair-coolant-leak
      :parameters (?r - robot ?c - radiator ?loc - location ?t - coolant-bypass-tool ?sp - coolant-reservoir)      ;; RIMOZIONE: ?t - tool → ?t - coolant-bypass-tool
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-tool ?r ?t)
          (has-spare ?r ?sp)
          (diagnosed ?c)
          (coolant-leak ?c))  
      :effect (and
          (not (diagnosed ?c))
          (not (coolant-leak ?c))
          (not (has-spare ?r ?sp))
          (repaired ?c)
          (not (has-tool ?r ?t))      
          (handempty ?r))     
  )

  ;; structural deformation is repaired by the additive-extruder tool.
  (:action repair-structural-deformation
      :parameters (?r - robot ?c - radiator ?loc - location ?t - additive-extruder)      ;; RIMOZIONE: ?t - tool → ?t - additive-extruder
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-tool ?r ?t)
          (diagnosed ?c)
          (structural-deformation ?c))  
      :effect (and
          (not (diagnosed ?c))
          (not (structural-deformation ?c))
          (repaired ?c)
          (not (has-tool ?r ?t))     
          (handempty ?r))    
  )
  ;;---------------------------------------------

  ;; VERIFY
  (:action verify-repair
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor)
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (repaired ?c))  
      :effect (and
          (not (repaired ?c))
          (verified ?c)
          (nominal ?c)
          (not (has-sensor ?r ?s))    
          (handempty ?r))    
  )
)    