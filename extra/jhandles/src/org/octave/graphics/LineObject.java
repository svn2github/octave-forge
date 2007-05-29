/*
 * oplot-gl 
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

public class LineObject extends GraphicObject
{
	/* properties */
	DoubleArrayProperty XData;
	DoubleArrayProperty YData;
	DoubleArrayProperty ZData;
	ColorProperty LineColor;
	LineStyleProperty LineStyle;
	DoubleProperty LineWidth;
	StringProperty KeyLabel;
	MarkerProperty Marker;
	DoubleProperty MarkerSize;

	public LineObject(HandleObject parent, double[] xdata, double[] ydata)
	{
		this(parent, xdata, ydata, new double[0]);
	}
	
	public LineObject(HandleObject parent, double[] xdata, double[] ydata, double[] zdata)
	{
		super(parent, "line");

		XData = new DoubleArrayProperty(this, "XData", xdata, -1);
		YData = new DoubleArrayProperty(this, "YData", ydata, -1);
		ZData = new DoubleArrayProperty(this, "ZData", (zdata == null ? new double[0] : zdata), -1);
		LineColor = new ColorProperty(this, "Color", Color.blue);
		LineStyle = new LineStyleProperty(this, "LineStyle", "-");
		LineWidth = new DoubleProperty(this, "LineWidth", 1.0);
		KeyLabel = new StringProperty(this, "KeyLabel", "");
		Marker = new MarkerProperty(this, "Marker", "none");
		MarkerSize = new DoubleProperty(this, "MarkerSize", 9.0);

		if (ZData.getArray().length > 0)
			ZLimInclude.reset(new Boolean(true));

		listen(XData);
		listen(YData);
		listen(ZData);
	}

	public void validate()
	{
		updateMinMax();
		super.validate();
	}

	private void updateMinMax()
	{
		double xmin, xmax, ymin, ymax, zmin, zmax;
		double[] xdata = XData.getArray();
		double[] ydata = YData.getArray();
		double[] zdata = ZData.getArray();
		boolean hasZ = (zdata.length > 0);
		int n = Math.min(Math.min(xdata.length, ydata.length), (hasZ ? zdata.length : Integer.MAX_VALUE));

		if (n == 0)
			return;

		xmin = xdata[0]; xmax = xdata[0];
		ymin = ydata[0]; ymax = ydata[0];
		zmin = (hasZ ? zdata[0] : -0.5); zmax = (hasZ ? zdata[0] : 0.5);

		for (int i=1; i<n; i++)
		{
			if (xdata[i] < xmin) xmin = xdata[i];
			else if (xdata[i] > xmax) xmax = xdata[i];
			if (ydata[i] < ymin) ymin = ydata[i];
			else if (ydata[i] > ymax) ymax = ydata[i];
			if (hasZ)
			{
				if (zdata[i] < zmin) zmin = zdata[i];
				else if (zdata[i] > zmax) zmax = zdata[i];
			}
		}

		XLim.set(new double[] {xmin, xmax}, true);
		YLim.set(new double[] {ymin, ymax}, true);
		if (hasZ)
			ZLim.set(new double[] {zmin, zmax}, true);
	}

	/* TODO: remove
	public void draw(GL gl)
	{
		LineColor.setup(gl);
		LineStyle.setup(gl);
		if (!LineStyle.is("-"))
			gl.glEnable(GL.GL_LINE_STIPPLE);
		gl.glLineWidth((float)LineWidth.doubleValue());

		double[] xdata = XData.getArray();
		double[] ydata = YData.getArray();
		double[] zdata = ZData.getArray();

		gl.glBegin(GL.GL_LINE_STRIP);
		if (zdata.length > 0)
		{
			gl.glVertex3d(xdata[0], ydata[0], zdata[0]);
			for (int i=1; i<xdata.length; i++)
				gl.glVertex3d(xdata[i], ydata[i], zdata[i]);
		}
		else
		{
			gl.glVertex3d(xdata[0], ydata[0], 0.0);
			for (int i=1; i<xdata.length; i++)
				gl.glVertex3d(xdata[i], ydata[i], 0.0);
		}
		gl.glEnd();

		if (Marker.isSet())
		{
			MarkerProperty.Marker marker = Marker.makeMarker(MarkerSize.doubleValue(), LineWidth.doubleValue());
			if (zdata.length > 0)
				for (int i=0; i<xdata.length; i++)
					marker.draw(gl, xdata[i], ydata[i], zdata[i]);
			else
				for (int i=0; i<xdata.length; i++)
					marker.draw(gl, xdata[i], ydata[i], 0.0);
		}

		gl.glDisable(GL.GL_LINE_STIPPLE);
		gl.glLineWidth(1.0f);
		gl.glLineStipple(1, (short)0xFFFF);
	}
	*/

	public void draw(Renderer r)
	{
		r.draw(this);
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == XData || p == YData || p == ZData)
			updateMinMax();
	}
}
