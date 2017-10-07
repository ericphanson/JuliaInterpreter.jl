function perform_return!(state)
    if length(state.stack) != 1
        returning_frame = state.stack[1]
        calling_frame = state.stack[2]
        returning_expr = pc_expr(returning_frame)
        @assert isexpr(returning_expr, :return)
        val = lookup_var_if_var(returning_frame, returning_expr.args[1])
        if returning_frame.generator
            # Don't do anything here, just return us to where we were
        else
            if isexpr(pc_expr(calling_frame), :(=))
                do_assignment!(calling_frame, pc_expr(calling_frame).args[1], val)
            end
            state.stack[2] = JuliaStackFrame(calling_frame, maybe_next_call!(calling_frame,
                calling_frame.pc + 1))
        end
    end
    shift!(state.stack)
    if !isempty(state.stack) && state.stack[1].wrapper
        state.stack[1] = JuliaStackFrame(state.stack[1], finish!(state.stack[1]))
        perform_return!(state)
    end
end

function DebuggerFramework.execute_command(state, frame::JuliaStackFrame, ::Union{Val{:ns},Val{:nc},Val{:n},Val{:se}}, command)
    if (pc = command == "ns" ? next_statement!(frame) :
           command == "nc" ? next_call!(frame) :
           command == "n" ? next_line!(frame, state.stack) :
           #= command == "se" =# step_expr(frame)) != nothing
        state.stack[1] = JuliaStackFrame(state.stack[1], pc)
        return true
    end
    perform_return!(state)
    return true
end

function DebuggerFramework.execute_command(state, frame::JuliaStackFrame, cmd::Union{Val{:s},Val{:si},Val{:sg}}, command)
    pc = frame.pc
    first = true
    while true
        expr = pc_expr(frame, pc)
        if isa(expr, Expr)
            if is_call(expr)
                isexpr(expr, :(=)) && (expr = expr.args[2])
                expr = Expr(:call, map(x->lookup_var_if_var(frame, x), expr.args)...)
                ok = true
                if !isa(expr.args[1], Union{Core.Builtin, Core.IntrinsicFunction})
                    new_frame = enter_call_expr(expr;
                        enter_generated = command == "sg")
                    if (cmd == Val{:s}() || cmd == Val{:sg}())
                        new_frame = JuliaStackFrame(new_frame, maybe_next_call!(new_frame))
                    end
                    # Don't step into Core.Inference
                    if new_frame.meth.module == Core.Inference
                        ok = false
                    else
                        state.stack[1] = JuliaStackFrame(frame, pc)
                        unshift!(state.stack, new_frame)
                        return true
                    end
                else
                    ok = false
                end
                if !ok
                    # It's confusing if we step into the next call, so just go there
                    # and then return
                    state.stack[1] = JuliaStackFrame(frame, next_call!(frame, pc))
                    return true
                end
            elseif !first && isexpr(expr, :return)
                state.stack[1] = JuliaStackFrame(frame, pc)
                return true
            end
        end
        first = false
        command == "si" && break
        new_pc = _step_expr(frame, pc)
        if new_pc == nothing
            state.stack[1] = JuliaStackFrame(frame, pc)
            perform_return!(state)
            return true
        else
            pc = new_pc
        end
    end
    state.stack[1] = JuliaStackFrame(frame, pc)
    return true
end

function DebuggerFramework.execute_command(state, frame::JuliaStackFrame, ::Val{:finish}, cmd)
    state.stack[1] = JuliaStackFrame(frame, finish!(frame))
    perform_return!(state)
    return true
end

function DebuggerFramework.execute_command(state, frane::JuliaStackFrame, ::Val{:?}, cmd)
    display(
            Base.@md_str """
    Basic Commands:\\
    - `n` steps to the next line\\
    - `s` steps into the next call\\
    - `finish` runs to the end of the function\\
    - `bt` shows a simple backtrace\\
    - ``` `stuff ``` runs `stuff` in the current frame's context\\
    - `fr v` will show all variables in the current frame\\
    - `f n` where `n` is an integer, will go to the `n`-th frame.\\
    Advanced commands:\\
    - `nc` steps to the next call\\
    - `ns` steps to the next statement\\
    - `se` does one expression step\\
    - `si` does the same but steps into a call if a call is the next expression\\
    - `sg` steps into a generated function\\
    """)
    return false
end