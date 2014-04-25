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
with Ada.Characters.Latin_1;
with Ada.Text_IO;

with System;

with Lumen.Shader;
with Lumen.Program;

package body GUI is

  ---------------------------------------------------------------------------

  package ASCII renames Ada.Characters.Latin_1;
  package TIO renames Ada.Text_IO;

  ---------------------------------------------------------------------------

  use type Box_Vectors.Vector;

  ---------------------------------------------------------------------------
  -- Create shader program for box.
  procedure Create_Program (Program: in out GL.UInt)
  is
    -------------------------------------------------------------------------
    -- Helper function that creates Vertex shader program.
    function Vertex_Shader return String
    is
    begin
      return  "#version 330" & ASCII.LF &
              "layout (location = 0) in vec3 Position;" & ASCII.LF &
              "void main (void) {" & ASCII.LF &
              "gl_Position = vec4 (Position, 1.0);" & ASCII.LF &
              "}" & ASCII.LF;
    end Vertex_Shader;

    -------------------------------------------------------------------------
    -- Helper function that creates Fragment shader program.
    function Fragment_Shader return String
    is
    begin
      return  "#version 330" & ASCII.LF &
              "out vec4 FragColor;" & ASCII.LF &
              "void main (void) {" & ASCII.LF &
              "FragColor = vec4 (0.0, 1.0, 0.0, 0.0);" & ASCII.LF &
              "}" & ASCII.LF;
    end Fragment_Shader;

    -------------------------------------------------------------------------
    -- Helper procedure for loading and compiling shaders and checking errors.
    procedure Add_Shader
      ( Shader_Program: in GL.UInt;
        Source        : in String;
        Shader_Type   : in GL.Enum
      )
    is
      Shader_Error  : exception;
      Shader_Object : GL.UInt;
      Success       : Boolean := False;
      V             : constant Boolean := Shader_Type = GL.GL_VERTEX_SHADER;
    begin
      Shader.From_String (Shader_Type, Source, Shader_Object, Success);

      if not Success then
        raise Shader_Error with "Failed to load shader." & Boolean'Image (V);
      end if;

      GL.Compile_Shader (Shader_Object);
      GL.Attach_Shader  (Shader_Program, Shader_Object);
    end Add_Shader;

    -------------------------------------------------------------------------
    -- Exceptions.
    Link_Error      : exception;
    Validate_Error  : exception;

    -------------------------------------------------------------------------
    -- Variables.
    Success : Boolean := False;

  begin
    Program := GL.Create_Program;

    Add_Shader (Program, Vertex_Shader, GL.GL_VERTEX_SHADER);
    Add_Shader (Program, Fragment_Shader, GL.GL_FRAGMENT_SHADER);

    GL.Link_Program (Program);
    GL.Get_Program  (Program, GL.GL_LINK_STATUS, Success'Address);
    if not Success then
      raise Link_Error with Lumen.Program.Get_Info_Log (Program);
    end if;

    GL.Validate_Program (Program);
    GL.Get_Program (Program, GL.GL_VALIDATE_STATUS, Success'Address);
    if not Success then
      raise Validate_Error with Lumen.Program.Get_Info_Log (Program);
    end if;
  end Create_Program;

  ---------------------------------------------------------------------------

  procedure Create_Box
    ( Win   : in Window.Window_Handle;
      Pos   : in Coord2D; -- Position of lower-left corner of this box
      Size  : in Coord2D; -- Dimensions of box
      Color : in GL.UInt;
      Boxes : in out Boxes_Type
    )
  is

    pragma Unreferenced (Color);

    -------------------------------------------------------------------------
    -- Helper function.
    function Compute_Vertices (Pos, Size: in Coord2D) return Floats
    is
      X: constant Float :=
        ((Float (Pos.Y) / Float (Window.Width  (Win))) * 2.0) - 1.0;
      Y: constant Float :=
        ((Float (Pos.Y) / Float (Window.Height (Win))) * 2.0) - 1.0;

      S: constant Float :=
        ((Float (Size.X) / Float (Window.Width (Win))) * 2.0);
      T: constant Float :=
        ((Float (Size.Y) / Float (Window.Height (Win))) * 2.0);

      Result: Floats (1 .. 3 * 4) := (others => 0.0);
    begin -- Order: lower left, lower right, upper right, upper left.
      Result (1) := X;
      Result (2) := Y;

      Result (4) := X + S;
      Result (5) := Y;

      Result (7) := X + S;
      Result (8) := Y + T;

      Result (10) := X;
      Result (11) := Y + T;

      return Result;
    end Compute_Vertices;

    Var: Box;
  begin
    Var.Vertices := Compute_Vertices (Pos, Size);
    if Boxes.Container.Is_Empty then
      Var.Attrib := 0;
    else
      Var.Attrib  := Box_Vectors.Last_Element (Boxes.Container).Attrib + 1;
    end if;

    GL.Gen_Buffers (1, Var.VBO'Address);
    GL.Bind_Buffer (GL.GL_ARRAY_BUFFER, Var.VBO);
    GL.Buffer_Data
      ( GL.GL_ARRAY_BUFFER,
        Var.Vertices'Length * (Float'Size / 8),
        Var.Vertices'Address,
        GL.GL_STATIC_DRAW
      );

    GL.Gen_Buffers (1, Var.IBO'Address);
    GL.Bind_Buffer (GL.GL_ELEMENT_ARRAY_BUFFER, Var.IBO);
    GL.Buffer_Data
      ( GL.GL_ELEMENT_ARRAY_BUFFER,
        Var.Indices'Length * (GL.UInt'Size / 8),
        Var.Indices'Address,
        GL.GL_STATIC_DRAW
      );

    Create_Program (Var.Program);
    GL.Use_Program (Var.Program);

    -- FIXME: Index may need to be different for each box.
    GL.Enable_Vertex_Attrib_Array (Var.Attrib);
    GL.Bind_Buffer (GL.GL_ARRAY_BUFFER, Var.VBO);
    GL.Vertex_Attrib_Pointer
      ( 0,
        3,
        GL.GL_FLOAT,
        GL.GL_FALSE,
        0,
        System'To_Address (0)
      );
    GL.Disable_Vertex_Attrib_Array (Var.Attrib);

    Boxes.Container.Append (Var);
  exception
    when Storage_Error =>
      TIO.Put_Line ("Error when creating box");
      raise Storage_Error;
  end Create_Box;

  ---------------------------------------------------------------------------

  procedure Init
  is
  begin
    GL.Clear_Color (0.0, 0.0, 0.0, 1.0);
    TIO.Put_Line ("GUI.Init was successful.");
  end Init;

  ---------------------------------------------------------------------------

  procedure Draw (Win: in Window.Window_Handle; Boxes: in Boxes_Type)
  is
    procedure Process (Cursor: in Box_Vectors.Cursor)
    is
      Attrib: constant GL.UInt := Box_Vectors.Element (Cursor).Attrib;
      Size  : constant Integer := Box_Vectors.Element (Cursor).Vertices'Length;
      Program : constant GL.UInt := Box_Vectors.Element (Cursor).Program;
    begin
      GL.Enable_Vertex_Attrib_Array (Attrib);
      GL.Draw_Elements
        ( GL.GL_TRIANGLES,
          Size,
          GL.GL_UNSIGNED_INT,
          System'To_Address (0)
        );
      GL.Disable_Vertex_Attrib_Array (Attrib);

      Window.Swap (Win);
      --GL.Use_Program (Program);

      TIO.Put_Line ("it works");
    exception
      when Storage_Error =>
        TIO.Put_Line
          ( "Error at Draw for Box " &
            GL.UInt'Image (Box_Vectors.Element (Cursor).Attrib)
          );
        raise Storage_Error;
    end Process;
  begin
    GL.Clear (GL.GL_COLOR_BUFFER_BIT);

    Boxes.Container.Iterate (Process'Access);

    Window.Swap (Win);
  end Draw;

  ---------------------------------------------------------------------------

end GUI;
