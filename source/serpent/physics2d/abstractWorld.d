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
import serpent.core.transform;

/**
 * Base implementation for our worlds. Worlds must be implemented internally
 * only.
 */
package abstract class AbstractWorld
{

private:

    /**
     * For each body in the simulation, if it has a corresponding Body object,
     * update the linked entity data.
     */
    extern (C) static final void updateBody(cpBody* _body, void* userdata)
    {
        View!ReadWrite* view = cast(View!ReadWrite*) userdata;

        if (_body.userData is null)
        {
            return;
        }

        /* Only update dynamic/kinematic bodies */
        if (cpBodyGetType(_body) == cpBodyType.CP_BODY_TYPE_STATIC)
        {
            return;
        }

        /* Process the entity update now */
        Body bd = cast(Body) _body.userData;
        auto transform = view.data!TransformComponent(bd.entity);

        transform.position = vec3f(bd.position.x, bd.position.y, transform.position.z);
    }

package:

    __gshared cpSpace* _space = null;

    pragma(inline, true) final @property cpSpace* chipSpace() @trusted @nogc nothrow
    {
        return _space;
    }

    pragma(inline, true) final @property void chipSpace(cpSpace* space) @trusted @nogc nothrow
    {
        _space = space;
    }

    /**
     * Used by each implementation to update components for every given body
     * within the space.
     *
     * It is quite possible this is inefficient right now.
     */
    pragma(inline, true) final void processUpdates(View!ReadWrite view) @trusted
    {
        cpSpaceEachBody(_space, &updateBody, cast(void*)&view);

    }

package:

    /**
     * Add body to the world simulation
     *
     * It is not enough for an entity to have a body component, it must
     * explicitly be registered with the simulation.
     */
    final void add(Body _body) @trusted
    {
        assert(_body !is null, "Cannot add null body");
        cpSpaceAddBody(chipSpace, _body.chipBody());
        _body.world = this;
    }

    /**
     * Remove a body from the world simulation
     */
    final void remove(Body _body) @trusted
    {
        assert(_body !is null, "Cannot remove null body");
        cpSpaceRemoveBody(chipSpace, _body.chipBody);
        _body.world = null;
    }

    /**
     * Add a shape to the world simulation
     */
    final void add(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot add null shape");
        cpSpaceAddShape(chipSpace, shape.chipShape);
    }

    /**
     * Remove a shape from the world simulation
     */
    final void remove(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot remove null shape");
        cpSpaceRemoveShape(chipSpace, shape.chipShape);
    }

    /**
     * Return true if we own this body
     */
    final bool contains(Body _body) @trusted
    {
        assert(_body !is null, "Cannot check contains for null body");
        return cpSpaceContainsBody(chipSpace, _body.chipBody) == cpTrue ? true : false;
    }

    /**
     * Return true if we own this shape
     */
    final bool contains(Shape shape) @trusted
    {
        assert(shape !is null, "Cannot check contains for null shape");
        return cpSpaceContainsShape(chipSpace, shape.chipShape) == cpTrue ? true : false;
    }

public:

    /**
     * Set the gravity property for the simulation
     */
    final @property void gravity(vec2f gravity) @trusted
    {
        cpSpaceSetGravity(chipSpace, cpVect(cast(cpFloat) gravity.x, cast(cpFloat) gravity.y));
    }

    /**
     * Return the gravity property for the simulation
     */
    final @property vec2f gravity() @trusted
    {
        auto gravity = cpSpaceGetGravity(chipSpace);
        return vec2f(cast(float) gravity.x, cast(float) gravity.y);
    }

    /**
     * Increase the iterations for higher accuracy
     */
    final @property void iterations(int n) @trusted
    {
        cpSpaceSetIterations(chipSpace, n);
    }

    /**
     * Return the number of iterations
     */
    final @property int iterations() @trusted
    {
        return cpSpaceGetIterations(chipSpace);
    }

    /**
     * Step through execution of the world
     */
    abstract void step(View!ReadWrite view, float frameTime) @trusted;
}
