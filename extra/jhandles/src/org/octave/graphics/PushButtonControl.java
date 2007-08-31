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
	implements UIControl, ActionListener, HandleNotifier.Sink
{
	UIControlObject uiObj;
	HandleNotifier uiNotifier;

	public PushButtonControl(UIControlObject obj)
	{
		super();
		setMargin(new Insets(2, 2, 2, 2));
		addActionListener(this);
		uiObj = obj;

		setText(obj.UIString.toString());

		uiNotifier = new HandleNotifier();
		uiNotifier.addSink(this);
		uiNotifier.addSource(obj.UIString);
	}

	/* UIControl interface */

	public void update()
	{
	}
	
	public JComponent getComponent()
	{
		return this;
	}

	public void dispose()
	{
		uiNotifier.removeSink(this);
	}

	/* ActionListener interface */

	public void actionPerformed(ActionEvent event)
	{
		uiObj.controlActivated(new UIControlEvent(this));
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
