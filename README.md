<div align="center">
	<h1>Javelin</h1>
	<p>An unique event library for Roblox.</p>
    <a href="https://github.com/lettuce-magician/Javelin/tree/main/CHANGELOG.md"><img src="https://img.shields.io/badge/version-v1.0.1-green"></a>
    <img src="https://img.shields.io/badge/docs-WIP-red">
    <a href="https://opensource.org/license/mit/"><img src="https://img.shields.io/github/license/lettuce-magician/Javelin"></a>
    <a href="https://roblox.com"><img src="https://img.shields.io/badge/Made%20for-Roblox-white?logo=roblox"></a>
</div>


## What is Javelin?
Javelin is a open source single-module roblox library for custom event handling.
It takes an approach similar to NodeJS events, giving a advantage over other forms of custom events.

Instead of a class representing a event, it has a class that can listen and emit to variable number of events.
```lua
local lance = Javelin.new()

lance:On("throw", function()
    print("The lance was thrown!")
end)

lance:On("break", function(whoBrokeIt)
    print(whoBrokeIt.." broke the lance!")
end)

lance:Emit("throw")
lance:DelayEmit(1, "break", "I")
```

This solves a common issue of other custom event implementations, which mimics [RBXScriptSignal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal) and require you to type *every single event by hand*.
```lua
local node = {
  created = Event.new(),
  destroyed = Event.new(),
  changed = Event.new(),
  childadded = Event.new(),
  -- more unnecessary event defining
}
```

As a Custom Event handler, it's planned to be used in classes, `Javelin.extend` allows you to take a new instance of a class and extend it with Javelin, instead of creating a value for it.
```lua
-- bad alternative
function myClass.new()
    local self = setmetatable({}, myClass)
    self.signal = Javelin.new()
    return self
end

-- intended purpose
function myClass.new()
    local self = Javelin.extend(myClass, {
        -- insert properties here
    })
    return self
end
```

Javelin also will warn you if you write redundant or weird code with it, you may disable/enable them by using `Javelin.diagnostic(diagnosticId, mode)`
```lua
local myJavelin = Javelin.new()
myJavelin:Emit("emitted") -- [Code '1']: Attempt to emit event '%s' that has no listeners.
Javelin.diagnostic(1, false)
myJavelin:Emit("emitted") -- no output
```

## Where to use Javelin?
Javelin is general purpose, meaning it can be used in anything, but there's a few use cases that were designed for it.

- Very useful on creating classes that has many events, since Javelin *creates the events when you start listening to them*, making you not to worry about creating the events.
- Can also work just as a standalone event handler for handling game events, such as intermission.

## How I can contribute to Javelin?

If you find a bug or you want to add a feature, create an Issue/Pull Request for it, I will respond to it fast as possible.

I'm on the process of creating documentation, any suggestions/contribuitions please deliver me a DM on Discord: `letiul`.

<div align="center">
<br/><br/>
<a href="https://github.com/lettuce-magician">
<img src="https://img.shields.io/badge/©%20lettuce--magician-2023-blue">
</a>
</div>
