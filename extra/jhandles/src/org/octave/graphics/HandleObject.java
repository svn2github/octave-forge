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
import java.lang.ref.WeakReference;

/**Base class for handle-based graphics*/
public class HandleObject extends PropertySet implements HandleNotifier.Sink
{
	private int handle;
	private Renderer.CachedData cachedData = null;
	private boolean valid = false;
	private List notifierList = new LinkedList();

	private static int handleSeed = -1;
	private static HashMap handleMap = new HashMap();

	/* Properties */
	StringProperty Type;
	StringProperty Tag;
	ObjectProperty UserData;
	HandleObjectListProperty Children;
	HandleObjectListProperty Parent;
	BooleanProperty Visible;

	private static int newHandle()
	{
		return handleSeed--;
	}

	public HandleObject(HandleObject parent, String type)
	{
		handle = newHandle();
		handleMap.put(new Integer(handle), new WeakReference(this));
		initProperties(parent, type);
	}

	public HandleObject(HandleObject parent, int handle, String type)
	{
		this.handle = handle;
		handleMap.put(new Integer(handle), new WeakReference(this));
		initProperties(parent, type);
	}

	protected void initProperties(HandleObject parent, String type)
	{
		Parent = new HandleObjectListProperty(this, "Parent", -1);
		Type = new StringProperty(this, "Type", type);
		Tag = new StringProperty(this, "Tag", "");
		UserData = new ObjectProperty(this, "UserData", null);
		Children = new HandleObjectListProperty(this, "Children", -1);
		Visible = new BooleanProperty(this, "Visible", true);

		if (parent != null)
		{
			Parent.addElement(parent);
			parent.addChild(this);
		}
	}

	protected void listen(Property p)
	{
		new HandleNotifier(p, this);
	}

	public int getHandle()
	{
		return handle;
	}

	public void deleteChildren()
	{
		synchronized (Children)
		{
			while (Children.size() > 0)
				Children.elementAt(0).delete();
		}
	}

	public boolean isLegendable()
	{
		return true;
	}

	public void delete()
	{
		super.delete();

		while (notifierList.size() > 0)
		{
			HandleNotifier n = (HandleNotifier)notifierList.remove(0);
			n.removeSink(this);
		}

		deleteChildren();
		if (cachedData != null)
			cachedData.dispose();
		Parent.elementAt(0).removeChild(this);

		//System.out.println("HandleObject::delete (" + getHandle() + ")");
		removeHandleObject(getHandle());
	}

	public void addChild(HandleObject child)
	{
		synchronized (Children)
		{
			Children.addElement(child);
		}
	}

	public void removeChild(HandleObject child)
	{
		synchronized (Children)
		{
			Children.removeElement(child);
		}
	}

	public void validate()
	{
		super.validate();
		valid = true;
		if (Parent.size() > 0)
		{
			HandleObject parent = Parent.elementAt(0);
			if (parent.Children.contains(this))
				parent.childValidated(this);
		}
	}

	protected void childValidated(HandleObject child)
	{
	}

	public boolean isValid()
	{
		return valid;
	}

	public static boolean isHandle(int handle)
	{
		WeakReference ref = (WeakReference)handleMap.get(new Integer(handle));
		if (ref != null && ref.get() != null)
			return true;
		return false;
	}

	public static HandleObject getHandleObject(int handle) throws Exception
	{
		WeakReference ref = (WeakReference)handleMap.get(new Integer(handle));
		if (ref != null && ref.get() != null)
		{
			return (HandleObject)ref.get();
		}
		if (handle == 0)
			return RootObject.getInstance();
		throw new Exception("invalid handle - " + handle);
	}

	public static void removeHandleObject(int handle)
	{
		handleMap.remove(new Integer(handle));
	}

	public static void listObjects()
	{
		Iterator it = handleMap.entrySet().iterator();
		while (it.hasNext())
		{
			Map.Entry entry = (Map.Entry)it.next();
			System.out.println(entry.getKey() + " = " + entry.getValue());
		}
	}

	public void setCachedData(Renderer.CachedData d)
	{
		cachedData = d;
	}

	public Renderer.CachedData getCachedData()
	{
		return cachedData;
	}

	/* HandleNotifier.Sink interface */

	public void addNotifier(HandleNotifier hn)
	{
		notifierList.add(hn);
	}

	public void removeNotifier(HandleNotifier hn)
	{
		notifierList.remove(hn);
	}

	public void propertyChanged(Property p) throws PropertyException {}
}
