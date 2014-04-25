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
with Lumen;
with Lumen.Window;
use Lumen;

with GUI;
procedure Check is

  Win: Window.Window_Handle;

  Boxes: GUI.Boxes_Type;

begin
  Window.Create (Win, Width => 640, Height => 480, Name => "check");
  Window.Make_Current (Win);
  GUI.Init;
  GUI.Create_Box (Win, GUI.Coord2D'(0, 0), GUI.Coord2D'(319, 479), 0, Boxes);
  GUI.Create_Box (Win, GUI.Coord2D'(450, 450), GUI.Coord2D'(49, 49), 0, Boxes);

  while Window.Process_Events (Win) loop
    GUI.Draw (Win, Boxes);
    delay 1.0;
  end loop;
end Check;
