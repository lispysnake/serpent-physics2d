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

module serpent.physics2d.boxShape;

import chipmunk;

public import gfm.math;
public import serpent.physics2d.shape : Shape;

/**
 * Implements a Box Shape. Highly useful, much recommended.
 */
final class BoxShape : Shape
{
private:

    cpPolyShape _shape;

public:

    /**
     * Construct a new BoxShape with the given width, height and radius
     */
    this(float width, float height, float radius = 0.0f)
    {
        this(rectanglef(0.0f, 0.0f, width, height), radius);
    }

    /**
     * Construct a new BoxShape from the given box and radius
     */
    this(box2f box, float radius = 0.0f)
    {
        auto cpBoxed = cpBBNew(cast(cpFloat) box.min.x, cast(cpFloat) box.min.y,
                cast(cpFloat) box.max.x, cast(cpFloat) box.max.y);
        cpBoxShapeInit2(&_shape, null, cpBoxed, cast(cpFloat) radius);
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
