(define (domain Q1)
  (:requirements :strips :typing :negative-preconditions)
  (:types robot location tool sensor slot component spare-component - object
      antenna-bracket radiator - component
      torque-wrench grasping-tool coolant-bypass-tool additive-extruder - tool 
      visual-camera profilometer-3d ultrasonic-sensor thermal-camera - sensor 
      spare-bracket coolant-reservoir - spare-component)
  (:predicates
    ;; Component state
    (controlled ?c - component)
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
    (in-slot-tool ?r - robot ?t - tool ?slot - slot)      ;;tool is in the slot of robot
    (in-slot-sensor ?r - robot ?s - sensor ?slot - slot)  ;;sensor is in the slot of robot  
    (in-slot-spare ?r - robot ?sp - spare-component ?slot - slot)   ;;spare part is in the slot of robot  
    (in-slot-broken ?r - robot ?c - component ?slot - slot)  ;;brokencomponent is in the slot of robot
    (handempty ?r - robot)                    ;;robot has no tool in hand
    (has-tool ?r - robot ?t - tool)            ;;robot has tool in hand
    (has-sensor ?r - robot ?s - sensor)      ;;robot has sensor in hand
    (has-spare ?r - robot ?sp - spare-component) ;;robot carries a spare part (consumable)

    ;; Location state
    (connected ?loc1 - location ?loc2 - location) ;;NO symmetry

    ;; Component damage 
    (is-loose ?c - antenna-bracket)
    (cracked-bracket ?c - antenna-bracket)
    (coolant-leak ?c - radiator)
    (structural-deformation ?c - radiator)
    ;;for repair actions
    (component-removed ?c - component)
    (component-positioned ?c - component)
  )

  ;; TOOL
  ;; take tool from storage
  (:action unstore-tool
      :parameters (?r - robot ?loc - location ?t - tool)      
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
      :parameters (?r - robot ?loc - location ?t - tool)      
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
      :parameters (?r - robot ?loc - location ?s - sensor)     
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
      :parameters (?r - robot ?loc - location ?s - sensor)   
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

  ;; take spare from slot
  (:action take-spare-from-slot
      :parameters (?r - robot ?sp - spare-component ?slot - slot)      
      :precondition (and   
          (not (slot-free ?r ?slot))
          (handempty ?r)
          (in-slot-spare ?r ?sp ?slot))
      :effect (and                
          (slot-free ?r ?slot)
          (not (handempty ?r))
          (has-spare ?r ?sp)      
          (not (in-slot-spare ?r ?sp ?slot)))      
  )

  ;; put spare in slot
  (:action put-spare-in-slot
      :parameters (?r - robot ?sp - spare-component ?slot - slot)      
      :precondition (and   
          (slot-free ?r ?slot)
          (has-spare ?r ?sp)     
          (not (handempty ?r)))
      :effect (and            
          (handempty ?r)
          (not (slot-free ?r ?slot))
          (in-slot-spare ?r ?sp ?slot)
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
  ;; the sensor collects data on the component
  ;; sensor stays in the hand
  (:action inspect-component
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor)
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (controlled ?c))  
      :effect (and
          (not (controlled ?c))
          (inspected ?c))
  )
  ;;--------------------------------------------- 

  ;; DIAGNOSIS
  ;; take data from inspection and diagnose the component

  ;; ANTENNA-BRACKET can be diagnosed as loose, cracked, or nominal
  (:action diagnose-loose-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location)     
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (inspected ?c)
          (is-loose ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c))
  )
  (:action diagnose-cracked-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location)    
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (inspected ?c)
          (cracked-bracket ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c))
  )
  ;; if there is no problem the antenna-bracket is diagnosed as nominal
  (:action diagnose-nominal-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location)     
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (inspected ?c)
          (not (is-loose ?c))
          (not (cracked-bracket ?c)))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (nominal ?c))
  )

  ;; RADIATOR can be diagnosed as coolant-leak, structural-deformation, or nominal
  (:action diagnose-coolant-leak
      :parameters (?r - robot ?c - radiator ?loc - location)     
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (inspected ?c)
          (coolant-leak ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c))
  )
  (:action diagnose-structural-deformation
      :parameters (?r - robot ?c - radiator ?loc - location)   
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (inspected ?c)
          (structural-deformation ?c))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c))
  )
  (:action diagnose-nominal-radiator
      :parameters (?r - robot ?c - radiator ?loc - location)     
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (inspected ?c)
          (not (coolant-leak ?c))
          (not (structural-deformation ?c)))  
      :effect (and
          (not (inspected ?c))
          (diagnosed ?c)
          (nominal ?c))
  )
  ;;---------------------------------------------

  ;; REPAIR
  ;; robot take the tools to repair components
  ;; tools stay in the hand after repairing 

  ;; ANTENNA-BRACKET
  ;; loose antenna is repaired by torque-wrench tool (mechanical tightening, no consumable)
  (:action repair-loose-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?t - torque-wrench)   
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-tool ?r ?t)
          (diagnosed ?c)
          (is-loose ?c))  
      :effect (and
          (not (diagnosed ?c))
          (not (is-loose ?c))
          (repaired ?c))
  )

  ;; cracked antenna bracket is defined with 3 actions:
  ;; 1. remove the cracked bracket (using grasping-tool) and put it in a slot
  ;; 2. take the spare bracket from the slot and position it
  ;; 3. install the spare bracket (using grasping-tool)
  (:action remove-cracked-bracket
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?t - grasping-tool ?slot - slot)
      :precondition (and
          (robot-at ?r ?loc) 
          (component-at ?c ?loc)
          (has-tool ?r ?t) 
          (diagnosed ?c) 
          (cracked-bracket ?c)
          (slot-free ?r ?slot))
      :effect (and
          (not (cracked-bracket ?c))
          (component-removed ?c)
          (not (slot-free ?r ?slot))
          (in-slot-broken ?r ?c ?slot))
  )
  (:action position-spare-bracket
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?sp - spare-bracket)
      :precondition (and
          (robot-at ?r ?loc) 
          (component-at ?c ?loc)
          (has-spare ?r ?sp) 
          (component-removed ?c))
      :effect (and
          (not (component-removed ?c))
          (not (has-spare ?r ?sp))
          (component-positioned ?c))
  )
  (:action install-spare-bracket
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?t - grasping-tool)
      :precondition (and
          (robot-at ?r ?loc) 
          (component-at ?c ?loc)
          (has-tool ?r ?t) 
          (component-positioned ?c))
      :effect (and
          (not (component-positioned ?c))
          (not (diagnosed ?c))
          (repaired ?c))
  )

  ;; RADIATOR
  ;; coolant leak is repaired by 
  ;; - the bypass tool 
  ;; - recharge from a coolant-reservoir (consumable, taken from the slot)
  (:action repair-coolant-leak
      :parameters (?r - robot ?c - radiator ?loc - location ?t - coolant-bypass-tool ?sp - coolant-reservoir)      
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
          (repaired ?c))
  )

  ;; structural deformation is repaired by the additive-extruder tool.
  (:action repair-structural-deformation
      :parameters (?r - robot ?c - radiator ?loc - location ?t - additive-extruder)     
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-tool ?r ?t)
          (diagnosed ?c)
          (structural-deformation ?c))  
      :effect (and
          (not (diagnosed ?c))
          (not (structural-deformation ?c))
          (repaired ?c))
  )
  ;;---------------------------------------------

  ;; VERIFY
  ;; verification requires a real new scan with the sensor
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
          (nominal ?c))
  )    

  ;; robot return to the storage to 'empty the slots'
  (:action empty-slots
    :parameters (?r - robot ?c - antenna-bracket ?loc - location ?slot - slot)
    :precondition (and
        (robot-at ?r esp-storage)  
        (in-slot- ?r ?c ?slot)
        (in-slot-tool ?r ?t ?slot)
        (in-slot-sensor ?r ?s ?slot)
        (verified ?c))
    :effect (and
        (not (in-slot-broken ?r ?c ?slot))
        (slot-free ?r ?slot))
)
)