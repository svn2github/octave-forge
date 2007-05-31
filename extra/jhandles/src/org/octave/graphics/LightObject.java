/*
 * jhandles 
 *
 * Copyright (C) 2007 Michael Goffioul 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 *
 */

package org.octave.graphics;

import java.awt.*;

public class LightObject extends GraphicObject
{
	private int lightIndex;

	/* Properties */
	ColorProperty LightColor;
	DoubleArrayProperty Position;
	RadioProperty Style;

	public LightObject(HandleObject parent)
	{
		super(parent, "light");

		LightColor = new ColorProperty(this, "Color", Color.white);
		Position = new DoubleArrayProperty(this, "Position", new double[] {0,0,1}, 3);
		Style = new RadioProperty(this, "Style", new String[] {"infinite", "local"}, "infinite");

		lightIndex = 0;
	}

	public void validate()
	{
		super.validate();
	}

	/* TODO: remove
	public void draw(GL gl)
	{
		float[] lp = new float[] {
			LightColor.getColor().getRed()/255.0f,
			LightColor.getColor().getGreen()/255.0f,
			LightColor.getColor().getBlue()/255.0f,
			1.0f};
		gl.glLightfv(GL.GL_LIGHT0+lightIndex, GL.GL_DIFFUSE, lp, 0);
		gl.glLightfv(GL.GL_LIGHT0+lightIndex, GL.GL_SPECULAR, lp, 0);

		double[] pos = Position.getArray();
		gl.glLightfv(GL.GL_LIGHT0+lightIndex, GL.GL_POSITION,
				new float[] {(float)pos[0], (float)pos[1], (float)pos[2], (Style.is("infinite") ? 0.0f : 1.0f)},
				0);
	}
	*/

	public void draw(Renderer r)
	{
		r.draw(this);
	}

	int getLightIndex()
	{
		return lightIndex;
	}

	void setLightIndex(int index)
	{
		lightIndex = index;
	}
}
