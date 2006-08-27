
package require BLT
namespace import blt::*

wm deiconify .

set HaveTable [expr [ catch { package require Tktable } ] == 0 ]
set HaveVTK [expr [ string equal [ info commands oct_mtovtk ] {} ] && \
	          [ catch { package require vtk } ] == 0 ]


set Matrix {}
proc undefinedMatrix {} {
    global Matrix
    if { $Matrix != {} && [ oct_matrix $Matrix exists ] } {
	return 0
    } else {
	return 1
    }
}

# ****************** Create graphs ******************************

grid [graph .matrix -height 350 -width 350] -row 0 -column 0 -sticky news
grid [graph .yslice -width 150] -row 0 -column 1 -sticky news
grid [graph .xslice -height 150] -row 1 -column 0 -sticky news
grid rowconfigure    . 0 -weight 1 -minsize 150
grid columnconfigure . 0 -weight 1 -minsize 150
grid rowconfigure    . 1 -weight 0
grid columnconfigure . 1 -weight 0

.xslice element create XSlice -label {} -pix 2 -fill ""
.yslice element create YSlice -label {} -pix 2 -fill "" -mapx x2 -mapy y2

Blt_ZoomStack    .matrix
Blt_Crosshairs   .matrix
Blt_ClosestPoint .matrix

# Use x2-y for the image, x2-y2 for the Y slice and x-y for the X slice
# Fix margin sizes so that scales are commensurate between the graphs
.matrix xaxis configure -hide yes
.matrix x2axis configure -hide no
.yslice yaxis configure -hide yes
.yslice y2axis configure -hide no
.yslice xaxis configure -hide yes
.yslice x2axis configure -hide no
.matrix configure -leftmargin 50 -topmargin 50 -rightmargin 0 -bottommargin 0
.yslice configure -rightmargin 50 -topmargin 50 -leftmargin 0 -bottommargin 0
.xslice configure -leftmargin 50 -bottommargin 50 -rightmargin 0 -topmargin 0

# Turn on grid marks
.matrix grid configure -hide no -dashes { 2 2 }
.xslice grid configure -hide no -dashes { 2 2 } 
.yslice grid configure -hide no -dashes { 2 2 } 

# Define image for matrix rendering
image create photo matrix

# ************** Define configurion control frame *****************

grid [frame .options] -row 0 -column 2 -rowspan 2 -sticky ns
grid columnconfigure . 2 -weight 0

# Add colormap bar
image create photo colorbar
grid [graph .options.colorbar -height 150 -width 80] \
   -row 0 -column 0 -rowspan 10 -sticky ns
.options.colorbar xaxis configure -hide yes

# Add slice locator
grid [label .options.slicelabel -text "Slice Coordinates:"] \
	-column 1 -row 0 -sticky w
grid [label .options.xvalue -text "X = 0"] -column 1 -row 1 -sticky w
grid [label .options.yvalue -text "Y = 0"] -column 1 -row 2 -sticky w

# Add colormap chooser
set colormapChoice {}
radiobutton .options.ocean \
	-variable colormapChoice -text Ocean   -value "-colormap tk_ocean"
radiobutton .options.rainbow \
	-variable colormapChoice -text Rainbow -value "-colormap tk_hsv"
radiobutton .options.custom \
	-variable colormapChoice -text Default -value {}
label .options.colormaplabel -text "Colormap Options:"
grid .options.colormaplabel -column 1 -row 3 -sticky w
grid .options.ocean   -column 1 -row 4 -sticky w
grid .options.rainbow -column 1 -row 5 -sticky w
grid .options.custom  -column 1 -row 6 -sticky w
bind .options.ocean <ButtonPress-1> {
    oct_cmd "tk_ocean = ocean(64);"
    set colormapChoice "-colormap tk_ocean"
    redraw_matrix
}
bind .options.rainbow   <ButtonPress-1> {
    oct_cmd "tk_hsv = rainbow(64);"
    set colormapChoice "-colormap tk_hsv"
    redraw_matrix
}
bind .options.custom    <ButtonPress-1> {
    set colormapChoice {}
    redraw_matrix
}

# Add matrix chooser
label .options.lmatrix -text "Octave Matrix Name :" -anchor w
entry .options.ematrix -textvariable Matrix -relief sunken
grid .options.lmatrix .options.ematrix
bind .options.ematrix <Return> {
    # Update the table with the new matrix dimensions
    redraw_matrix
    updateTable
}


