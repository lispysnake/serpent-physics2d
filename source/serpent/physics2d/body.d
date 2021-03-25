/*
 * This file is part of serpent.
 *
 * Copyright © 2019-2020 Lispy Snake, Ltd.
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

module serpent.physics2d.body;

public import serpent.physics2d.abstractWorld;
public import serpent.physics2d.shape;
public import gfm.math;
public import std.signals;

import chipmunk;
import serpent.ecs.entity : EntityID;

/**
 * A Rigid Body is a composition of shapes that are used to provide physics
 * support in the simulation
 */
class Body
{

private:

    Shape[] orphanShapes;
    Shape[] attachedShapes;

    /**
     * Remove all existing shapes from the world simulation
     */
    extern (C) static final void removeShapes(cpBody* parentBody, cpShape* _shape, void* userdata)
    {
        assert(_shape.userData !is null, "Cannot have shape without userData");
        Shape shape = cast(Shape) _shape.userData;
        AbstractWorld world = cast(AbstractWorld) userdata;
        if (world.contains(shape))
        {
            world.remove(shape);
        }
    }

    /**
     * Kill all shapes when destroying the body
     */
    extern (C) static final void killShapes(cpBody* parentBody, cpShape* _shape, void* userdata)
    {
        assert(_shape.userData !is null, "Cannot have shape without userData");
        Shape shape = cast(Shape) _shape.userData;
        shape.destroy();
    }

    /**
     * Clamp minimum velocity for a dynamic body
     *
     * In some situations (i.e. the paddle demo) with unrealistic
     * physics, the reality of physics sets in and we loose too much
     * velocity on a corner-hit.
     *
     * To alleviate this, we can set a minimum velocity for bodies that
     * should remain in motion with a constant minimum velocity.
     */
    extern (C) static final void velocityClampMinimum(cpBody* _body)
    {
        Body body = cast(Body) _body.userData;
        auto minVelocity = body.minVelocity;
        static const auto zerof = vec2f(0.0f, 0.0f);
        if (minVelocity == zerof)
        {
            return;
        }

        /* Clamp minimum X velocity in either direction */
        if (cast(float) _body.v.x >= 0.0f && cast(float) _body.v.x < minVelocity.x)
        {
            _body.v.x = cast(cpFloat) minVelocity.x;
        }
        else if (cast(float) _body.v.x < 0.0f && cast(float) _body.v.x > -minVelocity.x)
        {
            _body.v.x = cast(cpFloat)-minVelocity.x;
        }

        /* Clamp minimum Y velocity in either direction */
        if (cast(float) _body.v.y >= 0.0f && cast(float) _body.v.y < minVelocity.y)
        {
            _body.v.y = cast(cpFloat) minVelocity.y;
        }
        else if (cast(float) _body.v.y < 0.0f && cast(float) _body.v.y > -minVelocity.y)
        {
            _body.v.y = cast(cpFloat)-minVelocity.y;
        }
    }

    /**
     * Clamp maximum velocity for a dynamic body
     *
     * This is used to prevent tunnelling issues when using unrealistic
     * physics simulations, such as the paddle demo.
     *
     * Too high a velocity will result in the balls leaving the play
     * area.
     */
    extern (C) static final void velocityClampMaximum(cpBody* _body)
    {
        Body body = cast(Body) _body.userData;

        /* Ignore zero max velocity - equal to unset */
        auto maxVelocity = body.maxVelocity;
        static const auto zerof = vec2f(0.0f, 0.0f);
        if (maxVelocity == zerof)
        {
            return;
        }

        /* Clamp X velocity in either direction */
        if (cast(float) _body.v.x > 0.0f && cast(float) _body.v.x > maxVelocity.x)
        {
            _body.v.x = cast(cpFloat) maxVelocity.x;
        }
        else if (cast(float) _body.v.x < 0.0f && cast(float) _body.v.x < -maxVelocity.x)
        {
            _body.v.x = cast(cpFloat)-maxVelocity.x;
        }

        /* Clamp Y velocity in either direction */
        if (cast(float) _body.v.y > 0.0f && cast(float) _body.v.y > maxVelocity.y)
        {
            _body.v.y = cast(cpFloat) maxVelocity.y;
        }
        else if (cast(float) _body.v.y < 0.0f && cast(float) _body.v.y < -maxVelocity.y)
        {
            _body.v.y = cast(cpFloat)-maxVelocity.y;
        }
    }

    /**
     * Manually handle maximum and minimum velocities
     */
    extern (C) static final void velocityUpdateFunc(cpBody* _body,
            cpVect gravity, cpFloat damping, cpFloat dt)
    {
        assert(_body.userData !is null, "Cannot have body without userData");
        cpBodyUpdateVelocity(_body, gravity, damping, dt);

        /* Only interested in maximum velocity on dynamic types */
        if (cpBodyGetType(_body) != cpBodyType.CP_BODY_TYPE_DYNAMIC)
        {
            return;
        }

        velocityClampMinimum(_body);
        velocityClampMaximum(_body);
    }

package:

    cpBody* _body;
    EntityID _entity;
    vec2f _maxVelocity = vec2f(0.0f, 0.0f);
    vec2f _minVelocity = vec2f(0.0f, 0.0f);

    /**
     * Return pointer to the underlying chipmunk body.
     */
    pragma(inline, true) pure final cpBody* chipBody() @safe @nogc nothrow
    {
        return _body;
    }

    /**
     * Set the chipBody for this instance
     */
    pragma(inline, true) pure final void chipBody(cpBody* bodyPtr) @safe @nogc nothrow
    {
        _body = bodyPtr;
    }

    /**
     * Set the internal entity ID for the Body
     */
    pragma(inline, true) pure final void entity(EntityID id) @safe @nogc nothrow
    {
        _entity = id;
    }

