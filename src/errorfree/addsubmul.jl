"""
    add_hilo_acc(a, b)
    
*unchecked* requirement `|a| ≥ |b|`

Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function add_hilo_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

"""
    add_acc(a, b)
    
Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function add_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

"""
    sub_hilo_acc(a, b)
    
*unchecked* requirement `|a| ≥ |b|`

Computes `s = fl(a-b)` and `e = err(a-b)`.
"""
@inline function sub_hilo_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

"""
    sub_lohi_acc(a, b)
    
*unchecked* requirement `|b| ≥ |a|`

Computes `s = fl(a-b)` and `e = err(a-b)`.
"""
@inline function sub_lohi_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (s - b) + a
    s, e
end

"""
    sub_acc(a, b)
    
Computes `s = fl(a-b)` and `e = err(a-b)`.
"""
@inline function sub_acc(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)

    s, e
end


"""
    add_hilo_acc(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`

Computes `s = fl(a+b+c)` and `e1 = err(a+b+c), e2 = err(e1)`.
"""
function add_hilo_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo_acc(b, c)
    x, u = add_hilo_acc(a, s)
    y, z = add_hilo_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

"""
    add_acc(a, b, c)
    
Computes `s = fl(a+b+c)` and `e1 = err(a+b+c), e2 = err(e1)`.
"""
function add_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_acc(b, c)
    x, u = add_acc(a, s)
    y, z = add_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

"""
    sub_hilo_acc(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`

Computes `s = fl(a-b-c)` and `e1 = err(a-b-c), e2 = err(e1)`.
"""
function sub_hilo_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo_acc(-b, c)
    x, u = add_hilo_acc(a, s)
    y, z = add_hilo_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end

"""
    sub_acc(a, b, c)
    
Computes `s = fl(a-b-c)` and `e1 = err(a-b-c), e2 = err(e1)`.
"""
function sub_acc(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_acc(-b, c)
    x, u = add_acc(a, s)
    y, z = add_acc(u, t)
    x, y = add_hilo_acc(x, y)
    return x, y, z
end


"""
    add_acc(a, b, c, d)
    
Computes `s = fl(a+b+c+d)` and `e1, e2, e3 = err(a+b+c+d)`.
"""
function add_acc(a::T,b::T,c::T,d::T) where T<: AbstractFloat

    t0, t1 = add_acc(a ,  b)
    t0, t2 = add_acc(t0,  c)
    a,  t3 = add_acc(t0,  d)
    t0, t1 = add_acc(t1, t2)
    b,  t2 = add_acc(t0, t3)
    c,  d  = add_acc(t1, t2)

    return a, b, c, d
end



"""
    sqr_acc(a)

Computes `p = fl(a*a)` and `e = err(a*a)`.
"""
@inline function sqr_acc(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    p, e
end

"""
    mul_acc(a, b)

Computes `p = fl(a*b)` and `e = err(a*b)`.
"""
@inline function mul_acc(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    p, e
end


"""
    cub_acc(a)

Computes `p = fl(a*a*a)` and `e = err(a*a*a)`.
"""
@inline function cub_acc(a::T) where {T<:AbstractFloat}
    hi, lo = sqr_acc(a)
    hihi, hilo = mul_acc(hi, a)
    lohi, lolo = mul_acc(lo, a)
    hilo, lohi = add_hilo_acc(hilo, lohi)
    hi, lo = add_hilo_acc(hihi, hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   fma_acc algorithm from

   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    fma_acc(a, b, c)

Computes `x = fl(fma(a, b, c))` and `y, z = fl(err(fma(a, b, c)))`.
"""
function fma_acc(a::T, b::T, c::T) where {T<:AbstractFloat}
    x = fma(a, b, c)
    u1, u2 = mul_hilo_acc(a, b)
    a1, z  = add_acc(b, u2)
    b1, b2 = add_acc(u1, a1)
    y = (b1 - x) + b2
    y, z = add_hilo_acc(y, z)
    return x, y, z
end