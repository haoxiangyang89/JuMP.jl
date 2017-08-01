export PSDCone
# Used in @constraint m X in PSDCone
struct PSDCone end

struct SDVariableConstraint <: AbstractConstraint
    Q::Matrix{JuMP.Variable}
end

# Used by the @variable macro but can also be used through the @constraint macro
function constructconstraint!(Q::Matrix{JuMP.Variable}, ::PSDCone)
    @assert issymmetric(Q) # TODO it could be nonsymmetric if used through the @constraint macro
    SDVariableConstraint(Q)
end

"""
    addconstraint(m::Model, c::SDVariableConstraint)

Add a SD variable constraint to `Model m`.
"""
function addconstraint(m::Model, c::SDVariableConstraint)
    @assert issymmetric(c.Q)
    @assert !m.solverinstanceattached # TODO
    n = Base.LinAlg.checksquare(c.Q)
    cref = MOI.addconstraint!(m.instance, MOI.VectorOfVariables([instancereference(c.Q[i, j]) for i in 1:n for j in i:n]), MOI.PositiveSemidefiniteConeTriangle(n))
    return ConstraintRef(m, cref)
end
