pragma License (GPL);
------------------------------------------------------------------------------
-- EMAIL: <darkestkhan@gmail.com>                                           --
-- License: Modified GNU GPLv3 or any later as published by Free Software   --
--  Foundation (GMGPL, see COPYING file).                                   --
--                                                                          --
--                    Copyright © 2014 darkestkhan                          --
------------------------------------------------------------------------------
--  This Program is Free Software: You can redistribute it and/or modify    --
--  it under the terms of The GNU General Public License as published by    --
--    the Free Software Foundation: either version 3 of the license, or     --
--                 (at your option) any later version.                      --
--                                                                          --
--      This Program is distributed in the hope that it will be useful,     --
--      but WITHOUT ANY WARRANTY; without even the implied warranty of      --
--      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the        --
--              GNU General Public License for more details.                --
--                                                                          --
--    You should have received a copy of the GNU General Public License     --
--   along with this program.  If not, see <http://www.gnu.org/licenses/>.  --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
------------------------------------------------------------------------------
with Ada.Containers.Vectors;

with Lumen;
with Lumen.Window;
with Lumen.GL;
use Lumen;
package GUI is

  ---------------------------------------------------------------------------

  type Coord2D is
  record
    X: Natural;
    Y: Natural;
  end record;

  type Boxes_Type is limited private;

  ---------------------------------------------------------------------------
  -- Initialize OpenGL.
  procedure Init;

  ---------------------------------------------------------------------------
  -- Procedure that generates all needed vertex data to draw box.
  -- FIXME: coords have to be translated for box to be placed correctly
  procedure Create_Box
    ( Win   : in Window.Window_Handle;
      Pos   : in Coord2D; -- Position of lower-left corner of this box
      Size  : in Coord2D; -- Dimensions of box
      Color : in GL.UInt;
      Boxes : in out Boxes_Type
    );

  ---------------------------------------------------------------------------
  -- Actually perform drawing.
  procedure Draw
    ( Win : in Window.Window_Handle; Boxes: in Boxes_Type );

  ---------------------------------------------------------------------------

private

  ---------------------------------------------------------------------------

  type Floats is array (GL.UInt range <>) of Float;
  type UInts  is array (GL.UInt range <>) of GL.UInt;

  use type GL.UInt;

  type Box is
  record
    Vertices: Floats  (1 .. 3 * 4); -- Coordinates of vertices.
    Indices : UInts   (1 .. 6) := (0, 1, 2, 2, 3, 0);
    Program : GL.UInt;
    VBO     : GL.UInt;
    IBO     : GL.UInt;
    Attrib  : GL.UInt;
  end record;

  package Box_Vectors is new Ada.Containers.Vectors (Positive, Box);

  type Boxes_Type is
  record
    Container: Box_Vectors.Vector := Box_Vectors.Empty_Vector;
  end record;

  ---------------------------------------------------------------------------

end GUI;
