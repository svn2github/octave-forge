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

public class CallbackProperty extends Property
{
	CallbackProperty(PropertySet parent, String name, String cmd)
	{
		super(parent, name);
		pvalue = cmd;
	}
	
	CallbackProperty(PropertySet parent, String name, OctaveReference ref)
	{
		super(parent, name);
		pvalue = ref;
	}

	protected Object convertValue(Object value) throws PropertyException
	{
		if (value instanceof String || value instanceof OctaveReference)
			return value;
		else
			throw new PropertyException("invalid property value - " + value.toString());
	}

	public void execute()
	{
		execute(new Object[0]);
	}

	public void execute(final Object[] args)
	{
		final RootObject root = RootObject.getInstance();

		if (pvalue == null)
			return;

		Octave.invokeLater(new Runnable() {
			public void run()
			{
				try
				{
					root.setCallbackMode(true);
					if (pvalue instanceof OctaveReference)
						Octave.doInvoke(((OctaveReference)pvalue).getID(), args);
					else if (pvalue instanceof String)
						Octave.doEvalString((String)pvalue);
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
			}
		});

		/*
		try
		{
			root.setCallbackMode(true);
			if (pvalue != null)
			{
				if (pvalue instanceof OctaveReference)
					Octave.invokeLater((OctaveReference)pvalue, args);
				else if (pvalue instanceof String)
					Octave.evalLater((String)pvalue);
			}
			root.setCallbackMode(false);
		}
		catch (Exception e)
		{
			root.setCallbackMode(false);
			System.err.println("Exception occured during callback execution: " + e.toString());
			e.printStackTrace();
		}
		*/
	}
}
