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

public class HandleEventSource
{
	private Object source;
	protected Map eventMap;

	public HandleEventSource(Object source, String[] events)
	{
		this.source = source;
		this.eventMap = Collections.synchronizedMap(new HashMap());

		for (int i=0; i<events.length; i++)
			eventMap.put(events[i], null);
	}

	public boolean hasHandleEvent(String name)
	{
		return eventMap.containsKey(name);
	}

	public void fireEvent(String name)
	{
		if (eventMap.containsKey(name))
		{
			LinkedList l = (LinkedList)eventMap.get(name);
			if (l != null)
				synchronized (l)
				{
					HandleEvent evt = new HandleEvent(source, name);
					Iterator it = l.iterator();
					while (it.hasNext())
						((HandleEventSink)it.next()).eventOccured(evt);
				}
		}
		else
			System.out.println("ERROR: unknown event `" + name + "' for objects of type " + source.getClass());
	}

	public void addHandleEventSink(String name, HandleEventSink sink)
	{
		if (eventMap.containsKey(name))
		{
			List l = (List)eventMap.get(sink);
			if (l == null)
				eventMap.put(name, (l = new LinkedList()));
			l.add(sink);
		}
		else
			System.out.println("ERROR: unknown event `" + name + "' for objects of type " + source.getClass());
	}

	public void removeHandleEventSink(HandleEventSink sink)
	{
		Iterator it = eventMap.values().iterator();
		while (it.hasNext())
		{
			List l = (List)it.next();
			if (l != null)
				while (l.remove(sink));
		}
	}

	public void delete()
	{
		Iterator it = eventMap.values().iterator();
		while (it.hasNext())
		{
			List l = (List)it.next();
			if (l != null)
			{
				Iterator lit = l.iterator();
				while (lit.hasNext())
					((HandleEventSink)lit.next()).sourceDeleted(source);
			}
		}
	}
}
