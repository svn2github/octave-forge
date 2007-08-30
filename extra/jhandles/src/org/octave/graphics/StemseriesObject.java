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

public class StemseriesObject extends GroupObject
{
	/* Properties */
	HandleObjectListProperty BaseLine;
	DoubleProperty BaseValue;
	MarkerProperty Marker;
	ColorProperty StemColor;
	VectorProperty XData;
	VectorProperty YData;
	VectorProperty ZData;
	LineStyleProperty LineStyle;
	BooleanProperty ShowBaseLine;

	public StemseriesObject(HandleObject parent, double[] xdata, double[] ydata)
	{
		this(parent, xdata, ydata, new double[0]);
	}

	public StemseriesObject(HandleObject parent, double[] xdata, double[] ydata, double[] zdata)
	{
		super(parent);

		if (zdata == null)
			zdata = new double[0];

		double[] dummy = new double[0];

		LineObject line = new LineObject(this, dummy, dummy, dummy);
		LineObject markers = new LineObject(this, dummy, dummy, dummy);
		markers.Marker.reset("o");
		markers.LineStyle.reset("none");
		BaseLineObject base = getAxes().getBaseLine();

		XData = new VectorProperty(this, "XData", -1, xdata);
		YData = new VectorProperty(this, "YData", -1, ydata);
		ZData = new VectorProperty(this, "ZData", -1, zdata);
		BaseLine = new HandleObjectListProperty(this, "BaseLine", 1);
		BaseLine.addElement(base);
		BaseLine.setReadOnly(true);
		BaseValue = new DoubleProperty(this, "BaseValue", base.BaseValue.doubleValue());
		Marker = new MarkerProperty(this, "Marker", markers.Marker.getValue());
		StemColor = new ColorProperty(this, "Color", line.LineColor.getColor());
		LineStyle = new LineStyleProperty(this, "LineStyle", line.LineStyle.getValue());
		ShowBaseLine = new BooleanProperty(this, "ShowBaseLine", base.Visible.isSet());

		if (zdata.length > 0)
			ZLimInclude.reset(new Boolean(true));

		listen(Marker);
		listen(StemColor);
		listen(LineStyle);
		listen(base.BaseValue);
		listen(base.Visible);
		listen(BaseValue);
		listen(ShowBaseLine);
		listen(XData);
		listen(YData);
		listen(ZData);
		listen(line.XLim);
		listen(line.YLim);
		listen(line.ZLim);
	}

	public void delete()
	{
		super.delete();
	}

	public boolean isLegendable()
	{
		return true;
	}

	private void updateXyzData()
	{
		double[] xdata = XData.getArray();
		double[] ydata = YData.getArray();
		double[] zdata = ZData.getArray();

		int n = Math.min(Math.min(xdata.length, ydata.length), (zdata.length > 0 ? zdata.length : Integer.MAX_VALUE));

		double[] xx = new double[n*3];
		double[] yy = new double[n*3];
		double[] zz = new double[(zdata.length > 0 ? n*3 : 0)];

		double B = BaseValue.doubleValue();

		for (int i=0; i<n; i++)
		{
			xx[3*i] = xdata[i];
			xx[3*i+1] = xdata[i];
			xx[3*i+2] = Double.NaN;
			if (zdata.length == 0)
			{
				yy[3*i] = B;
				yy[3*i+1] = ydata[i];
				yy[3*i+2] = Double.NaN;
			}
			else
			{
				yy[3*i] = ydata[i];
				yy[3*i+1] = ydata[i];
				yy[3*i+2] = Double.NaN;
				zz[3*i] = 0;
				zz[3*i+1] = zdata[i];
				zz[3*i+2] = Double.NaN;
			}
		}

		LineObject line = getLine();
		line.XData.set(xx, true);
		line.YData.set(yy, true);
		if (zdata.length > 0)
			line.ZData.set(zz, true);

		LineObject markers = getMarkers();
		markers.XData.reset(xdata);
		markers.YData.reset(ydata);
		markers.ZData.reset(zdata);
	}

	public void validate()
	{
		updateXyzData();
		super.validate();
	}

	private LineObject getLine()
	{
		return (LineObject)Children.elementAt(0);
	}
	
	private LineObject getMarkers()
	{
		return (LineObject)Children.elementAt(1);
	}

	private BaseLineObject getBaseLine()
	{
		return (BaseLineObject)BaseLine.elementAt(0);
	}

	/* PropertyListener interface */

	public void propertyChanged(Property p) throws PropertyException
	{
		super.propertyChanged(p);

		if (p == Marker)
			getMarkers().Marker.set(Marker.get());
		else if (p == StemColor)
		{
			getMarkers().LineColor.set(StemColor.get());
			getLine().LineColor.set(StemColor.get());
		}
		else if (p == LineStyle)
			getLine().LineStyle.set(LineStyle.get());
		else if (p == BaseValue)
		{
			updateXyzData();
			getBaseLine().BaseValue.set(BaseValue.get());
		}
		else if (p.getName().equals("BaseValue"))
		{
			BaseValue.reset(p.get());
			updateXyzData();
		}
		else if (p == Visible)
		{
		}
		else if (p.getName().equals("Visible"))
			ShowBaseLine.set(p.get());
		else if (p == ShowBaseLine)
			getBaseLine().set("Visible", ShowBaseLine.get());
		else if (p == XData || p == YData || p == ZData)
			updateXyzData();

		if (p.getParent() != this)
		{
			String name = p.getName();
			
			if (name.equals("XLim"))
				XLim.set(p.get());
			else if (name.equals("YLim"))
				YLim.set(p.get());
			else if (name.equals("ZLim"))
				ZLim.set(p.get());
		}
	}

	public void propertyGetting(Property p) {}

	public void propertySetting(Property p, Object value) {}
}
