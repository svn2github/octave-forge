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
import java.awt.geom.*;
import java.util.Iterator;
import java.util.LinkedList;
import java.nio.ByteBuffer;

public class TextObject extends GraphicObject
{
	private Font font = null;
	private SimpleTextEngine.Content content;
	private ByteBuffer data;
	private AffineTransform T;
	private Rectangle r;
	private int w, h;
	private String currentUnits;

	/* properties */
	ColorProperty BackgroundColor;
	ColorProperty TextColor /* Color */;
	ColorProperty EdgeColor;
	RadioProperty FontAngle;
	StringProperty FontName;
	DoubleProperty FontSize;
	RadioProperty FontWeight;
	RadioProperty FontUnits;
	RadioProperty HAlign;
	LineStyleProperty LineStyle;
	DoubleProperty LineWidth;
	DoubleProperty Margin;
	VectorProperty Position;
	BooleanProperty PositionMode;
	DoubleProperty Rotation;
	StringProperty TextString;
	RadioProperty Units;
	RadioProperty VAlign;

	public TextObject(HandleObject parent, String txt, double[] pos)
	{
		super(parent, "text");

		Rotation = new DoubleProperty(this, "Rotation", 0.0);
		HAlign = new RadioProperty(this, "HorizontalAlignment", new String[] {"left", "center", "right"}, "left");
		VAlign = new RadioProperty(this, "VerticalAlignment", new String[] {"top", "middle", "bottom", "baseline"}, "middle");
		Position = new VectorProperty(this, "Position", 3, pos);
		PositionMode = new BooleanProperty(this, "PositionMode", true);
		Units = new RadioProperty(this, "Units", new String[] {"pixels", "data", "normalized",
			"inches", "centimeters", "points"}, "data");
		currentUnits = "data";
		TextColor = new ColorProperty(this, "Color", Color.black);
		TextString = new StringProperty(this, "String", txt);
		BackgroundColor = new ColorProperty(this, "BackgroundColor", (Color)null);
		EdgeColor = new ColorProperty(this, "EdgeColor", (Color)null);
		LineWidth = new DoubleProperty(this, "LineWidth", 1.0);
		Margin = new DoubleProperty(this, "Margin", 2.0);
		LineStyle = new LineStyleProperty(this, "LineStyle", "-");
		FontAngle = new RadioProperty(this, "FontAngle", new String[] {"normal", "oblique", "italic"}, "normal");
		FontName = new StringProperty(this, "FontName", "Helvetica");
		FontSize = new DoubleProperty(this, "FontSize", 10);
		FontWeight = new RadioProperty(this, "FontWeight", new String[] {"light", "normal", "demi", "bold"}, "normal");
		FontUnits = new RadioProperty(this, "FontUnits", new String[] {"points", "normalized", "inches",
			"centimeters", "pixels"}, "points");
		Clipping.reset("off");

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
		listen(FontAngle);
		listen(FontName);
		listen(FontSize);
		listen(FontWeight);
		listen(FontUnits);
		listen(HAlign);
	}

	public void validate()
	{
		currentUnits = Units.getValue();
		content = new SimpleTextEngine.Content(TextString.toString());
		data = null;
		updateMinMax();
		super.validate();
	}

	public Rectangle getExtent()
	{
		RenderCanvas comp = getAxes().getCanvas();
		Font fnt = Utils.getFont(FontName, FontSize, FontUnits, FontAngle, FontWeight, comp.getHeight());
		return (Rectangle)content.layout(comp, fnt).clone();
	}

	public void render(Graphics g)
	{
		content.render((Graphics2D)g);
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

		Font fnt = Utils.getFont(FontName, FontSize, FontUnits, FontAngle, FontWeight, comp.getHeight());

		r = (Rectangle)content.layout(comp, fnt).clone();
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
		g.setFont(fnt);
		content.align = (HAlign.is("left") ? 0 : (HAlign.is("center") ? 1 : 2));
		content.render(g);
		g.dispose();
		com.sun.opengl.util.ImageUtil.flipImageVertically(img);

		data = ByteBuffer.wrap(((DataBufferByte)img.getData().getDataBuffer()).getData());
	}

	protected void updateMinMax()
	{
		if (Units.is("data"))
		{
			double[] p = getAxes().convertUnits(Position.getArray(), Units.getValue());
			double xmin2 = (p[0] <= 0 ? Double.POSITIVE_INFINITY : p[0]);
			double xmax2 = (p[0] <= 0 ? Double.MIN_VALUE : p[0]);
			double ymin2 = (p[1] <= 0 ? Double.POSITIVE_INFINITY : p[1]);
			double ymax2 = (p[1] <= 0 ? Double.MIN_VALUE : p[1]);
			double zmin2 = (p[2] <= 0 ? Double.POSITIVE_INFINITY : p[2]);
			double zmax2 = (p[2] <= 0 ? Double.MIN_VALUE : p[2]);

			XLim.set(new double[] {p[0], p[0], xmin2, xmax2}, true);
			YLim.set(new double[] {p[1], p[1], ymin2, ymax2}, true);
			ZLim.set(new double[] {p[2], p[2], zmin2, zmax2}, true);
		}
		else
		{
			double[] lims = new double[] {Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY,
				Double.POSITIVE_INFINITY, Double.MIN_VALUE};
			XLim.set(lims, true);
			YLim.set(lims, true);
			ZLim.set(lims, true);
		}
	}

	public void drawAsImage(Renderer renderer)
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

	public void draw(Renderer renderer)
	{
		renderer.draw(this);
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		super.propertyChanged(p);

		if (p == Units)
		{
			AxesObject ax = getAxes();
			Position.reset(ax.convertUnits(Position.getArray(), currentUnits, Units.getValue()));
			currentUnits = Units.getValue();
		}
		else if (p == TextString)
		{
			content = new SimpleTextEngine.Content(TextString.toString());
			data = null;
		}
		else if (p == Rotation || p == TextColor || p == BackgroundColor || p == EdgeColor ||
				 p == Margin || p == LineStyle || p == LineWidth || p == FontAngle ||
				 p == FontName || p == FontSize || p == FontWeight || (p == HAlign && TextString.toString().indexOf('\n') != -1))
			data = null;

		if (p == Units || p == Position)
			PositionMode.set(new Boolean(false));

		if (p == Position)
			updateMinMax();
	}

	public String toPostScript()
	{
		SimpleTextEngine.PSTextRenderer r = new SimpleTextEngine.PSTextRenderer(
				FontName.toString(), Utils.getFontSize(FontSize, FontUnits, getAxes().getCanvas().getHeight()),
				(FontAngle.is("normal") ? 0 : Font.ITALIC)|(FontWeight.is("normal") ? 0 : Font.BOLD));
		content.render(r);
		return r.toString();
	}
}
