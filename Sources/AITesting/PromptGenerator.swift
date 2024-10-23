//
//  PromptGenerator.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

struct PromptGenerator {
    func generate(for context: AppContext, pastDecisions: [String]) -> String {
        """
        <instructions>
        \(context.instructions)
        </instructions>
        
        // all fields must be non-null, unless otherwise specified.
        <outputFormat>
        {
          "result": { "type": "string", "enum": ["pass", "fail"], "description": "Final test outcome. Present only when complete." },
          "actions": {
            "type": "array",
            "description": "List of pending test actions. Present and non-empty only when test is running.",
            "items": {
              "oneOf": [
                {
                  "type": "object",
                  "properties": {
                    "type": "tap",
                    "id": { "type": "object", "properties": { "type": "string" /* element type, for example "button" */, "id_or_label": "string" /* element id (preferred) or label */ } }
                  }
                },
                {
                  "type": "object",
                  "properties": { "type": "type", "id": { "type": "object", "properties": { "type": "string" /* element type, for example "button" */, "id_or_label": "string" /* element id (preferred) or label */ } }, "text": "string" }  // Type text into element
                },
                {
                  "type": "object",
                  "properties": { "type": "wait", "duration_secs": "number" }  // Pause execution
                },
                {
                  "type": "object",
                  "properties": { 
                    "type": "scroll",
                    "origin_x": "number", "origin_y": "number", "offset_x": "number", "offset_y": "number"  // Scroll coordinates
                  }
                }
              ]
            }
          },
          "comment": { "type": "string", "description": "Required explanation of test result/status", "required": true, "maxLength": 100 }
        }
        </outputFormat>
        
        <rules>
        - You must output JSON with the format specified above.
        - Only output a result if the test is completely finished or has obviously failed. Otherwise keep trying to take actions.
        - You can take multiple actions at a time to be more efficient.
        - If the test looks to have failed. Wait for 10 seconds and confirm the decision, in case something was just loading.
        - You will be repeatedly requested to make the next decision of what actions to take. Each decision is expensive so try to make the most of each one. You can assume there is at least a 1 second gap between each decision.
        - To scroll down/right, use a positive offset.
        - The current state of the app is defined in appState below. You can only interact with the elements defined there.
        - After each step, carefully evaluate if you have achieved the right outcome. Explicitly show your thinking: "I have evaluated step X..." If not correct, try again. Only when you confirm a step was executed correctly should you move on to the next one. Your reasoning of every decision should be put in the comment field.
        </rules>
        
        <appState>
        \(context.viewHierarchy)
        </appState>
        
        // chronological order, last 10 decisions
        <previousDecisions> 
        \(pastDecisions.suffix(10).joined(separator: "\n"))
        </previousDecisions>
        """
    }
}
