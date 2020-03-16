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

module serpent.physics2d.polyShape;

import chipmunk;

public import gfm.math;
public import serpent.physics2d.shape : Shape;

/**
 * Implements a polygon shape (i.e. more than one point)
 */
final class PolyShape : Shape
{
private:

    cpPolyShape _shape;

public:

    /**
     * Construct a new PolyShape with the given vertices and radius
     */
    this(ref vec2f[] vertices, float radius)
    {
        /* This is kinda nasty, wish we could avoid the alloc. */
        cpVect[] cpVertices = new cpVect[vertices.length];
        foreach (idx, ref v; vertices)
        {
            cpVertices[idx] = cpVect(cast(cpFloat) v.x, cast(cpFloat) v.y);
        }
        auto transform = cpTransformIdentity;
        cpPolyShapeInit(&_shape, null, cast(int) vertices.length,
                cast(const(cpVect*)) cpVertices.ptr, transform, cast(cpFloat) radius);

        super(cast(cpShape*)&_shape);
    }

    /**
     * Return a specific vertex pair from the shape
     */
    pragma(inline, true) @property final vec2f vertex(int index) @trusted
    {
        auto cpVertex = cpPolyShapeGetVert(chipShape, index);
        return vec2f(cast(float) cpVertex.x, cast(float) cpVertex.y);
    }

    /**
     * Return the radius (curve dampening) of the shape
     */
    pragma(inline, true) @property final float radius() @trusted
    {
        return cpPolyShapeGetRadius(chipShape);
    }
}
