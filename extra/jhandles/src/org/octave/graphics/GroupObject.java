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

import java.util.*;

public class GroupObject extends GraphicObject
{
	public GroupObject(HandleObject parent)
	{
		super(parent, "hggroup");
	}

	public void draw(Renderer r)
	{
		Iterator it = Children.iterator();
		while (it.hasNext())
		{
			GraphicObject obj = (GraphicObject)it.next();
			obj.draw(r);
		}
	}

	public void validate()
	{
		Iterator it = Children.iterator();
		while (it.hasNext())
			((HandleObject)it.next()).validate();
		super.validate();
	}
}
