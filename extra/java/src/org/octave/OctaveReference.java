package org.octave;

public class OctaveReference
{
	static
	{
		System.load (System.getProperty ("octave.java.path") + java.io.File.separator + "__java__.oct");
	}
  
	private int ID;

	public OctaveReference(int ID)
	{
		this.ID = ID;
	}

	private native static void doFinalize(int ID);
	private native static Object doInvoke(int ID, Object[] args);

	protected void finalize() throws Throwable
	{
		doFinalize(this.ID);
	}

	public String toString()
	{
		return ("<octave reference " + this.ID + ">");
	}

	public int getID()
	{
		return this.ID;
	}

	public Object invoke(Object[] args)
	{
		return doInvoke(this.ID, args);
	}
}
