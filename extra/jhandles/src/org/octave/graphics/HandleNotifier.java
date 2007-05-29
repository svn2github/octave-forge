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

public class HandleNotifier
{
	private List sources = new LinkedList();
	private List sinks = new LinkedList();

	public interface Source
	{
		public void addNotifier(HandleNotifier h);
		public void removeNotifier(HandleNotifier h);
	}

	public interface Sink
	{
		public void addNotifier(HandleNotifier h);
		public void removeNotifier(HandleNotifier h);
		public void propertyChanged(Property p) throws PropertyException;
	}

	public HandleNotifier(Source source, Sink sink)
	{
		sources.add(source);
		source.addNotifier(this);
		sinks.add(sink);
		sink.addNotifier(this);
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		Iterator it = sinks.iterator();
		while (it.hasNext())
			((Sink)it.next()).propertyChanged(p);
	}

	public void removeSource(Source source)
	{
		sources.remove(source);
		source.removeNotifier(this);
		checkForDelete();
	}

	public void removeSink(Sink sink)
	{
		sinks.remove(sink);
		sink.removeNotifier(this);
		checkForDelete();
	}

	private void checkForDelete()
	{
		if (sinks.size() == 0 || sources.size() == 0)
		{
			while (sources.size() > 0)
			{
				Source p = (Source)sources.remove(0);
				p.removeNotifier(this);
			}

			while (sinks.size() > 0)
			{
				Sink l = (Sink)sinks.remove(0);
				l.removeNotifier(this);
			}
		}
	}
}
