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

public class DoubleMatrixProperty extends Property
{
	private class MatrixData
	{
		Object matrix;
		int nDims;

		MatrixData(Object matrix, int nDims)
		{
			this.matrix = matrix;
			this.nDims = nDims;
		}
	}

	public DoubleMatrixProperty(PropertySet parent, String name)
	{
		this(parent, name, new double[0]);
	}

	public DoubleMatrixProperty(PropertySet parent, String name, Object value)
	{
		super(parent, name);
		try
		{
			pvalue = convertValue(value);
		}
		catch (PropertyException e) {}
	}

	public Object getInternal()
	{
		return ((MatrixData)pvalue).matrix;
	}

	protected Object convertValue(Object array) throws PropertyException
	{
		if (array == null)
			return new MatrixData(null, 0);

		Class cls = array.getClass();
		int n = 0;

		while (true)
		{
			if (cls.isArray())
			{
				n++;
				cls = cls.getComponentType();
			}
			else if (cls.equals(Double.class) && n == 0)
			{
				n++;
				array = new double[] {((Double)array).doubleValue()};
				break;
			}
			else if (cls.equals(Double.TYPE))
				break;
			else
				throw new PropertyException("invalid property value - not a double matrix - " + array);
		}
		if (n == 0)
			throw new PropertyException("invalid property value - not a double matrix - " + array);

		return new MatrixData(array, n);
	}

	public int getNDims()
	{
		return ((MatrixData)pvalue).nDims;
	}

	public int getDim(int index)
	{
		MatrixData data = (MatrixData)pvalue;

		if (index < 0 || index >= data.nDims)
			return -1;

		Object obj = data.matrix;
		for (int k=0; k<index; k++)
			obj = java.lang.reflect.Array.get(obj, 0);
		return java.lang.reflect.Array.getLength(obj);
	}

	public Object getObject()
	{
		return ((MatrixData)pvalue).matrix;
	}

	public double[] getVector()
	{
		MatrixData m = (MatrixData)pvalue;
		return (m.nDims == 1 ? (double[])getObject() : null);
	}

	public double[][] getMatrix()
	{
		MatrixData m = (MatrixData)pvalue;
		switch (m.nDims)
		{
		case 1:
			return new double[][] { getVector() };
		case 2:
			return (double[][])getObject();
		default:
			return null;
		}
	}

	public double[][][] getMatrix3()
	{
		MatrixData m = (MatrixData)pvalue;
		if (m.nDims < 3)
			return new double[][][] { getMatrix() };
		else if (m.nDims == 3)
			return (double[][][])getObject();
		else
			return null;
	}
}
