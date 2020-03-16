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

module serpent.physics2d.world;

/**
 * 2D Physics Support for the Serpent Framework
 */

public import serpent.physics2d.body;
public import serpent.physics2d.world;
public import gfm.math;

import chipmunk;
import serpent;

/**
 * A World is simply a space for the physics simulation to run.
 */
final class World
{

private:

    __gshared cpSpace* space = null;

public:

    /**
     * Construct a new World.
     */
    this()
    {
        space = cpSpaceNew();
        space.userData = cast(void*) this;
    }

    ~this()
    {
        cpSpaceFree(space);
        space = null;
    }

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

package:

    /**
     * Step through execution of the world
     */
    final void step(View!ReadWrite view, float frameTime)
    {
        cpSpaceStep(space, cast(cpFloat) frameTime);
    }
}
