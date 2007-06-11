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

import java.util.*;

public class GroupObject extends GraphicObject
{
	public GroupObject(HandleObject parent)
	{
		super(parent, "hggroup");
	}

	private void updateLimits()
	{
		synchronized (Children)
		{
			double xmin, xmax, ymin, ymax, zmin, zmax, cmin, cmax, amin, amax;
			Iterator it = Children.iterator();
			double[] lim;

			xmin = ymin = zmin = cmin = amin = Double.POSITIVE_INFINITY;
			xmax = ymax = zmax = cmax = amax = Double.NEGATIVE_INFINITY;
			while (it.hasNext())
			{
				GraphicObject obj = (GraphicObject)it.next();
				lim = obj.XLim.getArray();
				xmin = Math.min(lim[0], xmin);
				xmax = Math.max(lim[1], xmax);
				lim = obj.YLim.getArray();
				ymin = Math.min(lim[0], ymin);
				ymax = Math.max(lim[1], ymax);
				lim = obj.ZLim.getArray();
				zmin = Math.min(lim[0], zmin);
				zmax = Math.max(lim[1], zmax);
				lim = obj.CLim.getArray();
				cmin = Math.min(lim[0], cmin);
				cmax = Math.max(lim[1], cmax);
				lim = obj.ALim.getArray();
				amin = Math.min(lim[0], amin);
				amax = Math.max(lim[1], amax);
			}

			XLim.set(new double[] {xmin, xmax}, true);
			YLim.set(new double[] {ymin, ymax}, true);
			ZLim.set(new double[] {zmin, zmax}, true);
			CLim.set(new double[] {cmin, cmax}, true);
			ALim.set(new double[] {amin, amax}, true);
		}
	}

	public void childValidated(HandleObject child)
	{
		super.childValidated(child);
		updateLimits();
		if (child instanceof GraphicObject)
		{
			GraphicObject g = (GraphicObject)child;
			listen(g.XLim);
			listen(g.YLim);
			listen(g.ZLim);
			listen(g.CLim);
			listen(g.ALim);
		}
	}

	public void removeChild(HandleObject child)
	{
		super.removeChild(child);
		updateLimits();
	}

	public void draw(Renderer r)
	{
		synchronized (Children)
		{
			Iterator it = Children.iterator();
			while (it.hasNext())
			{
				GraphicObject obj = (GraphicObject)it.next();
				obj.draw(r);
			}
		}
	}

	public void validate()
	{
		synchronized (Children)
		{
			Iterator it = Children.iterator();
			while (it.hasNext())
				((HandleObject)it.next()).validate();
			super.validate();
		}
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		super.propertyChanged(p);
		
		String name = p.getName().toLowerCase();
		if (name.equals("xlim") || name.equals("ylim") || name.equals("zlim") ||
			name.equals("clim") || name.equals("alim"))
		{
			updateLimits();
		}
	}
}
