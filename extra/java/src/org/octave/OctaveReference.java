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
		//System.out.println("OctaveReference::invoke");
		Octave.doInvoke(this.ID, args);
		return null;
	}

	public synchronized Object invokeAndWait(Object[] args)
	{
		//System.out.println("OctaveReference::invokeandWait");
		Octave.invokeAndWait(this, args);
		return null;
	}
}
