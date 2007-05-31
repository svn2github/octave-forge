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

public abstract class GraphicObject extends HandleObject
{
	protected int glID;

	private static int glIDCounter = 1;

	/* properties */
	DoubleArrayProperty XLim;
	DoubleArrayProperty YLim;
	DoubleArrayProperty ZLim;
	DoubleArrayProperty CLim;
	DoubleArrayProperty ALim;
	BooleanProperty XLimInclude;
	BooleanProperty YLimInclude;
	BooleanProperty ZLimInclude;
	BooleanProperty CLimInclude;
	BooleanProperty ALimInclude;

	public GraphicObject(HandleObject parent, String type)
	{
		super(parent, type);

		glID = glIDCounter++;

		double[] d = new double[] {Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY};

		XLim = new DoubleArrayProperty(this, "XLim", d, 2);
		YLim = new DoubleArrayProperty(this, "YLim", d, 2);
		ZLim = new DoubleArrayProperty(this, "ZLim", d, 2);
		CLim = new DoubleArrayProperty(this, "CLim", d, 2);
		ALim = new DoubleArrayProperty(this, "ALim", d, 2);
		XLimInclude = new BooleanProperty(this, "XLimInclude", true);
		YLimInclude = new BooleanProperty(this, "YLimInclude", true);
		ZLimInclude = new BooleanProperty(this, "ZLimInclude", false);
		CLimInclude = new BooleanProperty(this, "CLimInclude", false);
		ALimInclude = new BooleanProperty(this, "ALimInclude", false);

		XLim.setVisible(false);
		YLim.setVisible(false);
		ZLim.setVisible(false);
		CLim.setVisible(false);
		ALim.setVisible(false);
		XLimInclude.setVisible(false);
		YLimInclude.setVisible(false);
		ZLimInclude.setVisible(false);
		CLimInclude.setVisible(false);
		ALimInclude.setVisible(false);
	}

	public AxesObject getAxes()
	{
		HandleObject obj = Parent.elementAt(0);
		if (obj instanceof AxesObject)
			return (AxesObject)obj;
		else
			return ((GraphicObject)obj).getAxes();
	}

	public abstract void draw(Renderer r);
}
