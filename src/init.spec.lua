return function ()
    local Javelin = require(script.Parent)
    Javelin.diagnostic("*",false)

    local signal
    beforeEach(function()
        signal = Javelin.new()
    end)

    describe("Javelin:On", function()
        it("should bind a function to a event", function()
            signal:On("emit")

            expect(signal.__events["emit"]).to.be.never.equal(nil)
        end)

        it("should run function when emitted", function()
            local wasEmitted = false
            signal:On("emit", function()
                wasEmitted = true
            end)
            signal:Emit("emit")
            expect(wasEmitted).to.be.equal(true)
        end)

        it("should receive the arguments accordingly", function()
            local arguments = 0
            signal:On("emit", function(...)
                arguments = #{...}
            end)
            signal:Emit("emit", 1, 2, 3, 4)
            expect(arguments).to.be.equal(4)
        end)
    end)

    describe("Javelin:Once", function()
        it("should bind a function thats disconnected after fired", function()
            local count = 0
            signal:Once("emit", function()
                count+=1
            end)
            for _ = 1, 5 do
                signal:Emit("emit")
            end

            expect(count).to.be.equal(1)
        end)
    end)

    describe("Javelin:OnSync", function()
        it("should bind a connection that is in the main thread", function()
            local thread
            signal:OnSync("emit", function()
                thread = coroutine.running()
            end)
            signal:Emit("emit")

            expect(thread).to.be.equal(coroutine.running())
        end)
    end)

    describe("Javelin:Emit", function()
        it("should execute all async events then the synced ones", function()
            local ranFirst = 0
            signal:On("emit", function()
                ranFirst = 1
            end)

            signal:OnSync("emit", function()
                task.wait(0.25)
                if ranFirst ~= 0 then return end
                ranFirst = 2
            end)

            signal:Emit("emit")
            expect(ranFirst).to.be.equal(1)
        end)
    end)

    describe("Javelin:Wrap", function()
        it("should wrap a RBXScriptSignal.", function()
            local part = Instance.new("Part")

            local ran = false
            signal:On("Destroying", function()
                ran = true
            end)
            signal:Wrap("Destroying",part.Destroying)
            part:Destroy()

            expect(ran).to.be.equal(true)
        end)
    end)

    describe("Javelin:Clear", function()
        it("should clear all connections and wraps from a event", function()
            local part = Instance.new("Part")

            for _ = 1, 5 do
                signal:On("emit")
            end
            signal:Wrap("emit", part.Destroying)
            signal:Clear('emit')
            part:Destroy()

            expect(signal.__events["emit"]).to.be.equal(nil)
            expect(signal.__RBXScriptSignalConnections["emit"]).to.be.equal(nil)
        end)
    end)

    describe("Javelin:ClearAll", function()
        it("should clear all events", function()
            local part = Instance.new("Part")

            for i = 1, 5 do
                signal:On(tostring(i))
                signal:Wrap(tostring(i), part.Destroying)
            end
            signal:ClearAll()

            expect(#signal.__events).to.be.equal(0)
            expect(#signal.__RBXScriptSignalConnections).to.be.equal(0)
        end)
    end)

    describe("Connection:Await", function()
        it("should return arguments passed", function()
            local Conn = signal:On("emit")
            signal:DelayEmit(0.1, "emit", 1, "a", true)
            local Length = #{Conn:Await()}
            expect(Length).to.be.equal(3)
        end)

        it("should timeout if nothing has been passed yet", function()
            local Conn = signal:On("emit")
            signal:DelayEmit(0.65, "emit", true)
            expect(Conn:Await(0.5)).to.be.equal(nil)
        end)
    end)

    describe("Javelin.extend", function()
        local myClass = {}
        myClass.__index = myClass

        function myClass.new()
            return Javelin.extend(myClass, {
                state = true
            })
        end

        function myClass:test()
        end

        local new = myClass.new()

        it("should maintain class memebers", function()
            expect(new.test).to.be.a("function")
        end)

        it("should make the class contain Javelin members", function()
            for k:string, v in pairs(Javelin) do
                if k:find("__") then continue end
                expect(new[k]).to.be.a(typeof(v))
            end
        end)

        it("should contain properties provided", function()
            expect(new.state).to.be.a("boolean")
        end)
    end)
end