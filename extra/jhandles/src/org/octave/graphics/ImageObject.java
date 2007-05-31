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

public class ImageObject extends GraphicObject
{
	/* Properties */
	DoubleArrayProperty XData;
	DoubleArrayProperty YData;
	MatrixProperty CData;

	public ImageObject(HandleObject parent, byte[][][] cdata)
	{
		super(parent, "image");

		CData = new MatrixProperty(this, "CData", cdata);
		XData = new DoubleArrayProperty(this, "XData", new double[] {1, cdata[0].length}, 2);
		YData = new DoubleArrayProperty(this, "YData", new double[] {1, cdata.length}, 2);

		XLim.reset(XData.getArray());
		YLim.reset(YData.getArray());
	}

	public ImageObject(HandleObject parent, double[][] r, double[][] g, double[][] b)
	{
		super(parent, "image");

		double[][][] buf = new double[r.length][r[0].length][3];
		for (int i=0; i<r.length; i++)
			for (int j=0; j<r[0].length; j++)
			{
				buf[i][j][0] = r[i][j];
				buf[i][j][1] = g[i][j];
				buf[i][j][2] = b[i][j];
			}
		
		CData = new MatrixProperty(this, "CData", buf);
		XData = new DoubleArrayProperty(this, "XData", new double[] {1, r[0].length}, 2);
		YData = new DoubleArrayProperty(this, "YData", new double[] {1, r.length}, 2);

		XLim.reset(XData.getArray());
		YLim.reset(YData.getArray());
	}

	public void validate()
	{
		super.validate();
	}

	public void draw(Renderer r)
	{
		r.draw(this);
	}
}
