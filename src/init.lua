---@class Javelin
local Javelin:Javelin = {}
Javelin.__index = Javelin

local __diag = {
    {
        Text = "Attempt to emit event '%s' that has no listeners.",
        Type = "warn",
        State = true
    },
    {
        Text = "Creating a connection with no function for event '%s'.",
        Type = "warn",
        State = true
    },
    {
        Text = "Connection:Await() of event '%s' has been cancelled because of timeout.",
        Type = "warn",
        State = true,
    },
    {
        Text = "Error on a Connection of Event '%s':\n%s",
        Type = "warn",
        State = true
    }
}

local funclist = {
    warn = warn,
    error = error,
}

local function _useDiag(id:number, level:number?, ...:string)
    local diag = __diag[id]
    if diag.State == true then
        local fn = funclist[diag.Type]
        if fn then
            fn(`[Code '{id}']: {string.format(diag.Text, ...)}\n{level and `Traceback:\n{level}` or ''}`)
        end
    end
end

---@class Connection
---@field Connected boolean
local Connection:JavelinConnection = {}
Connection.__index = Connection

function Connection.new(parent, name, props):JavelinConnection
    local self = setmetatable({
        parent = parent.__events[name],
        id = #parent+1,
        name = name,
        Connected = true
    }, Connection)

    for k, v in props do
        self[k] = v
    end

    return self
end

--- Unbinds the connection from the event.
function Connection:Off()
    self.parent[self.id] = nil
    self.Connected = false
end

--- ⚠ CAN YIELD!
---
--- Yields current thread until the timeout is reached or the event is fired.
function Connection:Await(timeout:number): ...any?
    timeout = (type(timeout)=="number" and timeout) or 5
    local timeWaiting = tick()
    repeat
        task.wait()
    until self.__args ~= nil or tick()-timeWaiting>=timeout

    if tick()-timeWaiting>=timeout then
        _useDiag(3, 3, self.name)
    else
        local args = self.__args
        self.__args = nil
        return unpack(args)
    end
end

local function new(tab:{[string]:{any}}, evname:string, props:{[string]:{any}})
    if not tab.__events[evname] then
        tab.__events[evname] = {}
    end

    if not props.fn then
        props.fn = function()
        end
        _useDiag(2, 4, evname)
    end

    local Conn = Connection.new(tab,evname,props)
    table.insert(tab.__events[evname], Conn)
    return Conn
end


--[=[
    Binds a function to an event, if the event does not exist it will create it.

    The function will receive any arguments passed by ``Javelin:Emit``

    Returns the ``Connection`` that was binded.
]=]
---@return Connection
function Javelin:On(event:string, fn:(...any)->()):JavelinConnection
    return new(self, event, {fn = fn})
end

--[=[
    Same as ``Javelin:On``, but when the event is
    emitted the connection is unbinded and then
    the function is ran.
]=]
---@return Connection
function Javelin:Once(event:string, fn:(...any)->()):JavelinConnection
    return new(self, event, {fn = fn, once = true})
end

--[=[
    ⚠ CAN YIELD!

    Same as ``Javelin:On``, but the function binded
    will be ran in the current thread instead of a
    separate one.
]=]
---@return Connection
function Javelin:OnSync(event:string, fn:(...any)->()):JavelinConnection
    return new(self, event, {fn = fn, sync = true})
end

--[=[
    ⚠ CAN YIELD!

    Same as ``Javelin:Once``, but the function binded
    will be ran in the current thread instead of a
    separate one.
]=]
---@return Connection
function Javelin:OnceSync(event:string, fn:(...any)->()):JavelinConnection
    return new(self, event, {fn = fn, sync = true, once = true})
end
--- Returns the number of connections binded to `event`.
---@return number
function Javelin:Count(event:string):number?
    local Event = self.__events[event]
    if Event then
        return #Event
    end
end

--- Emits all connections binded to `name`, passing a variable number of arguments to them.
function Javelin:Emit(name:string, ...:any?)
    local Event = self.__events[name]
    if not Event then
        _useDiag(1, 3, name)
        return
    end

    local function safeExec(fn:(...any)->(...any), ...)
        local results = {
            pcall(fn, ...)
        }

        if results[1] == false then
            _useDiag(4, nil, name, results[2])
        else
            return unpack(results, 2)
        end
    end

    local toSync = {}
    for _, conn:JavelinConnection in ipairs(Event) do
        local Fn = conn.fn
        if conn.once then
            conn:Off()
        end

        conn.__args = {...}
        if conn.sync then
            table.insert(toSync, Fn)
        else
            task.spawn(safeExec, Fn, ...)
        end
    end

    for _, fn in ipairs(toSync) do
        safeExec(fn, ...)
    end
end

--[=[
    Syntatic sugar for the code below:
    ```lua
    task.delay(time, function()
        signal:Emit(event, ...)
    end)
    ```
]=]
function Javelin:DelayEmit(time:number, event:string, ...:any?)
    task.delay(time, self.Emit, self, event, ...)
end

--- Clears all connections for a specific event.
function Javelin:Clear(event:string)
    self.__events[event] = nil
end

--- Clears all events from the class.
function Javelin:ClearAll()
    table.clear(self.__events)
end

--- Creates a new Javelin.
---@return Javelin
function Javelin.new()
    return setmetatable({
        __events = {}
    }, Javelin)
end

--- Extends a class, allowing you to call Javelin methods from it.
---
--- Make sure the class has a `__index` field.
---@return Javelin
function Javelin.extend(Class:{[any]:any},Properties:{[any]:any})
    local MTIndex = table.clone(Class.__index)
    for Key, Value in Javelin do
        if type(Value) == "function" then
            MTIndex[Key] = Value
        end
    end

    Properties.__events = {}

    return setmetatable(Properties, {__index = MTIndex})
end

--- 🛑 UNSAFE!
---
--- Toggle warns/error messages.
--- Using **"*"** as first argument will set
--- **ALL** diagnostics to `mode`.
---@param mode boolean
function Javelin.diagnostic(diagId:number|"*", mode:boolean)
    if diagId == "*" then
        for k in ipairs(__diag) do
            Javelin.diagnostic(k,mode)
        end
    else
        local diag = __diag[diagId]

        if diag ~= nil then
            diag.State = mode
        end
    end
end

export type JavelinConnection = typeof(Connection)
export type Javelin = typeof(Javelin)

return Javelin