# AI driven UI testing

This library allows testing an app's user interface automatically using AI. You write test instructions in human language, and the AI reasons about them and determines the needed actions in the app to perform the test.

The library uses XCUITest to:
- access the current state of the app (accessibility elements and screenshot)
- perform actions in the app

It runs an agent loop in a similar approach to [Anthropic's Computer Use](https://docs.anthropic.com/en/docs/build-with-claude/computer-use) feature.

A difference from Anthropic's approach is an accessibility elements tree is also provided to the model which allows it avoid having to estimate pixel locations from the screenshot. Moving to a purely vision based approach is an interesting area to explore further.

**This library is experimental. Use at your own risk.**

## Usage

Use this library in a UI testing target to automate a test. To minimize token consumption due to images, it's recommended to use a smaller screen size device.

```swift
import AITesting

func testApp() throws {
    let interactor = AITestInteractor(
        appInteractor: StandardAppInteractor(app: app),
        modelInteractor: AnthropicModelInteractor(apiKey: "api key here")
    )
    let instructions = """
        1. Create a new todo with the message "test the AI tester"
        2. Verify the todo appears in the todo list
        """

    // This returns once the test has passed, and throws if the test failed / something went wrong.
    try interactor.performTestBlocking(
        contextProvider: {
            // This is called repeatedly to provide the current app context (screenshot, accessibility elements, etc)
            try AppContext.capture(
                instructions: instructions,
                app: self.app
            )
        }
    )
}
```
