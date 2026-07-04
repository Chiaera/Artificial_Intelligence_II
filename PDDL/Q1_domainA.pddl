(define (domain Q1A)
  (:requirements :strips :typing)
  (:types robot location tool sensor slot component - object
      antenna-bracket radiator - component
      torque-wrench - tool 
      visual-camera - sensor )
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
    (slot-free ?r - robot ?s - slot)                 ;;robot has free slot
    (in-slot-tool ?r - robot ?t - tool ?slot - slot)      ;;tool is in the slot of robot
    (in-slot-sensor ?r - robot ?s - sensor ?slot - slot)  ;;sensor is in the slot of robot  
    (handempty ?r - robot)                    ;;robot has no tool in hand
    (has-tool ?r - robot ?t - tool)            ;;robot has tool in hand
    (has-sensor ?r - robot ?s - sensor)      ;;robot has sensor in hand

    ;; Location state
    (connected ?loc1 - location ?loc2 - location) ;;NO symmetry

    ;; Component damage 
    (is-loose ?c - antenna-bracket)
    (cracked-bracket ?c - antenna-bracket)
    (coolant-leak ?c - radiator)
    (structural-deformation ?c - radiator)
  )

  ;; TOOL
  ;; take tool from storage
  (:action unstore-tool
      :parameters (?r - robot ?loc - location ?t - tool ?c - component)      
      :precondition (and   
          (robot-at ?r ?loc)
          (tool-at ?t ?loc)
          (handempty ?r)
          (diagnosed ?c))
      :effect (and                
          (not (tool-at ?t ?loc))
          (not (handempty ?r))
          (has-tool ?r ?t))
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

  ;;----------------------------------------

  ;; SENSOR
  ;; take sensor from storage
  (:action unstore-sensor
      :parameters (?r - robot ?loc - location ?s - sensor ?c - component)     
      :precondition (and   
          (robot-at ?r ?loc)
          (sensor-at ?s ?loc)
          (handempty ?r)
          (controlled ?c))
      :effect (and                
          (not (sensor-at ?s ?loc))
          (not (handempty ?r))
          (has-sensor ?r ?s))
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
  ;; sensor collects data on the component. After inspection the sensor return in the slot

  ;; ANTENNA requires visual-camera
  (:action inspect-antenna
      :parameters (?r - robot ?c - antenna-bracket ?loc - location ?s - visual-camera ?slot - slot)
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (controlled ?c)
          (slot-free ?r ?slot))  
      :effect (and
          (not (controlled ?c))
          (inspected ?c)
          (not (has-sensor ?r ?s))
          (not (slot-free ?r ?slot))
          (in-slot-sensor ?r ?s ?slot)
          (handempty ?r))
  )
  ;;--------------------------------------------- 

  ;; DIAGNOSIS
  ;; take data from inspection and diagnose the component

  ;; ANTENNA-BRACKET can be diagnosed as loose, cracked or nominal
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
  ;;---------------------------------------------

  ;; REPAIR
  ;; robot take the tools to repair components and put the tools back in the slot

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
  ;;---------------------------------------------

  ;; VERIFY
  ;; verification requires a new scan with the sensor
    (:action verify-repair
      :parameters (?r - robot ?c - component ?loc - location ?s - sensor ?slot - slot)
      :precondition (and
          (robot-at ?r ?loc)
          (component-at ?c ?loc)
          (has-sensor ?r ?s)
          (repaired ?c)
          (slot-free ?r ?slot))  
      :effect (and
          (not (repaired ?c))
          (verified ?c)
          (nominal ?c)
          (not (has-sensor ?r ?s))
          (not (slot-free ?r ?slot))
          (in-slot-sensor ?r ?s ?slot)
          (handempty ?r))
    )

    ;; empty the slots
    (:action return-tool-to-storage
      :parameters (?r - robot ?t - tool ?slot - slot ?loc - location ?c - component)
      :precondition (and 
          (robot-at ?r ?loc) 
          (in-slot-tool ?r ?t ?slot)
          (verified ?c))
      :effect (and 
          (slot-free ?r ?slot) 
          (tool-at ?t ?loc))
    )
    (:action return-sensor-to-storage
      :parameters (?r - robot ?s - sensor ?slot - slot ?loc - location ?c - component)
      :precondition (and 
          (robot-at ?r ?loc) 
          (in-slot-sensor ?r ?s ?slot)
          (verified ?c))
      :effect (and 
          (slot-free ?r ?slot) 
          (sensor-at ?s ?loc))
    )
)