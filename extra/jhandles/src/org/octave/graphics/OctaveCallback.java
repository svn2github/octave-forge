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

import org.octave.OctaveReference;
import org.octave.Octave;

public class OctaveCallback extends Callback
{
	OctaveReference ref;
	String cmd;

	public OctaveCallback(OctaveReference ref)
	{
		this.ref = ref;
		this.cmd = null;
	}

	public OctaveCallback(String cmd)
	{
		this.ref = null;
		this.cmd = cmd;
	}

	public void execute(HandleObject parent, Object[] args)
	{
		if (ref == null && (cmd == null || cmd.length() == 0))
		{
			fireCallbackExecuted();
			return;
		}

		final RootObject root = RootObject.getInstance();
		final Object[] theArgs = args;
		final HandleObject theParent = parent;

		Octave.invokeLater(new Runnable() {
			public void run()
			{
				try
				{
					root.setCallbackMode(true, theParent);
					if (ref != null)
						Octave.doInvoke(ref.getID(), theArgs);
					else if (cmd != null && cmd.length() > 0)
						Octave.doEvalString(cmd);
				}
				catch (Exception e)
				{
					System.err.println("Exception occured during callback execution: " + e.toString());
					e.printStackTrace();
				}
				finally
				{
					root.setCallbackMode(false);
				}
				fireCallbackExecuted();
			}
		});
	}

	public Object get()
	{
		if (ref != null)
			return ref;
		else
			return cmd;
	}

	public String toString()
	{
		if (ref != null)
			return ref.toString();
		else
			return cmd;
	}
}
