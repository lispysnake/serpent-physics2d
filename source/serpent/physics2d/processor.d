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
import serpent.physics2d.abstractWorld;
import serpent.physics2d.component;
import serpent.physics2d.world;

/**
 * Our Processor is responsible for managing the world and stepping through
 * execution.
 */
final class PhysicsProcessor : Processor!ReadWrite
{

private:

    AbstractWorld _world = null;

    /* Run physics sim in discrete 60fps steps */
    const float physicsRate = 1000.0f / 60.0f;

    float timeAccumulated = 0.0f;

    /**
     * Update the actual physics simulation with a fixed time step
     */
    final void updateWorldView(View!ReadWrite view)
    {
        _world.step(view, physicsRate);
    }

public:

    this()
    {
        import serpent.physics2d.parallelWorld;

        _world = new ParallelWorld();
    }

    /**
     * Register relevant physics components
     */
    final override void bootstrap(View!ReadWrite view)
    {
        context.entity.tryRegisterComponent!PhysicsComponent;
    }

    /**
     * Update for the current frame step
     */
    final override void run(View!ReadWrite view)
    {
        timeAccumulated += context.frameTime;

        uint runCount = cast(uint)(timeAccumulated / physicsRate);
        timeAccumulated -= (runCount * physicsRate);
        while (runCount > 0)
        {
            updateWorldView(view);
            --runCount;
        }

        _world.processUpdates(view);

        /* Find unregistered physics bodies for f+1 */
        foreach (entity, transform, physics; view.withComponents!(TransformComponent,
                PhysicsComponent))
        {
            if (_world.contains(physics.body))
            {
                continue;
            }

            /* Link this body to the entity now */
            physics.body.entity = entity.id;
            /* Sync the position */
            physics.body.position = vec2f(transform.position.x, transform.position.y);
            _world.add(physics.body);
        }
    }

    /**
     * Return the world instance
     */
    pure final @property ref AbstractWorld world() @safe @nogc nothrow
    {
        return _world;
    }
}
