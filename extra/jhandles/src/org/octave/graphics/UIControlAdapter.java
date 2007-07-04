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
import javax.swing.JComponent;

public class UIControlAdapter extends Panel
	implements HandleNotifier.Sink, Positionable
{
	private UIControl ctrl;
	private UIControlObject uiObj;
	private HandleNotifier uiNotifier;

	public UIControlAdapter(UIControlObject obj) throws IllegalArgumentException
	{
		super(new BorderLayout());

		String style = obj.Style.toString();

		if (style.equalsIgnoreCase("pushbutton"))
			this.ctrl = new PushButtonControl(obj);
		else if (style.equalsIgnoreCase("edit"))
		{
			if ((obj.Max.doubleValue()-obj.Min.doubleValue()) <= 1.0)
				this.ctrl = new EditControl(obj);
			else
				this.ctrl = new Edit2Control(obj);
		}
		else
			throw new IllegalArgumentException("unsupported UI style `" + style + "'");
		this.uiObj = obj;
		init();
		add((JComponent)ctrl, BorderLayout.CENTER);

		uiNotifier = new HandleNotifier();
		uiNotifier.addSink(this);
		uiNotifier.addSource(obj.Position);
		uiNotifier.addSource(obj.BackgroundColor);
		uiNotifier.addSource(obj.ForegroundColor);
		uiNotifier.addSource(obj.FontAngle);
		uiNotifier.addSource(obj.FontSize);
		uiNotifier.addSource(obj.FontName);
		uiNotifier.addSource(obj.FontWeight);
		uiNotifier.addSource(obj.TooltipString);
	}

	private void init()
	{
		JComponent comp1 = ctrl.getComponent();

		comp1.setBackground(uiObj.BackgroundColor.getColor());
		comp1.setForeground(uiObj.ForegroundColor.getColor());
		double[] pos = uiObj.getPosition();
		setBounds((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
		if (uiObj.TooltipString.toString().length() > 0)
			comp1.setToolTipText(uiObj.TooltipString.toString());
		comp1.setFont(Utils.getFont(uiObj.FontName, uiObj.FontSize, uiObj.FontUnits,
				uiObj.FontAngle, uiObj.FontWeight, getHeight()));
	}

	public void update() { if (ctrl != null) ctrl.update(); }

	public void dispose()
	{
		if (ctrl != null)
			ctrl.dispose();
		if (getParent() != null)
			getParent().remove(this);
		uiNotifier.removeSink(this);
	}

	public Component getComponent()
	{
		return ctrl.getComponent();
	}

	/* HandleNotifier.Sink interface */

	public void addNotifier(HandleNotifier n)
	{
		if (n != uiNotifier)
			System.out.println("Warning: adding unknown notifier to UIControlAdapter object");
	}

	public void removeNotifier(HandleNotifier n)
	{
		if (n != uiNotifier)
			System.out.println("Warning: removing unknown notifier from UIControlAdapter object");
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (ctrl != null)
		{
			JComponent comp1 = ctrl.getComponent();

			if (p == uiObj.BackgroundColor)
				comp1.setBackground(uiObj.BackgroundColor.getColor());
			else if (p == uiObj.ForegroundColor)
				comp1.setForeground(uiObj.ForegroundColor.getColor());
			else if (p == uiObj.Position)
			{
				getParent().doLayout();
				getParent().validate();
				if (uiObj.FontUnits.is("normalized"))
					comp1.setFont(Utils.getFont(uiObj.FontName, uiObj.FontSize, uiObj.FontUnits,
						uiObj.FontAngle, uiObj.FontWeight, getHeight()));
			}
			else if (p == uiObj.FontAngle || p == uiObj.FontSize || p == uiObj.FontWeight || p == uiObj.FontName)
				comp1.setFont(Utils.getFont(uiObj.FontName, uiObj.FontSize, uiObj.FontUnits,
					uiObj.FontAngle, uiObj.FontWeight, getHeight()));
			else if (p == uiObj.TooltipString)
			{
				if (uiObj.TooltipString.toString().length() > 0)
					comp1.setToolTipText(uiObj.TooltipString.toString());
				else
					comp1.setToolTipText(null);
			}
		}
	}

	/* Positionable interface */

	public double[] getPosition()
	{
		return uiObj.getPosition();
	}
}
