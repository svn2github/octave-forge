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
import java.util.*;

public class UITooltipManager implements MouseListener
{
	private static UITooltipManager instance = new UITooltipManager();
	private Map tooltips;
	private Window tip;
	private Component activeComponent;

	private UITooltipManager()
	{
		tooltips = new HashMap();
		tip = null;
		activeComponent=  null;
	}

	public static UITooltipManager getInstance()
	{
		return instance;
	}

	public void add(Component comp, String s)
	{
		if (!tooltips.containsKey(comp))
			comp.addMouseListener(this);
		tooltips.put(comp, s);
	}

	public void remove(Component comp)
	{
		if (tooltips.containsKey(comp))
		{
			comp.removeMouseListener(this);
			tooltips.remove(comp);
		}
	}

	public void hideTip()
	{
		if (tip != null)
		{
			System.out.println("hide tip");

			tip.dispose();
			tip = null;
			activeComponent = null;
		}
	}

	public void showTip(Component comp, Point pt)
	{
		if (!tooltips.containsKey(comp) || tip != null)
			return;

		System.out.println("show tip");

		String tipString = (String)tooltips.get(comp);
		Label tipLabel = new Label(tipString);
		Window tipWin = new Window(null);

		tipWin.setLocation(comp.getLocationOnScreen().x+pt.x+5, comp.getLocationOnScreen().y+pt.y+5);
		tipWin.setLayout(null);
		tipLabel.setLocation(0, 0);
		tipLabel.setSize(100, 30);
		tipWin.setSize(tipLabel.getSize());
		tipWin.add(tipLabel);
		tipWin.setVisible(true);

		tip = tipWin;
		activeComponent = comp;
	}

	/* MouseListener interface */

	public void mouseClicked(MouseEvent e) {}

	public void mouseEntered(MouseEvent e)
	{
		showTip((Component)e.getSource(), e.getPoint());
	}

	public void mouseExited(MouseEvent e)
	{
		hideTip();
	}

	public void mousePressed(MouseEvent e) {}

	public void mouseReleased(MouseEvent e) {}
}
