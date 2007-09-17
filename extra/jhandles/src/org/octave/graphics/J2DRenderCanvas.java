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

import java.awt.Component;
import java.awt.Canvas;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.awt.event.*;
import java.util.*;

public class J2DRenderCanvas extends Canvas implements RenderCanvas
{
	private List listenerList;
	private J2DRenderer r;

	public J2DRenderCanvas()
	{
		listenerList = new LinkedList();
		r = new J2DRenderer();
	}

	public void paint(Graphics g)
	{
		r.setGraphics(g);

		Iterator it = listenerList.iterator();
		while (it.hasNext())
			((RenderEventListener)it.next()).display(this);

		r.setGraphics(null);
	}

	public void setBounds(int x, int y, int w, int h)
	{
		super.setBounds(x, y, w, h);
		Iterator it = listenerList.iterator();
		while (it.hasNext())
			((RenderEventListener)it.next()).reshape(this, x, y, w, h);
	}

	public void addRenderEventListener(RenderEventListener l)
	{
		listenerList.add(l);
	}

	public void removeRenderEventListener(RenderEventListener l)
	{
		listenerList.remove(l);
	}

	public void redraw()
	{
		repaint();
	}

	public Renderer getRenderer()
	{
		return r;
	}

	public Component getComponent()
	{
		return this;
	}

	public BufferedImage toImage()
	{
		return null;
	}

	public void toPostScript(String filename)
	{
	}
}
