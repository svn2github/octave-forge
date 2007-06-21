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

public class VectorProperty extends Property
{
	int fixedSize;

	public VectorProperty(PropertySet parent, String name)
	{
		this(parent, name, new double[0], -1);
	}

	public VectorProperty(PropertySet parent, String name, double[] data, int size)
	{
		super(parent, name);
		pvalue = new Matrix(data, new int[] {1, data.length});
		fixedSize = size;
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		if (value instanceof Number)
			return new Matrix(new double[] {((Number)value).doubleValue()}, new int[] {1, 1});
		else if (value instanceof Matrix)
		{
			Matrix m = (Matrix)value;
			if (m.getClassName().equals("double"))
			{
				if (m.getNDims() == 1 ||
				    (m.getNDims() == 2 && (m.getDim(0) == 1 || m.getDim(1) == 1)))
				{
					if (fixedSize == -1 || fixedSize == m.toDouble().length)
						return m;
					else
						throw new PropertyException("invalid vector length - " + value.toString());
				}
				else
					throw new PropertyException("invalid vector value - " + value.toString());
			}
			else
				throw new PropertyException("invalid vector element type - " + value.toString());
		}

		try
		{
			double[] v = (value == null ?  new double[0] : (double[])value);
			if (fixedSize == -1 || fixedSize == v.length)
				return new Matrix(v, new int[] {1, v.length});
			else
				throw new PropertyException("invaild vector length - " + value.toString());
		}
		catch (ClassCastException e)
		{
			throw new PropertyException("invalid vector value - " + value.toString());
		}
	}

	public double[] getVector()
	{
		return ((Matrix)pvalue).toDouble();
	}

	public double[] getArray()
	{
		return getVector();
	}

	public double elementAt(int index)
	{
		return getVector()[index];
	}

	public String toString()
	{
		return pvalue.toString();
	}
}
