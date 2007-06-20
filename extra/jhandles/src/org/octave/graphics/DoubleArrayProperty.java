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
import org.octave.Matrix;

public class DoubleArrayProperty extends Property
{
	private int maxCount;

	public DoubleArrayProperty(PropertySet parent, String name)
	{
		this(parent, name, new double[0], -1);
	}

	public DoubleArrayProperty(PropertySet parent, String name, double[] value, int maxCount)
	{
		super(parent, name);
		this.pvalue = value;
		this.maxCount = maxCount;
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		if (value instanceof Number)
			return new double[] {((Number)value).doubleValue()};
		else if (value instanceof Matrix)
		{
			Matrix m = (Matrix)value;
			if (m.getClassName().equals("double"))
			{
				if (m.getNDims() == 1 ||
				    (m.getNDims() == 2 && (m.getDim(0) == 1 || m.getDim(1) == 1)))
					return m.toDouble();
				else
					throw new PropertyException("invalid array value - " + value.toString());
			}
			else
				throw new PropertyException("invalid array value - " + value.toString());
		}

		try
		{
			double[] v = (value == null ? new double[0] : (double[])value);
			if (maxCount != -1 && v.length != maxCount)
				throw new PropertyException("incorrect array length - " + value.toString());
			return v;
		}
		catch (ClassCastException e)
		{
			throw new PropertyException("invalid array value - " + value.toString());
		}
	}

	public double[] getArray()
	{
		return (double[])pvalue;
	}

	public void setArray(double[] a)
	{
		try { set(a); }
		catch (PropertyException e) { }
	}

	public double elementAt(int index)
	{
		return getArray()[index];
	}

	public String toString()
	{
		double[] array = getArray();

		if (array.length > 4)
			return ("[ 1 x " + array.length + " array ]");
		else
		{
			String s = "[ ";
			DecimalFormat fmt = new DecimalFormat("0.0000 ");
			for (int i=0; i<array.length; i++)
				s += fmt.format(array[i]);
			s += "]";
			return s;
		}
	}

	public boolean isEqual(Object value)
	{
		return java.util.Arrays.equals((double[])value, getArray());
	}
}