    /**
     * Create a Body with the given mass and moment
     */
    this(cpBody* chipBody)
    {
        _body = chipBody;
        _body.userData = cast(void*) this;

        cpBodySetVelocityUpdateFunc(chipBody, &velocityUpdateFunc);
    }

    ~this()
    {
        auto world = this.world();
        if (world !is null)
        {
            world.remove(this);
        }

        cpBodyEachShape(chipBody, &killShapes, null);
        cpBodyFree(_body);
    }

    /**
     * Getting added/removed from a world
     */
    final @property void world(AbstractWorld newWorld) @trusted
    {
        auto oldWorld = this.world();

        /* Remove shapes from old world */
        if (oldWorld !is null)
        {
            cpBodyEachShape(chipBody, &removeShapes, cast(void*) oldWorld);
        }

        /* Add shapes to new world */
        if (newWorld !is null)
        {
            foreach (ref s; orphanShapes)
            {
                newWorld.add(s);
                attachedShapes ~= s;
            }
            orphanShapes = [];
        }
    }

public:

    /**
     * Emitted whenever we collide with another body's shape
     */
    mixin Signal!(Shape, Shape) collision;

    mixin Signal!(Shape, Shape) sensorActivated;
    /**
     * Return the world instance that this body is in
     */
    final @property AbstractWorld world() @trusted
    {
        cpSpace* space = cpBodyGetSpace(chipBody);
        if (space is null)
        {
            return null;
        }
        return cast(AbstractWorld) space.userData;
    }

    /**
     * Add the Shape to this Body
     */
    final void add(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot add null shape to Body");
        shape.chipBody = this;

        /* Add shape to world if we have one */
        auto world = this.world();
        if (world is null)
        {
            orphanShapes ~= shape;
            return;
        }
        attachedShapes ~= shape;
        world.add(shape);
    }

    /**
     * Remove the shape from the body
     */
    final void remove(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot remove shape from body");

        /* Remove shape from world if we have one */
        auto world = this.world();
        if (world !is null)
        {
            world.remove(shape);
        }

        shape.chipBody = null;

        import std.algorithm.mutation : remove;

        orphanShapes = orphanShapes.remove!((a) => a == shape);
        attachedShapes = attachedShapes.remove!((a) => a == shape);
    }

    /**
     * Return the current position property for this body
     */
    final @property vec2f position() @trusted
    {
        auto cpPosition = cpBodyGetPosition(chipBody);
        return vec2f(cast(float) cpPosition.x, cast(float) cpPosition.y);
    }

    /**
     * Set the position property for this body
     *
     * This should only be used when setting an *initial* position prior
     * to simulation
     */
    final @property void position(vec2f position) @trusted
    {
        cpBodySetPosition(chipBody, cpVect(cast(cpFloat) position.x, cast(cpFloat) position.y));
    }

    /**
     * Return the angular velocity for this body
     */
    final @property float angularVelocity() @trusted
    {
        return cast(float) cpBodyGetAngularVelocity(chipBody);
    }

    /*
     * Set the angular velocity for this body
     */
    final @property void angularVelocity(float v) @trusted
    {
        cpBodySetAngularVelocity(chipBody, cast(cpFloat) v);
    }

    /**
     * Return the angle property for this body
     */
    final @property float angle() @trusted
    {
        return cast(float) cpBodyGetAngle(chipBody);
    }

    /**
     * Set the angle property for this body
     */
    final @property void angle(float a) @trusted
    {
        cpBodySetAngle(chipBody, cast(cpFloat) a);
    }

    /**
     * Returns the body's center of gravity, in body-local units
     */
    final @property vec2f centerOfGravity() @trusted
    {
        auto cpCenterOfGravity = cpBodyGetCenterOfGravity(chipBody);
        return vec2f(cast(float) cpCenterOfGravity.x, cast(float) cpCenterOfGravity.y);
    }

    /**
     * Set the body's center of gravity, in body-local units
     */
    final @property void centerOfGravity(vec2f g) @trusted
    {
        cpBodySetCenterOfGravity(chipBody, cpVect(cast(cpFloat) g.x, cast(cpFloat) g.y));
    }

    /**
     * Return the velocity for this body
     */
    final @property vec2f velocity() @trusted
    {
        auto cpVelocity = cpBodyGetVelocity(chipBody);
        return vec2f(cast(float) cpVelocity.x, cast(float) cpVelocity.y);
    }

    /**
     * Set the velocity for this body
     */
    final @property void velocity(vec2f v) @trusted
    {
        cpBodySetVelocity(chipBody, cpVect(cast(cpFloat) v.x, cast(cpFloat) v.y));
    }

    /**
     * Return the maximum velocity for this body
     * Default: unset
     */
    pure final @property vec2f maxVelocity() @safe nothrow
    {
        return _maxVelocity;
    }

    /**
     * Set the maximum velocity for this body in positive X/Y
     * velocities.
     */
    pure final @property void maxVelocity(vec2f newv) @safe
    {
        assert(newv.x >= 0.0f, "maxVelocity must have positive X value");
        assert(newv.y >= 0.0f, "maxVelocity must have positive Y value");
        _maxVelocity = newv;
    }

    /**
     * Return the minimum velocity for this body
     */
    pure final @property vec2f minVelocity() @safe nothrow
    {
        return _minVelocity;
    }

    pure final @property void minVelocity(vec2f newv) @safe
    {
        assert(newv.x >= 0.0f, "minVelocity must have positive X value");
        assert(newv.y >= 0.0f, "minVelocity must have positive Y value");
        _minVelocity = newv;
    }

    /**
     * Return the internal entity ID for the Body
     */
    pragma(inline, true) pure final EntityID entity() @safe @nogc nothrow
    {
        return _entity;
    }
}
