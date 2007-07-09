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

import java.util.LinkedList;
import java.util.Iterator;
import org.octave.OctaveReference;

public abstract class Callback
{
	private LinkedList listenerList;

	public Callback()
	{
		listenerList = new LinkedList();
	}

	public void addCallbackListener(CallbackListener l)
	{
		synchronized(listenerList)
		{
			listenerList.add(l);
		}
	}

	public void removeCallbackListener(CallbackListener l)
	{
		synchronized(listenerList)
		{
			listenerList.remove(l);
		}
	}
	
	protected void fireCallbackExecuted()
	{
		synchronized(listenerList)
		{
			Iterator it = listenerList.iterator();
			while (it.hasNext())
				((CallbackListener)it.next()).callbackExecuted(this);
		}
	}

	public abstract void execute(HandleObject parent, Object[] args);

	public void execute(HandleObject parent)
	{
		execute(parent, new Object[0]);
	}

	public static Callback makeCallback(Object obj)
	{
		if (obj instanceof OctaveReference)
			return new OctaveCallback((OctaveReference)obj);
		else if (obj instanceof String)
			return new OctaveCallback((String)obj);
		return null;
	}

	public abstract Object get();
}
