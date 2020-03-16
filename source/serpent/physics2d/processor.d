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

module serpent.physics2d.processor;

import serpent;
import serpent.physics2d.world;

/**
 * Our Processor is responsible for managing the world and stepping through
 * execution.
 */
final class Physics2DProcessor : Processor!ReadWrite
{

private:

    World _world = null;

public:

    this()
    {
        _world = new World();
    }

    /**
     * Update for the current frame step
     */
    final override void run(View!ReadWrite view)
    {
        /* TODO: Add frame step accumulator */
        _world.step(view, context.frameTime);
    }

    /**
     * Return the world instance
     */
    pure final @property ref World world() @safe @nogc nothrow
    {
        return _world;
    }
}
