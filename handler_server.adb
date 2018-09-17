with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Unchecked_Deallocation;
with chat_messages;
with Ada.Command_Line;
with Ada.Calendar;
with Ordered_Maps_G;

package body Handler_Server is

	package ATI renames Ada.Text_IO;
	package CM renames chat_messages;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type AC.Time;
	use type LLU.End_Point_Type;


	function Hash_Numb (Key : ASU.Unbounded_String) return Maps_Range is
		Rang: Maps_Range:= 0;	
	begin
		for i in 1..ASU.Length(Key) loop
			Rang := Maps_Range'Mod(Character'Pos(ASU.To_String(Key)(i))+Integer(Rang));
		end loop;
		return Rang;
	end Hash_Numb;
	
	procedure Server_Handler (From: in LLU.End_Point_Type;
						To: in LLU.End_Point_Type;
						P_Buffer: access LLU.Buffer_Type) is
		
	
	Client_EP_Receive:LLU.End_Point_Type;
	Client_EP_Handler:LLU.End_Point_Type;
	Type_Mess: CM.Message_Type;
	Message: ASU.Unbounded_String;
	Mess: ASU.Unbounded_String;
	Nick: ASU.Unbounded_String;
	Nick_Old : ASU.Unbounded_String;
	V: Value;
	Success: Boolean;
	


	--aqui van los procedures
	procedure Send_To_All(Clients: Maps.Map; N:ASU.Unbounded_String) is 
		Curs: Maps.Cursor:= Maps.First(Client_List);
		i :Integer := 0;
	begin
		while Maps.Has_Element(Curs) and i < Maps.Map_Length(Clients)-1 loop
			if Maps.Element(Curs).Key /= N then
				LLU.Send(Maps.Element(Curs).Value.EP,P_Buffer);
				i := i+1;
			end if;
			Maps.Next(Curs);
		end loop;
	end Send_To_All;
	
	procedure Mess_Serv(N: ASU.Unbounded_String; Mess: ASU.Unbounded_String) is 
	begin
		LLU.Reset(P_Buffer.all);
		CM.Message_Type'Output(P_Buffer,chat_messages.Server);
		ASU.Unbounded_String'Output(P_Buffer,N);
		ASU.Unbounded_String'Output(P_Buffer,Mess);
	end Mess_Serv;

	procedure Mess_Welc(Accep: Boolean) is
	begin
		LLU.Reset(P_Buffer.all);
		CM.Message_Type'Output(P_Buffer,chat_messages.Welcome);
		Boolean'Output(P_Buffer,Accep);
	end Mess_Welc;


	procedure Init_Accepted is
	begin 
		Mess_Welc(True);
		LLU.Send(Client_EP_Receive,P_Buffer);
		ATI.Put_Line("INIT received from " & ASU.To_String(Nick) & " ACEPTED");
		Message:= ASU.To_Unbounded_String(ASU.To_String(Nick) & " joins the chat");
		--Mensaje Server a todos los clientes	
		Mess_Serv(ASU.To_Unbounded_String("Server"),Message);
		Send_To_All(Client_List,Nick);
	end Init_Accepted;

	
	function Mas_Antig(Clients: Maps.Map) return Maps.Element_Type is
		Curs: Maps.Cursor:= Maps.First(Client_List);
		Max_Old: Maps.Element_Type:= Maps.Element(Curs);
		i :Integer := 0;
	begin
		while Maps.Has_Element(Curs) and i /= Maps.Map_Length(Clients) loop
			if Maps.Element(Curs).Value.Hour < Max_Old.Value.Hour then
				Max_Old := Maps.Element(Curs);
			end if;
			i := i+1;
			Maps.Next(Curs);
		end loop;
		return Max_Old;
	end Mas_Antig;
		

	begin
		Type_Mess:= CM.Message_Type'Input(P_Buffer);	
		if Type_Mess = CM.Init then
			begin			
				ATI.Put_Line("Mensaje INIT");
				Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
				Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
				Nick := ASU.Unbounded_String'Input(P_Buffer);
				V.EP:= Client_EP_Handler;
				V.Hour := AC.Clock;				
				Maps.Get(Client_List,Nick,V,Success);
				if not Success then
					Maps.Put(Client_List,Nick,V);
					Init_Accepted;
				else
					Mess_Welc(False);
					LLU.Send(Client_EP_Receive,P_Buffer);
					ATI.Put_Line("INIT received from " & ASU.To_String(Nick) & " IGNORED");
		  			end if;
				exception  
					when Maps.Full_Map =>
						Nick_Old := Mas_Antig(Client_List).key;
						Mess:= ASU.To_Unbounded_String(ASU.To_String(Mas_Antig(Client_List).key) & " banned for being idle too long");
						Mess_Serv(ASU.To_Unbounded_String("Server"),Mess);
						Send_To_All(Client_List,Nick);
						Maps.Delete(Client_List,Nick_Old,Success);
						Maps_Old.Put(Old_List,Nick_Old,AC.Clock);						
						Maps.Put(Client_List,Nick,V);
						Init_Accepted;
					
			end;
			
				
		elsif Type_Mess = CM.Writer then
			begin
				Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
				Nick := ASU.Unbounded_String'Input(P_Buffer);
				Message:= ASU.Unbounded_String'Input(P_Buffer);
				V.EP:= Client_EP_Handler;			
				V.Hour := AC.Clock;
				Maps.Get(Client_List,Nick,V,Success);
				if Success then
					ATI.Put_Line("WRITER received from " & ASU.To_String(Nick) & ": " & ASU.To_String(Message));
					Maps.Put(Client_List,Nick,V);
					if Client_EP_Handler = V.EP then 
						--mandar un mensaje server
						LLU.Reset(P_Buffer.all);
						Mess_Serv(Nick,Message);
						Send_To_All(Client_List,Nick);
					end if;
				end if;
				exception  
					when Maps.Full_Map =>
						ATI.Put_Line("Writer from client banned");
			end;
	
		elsif Type_Mess = CM.Logout then
			begin
				ATI.Put_Line("Mensaje Logout");
				Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
				Nick := ASU.Unbounded_String'Input(P_Buffer);
				V.EP:= Client_EP_Handler;
				V.Hour := AC.Clock;
				Maps.Delete(Client_List,Nick,Success);
				Maps_Old.Put(Old_List,Nick,AC.Clock); 
				--Mensaje server informando de que se ha ido un usuario
				Message:= ASU.To_Unbounded_String(" Leaves the chat");
				Mess_Serv(Nick,Message);
				Send_To_All(Client_List,Nick);

			exception  
					when Maps.No_Element =>
						ATI.Put_Line("Lista Vacia");
			end;
		end if;


	end Server_Handler;
			
end Handler_Server;
