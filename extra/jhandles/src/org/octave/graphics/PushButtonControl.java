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

import java.awt.*;
import java.awt.event.*;
import org.octave.Matrix;

public class PushButtonControl extends Button implements UIControl, ActionListener
{
	private java.util.List listenerList = new java.util.LinkedList();

	public PushButtonControl(UIControlObject obj)
	{
		super();
		addActionListener(this);

		Container parent = (Container)obj.getParentComponent();

		update(obj);
		parent.add(this, 0);
		parent.validate();
	}

	protected void fireControlEvent()
	{
		UIControlEvent event = new UIControlEvent(this);
		java.util.Iterator it = listenerList.iterator();

		while (it.hasNext())
		{
			UIControlListener l = (UIControlListener)it.next();
			l.controlActivated(event);
		}
	}

	/* UIControl interface */

	public void update(UIControlObject obj)
	{
		setLabel(obj.UIString.toString());
		setBackground(obj.BackgroundColor.getColor());
		setForeground(obj.ForegroundColor.getColor());

		double[] pos = obj.getPosition();
		pos[1] = (obj.getParentComponent().getHeight()-pos[1]-pos[3]);
		setBounds((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
	}

	public Component getComponent()
	{
		return this;
	}

	public void addControlListener(UIControlListener l)
	{
		listenerList.add(l);
	}

	public void dispose()
	{
		getParent().remove(this);
	}

	/* ActionListener interface */

	public void actionPerformed(ActionEvent event)
	{
		fireControlEvent();
	}
}
