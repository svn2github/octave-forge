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

import java.awt.Color;
import java.util.LinkedList;
import java.util.Iterator;

/**Abstract root class for any kind of property*/
public abstract class Property implements HandleNotifier.Source
{
	private String name;
	private LinkedList notifierList = new LinkedList();
	private boolean lockNotify = true;
	private boolean readOnly = false;
	private boolean visible = true;
	private PropertySet parent;
	protected Object pvalue;

	private boolean setFlag = false;

	protected Property(PropertySet parent, String name)
	{
		this.name = name;
		this.parent = parent;
		parent.addProperty(this);
	}

	public PropertySet getParent()
	{
		return parent;
	}

	public String getName()
	{
		return name;
	}

	public boolean isReadOnly()
	{
		return readOnly;
	}

	public void setReadOnly(boolean flag)
	{
		readOnly = flag;
	}

	public boolean isVisible()
	{
		return visible;
	}

	public void setVisible(boolean flag)
	{
		visible = flag;
	}

	protected Object getInternal()
	{
		return pvalue;
	}

	protected void setInternal(Object value) throws PropertyException
	{
		pvalue = value;
	}

	public Object get()
	{
		/* TODO: needed?
		if (!lockNotify)
		{
			Iterator it = listenerList.iterator();
			while (it.hasNext())
				((PropertyListener)it.next()).propertyGetting(this);
		}
		*/
		return getInternal();
	}

	public void set(Object value) throws PropertyException
	{
		if (readOnly)
			throw new PropertyException("read-only property - " + getName());

		value = convertValue(value);
		if (isEqual(value))
		{
			//System.out.println(getName() + ": identical value, not setting - " + value.toString());
			return;
		}

		if (setFlag)
		{
			System.out.println("WARNING: " + getName() + ".set: recursive behavior detected, not setting");
			return;
		}

		setFlag = true;
		try
		{
			/* TODO: needed?
			if (!lockNotify)
			{
				Iterator it = listenerList.iterator();
				while (it.hasNext())
					((PropertyListener)it.next()).propertySetting(this, value);
			}
			*/
			setInternal(value);
			if (!lockNotify)
			{
				Iterator it = notifierList.iterator();
				while (it.hasNext())
					((HandleNotifier)it.next()).propertyChanged(this);
			}
			setFlag = false;
		}
		catch (Exception e)
		{
			setFlag = false;
			if (e instanceof PropertyException)
				throw (PropertyException)e;
			else
				throw new PropertyException(e);
		}
	}

	/* TODO: remove me
	void update(Object value)
	{
		boolean oldLockNotify = lockNotify;

		lockNotify = true;
		try { set(value); }
		catch (PropertyException e) { }
		lockNotify = oldLockNotify;
	}

	public void safeSet(Object value)
	{
		try { set(value); }
		catch (PropertyException e) {}
	}

	public void setNoNotify(Object value) throws PropertyException
	{
		boolean oldLockNotify = lockNotify;
		lockNotify = false;
		set(value);
		lockNotify = oldLockNotify;
	}
	*/

	public void reset(Object value)
	{
		boolean oldLockNotify = lockNotify;

		lockNotify = true;
		try { set(value); }
		catch (PropertyException e) { }
		lockNotify = oldLockNotify;
	}

	public void set(Object value, boolean warn_on_exception)
	{
		try { set(value); }
		catch (PropertyException e)
		{
			if (warn_on_exception)
				System.out.println("WARNING: " + getName() + ".set: exception occured");
		}
	}

	public void lock()
	{
		lockNotify = true;
	}

	public void unLock()
	{
		lockNotify = false;
	}

	protected boolean isEqual(Object value)
	{
		/*Object v = getInternal();*/
		Object v = pvalue;
		return (value == null ? v == null : value.equals(v));
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		return value;
	}

	public void delete()
	{
		while (notifierList.size() > 0)
		{
			HandleNotifier n = (HandleNotifier)notifierList.remove(0);
			n.removeSource(this);
		}
	}

	public void addNotifier(HandleNotifier n)
	{
		notifierList.add(n);
	}

	public void removeNotifier(HandleNotifier n)
	{
		notifierList.remove(n);
	}
}
