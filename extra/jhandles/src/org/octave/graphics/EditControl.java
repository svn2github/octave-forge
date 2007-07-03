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
import javax.swing.*;

public class EditControl
	extends JTextField
	implements UIControl, ActionListener, HandleNotifier.Sink
{
	UIControlObject uiObj;
	HandleNotifier uiNotifier;

	public EditControl(UIControlObject obj)
	{
		super();
		addActionListener(this);
		uiObj = obj;

		setAlignment();
		setText(obj.UIString.toString());

		uiNotifier = new HandleNotifier();
		uiNotifier.addSink(this);
		uiNotifier.addSource(obj.UIString);
		uiNotifier.addSource(obj.HorizontalAlignment);
	}

	public void setAlignment()
	{
		setHorizontalAlignment(
			uiObj.HorizontalAlignment.is("center") ? JTextField.CENTER :
			uiObj.HorizontalAlignment.is("left") ? JTextField.LEFT :
			uiObj.HorizontalAlignment.is("right") ? JTextField.RIGHT :
			JTextField.LEFT);
	}

	/* UIControl interface */

	public void update()
	{
		uiObj.UIString.reset(getText());
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
		else if (p == uiObj.HorizontalAlignment)
			setAlignment();
	}
}
