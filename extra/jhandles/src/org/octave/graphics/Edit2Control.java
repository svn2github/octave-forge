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
import java.awt.event.*;
import javax.swing.*;
import javax.swing.text.*;

public class Edit2Control extends JScrollPane implements UIControl, KeyListener
{
	UIControlObject uiObj;
	JTextPane text;

	public Edit2Control(UIControlObject obj)
	{
		super(new JTextPane());
		text = (JTextPane)getViewport().getView();
		text.addKeyListener(this);
		uiObj = obj;

		setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
	}

	public void setFont(Font f) { super.setFont(f); if (text != null) text.setFont(f); }
	public void setBackground(Color c) { super.setBackground(c); if (text != null) text.setBackground(c); }
	public void setForeground(Color c) { super.setForeground(c); if (text != null) text.setForeground(c); }

	/* UIControl interface */

	public void update(int mode)
	{
		if ((mode & UPDATE_OBJECT) != 0)
		{
			uiObj.UIString.reset(text.getText());
		}
	}

	public Component getComponent()
	{
		return this;
	}

	public void setString(String s)
	{
		text.setText(s);
	}

	public void setAlignment(int align)
	{
		MutableAttributeSet s = new SimpleAttributeSet();
		s.addAttribute(
			StyleConstants.Alignment,
			new Integer(
				(align == JTextField.LEFT ? StyleConstants.ALIGN_LEFT :
				 align == JTextField.CENTER ? StyleConstants.ALIGN_CENTER :
				 align == JTextField.RIGHT ? StyleConstants.ALIGN_RIGHT :
				 StyleConstants.ALIGN_LEFT)));
		StyledDocument doc = text.getStyledDocument();

		doc.setParagraphAttributes(0, doc.getLength()+1, s, false);
	}

	public void setTooltip(String s)
	{
		text.setToolTipText(s);
	}

	/* KeyListener interface */

	public void keyPressed(KeyEvent event)
	{
	}
	
	public void keyReleased(KeyEvent event)
	{
	}
	
	public void keyTyped(KeyEvent event)
	{
		if (event.getKeyChar() == '\n' && event.getModifiers() == InputEvent.CTRL_MASK)
			uiObj.controlActivated(new UIControlEvent(this));
	}
}
