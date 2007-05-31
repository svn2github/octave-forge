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

public class StringArrayProperty extends Property
{
	public StringArrayProperty(PropertySet parent, String name, String[] value)
	{
		super(parent, name);
		pvalue = value;
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		if (value instanceof String)
			return ((String)value).split("|");
		else
		{
			try
			{
				String[] v = (value == null ? new String[0] : (String[])value);
				return v;
			}
			catch (ClassCastException e)
			{
				throw new PropertyException("invalid character array value - " + value.toString());
			}
		}
	}

	public String[] getArray()
	{
		return (String[])pvalue;
	}

	public String toString()
	{
		String[] array = getArray();
		String buf = "[ ";
		for (int i=0; i<array.length; i++)
		{
			buf += (array[i] + " ");
			if (buf.length() > 64)
				return ("[ 1 x " + array.length + " character array ]");
		}
		buf += "]";
		return buf;
	}
}
