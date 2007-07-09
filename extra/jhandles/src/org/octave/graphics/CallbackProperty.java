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

public class CallbackProperty extends Property
{
	CallbackProperty(PropertySet parent, String name, Object cmd)
	{
		super(parent, name);
		pvalue = Callback.makeCallback(cmd);
	}
	
	protected Object convertValue(Object value) throws PropertyException
	{
		if (value == null)
			return value;
		
		Callback cb = Callback.makeCallback(value);

		if (cb != null)
			return cb;
		else
			throw new PropertyException("invalid property value - " + value.toString());
	}

	protected Object getInternal()
	{
		Callback cb = getCallback();
		if (cb != null)
			return cb.get();
		return null;
	}

	public Callback getCallback()
	{
		return (Callback)pvalue;
	}

	public void execute()
	{
		execute(new Object[0]);
	}

	public void execute(Object[] args)
	{
		Callback cb = getCallback();
		System.out.println("CallbackProperty.execute: " + cb);
		if (cb != null)
			cb.execute(args);
	}
}
