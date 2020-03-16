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

import chipmunk;
import serpent.core.entity : EntityID;

/**
 * A Rigid Body is a composition of shapes that are used to provide physics
 * support in the simulation
 */
class Body
{

private:

    /**
     * Add all existing shapes to the world simulation
     */
    extern (C) static final void addShapes(cpBody* parentBody, cpShape* _shape, void* userdata)
    {
        assert(_shape.userData !is null, "Cannot have shape without userData");
        Shape shape = cast(Shape) _shape.userData;
        AbstractWorld world = cast(AbstractWorld) userdata;
        world.add(shape);
    }

    /**
     * Remove all existing shapes from the world simulation
     */
    extern (C) static final void removeShapes(cpBody* parentBody, cpShape* _shape, void* userdata)
    {
        assert(_shape.userData !is null, "Cannot have shape without userData");
        Shape shape = cast(Shape) _shape.userData;
        AbstractWorld world = cast(AbstractWorld) userdata;
        world.remove(shape);
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

package:

    cpBody _body;
    EntityID _entity;

    /**
     * Return pointer to the underlying chipmunk body.
     */
    pragma(inline, true) pure final cpBody* chipBody() @safe @nogc nothrow
    {
        return &_body;
    }

    /**
     * Return the internal entity ID for the Body
     */
    pragma(inline, true) pure final EntityID entity() @safe @nogc nothrow
    {
        return _entity;
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
    this(float mass, float moment)
    {
        cpBodyInit(&_body, cast(cpFloat) mass, cast(cpFloat) moment);
        _body.userData = cast(void*) this;
    }

    /**
     * Create a Body with automatic mass and moment
     */
    this()
    {
        this(0.0f, 0.0f);
    }

    ~this()
    {
        auto world = this.world();
        if (world !is null)
        {
            world.remove(this);
        }

        cpBodyEachShape(chipBody, &killShapes, null);
        cpBodyDestroy(&_body);
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
            cpBodyEachShape(chipBody, &addShapes, cast(void*) newWorld);
        }
    }

public:

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
        shape.body = this;

        /* Add shape to world if we have one */
        auto world = this.world();
        if (world is null)
        {
            return;
        }
        world.add(shape);
    }

    /**
     * Remove the shape from the body
     */
    final void remove(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot remove shape from body");
        shape.body = null;

        /* Remove shape from world if we have one */
        auto world = this.world();
        if (world is null)
        {
            return;
        }
        world.remove(shape);
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
}
