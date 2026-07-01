# DOMINIO

## General

- Model a symbolic planning domain describing one or more
autonomous free-climbing robots operating on the external structure of an orbital platform.

- Locomote by attaching and detaching their limbs from a network of handrails distributed across the spacecraft structure. 
During locomotion, the robots must continuously maintain mechanically stable contact configurations.

- Environment:
	* Microgravity
	* NOT static: 
		- Components degrade over time, 
		- batteries discharge, 
		- temperatures depending on solar exposure, 
		- communication opportunities intermittent, 
		- tools may experience wear. 

- Operation: 
	* inspect components, 
	* replace damaged units, 
	* install new payloads, 
	* manipulate valves, 
	* transport tools, 
	* perform diagnostic operations.

- External subsystems:
	* structural trusses,
	* handrails,
	* communication antennas, 
	* radiators, 
	* solar arrays, 
	* batteries, 
	* scientific payloads, 
	* inspection panels,
	* tenance modules, 
	* storage containers, 
	* docking ports. 

---

## Modelling Assumptions

• **the orbital platform is represented as a graph of connected locations:** 'location' é un predicato simmetrico o direzionale. Sono nodi astratti

• **locomotion between locations is only possible through predefined connections, such as handrails,trusses, or other external structural interfaces:** NO teletrasporto o movimento libero nel grafo (= arco esplicito) --> (connection-type ?from ?to ?type)? 

• **robots possess one or more manipulators that can be used for locomotion, manipulation, tool handling, inspection, or repair:**  il manipolatore è una risorsa condivisa fra funzioni diverse --> se un'azione richiede un manipolatore libero, deve essere impossibile eseguirla se tutti i manipolatori sono occupati 

• **robots may differ in sensing capabilities, locomotion capabilities, payload capacity, computational resources, and available tools:**   predicati/funzioni di capability legati al singolo oggetto robot, non al tipo robot in generale (= differenziare tipi di robot) --> (has-sensor ?robot ?sensor-type), (payload-capacity ?robot) - number, (has-tool ?robot ?tool) 

• **external components may require specific sensing modalities or specialized maintenance tools:** compatibilità a livello di componente, non di azione generica -->(requires-sensor ?component ?sensor-type), (requires-tool ?component ?tool-type) - Le precondizioni delle azioni inspect/diagnose/repair devono controllare questa compatibilità

• **some actions may only be executable after satisfying symbolic preconditions such as inspection, calibration, stabilization, authorization, or tool installation;**  costruire catene di precondizioni causali --> ogni azione "avanzata" ha come precondizione lo stato prodotto dall'azione precedente nella catena. È anche la giustificazione per introdurre, se ti serve, uno stato intermedio tipo stabilized prima di repair

• **the student is free to introduce additional predicates, actions, functions, or objects whenever they improve the clarity or modularity of the symbolic model:**  predicato ausiliario per evitare un'azione monolitica, aggiungilo pure — ma nella discussione finale motiva perché quella scelta migliora modularità/riusabilità

### Design symbolic model
• modular;
• readable;
• reusable;
• easily extensible;
• physically meaningful.

---

## Deliverables:

###Q1
• a PDDL domain file;
• at least two PDDL problem files;
• valid plans for problem instances;

### Q2
• a PDDL+ domain file;
• at least two PDDL+ problem files;

### Discussion
• a short technical discussion explaining modelling choices, limitations, and differences between the PDDL and PDDL+ models.

### Avoid
Avoid trivial encodings, such as directly encoding goal satisfaction inside actions or
hardcoding a fixed plan inside the domain structure.

### Challenge
extend solution by introducing one or more abstractions inspired by autonomous free-climbing robots operating in microgravity.
--> identify suitable symbolic or hybrid abstractions that capture important physical constraints while remaining compatible with PDDL or PDDL+.
 SEE PAGE 3 - 5.

---
---

# SCENARIO V3: Structural Maintenance and Repair Verification
- External components of the orbital platform may degrade over time or become mechanically loose.
Examples:
	* thermal blanket fasteners, 
	* antenna brackets, 
	* inspection panel locks, 
	* radiator supports,
	* modular payload connectors.

- A free-climbing robot must 
	* inspect selected components, 
	* identify which components require maintenance, 
	* perform the appropriate repair action, 
	* verify that the repair was successful (complete IF verification has been performed)

- Some repairs require specific tools
- Some components cannot be repaired until they have first been inspected and classified.

- Causal structure: inspection, diagnosis, repair, and verification must be
represented as distinct stages of a maintenance workflow

## Domain Characteristics
• Robot: single free-climbing maintenance robot.
• Environment: external platform with multiple maintainable components.
• Tasks: inspection, diagnosis, repair, verification.
• Resources: tools, battery, possibly spare parts.
• Constraints: repair actions depend on diagnosis and tool availability.

## Modelling Guidelines
• Clearly separate inspection, diagnosis, repair, and verification.
• Avoid modelling repair as a single unconditional action.
• Represent component states explicitly, such as unknown, nominal, degraded, repaired, verified, or failed.
• Ensure that verification is required before the goal can be satisfied.
• Include at least one maintenance task where the robot must choose between inspecting more components and repairing an already diagnosed component.

---

## Q1 – Basic PDDL Model
• define types for components, tools, locations, and maintenance states;
• model inspection and diagnosis actions;
• model at least two different repair actions requiring different tools or preconditions;
• model verification explicitly;
• provide at least two problem instances:
	– one simple instance with a single degraded component;
	– one non-trivial instance with multiple components, different repair requirements, and limited resources.
• provide valid plans and justify your workflow representation.

## Q2 – PDDL+ Model
• introduce a process modelling progressive component degradation;
• introduce an event representing component failure once degradation exceeds a threshold;
• optionally introduce a process modelling repair progress over time;
• provide problem instances where delaying repair changes the feasibility of the mission;
• explain how continuous degradation affects inspection and repair ordering.

##Discussion
• how causal dependencies structure maintenance planning;
• how symbolic diagnosis differs from physical diagnosis;
• how PDDL+ changes the interpretation of deferred repair;
• how this model could support future autonomous maintenance benchmarks
