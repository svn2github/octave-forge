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

		updateMinMax();
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

		updateMinMax();
	}

	private void updateMinMax()
	{
		double[] x = XData.getArray(), y = YData.getArray();
		int h = CData.getDim(0), w = CData.getDim(1);
		double px = (x[1]-x[0])/(w-1), py = (y[1]-y[0])/(h-1);
		double xmin, xmax, ymin, ymax, xmin2, xmax2, ymin2, ymax2;

		xmin = xmin2 = x[0]-px/2; xmax = xmax2 = x[1]+px/2;
		ymin = ymin2 = y[0]-py/2; ymax = ymax2 = y[1]+py/2;
		if (xmax2 <= 0)
		{
			xmin2 = Double.POSITIVE_INFINITY;
			xmax2 = Double.MIN_VALUE;
		}
		else if (xmin2 <= 0)
		{
			double k = Math.ceil(0.5-x[0]/px);
			xmin2 = x[0]+(k-0.5)*px;
		}
		if (ymax2 <= 0)
		{
			ymin2 = Double.POSITIVE_INFINITY;
			ymax2 = Double.MIN_VALUE;
		}
		else if (ymin2 <= 0)
		{
			double k = Math.ceil(0.5-y[0]/py);
			ymin2 = y[0]+(k-0.5)*py;
		}

		XLim.set(new double[] {xmin, xmax, xmin2, xmax2}, true);
		YLim.set(new double[] {ymin, ymax, ymin2, ymax2}, true);
	}

	public void validate()
	{
		updateMinMax();
		super.validate();
	}

	public void draw(Renderer r)
	{
		r.draw(this);
	}
}
