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

public class NotImplProperty extends ObjectProperty
{
	public NotImplProperty(PropertySet parent, String name)
	{
		super(parent, name);
	}

	public NotImplProperty(PropertySet parent, String name, Object value)
	{
		super(parent, name, value);
	}

	public Object get()
	{
		System.out.println("WARNING: get: property `" + getName() + "' in object `" +
				((HandleObject)getParent()).Type.toString() + "'not implemented, returning dummy value");
		return super.get();
	}

	public void set(Object value) throws PropertyException
	{
		System.out.println("WARNING: set: property `" + getName() + "' in object `" + 
				((HandleObject)getParent()).Type.toString() + "'not implemented, setting value has no effect");
		super.set(value);
	}
}
