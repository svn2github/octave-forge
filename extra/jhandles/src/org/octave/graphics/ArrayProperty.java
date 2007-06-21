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
	String[] allowedTypes;
	int allowedDims;

	public ArrayProperty(PropertySet parent, String name)
	{
		this(parent, name, new Matrix(new double[0], new int[] {0, 0}));
	}

	public ArrayProperty(PropertySet parent, String name, Matrix matrix)
	{
		this(parent, name, matrix, null, -1);
	}

	public ArrayProperty(PropertySet parent, String name, Matrix matrix, String[] types, int dims)
	{
		super(parent, name);
		pvalue = (matrix != null ? matrix : new Matrix(new double[0], new int[] {0, 0}));
		allowedTypes = types;
		allowedDims = dims;
	}

	protected Object convertValue(Object array) throws PropertyException
	{
		if (array == null)
			return new Matrix(new double[0], new int[] {0, 0});

		if (array instanceof Matrix)
		{
			Matrix m = (Matrix)array;
			if (allowedTypes != null)
			{
				boolean found = false;
				String clsName = m.getClassName();
				for (int i=0; i<allowedTypes.length; i++)
					if (allowedTypes[i].equals(clsName))
					{
						found = true;
						break;
					}
				if (!found)
					throw new PropertyException("invalid matrix class - " + clsName);
			}
			if (allowedDims != -1)
			{
				if (m.getNDims() != allowedDims)
					throw new PropertyException("invalid matrix number of dimensions - " + m.getNDims());
			}
			return array;
		}
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

	protected void setInternal(Object value) throws PropertyException
	{
		super.setInternal(value);
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

	public double[] asDoubleVector()
	{
		return getMatrix().asDoubleVector();
	}

	public double[][] asDoubleMatrix()
	{
		return getMatrix().asDoubleMatrix();
	}

	public double[][][] asDoubleMatrix3()
	{
		return getMatrix().asDoubleMatrix3();
	}
}
