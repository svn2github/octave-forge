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

public class Edit2Control
	extends JScrollPane
	implements UIControl, KeyListener, HandleNotifier.Sink
{
	UIControlObject uiObj;
	HandleNotifier uiNotifier;
	JTextPane text;

	public Edit2Control(UIControlObject obj)
	{
		super(new JTextPane());
		text = (JTextPane)getViewport().getView();
		text.addKeyListener(this);
		uiObj = obj;

		setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		setAlignment();
		text.setText(obj.UIString.toString());
		setBackground(obj.BackgroundColor.getColor());
		setForeground(obj.ForegroundColor.getColor());

		uiNotifier = new HandleNotifier();
		uiNotifier.addSink(this);
		uiNotifier.addSource(obj.UIString);
		uiNotifier.addSource(obj.HorizontalAlignment);
		uiNotifier.addSource(obj.BackgroundColor);
		uiNotifier.addSource(obj.ForegroundColor);
	}

	public void setAlignment()
	{
		MutableAttributeSet s = new SimpleAttributeSet();
		s.addAttribute(
			StyleConstants.Alignment,
			new Integer(
				(uiObj.HorizontalAlignment.is("left") ? StyleConstants.ALIGN_LEFT :
				 uiObj.HorizontalAlignment.is("center") ? StyleConstants.ALIGN_CENTER :
				 uiObj.HorizontalAlignment.is("right") ? StyleConstants.ALIGN_RIGHT :
				 StyleConstants.ALIGN_LEFT)));
		StyledDocument doc = text.getStyledDocument();

		doc.setParagraphAttributes(0, doc.getLength()+1, s, false);
	}

	/* UIControl interface */

	public void update()
	{
		uiObj.UIString.reset(text.getText());
	}

	public JComponent getComponent()
	{
		return text;
	}

	public void dispose()
	{
		uiNotifier.removeSink(this);
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

	/* HandleNofitier.Sink interface */

	public void addNotifier(HandleNotifier n) {}

	public void removeNotifier(HandleNotifier n) {}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == uiObj.UIString)
			text.setText(uiObj.UIString.toString());
		else if (p == uiObj.HorizontalAlignment)
			setAlignment();
		else if (p == uiObj.BackgroundColor)
			setBackground(uiObj.BackgroundColor.getColor());
		else if (p == uiObj.ForegroundColor)
			setForeground(uiObj.ForegroundColor.getColor());
	}
}
