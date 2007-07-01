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

public class Edit2Control extends TextArea implements UIControl, KeyListener, HandleNotifier.Sink
{
	UIControlObject uiObj;
	HandleNotifier n;

	public Edit2Control(UIControlObject obj)
	{
		super();
		addKeyListener(this);
		uiObj = obj;

		Container parent = (Container)obj.getParentComponent();
		double[] pos = uiObj.getPosition();

		setText(uiObj.UIString.toString());
		setBackground(uiObj.BackgroundColor.getColor());
		setForeground(uiObj.ForegroundColor.getColor());
		pos[1] = (uiObj.getParentComponent().getHeight()-pos[1]-pos[3]);
		setBounds((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);

		n = new HandleNotifier();
		n.addSink(this);
		n.addSource(uiObj.UIString);

		parent.add(this, 0);
		parent.validate();
	}

	/* UIControl interface */

	public void update(int mode)
	{
		if ((mode & UPDATE_OBJECT) != 0)
		{
			uiObj.UIString.reset(getText());
		}
	}

	public Component getComponent()
	{
		return this;
	}

	public void dispose()
	{
		getParent().remove(this);
		n.removeSink(this);
	}

	/* KeyListener interface */

	public void keyPressed(KeyEvent event)
	{
	}
	
	public void keyReleased(KeyEvent event)
	{
	}
	
	public void keyTyped(KeyEvent event)
	{
	}

	/* HandleNotifier.Sink interface */

	public void addNotifier(HandleNotifier n) {}

	public void removeNotifier(HandleNotifier n) {}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == uiObj.UIString)
			setText(uiObj.UIString.toString());
	}
}
