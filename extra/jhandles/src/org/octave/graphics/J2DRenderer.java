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
import java.awt.image.BufferedImage;
import java.nio.ByteBuffer;
import java.util.Iterator;

public class J2DRenderer implements Renderer
{
	private Graphics2D g;
	private boolean clipping;
	private Matrix3D xForm;

	public J2DRenderer()
	{
		g = null;
		clipping = false;
	}

	void setGraphics(Graphics g)
	{
		this.g = (Graphics2D)g;
	}

	public void end()
	{
	}

	public void setClipping(boolean flag)
	{
		clipping = flag;
	}

	public boolean hasClipping()
	{
		return clipping;
	}

	public void setColor(Color c)
	{
		if (g != null)
			g.setColor(c);
	}

	public void setXForm(AxesObject ax)
	{
		xForm = ax.x_render;
	}

	private void transformPoints(java.util.List pts, int[] x, int[] y)
	{
		Iterator it = pts.iterator();
		double[] tmp = new double[4];
		int idx = 0;

		while (it.hasNext())
		{
			Point3D pt = (Point3D)it.next();
			xForm.transform(pt.x, pt.y, pt.z, tmp, 0);
			x[idx] = (int)Math.round(tmp[0]);
			y[idx] = (int)Math.round(tmp[1]);
			idx++;
		}
	}
	
	public void drawSegments(java.util.List pts)
	{
	}

	public void drawQuads(java.util.List pts, double zoffset)
	{
		if (g != null)
		{
			Iterator it = pts.iterator();
			int count = 0;
			int[] x = new int[4], y = new int[4];
			double[] tmp = new double[4];

			while (it.hasNext())
			{
				Point3D pt = (Point3D)it.next();
				xForm.transform(pt.x, pt.y, pt.z, tmp, 0);
				x[count] = (int)Math.round(tmp[0]);
				y[count] = (int)Math.round(tmp[1]);
				if (++count == 4)
				{
					count = 0;
					g.fillPolygon(x, y, 4);
				}
			}
		}
	}
}