# ************************* Graph interactions ***********************

# Record mouse coordinates when middle mouse button is pressed

set startX 0
set startY 0

proc record_mouse { X Y } {
   if { [undefinedMatrix] } { return }

   global Matrix
   global startX
   global startY
   set startX \
      [expr round([.matrix axis invtransform x2 [expr $X - [winfo rootx .]]])]
   if {$startX < 0} { set startX 0 }
   if {$startX >= [oct_matrix $Matrix cols]} {
      set startX [expr [oct_matrix $Matrix cols] - 1]
   }
   set startY \
      [expr round([.matrix axis invtransform y [expr $Y - [winfo rooty .]]])]
   if {$startY < 0} { set startY 0 }
   if {$startY >= [oct_matrix $Matrix rows]} {
      set startY [expr [oct_matrix $Matrix rows] - 1]
   }
   .options.xvalue configure -text "X = $startX"
   .options.yvalue configure -text "Y = $startY"
   draw_slices
}

bind . <ButtonPress-2> { record_mouse %X %Y }
bind . <B2-Motion>     { record_mouse %X %Y }

# We need to redraw our slices whenever zooming in/out.

bind .matrix <ButtonPress-3> { draw_slices }
bind .matrix <ButtonPress-1> { draw_slices }

# Graph drawing routines

vector x1 y1 x2 y2

proc draw_slices { } {
    if { [undefinedMatrix] } { return }

    global Matrix
    global startX
    global startY
    set minX [lindex [.matrix x2axis limits] 0]
    set maxX [lindex [.matrix x2axis limits] 1]
    set minY [lindex [.matrix yaxis limits] 0]
    set maxY [lindex [.matrix yaxis limits] 1]
    if { $startX >= [oct_matrix $Matrix cols]} {
	set startX [expr [oct_matrix $Matrix cols] - 1]
	.options.xvalue configure -text "X = $startX"
    }
    if { $startY >= [oct_matrix $Matrix rows]} {
	set startY [expr [oct_matrix $Matrix rows] - 1]
	.options.yvalue configure -text "Y = $startY"
    }
    x1 seq 0 [oct_matrix $Matrix cols]   
    x2 seq 0 [oct_matrix $Matrix rows]
    oct_mtov $Matrix y1 0 $startY [oct_matrix $Matrix cols] 1
    oct_mtov $Matrix y2 $startX 0 1 [oct_matrix $Matrix rows]
    .xslice element configure XSlice -xdata x1 -ydata y1
    .yslice element configure YSlice -xdata y2 -ydata x2
    .xslice xaxis configure -min $minX -max $maxX
    .yslice y2axis configure -min $minY -max $maxY
}

proc redraw_matrix { } {
    if {[undefinedMatrix]} { 
	if [ .matrix marker exists matrix ] {
	    .matrix marker delete
	}
	return 
    }

    global Matrix
    global colormapChoice
    
    # Find limits for the matrix value
    set MatrixRows [oct_matrix $Matrix rows]
    set MatrixCols [oct_matrix $Matrix cols]
    set MatrixMin  [oct_matrix $Matrix min]
    set MatrixMax  [oct_matrix $Matrix max]
    
    # Convert the matrix into an image and paste it into the graph
    matrix configure -data "$Matrix $colormapChoice"
    .matrix x2axis configure -min 0 -max $MatrixCols
    .matrix yaxis configure -min 0 -max $MatrixRows
    .matrix marker create image -name matrix -image matrix \
	    -coords "0 0 $MatrixCols $MatrixRows" -mapx x2 -under 1
    
    # Fix the limits on the X/Y slices so that they will work for any slice
    # Draw the current slice
    .xslice yaxis configure -min $MatrixMin -max $MatrixMax
    .yslice x2axis configure -min $MatrixMin -max $MatrixMax
    draw_slices
    
    # Draw the new colorbar for the given colormap choice
    # This converts the simple range stored in the octave variable 
    # "colorbar" into an image and pastes it into the colorbar graph.
    colorbar configure -data "colorbar $colormapChoice"
    .options.colorbar yaxis configure -min $MatrixMin -max $MatrixMax
    .options.colorbar marker create image -name colorbar \
	    -image colorbar -coords \
	    "0 $MatrixMin 1 $MatrixMax"
}



