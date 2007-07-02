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

import java.util.*;
import javax.swing.UIManager;

public class RootObject extends HandleObject
{
	private static RootObject instance = null;

	/* properties */
	HandleObjectListProperty CurrentFigure;

	private RootObject()
	{
		super(null, 0, "root");

		CurrentFigure = new HandleObjectListProperty(this, "CurrentFigure", 1);

		listen(CurrentFigure);
	}

	public static RootObject getInstance()
	{
		if (instance == null)
		{
			instance = new RootObject();
			instance.validate();
			try
			{
				UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
			}
			catch (Exception e)
			{
				System.out.println("Warning: unable to initialize Swing look and feel");
			}
		}
		return instance;
	}

	public int createNewFigure()
	{
		return createNewFigure(getUnusedFigureNumber());
	}

	public int createNewFigure(int fignum)
	{
		if (fignum > 0 && !isHandle(fignum))
			new FigureObject(fignum);
		return fignum;
	}

	public void removeChild(HandleObject child)
	{
		if (CurrentFigure.size() > 0 && CurrentFigure.elementAt(0) == child)
			CurrentFigure.removeAllElements();
		super.removeChild(child);
		if (CurrentFigure.size() == 0 && Children.size() > 0)
			CurrentFigure.addElement(Children.elementAt(0));
	}

	public FigureObject findFigure(int fignum)
	{
		Iterator it = Children.iterator();
		while (it.hasNext())
		{
			FigureObject fig = (FigureObject)it.next();
			if (fig.getHandle() == fignum)
				return fig;
		}
		return null;
	}

	public int getUnusedFigureNumber()
	{
		for (int i=1; i<999; i++)
			if (!isHandle(i))
				return i;
		return -1;
	}

	public double[][] defaultColorMap()
	{
		double[][] cmap = new double[64][3];
		double dx = 0.0625;
		int index = 0;

		for (double cval=0.5+dx; cval<=1.0; cval+=dx, index++)
			cmap[index][2] = cval;
		for (double cval=dx; cval<=1.0; cval+=dx, index++)
		{
			cmap[index][1] = cval;
			cmap[index][2] = 1.0;
		}
		for (double cval=dx; cval<=1.0; cval+=dx, index++)
		{
			cmap[index][0] = cval;
			cmap[index][1] = 1.0;
			cmap[index][2] = 1.0-cval;
		}
		for (double cval=dx; cval<=1.0; cval+=dx, index++)
		{
			cmap[index][0] = 1.0;
			cmap[index][1] = 1.0-cval;
		}
		for (double cval=dx; cval<=0.5; cval+=dx, index++)
			cmap[index][0] = 1.0-cval;

		return cmap;
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == CurrentFigure)
		{
			if (CurrentFigure.size() > 0)
				if (CurrentFigure.elementAt(0) == this)
					CurrentFigure.removeAllElements();
				else
					((FigureObject)CurrentFigure.elementAt(0)).activate();
		}
	}
}
