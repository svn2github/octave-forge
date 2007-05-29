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
import java.awt.image.*;
import javax.media.opengl.*;

public class GLTextRenderer
{
	public static Dimension draw(RenderCanvas comp, GL gl, String txt, int halign, int valign)
	{
		return draw(comp, gl, txt, halign, valign, 0.0, 5);
	}

	public static Dimension draw(RenderCanvas comp, GL gl, String txt, int halign, int valign, double angle)
	{
		return draw(comp, gl, txt, halign, valign, angle, 5);
	}

	public static Dimension draw(RenderCanvas comp, GL gl, String txt, int halign, int valign, double angle, int margin)
	{
		// create internal image
		FontMetrics fm = comp.getFontMetrics(comp.getFont());
		int h = fm.getMaxAscent()+fm.getMaxDescent()+2*margin, w = fm.stringWidth(txt)+2*margin;
		BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_BYTE_BINARY);

		// draw string onto image
		Graphics g = img.getGraphics();
		g.setFont(comp.getFont());
		g.drawString(txt, margin, fm.getMaxAscent()+margin);
		g.dispose();
		com.sun.opengl.util.ImageUtil.flipImageVertically(img);

		// extract binary daya
		byte[] img_data = ((DataBufferByte)img.getData().getDataBuffer()).getData();

		// compute offset
		float x, y;
		switch (halign)
		{
			default:
			case 0: x = 0; break;
			case 1: x = -w/2.0f; break;
			case 2: x = -w; break;
		}
		switch (valign)
		{
			default:
			case 0: y = 0; break;
			case 1: y = -h/2.0f; break;
			case 2: y = -h; break;
		}

		// output string onto GL context
		gl.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1);
		gl.glBitmap(0, 0, 0, 0, x, y, null, 0);
		gl.glBitmap(w, h, 0, 0, 0, 0, img_data, 0);
		gl.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4);

		return new Dimension(w, h);
	}
}
