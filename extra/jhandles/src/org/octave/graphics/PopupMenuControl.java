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

public class PopupMenuControl
	extends JComboBox
	implements UIControl, ActionListener, HandleNotifier.Sink
{
	UIControlObject uiObj;
	HandleNotifier uiNotifier;

	public PopupMenuControl(UIControlObject obj)
	{
		super();
		addActionListener(this);
		uiObj = obj;

		updateItems();
		updateValue();

		uiNotifier = new HandleNotifier();
		uiNotifier.addSink(this);
		uiNotifier.addSource(obj.UIString);
		uiNotifier.addSource(obj.Value);
	}

	private void updateItems()
	{
		String[] items = uiObj.UIString.toString().split("\\|");
		removeAllItems();
		for (int i=0; i<items.length; i++)
			addItem(items[i]);
	}

	private void updateValue()
	{
		if (uiObj.Value.getArray().length > 0)
		{
			int index = (int)uiObj.Value.getArray()[0];
			if (index > 0 && index <= getItemCount())
				setSelectedIndex(index-1);
		}
	}

	/* UIControl interface */

	public void update()
	{
		uiObj.Value.reset(new double[] {getSelectedIndex()+1});
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
			updateItems();
		else if (p == uiObj.Value)
			updateValue();
	}
}
