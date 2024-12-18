//
//  PromptGenerator.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

struct PromptGenerator {
    // TODO: implement output format as an Anthropic tool instead
    @MainActor
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
                  "description": "Tap on an element at the given coordinates",
                  "properties": {
                    "type": "tap", "x": "number", "y": number
                  }
                },
                {
                  "type": "object",
                  "description": "Type text in a text field at the given coordinates. Only possible for \"textField\" and \"textView\" elements.",
                  "properties": {
                    "type": "type", "x": "number", "y": number, "text": "string"
                  }
                },
                {
                  "type": "object",
                  "description": "Wait a given number of seconds.",
                  "properties": { "type": "wait", "duration_secs": "number" }
                },
                {
                  "type": "object",
                  "description": "Scroll the screen, starting from the given origin, and with the given offset.",
                  "properties": { 
                    "type": "scroll",
                    "origin_x": "number", "origin_y": "number", "offset_x": "number", "offset_y": "number"
                  }
                }
              ]
            }
          },
          "comment": { "type": "string", "description": "Required explanation of test result/status", "required": true, "maxLength": 100 }
        }
        </outputFormat>
        
        <rules>
        - You must output valid JSON with the format specified above.
        - Only output a result if the test is completely finished or has obviously failed. Otherwise keep trying to take actions.
        - You are only allowed to take one action.
        - If the test looks to have failed. Wait for 10 seconds and confirm the decision, in case something was just loading.
        - You will be repeatedly requested to make the next decision of what actions to take. Each decision is expensive so try to make the most of each one. You can assume there is at least a 1 second gap between each decision.
        - To scroll down/right, use a positive offset.
        - The current state of the app is defined in appState below along with the screenshot. Use both to decide what action to take.
        - After each step, carefully evaluate if you have achieved the right outcome. Explicitly show your thinking: "I have evaluated step X..." If not correct, try again. Only when you confirm a step was executed correctly should you move on to the next one. Your reasoning of every decision should be put in the comment field.
        </rules>
        
        Screen size: width \(Int(context.screenshot.image.size.width)), height \(Int(context.screenshot.image.size.height))
        
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
