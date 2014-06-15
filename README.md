import tool for IgorPro
=======================

General import tool for IgorPro for importing data files from different hardware/software

**Supported formats**:

  - SpecsLab2 *.xml and *.xy
  - SpecsLab1 *.exp
  - Kratos Vision *.dset
  - Gwyddion 2.x *.gwy
  - Omicron SCALA *.par
  - Nanotec WSxM *.stp
  - Veeco *.hdf
  - Spectra *.#

**Installation**:

Copy the "Igor Procedures" folder to:
  - Mac OS X: 	``/Users/<user>/Documents/WaveMetrics/Igor Pro 6 User Files/``
  - Windows: 	``<My Documents>\WaveMetrics\Igor Pro 6 User Files\``


**Howto**:

There are several ways to use the file loader:
	- Call each procedure through the macro menu to load a single file 
	- Use the multi file loader (macro menu) to change the flags and load multiple files at once
	- Call the procedures (''<name>_load_data()'') directly through the command window without parsing a parameter to load a single file
	- Call the procedures and parse an optional file ref (''<name>_load_data(optfile=<fileref>)'')

**Configuration**:

In order to change the behaviour of the import tool change the settings (importflags) in ``import_loader.ipf``.

**Authors**
  - Matthias Richter richtmat@yahoo.co.uk

**Credits**:
  - Parts of the procedures are based on xylib by Marcin Wojdyr
