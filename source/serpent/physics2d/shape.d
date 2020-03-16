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

module serpent.physics2d.shape;

import chipmunk;

public import gfm.math;
public import serpent.physics2d.body : Body;

/**
 * Base type for all shapes within serpent.physics2d.
 */
abstract class Shape
{

private:

    cpShape* _shapePtr = null;

package:

    /**
     * Initialise this shape with the shapePtr property
     */
    this(cpShape* shapePtr)
    {
        chipShape = shapePtr;
    }

    /**
     * Set the pointer to the underlying chipmunk shape
     */
    pragma(inline, true) pure final @property void chipShape(cpShape* shapePtr) @safe @nogc nothrow
    {
        _shapePtr = shapePtr;
    }

    /**
     * Retrieve the pointer to the underlying chipmunk shape
     */
    pragma(inline, true) pure final @property cpShape* chipShape() @safe @nogc nothrow
    {
        return _shapePtr;
    }

    /**
     * Set the body property
     */
    pragma(inline, true) final @property void body(Body bd) @trusted
    {
        assert(bd !is null, "Cannot set the body to a null body");
        cpShapeSetBody(chipShape, bd.chipBody);
    }

    pragma(inline, true) final @property Body body() @trusted
    {
        return cast(Body)(cpShapeGetBody(chipShape).userData);
    }

public:

     ~this()
    {
        cpShapeDestroy(chipShape);
        chipShape = null;
    }

    /**
     * Return the elasticity (bounciness) of the shape
     */
    pragma(inline, true) final @property float elasticity() @trusted
    {
        return cast(float) cpShapeGetElasticity(chipShape);
    }

    /**
     * Set the elasticity (or bounciness) of the shape
     */
    pragma(inline, true) final @property void elasticity(float e) @trusted
    {
        assert(e >= 0.0f && e <= 1.0f, "Elasticity not within 0.0f and 1.0f");
        cpShapeSetElasticity(chipShape, cast(cpFloat) e);
    }

    /**
     * Return the friction coefficient of the shape
     */
    pragma(inline, true) final @property float friction() @trusted
    {
        return cast(float) cpShapeGetFriction(chipShape);
    }

    /**
     * Set the friction coefficient of the shape
     */
    pragma(inline, true) final @property void friction(float f) @trusted
    {
        assert(f >= 0.0f && f <= 1.0f, "Friction coefficient not within 0.0f and 1.0f");
        cpShapeSetFriction(chipShape, cast(cpFloat) f);
    }

    /**
     * Return the surface velocity of the shape
     */
    pragma(inline, true) final @property vec2f surfaceVelocity() @trusted
    {
        auto cpSurfaceVelocity = cpShapeGetSurfaceVelocity(chipShape);
        return vec2f(cast(float) cpSurfaceVelocity.x, cast(float) cpSurfaceVelocity.y);
    }

    /**
     * Set the surface velocity of the shape
     */
    pragma(inline, true) final @property void surfaceVelocity(vec2f v) @trusted
    {
        assert(v.x >= 0.0f && v.x <= 1.0f, "Surface velocity X not within 0.0f and 1.0f");
        assert(v.y >= 0.0f && v.y <= 1.0f, "Surface velocity Y not within 0.0f and 1.0f");
        cpShapeSetSurfaceVelocity(chipShape, cpVect(cast(cpFloat) v.x, cast(cpFloat) v.y));
    }

    /**
     * Return the bounding box for the shape
     */
    pragma(inline, true) final @property box2f boundingBox() @trusted
    {
        auto cpBoundingBox = cpShapeGetBB(chipShape);
        return rectanglef(cast(float) cpBoundingBox.l, cast(float) cpBoundingBox.t,
                cast(float) cpBoundingBox.r, cast(float) cpBoundingBox.b);
    }
}
