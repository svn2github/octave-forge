/* Copyright (C) 2007 Michael Goffioul
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
*/

package org.octave;

import java.nio.*;

public class Matrix
{
	private int[] dims;
	private Buffer data;

	public Matrix(double[] data, int[] dims)
	{
		this.dims = dims;
		this.data = DoubleBuffer.wrap(data);
	}

	public Matrix(byte[] data, int[] dims)
	{
		this.dims = dims;
		this.data = ByteBuffer.wrap(data);
	}

	public Matrix(int[] data, int[] dims)
	{
		this.dims = dims;
		this.data = IntBuffer.wrap(data);
	}

	public double[] toDouble()
	{
		if (data instanceof DoubleBuffer)
			return ((DoubleBuffer)data).array();
		else
			throw new ClassCastException("matrix is not of type `double'");
	}

	public byte[] toByte()
	{
		if (data instanceof ByteBuffer)
			return ((ByteBuffer)data).array();
		else
			throw new ClassCastException("matrix is not of type `byte'");
	}

	public int[] toInt()
	{
		if (data instanceof IntBuffer)
			return ((IntBuffer)data).array();
		else
			throw new ClassCastException("matrix is not of type `integer'");
	}

	public int getNDims()
	{
		return (dims == null ? 0 : dims.length);
	}

	public int getDim(int index)
	{
		return (dims == null || index < 0 || index >= dims.length ? -1 : dims[index]);
	}

	public int[] getDims()
	{
		return dims;
	}

	public String getClassName()
	{
		if (data instanceof DoubleBuffer)
			return "double";
		else if (data instanceof IntBuffer)
			return "integer";
		else if (data instanceof ByteBuffer)
			return "byte";
		else
			return "unknown";
	}

	public String toString()
	{
		if (dims == null || data == null)
			return "null";

		String s = "";

		for (int i=0; i<dims.length; i++)
			if (i == 0)
				s = Integer.toString(dims[i]);
			else
				s += (" by " + Integer.toString(dims[i]));
		s = ("(" + s + ") array of " + getClassName());

		return s;
	}

	public static Object ident(Object o)
	{
		System.out.println(o);
		return o;
	}
}
