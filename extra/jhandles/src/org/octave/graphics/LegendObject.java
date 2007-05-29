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

import java.util.*;
import java.awt.*;

public class LegendObject extends AxesObject
{
	private class LegendItem
	{
		String name;
		TextObject text;
		LineObject line;
		LineObject marker;
		PatchObject patch;
	}

	private LegendItem makeItemFromLine(HandleObject line, String name)
	{
		LegendItem item = new LegendItem();
		item.name = name;

		try
		{
			item.text = new TextObject(this, name, new double[] {0, 0, 0});
			item.text.VAlign.reset("middle");
			item.text.TextColor.reset(TextColor.get());
			item.text.validate();

			item.line = new LineObject(this, new double[] {0, 0}, new double[] {0, 0});
			item.line.LineColor.reset(line.get("Color"));
			item.line.LineStyle.reset(line.get("LineStyle"));
			item.line.validate();

			item.marker = new LineObject(this, new double[] {0, 0}, new double[] {0, 0});
			item.marker.LineColor.reset(line.get("Color"));
			item.marker.LineStyle.reset("none");
			item.marker.Marker.reset(line.get("Marker"));
			item.marker.validate();
		}
		catch (PropertyException e) {}

		return item;
	}

	private LegendItem[] items;
	private AxesObject axes;
	private Dimension size;

	/* Properties */
	RadioProperty Location;
	ColorProperty EdgeColor;
	ColorProperty TextColor;
	StringArrayProperty String;
	RadioProperty Orientation;

	public LegendObject(AxesObject axes, String[] names)
	{
		super(axes.getFigure(), false);
		alwaysDrawBox = false;

		Location = new RadioProperty(this, "Location",
			new String[] {
				"North", "South", "East", "West",
				"NorthEast", "NorthWest", "SouthEast", "SouthWest",
				"NorthOutside", "SouthOutside", "EastOutside", "WestOutside",
				"NorthEastOutside", "NorthWestOutside", "SouthEastOutside", "SouthWestOutside",
				 "Best", "BestOutside", "none"},
			"NorthEast");
		EdgeColor = new ColorProperty(this, "EdgeColor", Color.black, new String[] {"none"}, null);
		TextColor = new ColorProperty(this, "TextColor", Color.black, new String[] {"none"}, null);
		String = new StringArrayProperty(this, "String", new String[0]);
		Orientation = new RadioProperty(this, "Orientation", new String[] {"vertical", "horizontal"}, "vertical");

		ActivePositionProperty.reset("position");
		XLimMode.reset("manual");
		YLimMode.reset("manual");
		ZLimMode.reset("manual");
		XLim.reset(new double[] {0, 1});
		YLim.reset(new double[] {0, 1});
		ZLim.reset(new double[] {-0.5, 0.5});
		XTickMode.reset("manual");
		YTickMode.reset("manual");
		ZTickMode.reset("manual");
		XTick.reset(null);
		YTick.reset(null);
		ZTick.reset(null);
		XTickLabelMode.reset("manual");
		YTickLabelMode.reset("manual");
		ZTickLabelMode.reset("manual");
		XTickLabel.reset(null);
		YTickLabel.reset(null);
		ZTickLabel.reset(null);
		XColor.reset(EdgeColor.get());
		YColor.reset(EdgeColor.get());
		ZColor.reset(EdgeColor.get());
		Tag.reset("legend");

		buildLegend(axes, names);
		listen(axes.Position);
		listen(axes.OuterPosition);
		listen(Location);
		listen(Orientation);
		listen(EdgeColor);
		listen(TextColor);
		listen(String);
	}

	public void buildLegend(AxesObject axes, String[] names)
	{
		doClear();
		this.axes = axes;

		LinkedList tmp = new LinkedList();
		Iterator it = axes.Children.iterator();
		int index = 0;

		while (it.hasNext())
		{
			HandleObject obj = (HandleObject)it.next();

			if (!obj.isLegendable())
				continue;

			if (obj instanceof LineObject || obj instanceof StemseriesObject)
			{
				if (index < names.length)
					tmp.add(makeItemFromLine(obj, names[index++]));
				else
				{
					index++;
					tmp.add(makeItemFromLine(obj, "data"+index));
				}
			}
		}

		if (index < names.length)
			System.out.println("WARNING: ignoring extra legend entries");

		items = (LegendItem[])tmp.toArray(new LegendItem[tmp.size()]);
		doLayout();
		doLocate();
		
		String[] used_names = new String[index];
		System.arraycopy(names, 0, used_names, 0, index);
		String.reset(used_names);
	}

	public int size()
	{
		return (items != null ? items.length : 0);
	}

	private void doClear()
	{
		while (Children.size() > 0)
			Children.elementAt(0).delete();
	}

