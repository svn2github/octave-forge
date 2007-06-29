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

import org.octave.Matrix;
import java.awt.*;

public class UIControlObject extends HandleObject implements UIControlListener
{
	private UIControl ctrl;
	private String currentUnits;

	/* Properties */
	ColorProperty BackgroundColor;
	CallbackProperty Callback;
	RadioProperty Enable;
	VectorProperty Extent;
	ColorProperty ForegroundColor;
	RadioProperty HorizontalAlignment;
	DoubleProperty Min;
	DoubleProperty Max;
	VectorProperty Position;
	StringProperty UIString;
	RadioProperty Style;
	RadioProperty Units;
	VectorProperty Value;

	public UIControlObject(HandleObject parent)
	{
		super(parent, "uicontrol");

		BackgroundColor = new ColorProperty(this, "BackgroundColor", Color.lightGray);
		Callback = new CallbackProperty(this, "Callback", (String)null);
		Enable = new RadioProperty(this, "Enable", new String[] {"on", "inactive", "off"}, "on");
		Extent = new VectorProperty(this, "Extent", new double[] {0, 0, 0, 0}, 4);
		ForegroundColor = new ColorProperty(this, "ForegroundColor", Color.black);
		HorizontalAlignment = new RadioProperty(this, "HorizontalAlignment", new String[] {"left", "center", "right"}, "center");
		Min = new DoubleProperty(this, "Min", 0);
		Max = new DoubleProperty(this, "Max", 1);
		Position = new VectorProperty(this, "Position", new double[] {10, 10, 80, 25}, 4);
		UIString = new StringProperty(this, "String", "");
		Style = new RadioProperty(this, "Style", new String[] {
			  "pushbutton",
			  "togglebutton",
			  "radiobutton",
			  "checkbox",
			  "edit",
			  "text",
			  "slider",
			  "frame",
			  "listbox",
			  "popupmenu"}, "pushbutton");
		Units = new RadioProperty(this, "Units", new String[] {"pixels", "normalized"}, "pixels");
		Value = new VectorProperty(this, "Vector", new double[] {0}, -1);

		listen(BackgroundColor);
		listen(Enable);
		listen(ForegroundColor);
		listen(HorizontalAlignment);
		listen(Position);
		listen(UIString);
		listen(Style);
		listen(Units);
	}

	protected void deleteComponent()
	{
		if (ctrl != null)
		{
			ctrl.dispose();
			ctrl = null;
		}
	}

	public void delete()
	{
		super.delete();
		deleteComponent();
	}

	public void validate()
	{
		deleteComponent();
		currentUnits = Units.getValue();
		ctrl = makeControl(this);
		if (ctrl != null)
			ctrl.addControlListener(this);
		super.validate();
	}

	public UIControl makeControl(UIControlObject obj)
	{
		String style = obj.Style.toString();

		if (style.equalsIgnoreCase("pushbutton"))
			return new PushButtonControl(obj);
		else
		{
			System.out.println("Warning: UI style not supported yet: " + style);
			return null;
		}
	}

	public double[] convertPosition(double[] pos, String units, String toUnits)
	{
		if (ctrl != null)
		{
			Dimension sz = getComponent().getSize();
			double[] p;

			if (units.equalsIgnoreCase("pixels"))
				p = new double[] {pos[0], pos[1], pos[2], pos[3]};
			else if (units.equalsIgnoreCase("normalized"))
				p = new double[] {pos[0]*sz.width, pos[1]*sz.height, pos[2]*sz.width, pos[3]*sz.height};
			else
			{
				System.out.println("Warning: cannot convert from `" + units + "' units");
				p = (double[])pos.clone();
			}

			if (!toUnits.equalsIgnoreCase("pixels"))
			{
				if (toUnits.equalsIgnoreCase("normalized"))
				{
					p[0] /= sz.width;
					p[2] /= sz.width;
					p[1] /= sz.height;
					p[3] /= sz.height;
				}
			}

			return p;
		}
		else
			System.out.println("Warning: cannot convert position, no control associated with this object");

		return pos;
	}

	public double[] getPosition()
	{
		if (Parent.size() > 0)
			return Parent.elementAt(0).convertPosition(Position.getArray(), Units.getValue(), "pixels");
		else
		{
			System.out.println("Warning: cannot compute position of parentless controls");
			return new double[] {0, 0, 0, 0};
		}
	}

	public Component getComponent()
	{
		if (ctrl != null)
			return ctrl.getComponent();
		else
			return null;
	}

	public Component getParentComponent()
	{
		if (Parent.size() > 0)
		{
			HandleObject obj = Parent.elementAt(0);
			if (obj instanceof UIControlObject)
				return ((UIControlObject)obj).getComponent();
			else if (obj instanceof FigureObject)
				return ((FigureObject)obj).getComponent();
			else
				return null;
		}
		else
			return null;
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == Style)
		{
		}
		else if (ctrl != null)
		{
			if (p == Units)
			{
				double[] pos = Parent.elementAt(0).convertPosition(Position.getArray(), currentUnits, Units.getValue());
				Position.set(pos, true);
				currentUnits = Units.getValue();
			}
			else
				ctrl.update(this);
		}
	}

	/* UIControlListener interface */

	public void controlActivated(UIControlEvent event)
	{
		System.out.println("Control activated");
		Callback.execute();
	}
}
