with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Unchecked_Deallocation;
with Chat_Messages;
with Ada.Command_Line;
with Handler_Client;


procedure Chat_Client_2 is

	package ACL renames Ada.Command_Line;
	package ATI renames Ada.Text_IO;
	package CM renames chat_messages;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;

	Buffer: aliased LLU.Buffer_Type(1024);
	Dir_IP_Client: ASU.Unbounded_String;
	Dir_IP_Server: ASU.Unbounded_String;
	Client :ASU.Unbounded_String;
	Server_EP: LLU.End_Point_Type;
	Puerto: Integer;
	Type_Mess: CM.Message_Type;
	Client_EP_Handler:LLU.End_Point_Type;
	Client_EP_Receive:LLU.End_Point_Type;
	Nick: ASU.Unbounded_String;
	Message: ASU.Unbounded_String;
	Acepted: Boolean;
	
begin

	Dir_IP_Server:= ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(1)));
	Puerto:= Integer'Value(ACL.Argument(2));
	Nick:= ASU.To_Unbounded_String(ACL.Argument(3));
	
	--te atas al server
	Server_EP:= LLU.Build(ASU.To_String(Dir_IP_Server),Puerto);
	
	--te atas con un puerto cualquiera del cliente,
	--si llega un mensaje llamara al handler
	LLU.Bind_Any(Client_EP_Receive);	
	LLU.Bind_Any(Client_EP_Handler,Handler_Client.Client_Handler'Access);
	--envias mensaje de INIT
	LLU.Reset(Buffer);
	CM.Message_Type'Output(Buffer'Access,chat_messages.Init);
	LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Receive);
	LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Handler);
	ASU.Unbounded_String'Output(Buffer'Access,Nick);
	LLU.Send(Server_EP,Buffer'Access);
	--Llamar al handler para que haga la funcion de reader
	LLU.Reset(Buffer);
	LLU.Receive(Client_EP_Receive,Buffer'Access);

	--Utilizar el Expired para que si pasa el plazo salga de la aplicacion
	--el cliente termina mostrando es su pantalla que el server no se encuentra
	Type_Mess:= CM.Message_Type'Input(Buffer'Access);
	Acepted:= Boolean'Input(Buffer'Access);
	
	if Acepted then 
		ATI.Put_Line("Welcome " & ASU.To_String(Nick));
	
		loop
			LLU.Reset(Buffer);
			ATI.Put_Line("Message: ");
			CM.Message_Type'Output(Buffer'Access,chat_messages.Writer);
			LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Handler);
			ASU.Unbounded_String'Output(Buffer'Access,Nick);
			Message := ASU.To_Unbounded_String(ATI.Get_Line);
			ASU.Unbounded_String'Output(Buffer'Access,Message);
			LLU.Send(Server_EP,Buffer'Access);
			exit when Message = ".quit";
		end loop;
	
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access,chat_messages.Logout);
		LLU.End_Point_Type'Output(Buffer'Access,Client_EP_Handler);
		ASU.Unbounded_String'Output(Buffer'Access,Nick);
		LLU.Send(Server_EP,Buffer'Access);
	
	else
		ATI.Put_Line("No ha sido aceptado");
	end if;

	LLU.Finalize;
	
end Chat_Client_2;
