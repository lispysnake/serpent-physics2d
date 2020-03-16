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

module serpent.physics2d.abstractWorld;

/**
 * 2D Physics Support for the Serpent Framework
 */

public import serpent.physics2d.body;
public import gfm.math;

import chipmunk;
import serpent.core.view;

/**
 * Base implementation for our worlds. Worlds must be implemented internally
 * only.
 */
package abstract class AbstractWorld
{

package:

    __gshared cpSpace* _space = null;

    pragma(inline, true) final @property cpSpace* space() @trusted @nogc nothrow
    {
        return _space;
    }

    pragma(inline, true) final @property void space(cpSpace* space) @trusted @nogc nothrow
    {
        _space = space;
    }

public:

    /**
     * Set the gravity property for the simulation
     */
    final @property void gravity(vec2f gravity) @trusted
    {
        cpSpaceSetGravity(space, cpVect(cast(cpFloat) gravity.x, cast(cpFloat) gravity.y));
    }

    /**
     * Return the gravity property for the simulation
     */
    final @property vec2f gravity() @trusted
    {
        auto gravity = cpSpaceGetGravity(space);
        return vec2f(cast(float) gravity.x, cast(float) gravity.y);
    }

    /**
     * Add body to the world simulation
     *
     * It is not enough for an entity to have a body component, it must
     * explicitly be registered with the simulation.
     */
    final void addBody(Body _body) @trusted
    {
        assert(_body !is null, "Cannot add null body");
        cpSpaceAddBody(space, _body.chipBody());

        /* TODO: Figure out how to add all shapes.. ?*/
    }

    /**
     * Remove a body from the world simulation
     */
    final void removeBody(Body _body) @trusted
    {
        assert(_body !is null, "Cannot remove null body");
        cpSpaceRemoveBody(space, _body.chipBody());
    }

    /**
     * Step through execution of the world
     */
    abstract void step(View!ReadWrite view, float frameTime) @trusted;
}