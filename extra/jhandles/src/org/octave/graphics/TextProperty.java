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

public class TextProperty extends Property
{
	public TextProperty(PropertySet parent, String name, TextObject obj)
	{
		super(parent, name);
		pvalue = obj;
	}

	public Object getInternal()
	{
		return new Double(((TextObject)pvalue).getHandle());
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		if (value instanceof String)
			return value;
		else if (value instanceof Double)
		{
			int h = ((Double)value).intValue();
			if (HandleObject.isHandle(h))
			{
				try
				{
					HandleObject obj = HandleObject.getHandleObject(h);
					if (obj instanceof TextObject)
						return obj;
					else
						throw new PropertyException("invalid text object - " + obj.toString());
				}
				catch (Exception e)
				{
					if (e instanceof PropertyException)
						throw (PropertyException)e;
					else
						throw new PropertyException("unexpected error - " + e.toString());
				}
			}
			else
				throw new PropertyException("invalid handle - " + value.toString());
		}
		else
			throw new PropertyException("invalid property value - " + value.toString());
	}

	public void setInternal(Object value) throws PropertyException
	{
		if (value instanceof String)
			((TextObject)pvalue).set("String", value);
		else if (value instanceof TextObject)
			pvalue = value;
	}

	public TextObject getText()
	{
		return (TextObject)pvalue;
	}

	public String toString()
	{
		return ("[ " + getText().getHandle() + " ]");
		//return txtObject.TextString.toString();
	}

	public boolean isEmpty()
	{
		return (getText().TextString.toString() == "");
	}

	protected boolean isEqual(Object value)
	{
		if (value instanceof String)
			return ((TextObject)pvalue).TextString.isEqual(value);
		else
			return (pvalue == value);
	}
}
