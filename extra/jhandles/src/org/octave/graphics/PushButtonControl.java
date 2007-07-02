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
import javax.swing.*;

public class PushButtonControl
	extends JButton
	implements UIControl, ActionListener
{
	UIControlObject uiObj;

	public PushButtonControl(UIControlObject obj)
	{
		super();
		addActionListener(this);
		uiObj = obj;
	}

	/* UIControl interface */

	public void update(int mode)
	{
	}
	
	public Component getComponent()
	{
		return this;
	}

	public void setString(String s)
	{
		setLabel(s);
	}

	public void setAlignment(int align)
	{
	}

	public void setTooltip(String s)
	{
		setToolTipText(s);
	}

	/* ActionListener interface */

	public void actionPerformed(ActionEvent event)
	{
		uiObj.controlActivated(new UIControlEvent(this));
	}
}
