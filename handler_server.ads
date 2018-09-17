with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Hash_Maps_G;
with Ordered_Maps_G;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Ada.Command_Line;

package Handler_Server is

package LLU renames Lower_Layer_UDP;
package ASU renames Ada.Strings.Unbounded;
package AC renames Ada.Calendar;

	Type Value is record
		EP: LLU.End_Point_Type;
		Hour: AC.Time;
	end record;


	type Maps_Range is mod 50;
	function Hash_Numb (Key : ASU.Unbounded_String) return Maps_Range;

	Users: Natural := Integer'Value(Ada.Command_Line.Argument(2));

	--clientes activos
	package Maps is new Hash_Maps_G(Key_Type => ASU.Unbounded_String,
					Value_Type => Value,
					"="        => ASU."=",
					Hash_Range => Maps_Range,
					Hash => Hash_Numb,
					Max => Users);
	
	--clientes viejos
	package Maps_Old is new Ordered_Maps_G (Key_Type => ASU.Unbounded_String,
					Value_Type => AC.Time,
					"="	=> ASU."=",
					"<" => ASU."<",
					Max_Users => 150);				
	
	
	Client_List: Maps.Map;
	Old_List: Maps_Old.Map;

	procedure Server_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type);
			     
end Handler_Server;
