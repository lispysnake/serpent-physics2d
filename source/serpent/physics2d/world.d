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

public import serpent.physics2d.abstractWorld;
public import serpent.physics2d.body;
public import gfm.math;

import chipmunk;
import serpent.ecs.view;

/**
 * The default World implementation is single-threaded in nature
 */
final class World : AbstractWorld
{

public:

    /**
     * Construct a new World.
     */
    this()
    {
        super(cpSpaceNew());
    }

    ~this()
    {
        cpSpaceFree(chipSpace);
        chipSpace = null;
    }

    /**
     * Step through execution of the world
     */
    final override void step(View!ReadWrite view, float frameTime) @trusted
    {
        cpSpaceStep(chipSpace, cast(cpFloat) frameTime);
    }
}
