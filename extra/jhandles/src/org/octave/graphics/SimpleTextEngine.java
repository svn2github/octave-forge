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
		private StringBuilder builder;

		SimpleFactory(String txt, LinkedList lst)
		{
			buffer = txt;
			list = lst;
			builder = new StringBuilder();
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

		String getTeXCommand(int start)
		{
			int end = start;
			while (end < buffer.length())
			{
				char c = buffer.charAt(end);
				if (!Character.isLetterOrDigit(c))
					break;
				end++;
			}
			anchor = end;
			return buffer.substring(start, end);
		}

		void flush()
		{
			if (current > anchor && builder.length() > 0)
			{
				list.add(new Element(builder.toString()));
				anchor = current;
				builder.setLength(0);
			}
		}

		void parse()
		{
			String arg;

			current = anchor;
			while (current < buffer.length())
			{
				switch (buffer.charAt(current))
				{
				case '^':
				case '_':
					flush();
					arg = getArgument(current+1);
					if (arg != null)
					{
						if (buffer.charAt(current) == '_')
							list.add(new SubscriptElement(arg));
						else if (buffer.charAt(current) == '^')
							list.add(new SuperscriptElement(arg));
						current = anchor;

						if (list.size() > 1)
						{
							Element e1 = (Element)list.get(list.size()-2);
							Element e2 = (Element)list.get(list.size()-1);
							if ((e1 instanceof SubscriptElement && e2 instanceof SuperscriptElement) ||
							    (e2 instanceof SubscriptElement && e1 instanceof SuperscriptElement))
							{
								list.remove(list.size()-2);
								list.remove(list.size()-1);
								list.add(new ScriptElement(e1, e2));
							}
						}
					}
					else
						current++;
					break;
				case '{':
					flush();
					arg = getArgument(current);
					if (arg != null)
						list.add(new LineElement(arg));
					else
						System.err.println("WARNING: unmatched brace '{'");
					current = anchor;
					break;
				case '\\':
					if (current+1 < buffer.length())
						switch (buffer.charAt(current+1))
						{
							case '\\':
							case '{':
							case '}':
							case '_':
							case '^':
								builder.append(buffer.charAt(current+1));
								current = anchor = current+2;
								break;
							default:
								flush();
								arg = getTeXCommand(current+1);
								if (arg != null && arg.length() > 0)
									list.add(new TeXElement(arg));
								else
									System.err.println("WARNING: unable to interpret TeX command: " + buffer.substring(current));
								current = anchor;
								break;
						}
					else
						System.err.println("WARNING: unable to interpret TeX command: " + buffer.substring(current));
					break;
				default:
					builder.append(buffer.charAt(current++));
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

	static class ScriptElement extends Element
	{
		private Element[] elems = new Element[2];

		ScriptElement(Element e1, Element e2)
		{
			super("");
			elems[0] = e1;
			elems[1] = e2;
		}

		Rectangle layout(RenderCanvas comp, Font font)
		{
			rect = elems[0].layout(comp, font);
			rect = rect.union(elems[1].layout(comp, font));
			return rect;
		}

		void render(Graphics2D g)
		{
			elems[0].render(g);
			elems[1].render(g);
		}
	}

	static class TeXElement extends Element
	{
		private static String[] symbol_names = {
			"alpha",
			"beta",
			"gamma",
			"delta",
			"epsilon",
			"zeta",
			"eta",
			"theta",
			//"vartheta",
			"iota",
			"kappa",
			"lambda",
			"mu",
			"nu",
			"xi",
			"pi",
			"rho",
			"sigma",
			//"varsigma",
			"tau",
			"upsilon",
			"phi",
			"chi",
			"psi",
			"omega",
			"equiv",
			"int",
			"forall",
			"Delta",
			"Sigma",
			null
		};
		private static int[] symbol_codes = {
			0x03B1,		// alpha
			0x03B2,		// beta
			0x03B3,		// gamma
			0x03B4,		// delta
			0x03B5,		// epsilon
			0x03B6,		// zeta
			0x03B7,		// eta
			0x03B8,		// theta
			//0,		// vartheta
			0x03B9,		// iota
			0x03BA,		// kappa
			0x03BB,		// lambda
			0x03BC,		// mu
			0x03BD,		// nu
			0x03BE,		// xi
			0x03C0,		// pi
			0x03C1,		// rho
			0x03C3,		// sigma
			//0,		// varsigma
			0x03C4,		// tau
			0x03C5,		// upsilon
			0x03C6,		// phi
			0x03C7,		// chi
			0x03C8,		// psi
			0x03C9,		// omega
			0x2261,		// equiv
			0x222B,		// int
			0x2200,		// forall
			0x0394,		// Delta
			0x03A3,		// Sigma
			0
		};
		private static Map symbol_map;

		TeXElement(String txt)
		{
			super(convertString(txt));
		}

		private static String convertString(String s)
		{
			System.out.println("convert: " + s);
			int c = getSymbolCode(s);
			if (c != 0)
				return new String(new int[] {c}, 0, 1);
			return "";
		}

		private static int getSymbolCode(String s)
		{
			if (symbol_map == null)
			{
				symbol_map = new HashMap();
				for (int i=0; i<symbol_names.length; i++)
					if (symbol_names[i] != null)
						symbol_map.put(symbol_names[i], new Integer(symbol_codes[i]));
			}
			Integer c = (Integer)symbol_map.get(s);
			if (c != null)
				return c.intValue();
			return 0;
		}
	}

	static class Content extends Element
	{
		private LineElement[] lines;
		public int align;

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
			int w = 0, h = 0;
			Rectangle r;

			for (int i=0; i<lines.length; i++)
			{
				r = lines[i].layout(comp, font);
				if (r.width > w)
					w = r.width;
				h += r.height;
			}
			rect = new Rectangle(0, -(h-lines[0].rect.height-lines[0].rect.y), w, h);
			return rect;
			//return lines[0].layout(comp, font);
		}

		void render(Graphics2D g)
		{
			int xoffset = 0, yoffset = 0;

			for (int i=0; i<lines.length; i++)
			{
				int dx = rect.width-lines[i].rect.width;
				xoffset = (align == 0 ? 0 : (align == 1 ? dx/2 : dx));
				g.translate(xoffset, 0);
				lines[i].render(g);
				g.translate(-xoffset, lines[i].rect.height);
				yoffset += lines[i].rect.height;
			}
			g.translate(0, -yoffset);
			//lines[0].render(g);
		}
	}

	public static Dimension drawAsImage(RenderCanvas comp, String txt, double[] pos, int halign, int valign)
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

		// return value
		return new Dimension(r.width, r.height);
	}
}
