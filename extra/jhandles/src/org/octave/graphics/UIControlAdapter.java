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

public class UIControlAdapter extends Panel
{
	private UIControl ctrl;

	public UIControlAdapter(UIControl ctrl)
	{
		super(new BorderLayout());
		this.ctrl = ctrl;
		add(ctrl.getComponent(), BorderLayout.CENTER);
	}

	public void setForeground(Color c) { ctrl.getComponent().setForeground(c); }
	public void setBackground(Color c) { ctrl.getComponent().setBackground(c); }
	public void setFont(Font f) { ctrl.getComponent().setFont(f); }
	public void setString(String s) { ctrl.setString(s); }
	public void setAlignment(int align) { ctrl.setAlignment(align); }
	public void setTooltip(String s) { ctrl.setTooltip(s); }
	public void update(int mode) { ctrl.update(mode); }

	public void dispose()
	{
		if (getParent() != null)
			getParent().remove(this);
	}

	public void setPosition(double[] pos)
	{
		setBounds((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
		validate();
	}

	public Component getComponent()
	{
		return ctrl.getComponent();
	}

	/*
	public void update(Graphics g)
	{
		System.out.println("update");
	}

	public void paint(Graphics g)
	{
		System.out.println("paint");
	}
	*/
}
