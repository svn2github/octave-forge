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

public class OctaveSink implements HandleNotifier.Sink
{
	private OctaveReference ref;

	public OctaveSink(OctaveReference ref, Property p)
	{
		this.ref = ref;
		new HandleNotifier(p, this);
	}

	public void addNotifier(HandleNotifier h)
	{
	}

	public void removeNotifier(HandleNotifier h)
	{
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		//System.out.println("OctaveSink executing: thread ID = " + Thread.currentThread().getId());
		ref.invokeAndWait(new Object[] {p});
	}
}
