/**
 *
 * A class to hold a TeX character code -> Unicode translation pair.
 *
 * <p>Copyright (c) 2010 Martin Hepperle</p>
 *
 * @author Martin Hepperle
 * @version 1.0
 */
package org.octave;

public class TeXcode
{
   protected String tex;
   protected char ucode;

   public TeXcode ( String t, char u )
   {
      tex = t;
      ucode = u;
   }
}
