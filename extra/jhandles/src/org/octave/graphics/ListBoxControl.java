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
import javax.swing.event.*;

public class ListBoxControl
	extends JScrollPane
	implements UIControl, ListSelectionListener, HandleNotifier.Sink
{
	UIControlObject uiObj;
	HandleNotifier uiNotifier;
	JList list;

	public ListBoxControl(UIControlObject obj)
	{
		super();
		uiObj = obj;

		list = new JList();
		list.getSelectionModel().addListSelectionListener(this);
		getViewport().setView(list);

		updateItems();
		updateSelectionMode();
		updateColors();
		updateTop();
		updateValue();

		uiNotifier = new HandleNotifier();
		uiNotifier.addSink(this);
		uiNotifier.addSource(obj.UIString);
		uiNotifier.addSource(obj.Value);
		uiNotifier.addSource(obj.Min);
		uiNotifier.addSource(obj.Max);
		uiNotifier.addSource(obj.BackgroundColor);
		uiNotifier.addSource(obj.ForegroundColor);
		uiNotifier.addSource(obj.ListboxTop);
	}

	private void updateItems()
	{
		String[] items = uiObj.UIString.toString().split("\\|");
		list.setListData(items);
	}

	private void updateValue()
	{
		if (uiObj.Value.getArray().length > 0)
		{
			double[] val = uiObj.Value.getArray();
			int[] sel = new int[val.length];

			for (int i=0; i<val.length; i++)
				sel[i] = (int)val[i]-1;
			list.setSelectedIndices(sel);
		}
		else
			list.clearSelection();
	}

	private void updateSelectionMode()
	{
		if ((uiObj.Max.doubleValue() - uiObj.Min.doubleValue()) <= 1)
			list.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		else
			list.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
	}

	private void updateColors()
	{
		setBackground(uiObj.BackgroundColor.getColor());
		setForeground(uiObj.ForegroundColor.getColor());
		list.setBackground(uiObj.BackgroundColor.getColor());
		list.setForeground(uiObj.ForegroundColor.getColor());
	}

	private void updateTop()
	{
		list.ensureIndexIsVisible(uiObj.ListboxTop.intValue()-1);
		/*
		Point pt = list.indexToLocation(uiObj.ListboxTop.intValue()-1);
		if (pt != null)
			getViewport().setViewPosition(pt);
			*/
	}

	/* UIControl interface */

	public void update()
	{
		int[] sel = list.getSelectedIndices();
		double[] val = new double[sel.length];

		for (int i=0; i<sel.length; i++)
			val[i] = sel[i]+1;
		uiObj.Value.reset(val);
		uiObj.ListboxTop.reset(new Double(list.getFirstVisibleIndex()+1));
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

	public void valueChanged(ListSelectionEvent event)
	{
		if (!event.getValueIsAdjusting())
		{
			uiObj.controlActivated(new UIControlEvent(this));
		}
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
		else if (p == uiObj.Min || p == uiObj.Max)
			updateSelectionMode();
		else if (p == uiObj.BackgroundColor || p == uiObj.ForegroundColor)
			updateColors();
		else if (p == uiObj.ListboxTop)
			updateTop();
	}
}
