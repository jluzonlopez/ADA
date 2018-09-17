with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Unchecked_Deallocation;
with chat_messages;
with Ada.Command_Line;
with Handler_Server;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Hash_Maps_G;
with Ordered_Maps_G;

procedure Chat_Server_2 is

	package AC renames Ada.Calendar;
	package ACL renames Ada.Command_Line;
	package ATI renames Ada.Text_IO;
	package CM renames chat_messages;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
	use type CM.Message_Type;
	
	
	function Time_Image (T: AC.Time) return String is 
	begin
		return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
	end Time_Image; 

	procedure Print_Active_Clients(M: Handler_Server.Maps.Map) is 
		Curs: Handler_Server.Maps.Cursor := Handler_Server.Maps.First(M);
		EP: ASU.Unbounded_String;
		N: Natural;
		Num_Client_Print : Integer:= 0;	
	begin	
		ATI.Put_Line ("========");
	 	while Handler_Server.Maps.Has_Element(Curs) and Num_Client_Print /= Handler_Server.Maps.Map_Length(M) loop
			EP := ASU.To_Unbounded_String(LLU.Image(Handler_Server.Maps.Element(Curs).Value.EP));
			N := ASU.Index(EP,"S")+1;
			EP := ASU.Tail(EP,ASU.Length(EP)-N);	
			ATI.Put(ASU.To_String(Handler_Server.Maps.Element(Curs).Key) & " " & ASU.To_String(EP));
			ATI.Put_Line(", " & Time_Image(Handler_Server.Maps.Element(Curs).Value.Hour));
			Num_Client_Print := Num_Client_Print+1;
         	Handler_Server.Maps.Next(Curs);
      	end loop;
	end Print_Active_Clients;


	procedure Print_Old_Clients(M: Handler_Server.Maps_Old.Map) is 
		Curs: Handler_Server.Maps_Old.Cursor := Handler_Server.Maps_Old.First(M);
	begin	
		ATI.Put_Line ("========");
	 	while Handler_Server.Maps_Old.Has_Element(Curs) loop	
			ATI.Put(ASU.To_String(Handler_Server.Maps_Old.Element(Curs).Key));
			ATI.Put_Line(": " & Time_Image(Handler_Server.Maps_Old.Element(Curs).Value));
         	Handler_Server.Maps_Old.Next(Curs);
      	end loop;
	end Print_Old_Clients;


	Server: ASU.Unbounded_String;
	Dir_IP_Server: ASU.Unbounded_String;
	Server_EP: LLU.End_Point_Type;
	Puerto: Integer;
	Chat_Max_Users: Integer;
	Nick: ASU.Unbounded_String;
	Message: ASU.Unbounded_String;
	C: Character;
		
begin
	ATI.Put_Line ("Welcome to Chat_Server");
	--construyes un EP donde esta el servidor
	Server := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	Dir_IP_Server:= ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Server)));
	--Meter con un argumento
	Puerto:= Integer'Value(ACL.Argument(1));
	Chat_Max_Users:= Integer'Value(ACL.Argument(2));
	Server_EP:= LLU.Build(ASU.To_String(Dir_IP_Server),Puerto);
	LLU.Bind(Server_EP,Handler_Server.Server_Handler'Access);
	loop
	--meter las opciones de la linea de comandos
		ATI.Get_Immediate(C);
		if C = 'l' or C = 'L' then
			ATI.Put_Line("ACTIVE CLIENTS");
			Print_Active_Clients(Handler_Server.Client_List);
		elsif C = 'o' or C = 'O' then
			ATI.Put_Line("OLD CLIENTS");
			Print_Old_Clients(Handler_Server.Old_List);
		end if;
	end loop;


end Chat_Server_2;
