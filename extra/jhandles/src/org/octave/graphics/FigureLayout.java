/*
 * oplot-gl 
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

public class FigureLayout implements LayoutManager
{
	public FigureLayout()
	{
	}

	/* LayoutManager interface */

	public void addLayoutComponent(String name, Component comp) {}

	public void layoutContainer(Container parent)
	{
		Component glComp = parent.getComponent(parent.getComponentCount()-1);
		Insets ir = parent.getInsets();
		Rectangle r = parent.getBounds();

		glComp.setBounds(ir.left, ir.top, r.width-ir.left-ir.right, r.height-ir.top-ir.bottom);
		for (int i=parent.getComponentCount()-2; i>=0; i--)
			parent.getComponent(i).setLocation(ir.left, ir.top);
	}

	public Dimension minimumLayoutSize(Container parent)
	{
		return new Dimension(100, 100);
	}

	public Dimension preferredLayoutSize(Container parent)
	{
		return new Dimension(500, 400);
	}

	public void removeLayoutComponent(Component comp) {}
}
