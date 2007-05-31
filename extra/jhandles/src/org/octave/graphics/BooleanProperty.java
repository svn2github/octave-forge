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

public class BooleanProperty extends RadioProperty
{
	public BooleanProperty(PropertySet parent, String name, boolean value)
	{
		super(parent, name, new String[] {"on", "off"}, (value ? "on" : "off"));
	}

	public boolean getBoolean()
	{
		return getValue().equals("on");
	}

	public boolean isSet()
	{
		return getBoolean();
	}

	public void set(Object value) throws PropertyException
	{
		if (value instanceof Boolean)
			super.set(((Boolean)value).booleanValue() ? "on" : "off");
		else if (value instanceof Number)
			super.set(((Number)value).intValue() != 0 ? "on" : "off");
		else
			super.set(value);
	}
}
