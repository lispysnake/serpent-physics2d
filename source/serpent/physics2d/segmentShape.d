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

module serpent.physics2d.segmentShape;

import chipmunk;

public import gfm.math;
public import serpent.physics2d.shape : Shape;

/**
 * Implements a Segment shape - a line with a given thickness between
 * two specified points
 */
final class SegmentShape : Shape
{

public:

    /**
     * Construct a new SegmentShape between the two x,y coordinates with
     * the given radius/thickness
     */
    this(ref vec2f a, ref vec2f b, float radius = 1.0f)
    {

        super(cpSegmentShapeNew(null, cpVect(cast(cpFloat) a.x,
                cast(cpFloat) a.y), cpVect(cast(cpFloat) b.x,
                cast(cpFloat) b.y), cast(cpFloat) radius));
    }

    /**
     * Return the radius/thickness of the shape
     */
    pragma(inline, true) @property final float radius() @trusted
    {
        return cpSegmentShapeGetRadius(chipShape);
    }

    /**
     * Returns point A as a vector
     */
    pragma(inline, true) @property final vec2f a() @trusted
    {
        auto pointA = cpSegmentShapeGetA(chipShape);
        return vec2f(cast(float) pointA.x, cast(float) pointA.y);
    }

    /**
     * Returns point B as a vector
     */
    pragma(inline, true) @property final vec2f b() @trusted
    {
        auto pointB = cpSegmentShapeGetB(chipShape);
        return vec2f(cast(float) pointB.x, cast(float) pointB.y);
    }

    /**
     * Return the segments normal as a vector
     */
    pragma(inline, true) @property final vec2f normal() @trusted
    {
        auto norm = cpSegmentShapeGetNormal(chipShape);
        return vec2f(cast(float) norm.x, cast(float) norm.y);
    }
}
