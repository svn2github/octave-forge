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
import java.awt.geom.*;
import java.util.Iterator;
import java.util.LinkedList;
import java.nio.ByteBuffer;

public class TextObject extends GraphicObject
{
	public static final int H_LEFT = 0;
	public static final int H_CENTER = 1;
	public static final int H_RIGHT = 2;
	public static final int V_TOP = 0;
	public static final int V_MIDDLE = 1;
	public static final int V_BOTTOM = 3;

	private Font font = null;
	private Content content;
	private ByteBuffer data;
	private AffineTransform T;
	private Rectangle r;
	private int w, h, baseline;
	private String currentUnits;

	/* properties */
	DoubleProperty Rotation;
	RadioProperty HAlign;
	RadioProperty VAlign;
	DoubleArrayProperty Position;
	BooleanProperty PositionMode;
	RadioProperty Units;
	ColorProperty TextColor;
	StringProperty TextString;
	ColorProperty BackgroundColor;
	LineStyleProperty LineStyle;
	ColorProperty EdgeColor;
	DoubleProperty LineWidth;
	DoubleProperty Margin;

	class SimpleFactory
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
				case '}': depth--; if (depth == 0) return start;
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

	class Element
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

	class LineElement extends Element
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

	class SubscriptElement extends LineElement
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

	class SuperscriptElement extends LineElement
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

	class Content extends Element
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

	public TextObject(HandleObject parent, String txt, double[] pos)
	{
		super(parent, "text");

		this.content = new Content(txt);
		this.data = null;

		Rotation = new DoubleProperty(this, "Rotation", 0.0);
		HAlign = new RadioProperty(this, "HorizontalAlignment", new String[] {"left", "center", "right"}, "left");
		VAlign = new RadioProperty(this, "VerticalAlignment", new String[] {"top", "middle", "bottom", "baseline"}, "baseline");
		Position = new DoubleArrayProperty(this, "Position", pos, 3);
		PositionMode = new BooleanProperty(this, "PositionMode", true);
		Units = new RadioProperty(this, "Units", new String[] {"pixels", "data"}, "data");
		currentUnits = "data";
		TextColor = new ColorProperty(this, "Color", Color.black);
		TextString = new StringProperty(this, "String", txt);
		BackgroundColor = new ColorProperty(this, "BackgroundColor", null);
		EdgeColor = new ColorProperty(this, "EdgeColor", null);
		LineWidth = new DoubleProperty(this, "LineWidth", 1.0);
		Margin = new DoubleProperty(this, "Margin", 2.0);
		LineStyle = new LineStyleProperty(this, "LineStyle", "-");

		listen(Units);
		listen(TextString);
		listen(Rotation);
		listen(TextColor);
		listen(BackgroundColor);
		listen(EdgeColor);
		listen(Margin);
		listen(LineStyle);
		listen(LineWidth);
		listen(Position);
	}

	public void validate()
	{
		super.validate();
	}

	public Rectangle getExtent()
	{
		RenderCanvas comp = getAxes().getCanvas();
		return (Rectangle)content.layout(comp, comp.getFont()).clone();
	}

	private void updateData()
	{
		RenderCanvas comp = getAxes().getCanvas();
		double angle = Rotation.doubleValue()*Math.PI/180.0;
		int angleD = Rotation.intValue();
		int margin = Margin.intValue();
		int offset = (LineWidth.intValue()+1)/2;

		if (EdgeColor.isSet())
			margin += LineWidth.intValue();

		r = (Rectangle)content.layout(comp, comp.getFont()).clone();
		r.x -= margin;
		r.y -= margin;
		r.width += 2*margin;
		r.height += 2*margin;
		w = (int)Math.round(Math.abs(r.width*Math.cos(angle))+Math.abs(r.height*Math.sin(angle)));
		h = (int)Math.round(Math.abs(r.height*Math.cos(angle))+Math.abs(r.width*Math.sin(angle)));
		while (angleD < 0) angleD += 360;
		while (angleD > 360) angleD -= 360;

		BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_4BYTE_ABGR);

