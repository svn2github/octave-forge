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
import javax.media.opengl.*;

public class LineStyleProperty extends RadioProperty
{
	public LineStyleProperty(PropertySet parent, String name)
	{
		this(parent, name, "-");
	}

	public LineStyleProperty(PropertySet parent, String name, String style)
	{
		super(parent, name, new String[] {"-", ":", "--", "-.", "none"}, style);
	}

	public void setup(GL gl)
	{
		String ls = getValue();
		if (ls.equals(":"))
			gl.glLineStipple(1, (short)0x8888);
		else if (ls.equals("-"))
			gl.glLineStipple(1, (short)0xFFFF);
		else if (ls.equals("--"))
			gl.glLineStipple(1, (short)0x0FFF);
		else if (ls.equals("-."))
			gl.glLineStipple(1, (short)0x028F);
		else
			gl.glLineStipple(1, (short)0x0000);
	}
	
	public Stroke getStroke(float width)
	{
		String ls = getValue();
		if (ls.equals(":"))
			return new BasicStroke(width, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1.0f,
					new float[] {2.0f, 3.0f}, 0.0f);
		else if (ls.equals("-"))
			return new BasicStroke(width);
		else if (ls.equals("--"))
			return new BasicStroke(width, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1.0f,
					new float[] {10.0f, 5.0f}, 0.0f);
		else if (ls.equals("-."))
			return new BasicStroke(width, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1.0f,
					new float[] {5.0f, 5.0f, 1.0f, 5.0f}, 0.0f);
		else
			return null;
	}

	public static void setupSolid(GL gl)
	{
		gl.glLineStipple(1, (short)0xFFFF);
	}

	public void setStyle(String s)
	{
		try { set(s); }
		catch (PropertyException e) { }
	}

	public int getStyle()
	{
		String ls = getValue();
		if (ls.equals("-"))
			return Renderer.LS_SOLID;
		else if (ls.equals(":"))
			return Renderer.LS_DOTTED;
		else if (ls.equals("--"))
			return Renderer.LS_DASHED;
		else if (ls.equals("-."))
			return Renderer.LS_DASHDOT;
		return Renderer.LS_NONE;
	}

	public boolean isSet()
	{
		return !is("none");
	}
}