# ******************* Table commands **************************
proc updateTable {} {
    global Matrix
    if [ winfo exists .table.t ] {
	if { [undefinedMatrix] } {
	    .table.t config -rows 1 -cols 1
	} else {
	    .table.t config -rows [oct_matrix $Matrix rows] \
		    -cols [oct_matrix $Matrix cols]
	}
    }
}

proc toggleTable {} {
    if [ winfo exists .table ] {
	destroy .table
    } else {
	createTable
    }
}

proc tableCommand { Row Col Set Value } {
    global Matrix
    if {$Set} {
	oct_cmd "$Matrix\($Row,$Col\)=$Value;"
	redraw_matrix
    } else {
	if { $Row == 0 && $Col == 0 } {
	    if { $Matrix == "" } {
		return "<none>"
	    } else {
		return $Matrix
	    }
	} elseif { $Row == 0 } {
	    return $Col
	} elseif { $Col == 0 } {
	    return $Row
	} else {
	    return [oct_matrix $Matrix elem [expr $Row-1] [expr $Col-1] ]
	}
    }
}

proc createTable {} {
    # ********************* Create data display table ******************
    toplevel .table
    wm title .table "TK Octave Data"
    table .table.t \
	    -xscrollcommand {.table.x set} -yscrollcommand {.table.y set} \
	    -height 10 -width 6 -titlerows 1 -titlecols 1 -rows 1 -cols 1 \
	    -command { tableCommand %r %c %i %s } -usecommand true
    scrollbar .table.y -orient v -command [list .table.t yview]
    scrollbar .table.x -orient h -command [list .table.t xview]
    grid .table.t -row 0 -column 0 -sticky news
    grid .table.y -row 0 -column 1 -sticky ns
    grid .table.x -row 1 -column 0 -sticky ew
    grid rowconfig    .table 0 -weight 1
    grid columnconfig .table 0 -weight 1
    grid rowconfig    .table 1 -weight 0
    grid columnconfigure .table 1 -weight 0
    updateTable
}

bind . <Destroy> { catch { if {%W = "."} { oct_quit } } }


# ******************* Create Octave Interactor *********************

catch {unset octInteract.bold}
catch {unset octInteract.normal}
catch {unset octInteract.tagcount}
set octInteractBold "-background #43ce80 -foreground #221133 -relief raised -borderwidth 1"
set octInteractNormal "-background #dddddd -foreground #221133 -relief flat"
set octInteractTagcount 1
set octInteractCommandList ""
set octInteractCommandIndex 0

proc do_oct {s w} {
   global octInteractBold octInteractNormal octInteractTagcount
   global octInteractCommandList octInteractCommandIndex

   set c "oct_cmd \{$s\}"
   set tag [append tagnum $octInteractTagcount]
   set octInteractCommandIndex $octInteractTagcount
   incr octInteractTagcount 1
   .octInteract.display.text configure -state normal
   .octInteract.display.text insert end $s $tag
   set octInteractCommandList [linsert $octInteractCommandList end $s]
   eval .octInteract.display.text tag configure $tag $octInteractNormal
   .octInteract.display.text tag bind $tag <Any-Enter> \
   ".octInteract.display.text tag configure $tag $octInteractBold"
   .octInteract.display.text tag bind $tag <Any-Leave> \
   ".octInteract.display.text tag configure $tag $octInteractNormal"
   .octInteract.display.text tag bind $tag <1> "do_oct [list $s] .octInteract"
   .octInteract.display.text insert end \n;
   .octInteract.display.text insert end [uplevel 1 $c]
   .octInteract.display.text insert end \n\n
   .octInteract.display.text configure -state disabled
   .octInteract.display.text yview end
}

catch {destroy .octInteract}

