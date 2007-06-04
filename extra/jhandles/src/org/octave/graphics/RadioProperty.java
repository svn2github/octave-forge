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

import java.util.*;

public class RadioProperty extends Property
{
	private class StringComparator implements Comparator
	{
		StringComparator()
		{
		}

		public int compare(Object o1, Object o2)
		{
			return ((String)o1).compareToIgnoreCase((String)o2);
		}
	}

	private Map valueSet;
	//private String value;

	public RadioProperty(PropertySet parent, String name)
	{
		this(parent, name, new String[0], "");
	}

	public RadioProperty(PropertySet parent, String name, String[] values, String defaultValue)
	{
		super(parent, name);
		valueSet = Collections.synchronizedMap(new TreeMap(new StringComparator()));
		for (int i=0; i<values.length; i++)
			valueSet.put(values[i], values[i]);
		if (valueSet.containsKey(defaultValue))
			pvalue = defaultValue;
		else
			pvalue = (values.length > 0 ? values[0] : "");
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		if (value instanceof String && valueSet.containsKey(value))
			return valueSet.get(value);
		else
			throw new PropertyException("invalid property value - " + value.toString());
	}

	public String getValue()
	{
		return (String)pvalue;
	}

	public boolean is(String val)
	{
		return getValue().equalsIgnoreCase(val);
	}

	public String toString()
	{
		return (String)pvalue;
	}
}

