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
import java.awt.image.*;
import java.util.*;
import java.nio.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*;

public class GLRenderCanvas extends GLCanvas
	implements GLEventListener, RenderCanvas
{
	private GLRenderer r;
	private java.util.List rListeners;

	public GLRenderCanvas()
	{
		r = null;
		rListeners = new LinkedList();

		addGLEventListener(this);
	}

	/* GLEventListener interface */

	public void display(GLAutoDrawable d)
	{
		Iterator it = rListeners.iterator();
		while (it.hasNext())
			((RenderEventListener)it.next()).display(this);
	}

	public void init(GLAutoDrawable d)
	{
		GL gl = getGL();

		r = new GLRenderer(d);
		gl.glEnable(GL.GL_DEPTH_TEST);
		gl.glDepthFunc(GL.GL_LEQUAL);
		gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
		gl.glEnable(GL.GL_NORMALIZE);
		//gl.glFrontFace(GL.GL_CW);
		//gl.glCullFace(GL.GL_BACK);
		//gl.glEnable(GL.GL_CULL_FACE);
	}

	public void reshape(GLAutoDrawable d, int x, int y, int width, int height)
	{
		r.setViewport(width, height);
		
		Iterator it = rListeners.iterator();
		while (it.hasNext())
			((RenderEventListener)it.next()).reshape(this, x, y, width, height);
	}

	public void displayChanged(GLAutoDrawable d, boolean deviceChanged, boolean modeChanged) {}

	/* RenderCanvas interface */

	public Renderer getRenderer()
	{
		return r;
	}

	public Component getComponent()
	{
		return this;
	}

	public void redraw()
	{
		display();
	}

	public void addRenderEventListener(RenderEventListener l)
	{
		rListeners.add(l);
	}
	
	public void removeRenderEventListener(RenderEventListener l)
	{
		rListeners.remove(l);
	}

	public BufferedImage toImage()
	{
		display();
		getContext().makeCurrent();

		GL gl = getGL();
		ByteBuffer buf = ByteBuffer.allocate(getWidth()*getHeight()*4);
		gl.glReadPixels(0, 0, getWidth(), getHeight(), GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, buf);

		BufferedImage img = new BufferedImage(getWidth(), getHeight(), BufferedImage.TYPE_4BYTE_ABGR);
		img.getRaster().setDataElements(0, 0, getWidth(), getHeight(), buf.array());
		com.sun.opengl.util.ImageUtil.flipImageVertically(img);

		getContext().release();

		return img;
	}
}
