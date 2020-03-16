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

module serpent.physics2d.component;

public import serpent.physics2d.body : Body;
public import serpent.core.component;

/**
 * Ensrre that a cpBody is correctly removed from the space and that
 * resources are returned to the OS
 */
final static void freeComponent(void* v)
{
    PhysicsComponent* comp = cast(PhysicsComponent*) v;
    if (comp.body is null)
    {
        return;
    }

    comp.body.destroy();
    comp.body = null;
}

/**
 * Add a Physics2D Component to your entity to imbue it with physics
 * properties. Note you should a body can only be attached to a single
 * entity, and a component must contain a valid body.
 */
final @serpentComponent struct PhysicsComponent
{
    Body body;
}
