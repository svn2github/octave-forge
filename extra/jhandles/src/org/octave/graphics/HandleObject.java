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

import org.octave.Octave;
import java.util.*;
import java.lang.ref.WeakReference;

/**Base class for handle-based graphics*/
public class HandleObject extends PropertySet implements HandleNotifier.Sink
{
	private int handle;
	private Renderer.CachedData cachedData = null;
	private boolean valid = false;
	private List notifierList;
	private HandleEventSource eventSource;
	
	protected int autoMode = 0;
	protected PropertySet defaultSet = new PropertySet();

	private static int handleSeed = -1;
	private static HashMap handleMap = new HashMap();

	/* Properties */
	BooleanProperty BeingDeleted;
	CallbackProperty ButtonDownFcn;
	HandleObjectListProperty Children;
	BooleanProperty Clipping;
	CallbackProperty CreateFcn;
	CallbackProperty DeleteFcn;
	RadioProperty HandleVisibility;
	HandleObjectListProperty Parent;
	StringProperty Tag;
	StringProperty Type;
	ObjectProperty UserData;
	BooleanProperty Visible;

	protected static int newHandle()
	{
		return handleSeed--;
	}

	public HandleObject(HandleObject parent, String type)
	{
		this(parent, newHandle(), type);
	}

	public HandleObject(HandleObject parent, int handle, String type)
	{
		this.handle = handle;
		this.notifierList = new LinkedList();
		this.eventSource = new HandleEventSource(this, new String[] {"ObjectDeleted"});

		addHandleObject(getHandle(), this);
		initProperties(parent, type);
	}

	protected void initProperties(HandleObject parent, String type)
	{
		// These properties must be created first, in order to
		// get correct behavior when looking for default values
		// of properties
		Type = new StringProperty(this, "Type", type);
		Parent = new HandleObjectListProperty(this, "Parent", -1);
		if (parent != null)
			Parent.addElement(parent);

		// Create other properties
		BeingDeleted = new BooleanProperty(this, "BeingDeleted", false);
		ButtonDownFcn = new CallbackProperty(this, "ButtonDownFcn", (String)null);
		Children = new HandleObjectListProperty(this, "Children", -1);
		Clipping = new BooleanProperty(this, "Clipping", true);
		CreateFcn = new CallbackProperty(this, "CreateFcn", (String)null);
		DeleteFcn = new CallbackProperty(this, "DeleteFcn", (String)null);
		HandleVisibility = new RadioProperty(this, "HandleVisibility", new String[] {"on", "callback", "off"}, "on");
		Tag = new StringProperty(this, "Tag", "");
		UserData = new ObjectProperty(this, "UserData", null);
		Visible = new BooleanProperty(this, "Visible", true);

		// TODO: move this to validate() ??
		if (parent != null)
			parent.addChild(this);
	}

	protected void setHandle(int handle)
	{
		removeHandleObject(getHandle());
		this.handle = handle;
		addHandleObject(getHandle(), this);
	}

	protected void listen(Property p)
	{
		new HandleNotifier(p, this);
	}

	public int getHandle()
	{
		return handle;
	}

	public String getType()
	{
		return (Type != null ? Type.toString() : "");
	}

	public Property getDefaultProperty(String name)
	{
		Property p = defaultSet.getProperty(name);
		if (p != null)
			return p;
		else if (Parent.size() > 0)
			return Parent.elementAt(0).getDefaultProperty(name);
		else
			return Factory.getDefaultProperty(name);
	}

	public void deleteChildren()
	{
		synchronized (Children)
		{
			while (Children.size() > 0)
			{
				int len = Children.size();
				HandleObject obj = Children.elementAt(0);

				obj.delete();
				if (Children.size() == len)
				{
					System.out.println("ERROR: wrong parentship in graphic object of class `" + Type.toString() + "' with child of class `" + 
							obj.Type.toString() + "'");
					break;
				}
			}
		}
	}

	public boolean isLegendable()
	{
		return false;
	}

	public void delete()
	{
		BeingDeleted.reset("on");
		eventSource.fireEvent("ObjectDeleted");
		DeleteFcn.execute(new Object[] {
			new Double(getHandle()),
			null});
		removeHandleObject(getHandle());

		super.delete();

		while (notifierList.size() > 0)
		{
			HandleNotifier n = (HandleNotifier)notifierList.remove(0);
			n.removeSink(this);
		}
		eventSource.delete();

		deleteChildren();
		if (cachedData != null)
			cachedData.dispose();
		Parent.elementAt(0).removeChild(this);
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

		CreateFcn.execute(new Object[] {
			new Double(getHandle()),
			null});
	}

