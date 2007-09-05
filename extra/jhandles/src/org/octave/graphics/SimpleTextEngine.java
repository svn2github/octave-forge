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

class SimpleTextEngine
{
	static class SimpleFactory
	{
		private String buffer;
		private LinkedList list;
		private int anchor = 0, current = 0;

		SimpleFactory(String txt, LinkedList lst)
		{
			buffer = txt;
			list = lst;
		}

		int matchBrace(int start)
		{
			int depth = 0;
			while (start < buffer.length())
			{
				switch (buffer.charAt(start))
				{
				case '{': depth++; break;
				case '}': depth--; if (depth == 0) return start; break;
				default: break;
				}
				start++;
			}
			return -1;
		}

		String getArgument(int start)
		{
			if (start >= buffer.length())
				return null;
			if (buffer.charAt(start) == '{')
			{
				int pos = matchBrace(start);
				if (pos < 0)
					return null;
				else
				{
					anchor = pos+1;
					return buffer.substring(start+1, pos);
				}
			}
			else
			{
				anchor = start+1;
				return buffer.substring(start, start+1);
			}
		}

		void flush()
		{
			if (current > anchor)
			{
				list.add(new Element(buffer.substring(anchor, current)));
				anchor = current;
			}
		}

		void parse()
		{
			current = anchor;
			while (current < buffer.length())
			{
				switch (buffer.charAt(current))
				{
				case '^':
				case '_':
					flush();
					String arg = getArgument(current+1);
					if (arg != null)
					{
						if (buffer.charAt(current) == '_')
							list.add(new SubscriptElement(arg));
						else if (buffer.charAt(current) == '^')
							list.add(new SuperscriptElement(arg));
						current = anchor;
					}
					else
						current++;
					break;
				default:
					current++;
					break;
				}
			}

			flush();
		}

	}

	static class Element
	{
		String text;
		Rectangle rect;
		
		Element(String txt)
		{
			text = txt;
		}

		void render(Graphics2D g)
		{
			g.drawString(text, 0, 0);
		}

		Rectangle layout(RenderCanvas comp, Font font)
		{
			FontMetrics fm = comp.getFontMetrics(font);
			rect = new Rectangle(0, -fm.getMaxDescent(), fm.stringWidth(text), fm.getMaxDescent()+fm.getMaxAscent());
			return rect;
		}
	}

	static class LineElement extends Element
	{
		private LinkedList elements = new LinkedList();

		LineElement(String txt)
		{
			super(txt);

			SimpleFactory f = new SimpleFactory(txt, elements);
			f.parse();
		}

		Rectangle layout(RenderCanvas comp, Font font)
		{
			Iterator it = elements.iterator();
			FontMetrics fm = comp.getFontMetrics(font);

			rect = new Rectangle(0, -fm.getMaxDescent(), 0, fm.getMaxAscent()+fm.getMaxDescent());
			while (it.hasNext())
			{
				Element e = (Element)it.next();
				Rectangle eRect = e.layout(comp, font);
				eRect.x = rect.width;
				rect = rect.union(eRect);
			}
			return rect;
		}

		void render(Graphics2D g)
		{
			Iterator it = elements.iterator();
			int xoffset = 0, yoffset = (rect.height + rect.y);

			g.translate(0, yoffset);
			while (it.hasNext())
			{
				Element e = (Element)it.next();
				e.render(g);
				g.translate(e.rect.width, 0);
				xoffset += e.rect.width;
			}
			g.translate(-xoffset, -yoffset);
		}

		void add(Element e)
		{
			elements.add(e);
		}
	}

	static class SubscriptElement extends LineElement
	{
		SubscriptElement(String txt)
		{
			super(txt);
		}

		Font getSubscriptFont(Font f)
		{
			return new Font(f.getFamily(), f.getStyle(), f.getSize()-2);
		}

		Rectangle layout(RenderCanvas comp, Font font)
		{
			Font subscriptFont = getSubscriptFont(font);

			super.layout(comp, subscriptFont);
			rect.y -= (rect.height+rect.y)/2;

			return rect;
		}

		void render(Graphics2D g)
		{
			Font currentFont = g.getFont();
			Font subscriptFont = getSubscriptFont(currentFont);

			g.setFont(subscriptFont);
			super.render(g);
			g.setFont(currentFont);
		}
	}

	static class SuperscriptElement extends LineElement
	{
		SuperscriptElement(String txt)
		{
			super(txt);
		}

		Font getSuperscriptFont(Font f)
		{
			return new Font(f.getFamily(), f.getStyle(), f.getSize()-2);
		}

		Rectangle layout(RenderCanvas comp, Font font)
		{
			Font superscriptFont = getSuperscriptFont(font);

			super.layout(comp, superscriptFont);

			FontMetrics fm = comp.getFontMetrics(superscriptFont);
			rect.y += fm.getMaxAscent()/2;

			return rect;
		}

		void render(Graphics2D g)
		{
			Font currentFont = g.getFont();
			FontMetrics fm = g.getFontMetrics();
			int ascent = fm.getMaxAscent();
			Font subscriptFont = getSuperscriptFont(currentFont);

			g.setFont(subscriptFont);
			g.translate(0, -(rect.height+rect.y)-ascent/2);
			super.render(g);
			g.translate(0, (rect.height+rect.y)+ascent/2);
			g.setFont(currentFont);
		}
	}

	static class Content extends Element
	{
		private LineElement[] lines;

		Content(String txt)
		{
			super(txt);
			String[] txtLines = txt.split("\n", -1);
			lines = new LineElement[txtLines.length];
			for (int i=0; i<txtLines.length; i++)
			{
				lines[i] = new LineElement(txtLines[i]);
			}
		}

		Rectangle layout(RenderCanvas comp, Font font)
		{
			return lines[0].layout(comp, font);
		}

		void render(Graphics2D g)
		{
			lines[0].render(g);
		}
	}

	public static Dimension draw(RenderCanvas comp, String txt, double[] pos, int halign, int valign)
	{
		// create internal image
		int margin = 0;
		Content content = new Content(txt);
		Rectangle r = (Rectangle)content.layout(comp, comp.getFont()).clone();

		if (r.width <=0 || r.height <= 0)
			return new Dimension(0, 0);

		r.width += 2*margin;
		r.height += 2*margin;
		BufferedImage img = new BufferedImage(r.width, r.height, BufferedImage.TYPE_BYTE_BINARY);

		// draw string
		Graphics g = img.getGraphics();
		g.setFont(comp.getFont());
		g.translate(margin, margin);
		content.render((Graphics2D)g);
		g.dispose();
		com.sun.opengl.util.ImageUtil.flipImageVertically(img);

		// compute offsets
		int xoff, yoff;
		switch (halign)
		{
		default:
		case 0: xoff = 0; break;
		case 1: xoff = -r.width/2; break;
		case 2: xoff = -r.width; break;
		}
		switch (valign)
		{
		default:
		case 0: yoff = 0; break;
		case 1: yoff = -r.height/2; break;
		case 2: yoff = -r.height; break;
		}

		// render to canvas
		comp.getRenderer().drawBitmap(img, pos, xoff, yoff);
		comp.getRenderer().drawText(txt, pos, halign, valign, 0, margin, true,
				0, null, "-", null, true);

		// return value
		return new Dimension(r.width, r.height);
	}
}
