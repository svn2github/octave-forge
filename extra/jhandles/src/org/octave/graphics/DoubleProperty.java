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

import java.text.DecimalFormat;

public class DoubleProperty extends Property
{
	public DoubleProperty(PropertySet parent, String name)
	{
		this(parent, name, 0);
	}

	public DoubleProperty(PropertySet parent, String name, double value)
	{
		super(parent, name);
		pvalue = new Double(value);
	}

	protected Object convertValue(Object val) throws PropertyException
	{
		if (val instanceof Number)
			if (val instanceof Double)
				return val;
			else
				return new Double(((Number)val).doubleValue());
		else
			throw new PropertyException("invalid property value - " + val.toString());
	}

	public double doubleValue()
	{
		return ((Double)pvalue).doubleValue();
	}

	public float floatValue()
	{
		return ((Double)pvalue).floatValue();
	}

	public int intValue()
	{
		return (int)Math.round(((Double)pvalue).doubleValue());
	}

	public String toString()
	{
		DecimalFormat fmt = new DecimalFormat("0.0000");
		return fmt.format(doubleValue());
	}
}