#toplevel .octInteract -bg #bbbbbb
#wm title .octInteract "tk_octave interactor"
grid [frame .octInteract -bg #bbbbbb] -row 2 -column 0 \
	-columnspan 3 -sticky news

grid columnconfigure .octInteract 0 -weight 1
grid rowconfigure    .octInteract 3 -weight 1

# Command input
frame .octInteract.file -bg #bbbbbb
grid columnconfigure .octInteract.file 1 -weight 1
label .octInteract.file.label -text "Command:" -width 10 -anchor w \
    -bg #bbbbbb -fg #221133
entry .octInteract.file.entry -width 40 \
    -bg #dddddd -fg #221133 -highlightthickness 1 -highlightcolor #221133
bind .octInteract.file.entry <Return> {
   do_oct [%W get] .octInteract; %W delete 0 end}
grid .octInteract.file.label -row 0 -column 0 -sticky w
grid .octInteract.file.entry -row 0 -column 1 -sticky news
grid .octInteract.file -row 0 -column 0 -sticky news

# Command output
frame .octInteract.display -bg #bbbbbb
grid columnconfigure .octInteract.display 0 -weight 1
text .octInteract.display.text -yscrollcommand \
   ".octInteract.display.scroll set" \
   -setgrid true -width 60 -height 8 -wrap word -bg #dddddd -fg #331144 \
   -state disabled
scrollbar .octInteract.display.scroll \
    -command ".octInteract.display.text yview" -bg #bbbbbb \
    -troughcolor #bbbbbb -activebackground #cccccc -highlightthickness 0
grid .octInteract.display.text   -row 0 -column 0 -sticky news
grid .octInteract.display.scroll -row 0 -column 1 -sticky ns
grid .octInteract.display -row 1 -column 0 -sticky news -columnspan 2


# Keyboard control for command history

bind [winfo toplevel .octInteract] <Down> {
   if { $octInteractCommandIndex < [expr $octInteractTagcount - 1] } {
      incr octInteractCommandIndex
      set command_string \
         [lindex $octInteractCommandList $octInteractCommandIndex]
      .octInteract.file.entry delete 0 end
      .octInteract.file.entry insert end $command_string
   } elseif {
      $octInteractCommandIndex == [expr $octInteractTagcount - 1] } {
      .octInteract.file.entry delete 0 end
   }
}

bind [winfo toplevel .octInteract] <Up> {
   if { $octInteractCommandIndex > 0 } {
      set octInteractCommandIndex [expr $octInteractCommandIndex - 1]
      set command_string \
         [lindex $octInteractCommandList $octInteractCommandIndex]
      .octInteract.file.entry delete 0 end
      .octInteract.file.entry insert end $command_string
   }
}

# Control buttons
frame .octInteract.buttons
button .octInteract.buttons.quit -text Quit  -command oct_quit \
   -bg #bbbbbb -fg #221133 -activebackground #cccccc -activeforeground #221133
pack .octInteract.buttons.quit -side left -expand true -fill x
if { $HaveTable } {
    button .octInteract.buttons.table -text Table -command toggleTable \
	    -bg #bbbbbb -fg #221133 \
	    -activebackground #cccccc -activeforeground #221133
    pack .octInteract.buttons.table -side left -expand true -fill x
}
if { $HaveVTK } {
    button .octInteract.buttons.render -text Render -command vtk_render \
	    -bg #bbbbbb -fg #221133 -activebackground #cccccc -activeforeground #221133
    pack .octInteract.buttons.render -side left -expand true -fill x
}

grid .octInteract.buttons -row 2 -column 0 -sticky ew -columnspan 2


# ************************ VTK test stuff ******************************


proc vtk_render { } {
   if {[undefinedMatrix]} { return }

   global Matrix

   catch { iren Disable }
   catch { ren RemoveActor carpet }
   catch { surface Delete }
   catch { warp Delete }
   catch { mapper Delete }
   catch { carpet Delete }
   catch { ren Delete }
   catch { iren Delete }
   catch { vtkTkRenderWidget .octInteract.window }
   grid .octInteract.window -row 3 -column 0 -columnspan 2 -sticky news

   oct_mtovtk $Matrix surface
   vtkWarpScalar warp
   warp SetInput surface
   warp XYPlaneOn
   warp SetScaleFactor 0.5
   vtkDataSetMapper mapper
   mapper SetInput [warp GetOutput]
   mapper SetScalarRange \
      [lindex [surface GetScalarRange] 0] [lindex [surface GetScalarRange] 1]
   vtkActor carpet
   carpet SetMapper mapper
   vtkRenderer ren
   ren AddActor carpet
   ren SetBackground 1 1 1
   set renWin [.octInteract.window GetRenderWindow]
   $renWin AddRenderer ren
   $renWin SetSize 300 300
   vtkRenderWindowInteractor iren
   iren SetRenderWindow $renWin
   $renWin Render
   iren Initialize
   iren Enable
   iren Start
}