	private void doLayout()
	{
		FontMetrics fm = canvas.getFontMetrics(canvas.getFont());
		int lineWidth = 30, margin = 5;
		int maxWidth = 0, maxHeight = fm.getHeight()+margin;

		int totalWidth = 0, totalHeight = 0;

		if (Orientation.is("vertical"))
		{
			for (int i=0; i<items.length; i++)
			{
				Rectangle r = items[i].text.getExtent();
				maxWidth = Math.max(r.width, maxWidth);
				maxHeight = Math.max(r.height+margin, maxHeight);
			}

			totalWidth = (maxWidth+3*margin+lineWidth);
			totalHeight = items.length*maxHeight;

			double xt = 1-((double)(maxWidth+margin))/totalWidth;
			double x1 = ((double)margin)/totalWidth, x2 = ((double)(margin+lineWidth))/totalWidth;

			for (int i=0; i<items.length; i++)
			{
				double ypos = 1-(i+0.5)/items.length;
				if (items[i].patch != null)
				{
				}
				else
				{
					items[i].text.Position.reset(new double[] {xt, ypos, 0});
					items[i].line.XData.reset(new double[] {x1, x2});
					items[i].line.YData.reset(new double[] {ypos, ypos});
					items[i].marker.XData.reset(new double[] {(x1+x2)/2});
					items[i].marker.YData.reset(new double[] {ypos});
				}
			}
		}
		else
		{
			int[] w = new int[items.length];

			for (int i=0; i<items.length; i++)
			{
				Rectangle r = items[i].text.getExtent();
				w[i] = totalWidth;
				totalWidth += (r.width+lineWidth+3*margin);
				totalHeight = Math.max(r.height+margin, totalHeight);
			}

			double y = 0.5;
			double x1 = ((double)margin)/totalWidth, x2 = ((double)(margin+lineWidth))/totalWidth;
			double xt = ((double)(2*margin+lineWidth))/totalWidth;
			
			for (int i=0; i<items.length; i++)
			{
				double xpos = ((double)w[i])/totalWidth;
				if (items[i].patch != null)
				{
				}
				else
				{
					items[i].text.Position.reset(new double[] {xpos+xt, y, 0});
					items[i].line.XData.reset(new double[] {xpos+x1, xpos+x2});
					items[i].line.YData.reset(new double[] {y, y});
					items[i].marker.XData.reset(new double[] {xpos+(x1+x2)/2});
					items[i].marker.YData.reset(new double[] {y});
				}
			}
		}

		Position.reset(new double[] {0, 0, ((double)totalWidth)/canvas.getWidth(), ((double)totalHeight)/canvas.getHeight()});
		updateOuterPosition();
		size = new Dimension(totalWidth, totalHeight);
	}

	private void doLocate()
	{
		if (Location.is("none"))
			return;

		double[] aPos = getFigure().convertPosition(axes.Position.getArray(), axes.Units.getValue());
		double[] aOPos = getFigure().convertPosition(axes.OuterPosition.getArray(), axes.Units.getValue());
		double[] pos = getFigure().convertPosition(Position.getArray(), Units.getValue());
		boolean outerActive = axes.ActivePositionProperty.is("outerposition");
		int margin = 10;

		if (Location.is("NorthEast"))
		{
			pos[0] = aPos[0]+aPos[2]-margin-pos[2];
			pos[1] = aPos[1]+aPos[3]-margin-pos[3];
		}
		else if (Location.is("NorthWest"))
		{
			pos[0] = aPos[0]+margin;
			pos[1] = aPos[1]+aPos[3]-margin-pos[3];
		}
		else if (Location.is("North"))
		{
			pos[0] = aPos[0]+(aPos[2]-pos[2])/2;
			pos[1] = aPos[1]+aPos[3]-margin-pos[3];
		}
		else if (Location.is("NorthEastOutside"))
		{
			if (outerActive && (aPos[0]+aPos[2]+2*margin+pos[2]) > (aOPos[0]+aOPos[2]))
			{
				aPos[2] = aOPos[0]+aOPos[2]-2*margin-pos[2]-aPos[0];
			}
			pos[0] = aPos[0]+aPos[2]+margin;
			pos[1] = aPos[1]+aPos[3]-margin-pos[3];
		}

		Position.reset(getFigure().convertPosition(pos, "pixels", Units.getValue()));
		updateOuterPosition();
		axes.Position.reset(getFigure().convertPosition(aPos, "pixels", axes.Units.getValue()));
	}

	void updateActivePosition()
	{
		double[] pos = getFigure().convertPosition(Position.getArray(), Units.getValue());
		pos[2] = size.width;
		pos[3] = size.height;
		Position.reset(getFigure().convertPosition(pos, "pixels", Units.getValue()));
		doLocate();
		updateOuterPosition();
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == EdgeColor)
		{
			Object c = EdgeColor.get();
			XColor.set(c);
			YColor.set(c);
			ZColor.set(c);
		}
		else if (p == TextColor)
		{
			for (int i=0; i<items.length; i++)
				items[i].text.set("Color", TextColor.get());
		}
		else if (p == String)
		{
			String[] s = String.getArray();
			for (int i=0; i<items.length; i++)
				if (i < s.length)
					items[i].text.set("String", s[i]);
				else
					items[i].text.set("String", "");
			doLayout();
			doLocate();

			String[] used_names = new String[Math.min(s.length, items.length)];
			System.arraycopy(s, 0, used_names, 0, used_names.length);
			String.set(used_names);
		}
		else if (p == axes.Position || p == axes.OuterPosition)
			doLocate();
		else if (p == Location)
		{
			axes.updateActivePosition();
			doLocate();
		}
		else if (p == Orientation)
		{
			doLayout();
			doLocate();
		}
		else
			super.propertyChanged(p);
	}
}
