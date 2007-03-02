package org.octave;

public class Octave
{
  static
  {
    System.load (System.getProperty ("octave.java.path") + java.io.File.separator + "__java__.oct");
  }

  public native static boolean call (String name, Object[] argin, Object[] argout);

  public static Object do_test (String name, Object arg0) throws Exception
    {
      Object[] argin = new Object[] { arg0 };
	  Object[] argout = new Object[1];
      if (call (name, argin, argout))
        return argout[0];
      throw new Exception ("octave call failed");
    }
}
