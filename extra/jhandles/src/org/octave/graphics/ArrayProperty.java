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

public class ArrayProperty extends Property
{
	public ArrayProperty(PropertySet parent, String name)
	{
		this(parent, name, new Matrix(new double[0], new int[] {0, 0}));
	}

	public ArrayProperty(PropertySet parent, String name, Matrix matrix)
	{
		super(parent, name);
		pvalue = matrix;
	}

	protected Object convertValue(Object array) throws PropertyException
	{
		if (array == null)
			return new Matrix(new double[0], new int[] {0, 0});

		if (array instanceof Matrix)
			return array;
		else
		{
			try
			{
				double[] v = (double[]) array;
				return new Matrix(v, new int[] {1, v.length});
			}
			catch (ClassCastException e)
			{
				throw new PropertyException("invalid property value - " + array.toString());
			}
		}
	}

	public Matrix getMatrix()
	{
		return (Matrix)pvalue;
	}

	public int getNDims()
	{
		return ((Matrix)pvalue).getNDims();
	}

	public int getDim(int index)
	{
		return ((Matrix)pvalue).getDim(index);
	}

	public String getClassName()
	{
		return ((Matrix)pvalue).getClassName();
	}

	public String toString()
	{
		return pvalue.toString();
	}
}
