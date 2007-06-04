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

import java.awt.Color;
import java.text.DecimalFormat;
import java.util.*;
import javax.media.opengl.*;

public class ColorProperty extends Property
{
	private Set valueSet;

	public ColorProperty(PropertySet parent, String name)
	{
		this(parent, name, Color.black);
	}

	public ColorProperty(PropertySet parent, String name, Color color)
	{
		this(parent, name, color, null, null);
	}

	public ColorProperty(PropertySet parent, String name, Color color, String[] values, String value)
	{
		super(parent, name);
		this.pvalue = (color != null ? (Object)color : (Object)value);
		if (values != null)
		{
			this.valueSet = Collections.synchronizedSet(new HashSet());
			for (int i=0; i<values.length; i++)
				this.valueSet.add(values[i]);
		}
		else
			this.valueSet = null;
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		Object c = null;

		if (value == null)
			c = null;
		else if (value instanceof Color)
			c = value;
		else if (value instanceof String)
		{
			c = decodeColor((String)value);
			if (c == null)
			{
				if (valueSet.contains((String)value))
					c = value;
				else
					throw new PropertyException("invalid color name - " + value.toString());
			}
		}
		else
		{
			try
			{
				double[] cv = (double[])value;
				if (cv.length == 3)
					c = new Color((float)cv[0], (float)cv[1], (float)cv[2]);
			}
			catch (ClassCastException e) { }
			if (c == null)
				throw new PropertyException("invalid color value - " + value.toString());
		}
		
		return c;
	}

	public Color getColor()
	{
		return (isSet() ? (Color)pvalue : null);
	}

	public boolean isSet()
	{
		return (pvalue instanceof Color);
	}

	public boolean is(String s)
	{
		return (!isSet() && pvalue != null && ((String)pvalue).equalsIgnoreCase(s));
	}

	public void setup(GL gl)
	{
		setup(gl, 1.0f);
	}

	public void setup(GL gl, float alpha)
	{
		if (isSet())
		{
			Color c = (Color)pvalue;
			gl.glColor4f(c.getRed()/255.0f, c.getGreen()/255.0f, c.getBlue()/255.0f, alpha);
		}
	}

	public double[] getArray()
	{
		if (isSet())
		{
			Color c = getColor();
			return new double[] {c.getRed()/255.0, c.getGreen()/255.0, c.getBlue()/255.0};
		}
		else
			return null;
	}

	private Color decodeColor(String name)
	{
		if (name.length() == 1)
			switch (name.charAt(0))
			{
			case 'r': return Color.red;
			case 'c': return Color.cyan;
			case 'y': return Color.yellow;
			case 'g': return Color.green;
			case 'm': return Color.magenta;
			case 'k': return Color.black;
			case 'b': return Color.blue;
			case 'w': return Color.white;
			}

		return null;
	}

	public String toString()
	{
		if (isSet())
		{
			DecimalFormat fmt = new DecimalFormat("0.0000 ");
			Color c = (Color)pvalue;
			return (
				"[ " +
				fmt.format(c.getRed()/255.0) +
				fmt.format(c.getGreen()/255.0) +
				fmt.format(c.getBlue()/255.0) +
				"]");
		}
		else if (pvalue != null)
			return pvalue.toString();
		else
			return "<not set>";
	}
}
