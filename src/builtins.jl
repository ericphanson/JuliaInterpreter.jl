# This file is mostly generated by `generate_builtins.jl` with some additional @static checks
# for recently added builtins.

function getargs(args, frame)
    nargs = length(args)-1  # skip f
    callargs = resize!(frame.framedata.callargs, nargs)
    for i = 1:nargs
        callargs[i] = @lookup(frame, args[i+1])
    end
    return callargs
end

const kwinvoke_name = isdefined(Core, Symbol("#kw##invoke")) ? Symbol("#kw##invoke") : Symbol("##invoke")
const kwinvoke_instance = getfield(Core, kwinvoke_name).instance

"""
    ret = maybe_evaluate_builtin(frame, call_expr, expand::Bool)

If `call_expr` is to a builtin function, evaluate it, returning the result inside a `Some` wrapper.
Otherwise, return `call_expr`.

If `expand` is true, `Core._apply` calls will be resolved as a call to the applied function.
"""
function maybe_evaluate_builtin(frame, call_expr, expand::Bool)
    # By having each call appearing statically in the "switch" block below,
    # each gets call-site optimized.
    args = call_expr.args
    nargs = length(args) - 1
    fex = args[1]
    if isa(fex, QuoteNode)
        f = fex.value
    else
        f = @lookup(frame, fex)
    end
    # Builtins and intrinsics have empty method tables. We can circumvent
    # a long "switch" check by looking for this.
    mt = typeof(f).name.mt
    if isa(mt, Core.MethodTable)
        isempty(mt) || return call_expr
    end
    # Builtins
    if f === <:
        if nargs == 2
            return Some{Any}(<:(@lookup(frame, args[2]), @lookup(frame, args[3])))
        else
            return Some{Any}(<:(getargs(args, frame)...))
        end
    elseif f === ===
        if nargs == 2
            return Some{Any}(===(@lookup(frame, args[2]), @lookup(frame, args[3])))
        else
            return Some{Any}(===(getargs(args, frame)...))
        end
    elseif f === Core._apply
        argswrapped = getargs(args, frame)
        if !expand
            return Some{Any}(Core._apply(argswrapped...))
        end
        new_expr = Expr(:call, argswrapped[1])
        popfirst!(argswrapped)
        argsflat = append_any(argswrapped...)
        for x in argsflat
            push!(new_expr.args, (isa(x, Symbol) || isa(x, Expr) || isa(x, QuoteNode)) ? QuoteNode(x) : x)
        end
        return new_expr
    elseif @static isdefined(Core, :_call_latest) ? f === Core._call_latest : false
        argswrapped = getargs(args, frame)
        if !expand
            return Some{Any}(Core._call_latest(argswrapped...))
        end
        new_expr = Expr(:call, argswrapped[1])
        popfirst!(argswrapped)
        argsflat = append_any(argswrapped)
        for x in argsflat
            push!(new_expr.args, (isa(x, Symbol) || isa(x, Expr) || isa(x, QuoteNode)) ? QuoteNode(x) : x)
        end
        return new_expr
    elseif @static isdefined(Core, :_apply_latest) ? f === Core._apply_latest : false
        argswrapped = getargs(args, frame)
        if !expand
            return Some{Any}(Core._apply_latest(argswrapped...))
        end
        new_expr = Expr(:call, argswrapped[1])
        popfirst!(argswrapped)
        argsflat = append_any(argswrapped...)
        for x in argsflat
            push!(new_expr.args, (isa(x, Symbol) || isa(x, Expr) || isa(x, QuoteNode)) ? QuoteNode(x) : x)
        end
        return new_expr
    elseif @static isdefined(Core, :_apply_iterate) ? f === Core._apply_iterate : false
        argswrapped = getargs(args, frame)
        if !expand
            return Some{Any}(Core._apply_iterate(argswrapped...))
        end
        aw1 = argswrapped[1]::Function
        @assert aw1 === Core.iterate || aw1 === Core.Compiler.iterate || aw1 === Base.iterate "cannot handle `_apply_iterate` with non iterate as first argument, got $(aw1), $(typeof(aw1))"
        new_expr = Expr(:call, argswrapped[2])
        popfirst!(argswrapped) # pop the iterate
        popfirst!(argswrapped) # pop the function
        argsflat = append_any(argswrapped...)
        for x in argsflat
            push!(new_expr.args, (isa(x, Symbol) || isa(x, Expr) || isa(x, QuoteNode)) ? QuoteNode(x) : x)
        end
        return new_expr
    elseif f === Core._apply_pure
        return Some{Any}(Core._apply_pure(getargs(args, frame)...))
    elseif f === Core._expr
        return Some{Any}(Core._expr(getargs(args, frame)...))
    elseif @static isdefined(Core, :_typevar) ? f === Core._typevar : false
        if nargs == 3
            return Some{Any}(Core._typevar(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4])))
        else
            return Some{Any}(Core._typevar(getargs(args, frame)...))
        end
    elseif f === Core.apply_type
        return Some{Any}(Core.apply_type(getargs(args, frame)...))
    elseif f === Core.arrayref
        if nargs == 0
            return Some{Any}(Core.arrayref())
        elseif nargs == 1
            return Some{Any}(Core.arrayref(@lookup(frame, args[2])))
        elseif nargs == 2
            return Some{Any}(Core.arrayref(@lookup(frame, args[2]), @lookup(frame, args[3])))
        elseif nargs == 3
            return Some{Any}(Core.arrayref(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4])))
        elseif nargs == 4
            return Some{Any}(Core.arrayref(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4]), @lookup(frame, args[5])))
        elseif nargs == 5
            return Some{Any}(Core.arrayref(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4]), @lookup(frame, args[5]), @lookup(frame, args[6])))
        else
            return Some{Any}(Core.arrayref(getargs(args, frame)...))
        end
    elseif f === Core.arrayset
        if nargs == 0
            return Some{Any}(Core.arrayset())
        elseif nargs == 1
            return Some{Any}(Core.arrayset(@lookup(frame, args[2])))
        elseif nargs == 2
            return Some{Any}(Core.arrayset(@lookup(frame, args[2]), @lookup(frame, args[3])))
        elseif nargs == 3
            return Some{Any}(Core.arrayset(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4])))
        elseif nargs == 4
            return Some{Any}(Core.arrayset(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4]), @lookup(frame, args[5])))
        elseif nargs == 5
            return Some{Any}(Core.arrayset(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4]), @lookup(frame, args[5]), @lookup(frame, args[6])))
        elseif nargs == 6
            return Some{Any}(Core.arrayset(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4]), @lookup(frame, args[5]), @lookup(frame, args[6]), @lookup(frame, args[7])))
        else
            return Some{Any}(Core.arrayset(getargs(args, frame)...))
        end
    elseif f === Core.arraysize
        if nargs == 2
            return Some{Any}(Core.arraysize(@lookup(frame, args[2]), @lookup(frame, args[3])))
        else
            return Some{Any}(Core.arraysize(getargs(args, frame)...))
        end
    elseif @static isdefined(Core, :const_arrayref) ? f === Core.const_arrayref : false
        return Some{Any}(Core.const_arrayref(getargs(args, frame)...))
    elseif f === Core.sizeof
        if nargs == 1
            return Some{Any}(Core.sizeof(@lookup(frame, args[2])))
        else
            return Some{Any}(Core.sizeof(getargs(args, frame)...))
        end
    elseif f === Core.svec
        return Some{Any}(Core.svec(getargs(args, frame)...))
    elseif f === applicable
        return Some{Any}(applicable(getargs(args, frame)...))
    elseif f === fieldtype
        if nargs == 2
            return Some{Any}(fieldtype(@lookup(frame, args[2]), @lookup(frame, args[3]))::Type)
        elseif nargs == 3
            return Some{Any}(fieldtype(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4]))::Type)
        else
            return Some{Any}(fieldtype(getargs(args, frame)...)::Type)
        end
    elseif f === getfield
        if nargs == 2
            return Some{Any}(getfield(@lookup(frame, args[2]), @lookup(frame, args[3])))
        elseif nargs == 3
            return Some{Any}(getfield(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4])))
        else
            return Some{Any}(getfield(getargs(args, frame)...))
        end
    elseif f === ifelse
        if nargs == 3
            return Some{Any}(ifelse(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4])))
        else
            return Some{Any}(ifelse(getargs(args, frame)...))
        end
    elseif f === invoke
            if !expand
                argswrapped = getargs(args, frame)
                return Some{Any}(invoke(argswrapped...))
            end
            return Expr(:call, invoke, args[2:end]...)
    elseif f === isa
        if nargs == 2
            return Some{Any}(isa(@lookup(frame, args[2]), @lookup(frame, args[3])))
        else
            return Some{Any}(isa(getargs(args, frame)...))
        end
    elseif f === isdefined
        if nargs == 1
            return Some{Any}(isdefined(@lookup(frame, args[2])))
        elseif nargs == 2
            return Some{Any}(isdefined(@lookup(frame, args[2]), @lookup(frame, args[3])))
        else
            return Some{Any}(isdefined(getargs(args, frame)...))
        end
    elseif f === nfields
        if nargs == 1
            return Some{Any}(nfields(@lookup(frame, args[2])))
        else
            return Some{Any}(nfields(getargs(args, frame)...))
        end
    elseif f === setfield!
        if nargs == 3
            return Some{Any}(setfield!(@lookup(frame, args[2]), @lookup(frame, args[3]), @lookup(frame, args[4])))
        else
            return Some{Any}(setfield!(getargs(args, frame)...))
        end
    elseif f === throw
        if nargs == 1
            return Some{Any}(throw(@lookup(frame, args[2])))
        else
            return Some{Any}(throw(getargs(args, frame)...))
        end
    elseif f === tuple
        return Some{Any}(ntupleany(i->@lookup(frame, args[i+1]), length(args)-1))
    elseif f === typeassert
        if nargs == 2
            return Some{Any}(typeassert(@lookup(frame, args[2]), @lookup(frame, args[3])))
        else
            return Some{Any}(typeassert(getargs(args, frame)...))
        end
    elseif f === typeof
        if nargs == 1
            return Some{Any}(typeof(@lookup(frame, args[2])))
        else
            return Some{Any}(typeof(getargs(args, frame)...))
        end
    # Intrinsics
    elseif f === Base.cglobal
        if nargs == 1
            call_expr = copy(call_expr)
            args2 = args[2]
            call_expr.args[2] = isa(args2, QuoteNode) ? args2 : @lookup(frame, args2)
            return Some{Any}(Core.eval(moduleof(frame), call_expr))
        elseif nargs == 2
            call_expr = copy(call_expr)
            args2 = args[2]
            call_expr.args[2] = isa(args2, QuoteNode) ? args2 : @lookup(frame, args2)
            call_expr.args[3] = @lookup(frame, args[3])
            return Some{Any}(Core.eval(moduleof(frame), call_expr))
        end
    elseif f === Base.llvmcall
        return Some{Any}(Base.llvmcall(getargs(args, frame)...))
    end
    if isa(f, Core.IntrinsicFunction)
        cargs = getargs(args, frame)
        return Some{Any}(ccall(:jl_f_intrinsic_call, Any, (Any, Ptr{Any}, UInt32), f, cargs, length(cargs)))
    end
    if isa(f, getfield(Core, kwinvoke_name))
        return Some{Any}(kwinvoke_instance(getargs(args, frame)...))
    end
    return call_expr
end