		Graphics2D g = img.createGraphics();
		//g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
		g.setComposite(AlphaComposite.getInstance(AlphaComposite.CLEAR, 0.0f));
		g.fillRect(0, 0, w, h);
		g.setPaintMode();
		switch ((angleD/90)%4)
		{
			case 0:
				g.translate(0, r.width*Math.sin(angle));
				break;
			case 1:
				g.translate(r.width*Math.sin(angle-Math.PI/2.0), h);
				break;
			case 2:
				g.translate(w, h-r.width*Math.sin(angle-Math.PI));
				break;
			case 3:
				g.translate(w-r.width*Math.sin(angle-3.0*Math.PI/2.0), 0);
				break;
		}
		g.rotate(-angle);
		g.translate(margin, margin);
		T = g.getTransform();
		if (BackgroundColor.isSet())
		{
			g.setColor(BackgroundColor.getColor());
			g.fillRect(-margin+offset, -margin+offset, r.width-2*offset-1, r.height-2*offset-1);
		}
		if (EdgeColor.isSet() && !LineStyle.is("none"))
		{
			Stroke oldS = g.getStroke();
			g.setStroke(LineStyle.getStroke(LineWidth.floatValue()));
			g.setColor(EdgeColor.getColor());
			g.drawRect(-margin+offset, -margin+offset, r.width-2*offset-1, r.height-2*offset-1);
			g.setStroke(oldS);
		}
		g.setColor(TextColor.getColor());
		g.setFont(comp.getFont());
		content.render(g);
		g.dispose();
		com.sun.opengl.util.ImageUtil.flipImageVertically(img);

		data = ByteBuffer.wrap(((DataBufferByte)img.getData().getDataBuffer()).getData());
	}

	/* TODO: remove
	public void draw(GL gl)
	{
		if (data == null)
			updateData();

		AxesObject ax = getAxes();
		double[] pos = ax.convertUnits(Position.getArray(), Units.getValue());
		boolean clipEnabled = ax.getClipping(gl);
		boolean dataUnits = Units.is("data");

		int x = 0, y = 0, margin = -r.x;

		if (HAlign.is("center")) x = (r.width-2*margin)/2;
		else if (HAlign.is("right")) x = (r.width-2*margin);
		if (VAlign.is("bottom")) y = (r.height-2*margin);
		else if (VAlign.is("middle")) y = (r.height-2*margin)/2;
		else if (VAlign.is("baseline")) y = (r.height+r.y-margin);

		Point2D.Double p1 = new Point2D.Double(x, y), p2 = new Point2D.Double();
		T.transform(p1, p2);

		int xOffset = (int)p2.getX(), yOffset = h-(int)p2.getY();

		TextColor.setup(gl);
		if (clipEnabled)
			ax.setClipping(gl, false);
		gl.glEnable(GL.GL_ALPHA_TEST);
		if (!dataUnits)
			gl.glDisable(GL.GL_DEPTH_TEST);
		gl.glAlphaFunc(GL.GL_GREATER, 0.0f);
		gl.glRasterPos3d(pos[0], pos[1], pos[2]);
		gl.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1);
		gl.glBitmap(0, 0, 0, 0, -xOffset, -yOffset, null, 0);
		gl.glDrawPixels(w, h, GL.GL_ABGR_EXT, GL.GL_UNSIGNED_BYTE, data);
		gl.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4);
		gl.glDisable(GL.GL_ALPHA_TEST);
		if (!dataUnits)
			gl.glEnable(GL.GL_DEPTH_TEST);
		if (clipEnabled)
			ax.setClipping(gl, true);
	}
	*/

	public void draw(Renderer renderer)
	{
		if (data == null)
			updateData();

		AxesObject ax = getAxes();
		double[] pos = ax.convertUnits(Position.getArray(), Units.getValue());
		boolean dataUnits = Units.is("data");

		int x = 0, y = 0, margin = -r.x;

		if (HAlign.is("center")) x = (r.width-2*margin)/2;
		else if (HAlign.is("right")) x = (r.width-2*margin);
		if (VAlign.is("bottom")) y = (r.height-2*margin);
		else if (VAlign.is("middle")) y = (r.height-2*margin)/2;
		else if (VAlign.is("baseline")) y = (r.height+r.y-margin);

		Point2D.Double p1 = new Point2D.Double(x, y), p2 = new Point2D.Double();
		T.transform(p1, p2);

		int xOffset = (int)p2.getX(), yOffset = h-(int)p2.getY();

		renderer.draw(data, w, h, pos, xOffset, yOffset, false, dataUnits);
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == Units)
		{
			AxesObject ax = getAxes();
			Position.reset(ax.convertUnits(Position.getArray(), currentUnits, Units.getValue()));
			currentUnits = Units.getValue();
		}
		else if (p == TextString)
		{
			content = new Content(TextString.toString());
			data = null;
		}
		else if (p == Rotation || p == TextColor || p == BackgroundColor || p == EdgeColor ||
				 p == Margin || p == LineStyle || p == LineWidth)
			data = null;

		if (p == Units || p == Position)
			PositionMode.set(new Boolean(false));
	}
}
