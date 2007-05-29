/*
 * oplot-gl 
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

public class HandleObjectListProperty extends Property
{
	int maxCount;

	public HandleObjectListProperty(PropertySet parent, String name, int maxCount)
	{
		super(parent, name);
		this.maxCount = maxCount;
		this.pvalue = new Vector();
	}

	protected Object getInternal()
	{
		return getHandleArray();
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		Class cls = value.getClass();
		Vector v = new Vector();

		if (value instanceof Number)
		{
			int h = ((Number)value).intValue();
			try
			{
				v.add(HandleObject.getHandleObject(h));
			}
			catch (Exception e)
			{
				throw new PropertyException("invalid handle value - " + h);
			}
		}
		else if (cls.isArray() && cls.getComponentType().equals(Double.TYPE))
		{
			double[] hv = (double[])value;
			try
			{
				for (int i=0; i<hv.length; i++)
					v.add(HandleObject.getHandleObject((int)hv[i]));
			}
			catch (Exception e)
			{
				throw new PropertyException("invalid handle value");
			}
		}
		else
			throw new PropertyException("invalid property value - " + value);

		return v;
	}

	public double[] getHandleArray()
	{
		double[] hList = new double[((Vector)pvalue).size()];
		Iterator it = ((Vector)pvalue).iterator();
		int index = 0;

		while (it.hasNext())
		{
			HandleObject hObj = (HandleObject)it.next();
			hList[index++] = hObj.getHandle();
		}
		return hList;
	}

	public void addElement(HandleObject obj)
	{
		Vector objectList = (Vector)pvalue;
		if (maxCount <= 0 || objectList.size() < maxCount)
			objectList.add(obj);
		else
			objectList.set(maxCount-1, obj);
	}

	public void removeElement(HandleObject obj)
	{
		Vector objectList = (Vector)pvalue;
		objectList.remove(obj);
	}

	public HandleObject elementAt(int index)
	{
		Vector objectList = (Vector)pvalue;
		return (HandleObject)objectList.elementAt(index);
	}

	public int size()
	{
		Vector objectList = (Vector)pvalue;
		return objectList.size();
	}

	public Iterator iterator()
	{
		Vector objectList = (Vector)pvalue;
		return objectList.iterator();
	}

	public boolean contains(HandleObject obj)
	{
		Vector objectList = (Vector)pvalue;
		return objectList.contains(obj);
	}

	public void removeAllElements()
	{
		Vector objectList = (Vector)pvalue;
		objectList.removeAllElements();
	}

	public String toString()
	{
		Vector objectList = (Vector)pvalue;
		String buf = "[ ";
		Iterator it = objectList.iterator();

		while (it.hasNext())
		{
			HandleObject hObj = (HandleObject)it.next();
			buf += (hObj.getHandle() + " ");
			if (buf.length() > 64)
				return ("[ 1 x " + objectList.size() + " handle array ]");
		}
		buf += "]";

		return buf;
	}
}
