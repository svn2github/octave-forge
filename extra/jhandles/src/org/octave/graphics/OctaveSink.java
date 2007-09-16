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

import org.octave.*;

public class OctaveSink implements HandleEventSink
{
	private OctaveReference ref;

	public OctaveSink(OctaveReference ref, Property p)
	{
		this.ref = ref;
		p.addHandleEventSink("PropertyChanged", this);
	}

	public OctaveSink(OctaveReference ref, HandleObject h, String[] pnames)
	{
		this.ref = ref;

		for (int i=0; i<pnames.length; i++)
		{
			Property p = h.getProperty(pnames[i]);
			if (p != null)
				p.addHandleEventSink("PropertyChanged", this);
			else if (h.hasHandleEvent(pnames[i]))
				h.addHandleEventSink(pnames[i], this);
			else
				System.out.println("WARNING: `" + pnames[i] + "' is not a valid property name of " + h.Type.toString());
		}
	}

	/* HandleEventSink interface */

	public void eventOccured(HandleEvent evt)
	{
		HandleObject h = evt.getHandleObject();
		if (h != null)
			ref.invokeAndWait(new Object[] {new Double(h.getHandle()), null});
		else
			ref.invokeAndWait(new Object[] {null, evt});
	}

	public void sourceDeleted(Object src) {}

	public boolean executeOnce()
	{
		return false;
	}
}