	protected void childValidated(HandleObject child)
	{
	}

	public void addProperty(Property p)
	{
		super.addProperty(p);
		if (isValid())
			p.unLock();
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

	public static void addHandleObject(int handle, HandleObject obj)
	{
		handleMap.put(new Integer(handle), new WeakReference(obj));
	}

	public static void shutdown()
	{
		LinkedList figList = new LinkedList();
		Iterator it = handleMap.values().iterator();

		while (it.hasNext())
		{
			WeakReference ref = (WeakReference)it.next();
			if (ref != null && ref.get() != null && ref.get() instanceof FigureObject)
				figList.add(ref.get());
		}

		it = figList.iterator();
		while (it.hasNext())
			((HandleObject)it.next()).delete();
	}

	public static void listObjects()
	{
		Iterator it = handleMap.entrySet().iterator();
		while (it.hasNext())
		{
			Map.Entry entry = (Map.Entry)it.next();
			HandleObject hObj = (HandleObject)((WeakReference)entry.getValue()).get();
			System.out.println(entry.getKey() + " = " + hObj.getClass());
		}
	}

	public void setCachedData(Renderer.CachedData d)
	{
		if (cachedData != null)
			cachedData.dispose();
		cachedData = d;
	}

	public Renderer.CachedData getCachedData()
	{
		return cachedData;
	}

	public java.awt.Component getComponent()
	{
		System.out.println("Warning: no component associated with " + getClass());
		return null;
	}

	protected void autoSet(Property p, Object value)
	{
		autoMode++;
		p.set(value, true);
		autoMode--;
	}

	protected boolean isAutoMode()
	{
		return (autoMode > 0);
	}

	public HandleObject getAncestor(String type)
	{
		HandleObject curr = this;

		while (true)
		{
			if (curr.Type.toString().equalsIgnoreCase(type))
				return curr;
			else if (curr.Parent.size() <= 0)
				return null;
			else
				curr = curr.Parent.elementAt(0);
		}
	}

	public Object get(String name) throws PropertyException
	{
		if (name.toLowerCase().startsWith("default"))
		{
			Property p = getDefaultProperty(name);
			if (p != null)
				return p.get();
			throw new PropertyException("invalid default property - " + name.toLowerCase());
		}
		else
			return super.get(name);
	}

	public void set(String name, Object value) throws PropertyException
	{
		if (name.toLowerCase().startsWith("default"))
		{
			Property p = getDefaultProperty(name);
			if (p != null)
			{
				Property new_p = p.cloneProperty();
				new_p.set(value);
				defaultSet.addProperty(new_p);
			}
			else
				throw new PropertyException("invalid default property - " + name.toLowerCase());
		}
		else
			super.set(name, value);
	}

	public void addHandleEventSink(String name, HandleEventSink sink)
	{
		eventSource.addHandleEventSink(name, sink);
	}

	public void removeHandleEventSink(HandleEventSink sink)
	{
		eventSource.removeHandleEventSink(sink);
	}

	public boolean hasHandleEvent(String name)
	{
		return eventSource.hasHandleEvent(name);
	}

	public void waitFor()
	{
		waitFor(null, null, false);
	}

	public void waitFor(String pname)
	{
		waitFor(pname, null, false);
	}

	public void waitFor(String pname, Object value)
	{
		waitFor(pname, value, true);
	}

	private void waitFor(String pname, final Object value, final boolean hasValue)
	{
		final Object waitObj = new Object();
		final Property p = (pname != null ? getProperty(pname) : null);

		if (pname != null && p == null)
			return;
		if (hasValue && p != null && p.isSameValue(value))
			return;

		HandleEventSink sink = new HandleEventSink() {
			private boolean execFlag = false;
			public void eventOccured(HandleEvent evt)
			{
				execFlag = false;
				if (evt.getName().equals("ObjectDeleted"))
					Octave.endWaitFor(waitObj);
				else if (evt.getName().equals("PropertyPostSet") && !hasValue)
					Octave.endWaitFor(waitObj);
				else if (p.isSameValue(value))
					Octave.endWaitFor(waitObj);
				else
					execFlag = true;
			}
			public void sourceDeleted(Object source) {}
			public boolean executeOnce() { return !execFlag; }
		};

		addHandleEventSink("ObjectDeleted", sink);
		if (p != null)
			p.addHandleEventSink("PropertyPostSet", sink);

		Octave.waitFor(waitObj);
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

	public void propertyChanged(Property p) throws PropertyException
	{
	}
}
