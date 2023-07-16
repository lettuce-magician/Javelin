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