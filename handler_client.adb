with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Unchecked_Deallocation;
with chat_messages;
with Ada.Command_Line;

package body Handler_Client is

	package ASU renames Ada.Strings.Unbounded;
	package CM renames chat_messages;
	package ATI renames Ada.Text_IO;
	
	procedure Client_Handler (From: in     LLU.End_Point_Type;
						To: in LLU.End_Point_Type;
						P_Buffer: access LLU.Buffer_Type) is
						
						
		Type_Mess: CM.Message_Type;
		Nick: ASU.Unbounded_String;
		Message: ASU.Unbounded_String;
	begin
		Type_Mess:= CM.Message_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);
		Message:= ASU.Unbounded_String'Input(P_Buffer);
		ATI.Put_Line(ASU.To_String(Nick) & ":"& ASU.To_String(Message));
	end Client_Handler;
		
end Handler_Client;
