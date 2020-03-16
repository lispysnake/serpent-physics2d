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

/**
 * A Rigid Body is a composition of shapes that are used to provide physics
 * support in the simulation
 */
class Body
{
package:

    cpBody _body;

    /**
     * Return pointer to the underlying chipmunk body.
     */
    pragma(inline, true) pure final cpBody* chipBody() @safe @nogc nothrow
    {
        return &_body;
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
        cpBodyDestroy(&_body);
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
    }

    /**
     * Remove the shape from the body
     */
    final void remove(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot remove shape from body");
        shape.body = null;
    }
}
