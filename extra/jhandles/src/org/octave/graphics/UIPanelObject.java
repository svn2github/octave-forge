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

import org.octave.Matrix;
import java.awt.*;
import javax.swing.*;
import javax.swing.border.TitledBorder;

public class UIPanelObject extends HandleObject
{
	protected JPanel panel;
	protected Panel panelWrapper;
	private String currentUnits;

	/* Properties */
	ColorProperty BackgroundColor;
	RadioProperty FontAngle;
	StringProperty FontName;
	DoubleProperty FontSize;
	RadioProperty FontUnits;
	RadioProperty FontWeight;
	ColorProperty ForegroundColor;
	ColorProperty HighlightColor;
	VectorProperty Position;
	ColorProperty ShadowColor;
	StringProperty Title;
	RadioProperty TitlePosition;
	RadioProperty Units;

	public UIPanelObject(HandleObject parent)
	{
		super(parent, "uipanel");

		BackgroundColor = new ColorProperty(this, "BackgroundColor", Color.lightGray);
		FontAngle = new RadioProperty(this, "FontAngle", new String[] {"normal", "italic", "oblique"}, "normal");
		FontName = new StringProperty(this, "FontName", "Helvetica");
		FontSize = new DoubleProperty(this, "FontSize", 12);
		FontUnits = new RadioProperty(this, "FontUnits",
			new String[] {"points", "normalized", "inches", "centimeters", "pixels"}, "points");
		FontWeight = new RadioProperty(this, "FontWeight", new String[] {"light", "normal", "demi", "bold"}, "normal");
		ForegroundColor = new ColorProperty(this, "ForegroundColor", Color.black);
		HighlightColor = new ColorProperty(this, "HighlightColor", Color.white);
		Position = new VectorProperty(this, "Position", new double[] {0, 0, 1, 1}, 4);
		ShadowColor = new ColorProperty(this, "ShadowColor", Color.gray);
		Title = new StringProperty(this, "Title", "");
		TitlePosition = new RadioProperty(this, "TitlePosition", new String[] {
			"lefttop", "centertop", "righttop",
			"leftbottom", "centerbottom", "rightbottom"}, "lefttop");
		Units = new RadioProperty(this, "Units", new String[] {"pixels", "normalized"}, "normalized");

		listen(FontUnits);
		listen(Units);
	}

	protected void deleteComponent()
	{
		if (panel != null)
		{
			panel.getParent().remove(panel);
			panel = null;
		}
	}

	public void delete()
	{
		super.delete();
		deleteComponent();
	}

	public void validate()
	{
		deleteComponent();
		currentUnits = Units.getValue();
		makePanel();
		super.validate();
	}

	public void makePanel()
	{
		TitledBorder border = BorderFactory.createTitledBorder(
				BorderFactory.createEtchedBorder(HighlightColor.getColor(), ShadowColor.getColor()),
				Title.toString());
		String tPos = TitlePosition.getValue().toLowerCase();
		
		panel = new JPanel();
		panel.setBackground(BackgroundColor.getColor());
		panelWrapper = new Panel(new BorderLayout());
		double[] pos = getPosition();
		panelWrapper.setBounds((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
		panelWrapper.add(panel, BorderLayout.CENTER);
		border.setTitleFont(Utils.getFont(FontName, FontSize, FontUnits, FontAngle, FontWeight, panelWrapper.getHeight()));
		border.setTitleColor(ForegroundColor.getColor());
		border.setTitlePosition(tPos.contains("bottom") ? TitledBorder.BOTTOM : TitledBorder.TOP);
		border.setTitleJustification(
				tPos.contains("left") ? TitledBorder.LEFT :
				tPos.contains("center") ? TitledBorder.CENTER :
				tPos.contains("right") ? TitledBorder.RIGHT :
				TitledBorder.LEFT);
		panel.setBorder(border);

		Container pContainer = (Container)getParentComponent();
		pContainer.add(panelWrapper, 0);
		pContainer.validate();
	}

	public double[] convertPosition(double[] pos, String units, String toUnits)
	{
		if (panel != null)
		{
			Dimension sz = panel.getSize();
			double[] p;

			if (units.equalsIgnoreCase("pixels"))
				p = new double[] {pos[0], pos[1], pos[2], pos[3]};
			else if (units.equalsIgnoreCase("normalized"))
				p = new double[] {pos[0]*sz.width, pos[1]*sz.height, pos[2]*sz.width, pos[3]*sz.height};
			else
			{
				System.out.println("Warning: cannot convert from `" + units + "' units");
				p = (double[])pos.clone();
			}

			if (!toUnits.equalsIgnoreCase("pixels"))
			{
				if (toUnits.equalsIgnoreCase("normalized"))
				{
					p[0] /= sz.width;
					p[2] /= sz.width;
					p[1] /= sz.height;
					p[3] /= sz.height;
				}
			}

			return p;
		}
		else
			System.out.println("Warning: cannot convert position, no control associated with this object");

		return pos;
	}

	public double[] getPosition()
	{
		Component pComp = getParentComponent();
		if (pComp != null)
		{
			double[] pos = Parent.elementAt(0).convertPosition(Position.getArray(), Units.getValue(), "pixels");
			pos[1] = (pComp.getHeight()-pos[1]-pos[3]);
			return pos;
		}
		else
		{
			System.out.println("Warning: cannot compute position of parentless controls");
			return new double[] {0, 0, 0, 0};
		}
	}

	public Component getComponent()
	{
		return panel;
	}

	public Component getParentComponent()
	{
		if (Parent.size() > 0)
		{
			HandleObject obj = Parent.elementAt(0);
			return obj.getComponent();
		}
		else
			return null;
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (panel != null)
		{
			if (p == Units)
			{
				double[] pos = Parent.elementAt(0).convertPosition(Position.getArray(), currentUnits, Units.getValue());
				Position.set(pos, true);
				currentUnits = Units.getValue();
			}
			else if (p == FontUnits)
			{
			}
		}
	}
}
