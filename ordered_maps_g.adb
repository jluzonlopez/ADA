with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Ordered_Maps_G is

	procedure Get (M       : Map;
			Key     : in  Key_Type;
			Value   : out Value_Type;
			Success : out Boolean) is
		i_Min: Natural:= 1;
		i_Max: Natural:= Map_Length(M);
		i_Bus: Natural:= Map_Length(M)/2;
		Num_Bus : Integer:= 1;
		P_Aux: Cell_Array_A:= M.P_Array;
	begin
		Success := False;
		if P_Aux /= null then
			i_Bus := (i_Max-i_Min)/2;
			while not Success and Num_Bus < Map_Length(M) loop				
				if P_Aux(i_Bus).Key = Key then
					Value := P_Aux(i_Bus).Value;
					Success := True;
				elsif P_Aux(i_Bus).Key < Key then
					i_Min := i_Bus;
					if (i_Max-i_Min) = 1 then
						i_Bus := i_Bus+1;
					else
						i_Bus := i_Bus + (i_Max-i_Min)/2;
					end if;
				else
					i_Max := i_Bus;
					if (i_Max-i_Min) = 1 then
						i_Bus := i_Bus-1;
					else
						i_Bus := i_Bus - (i_Max-i_Min)/2;
					end if;
				end if;
				Num_Bus := Num_Bus+1;
			end loop;
		end if;
	end Get;

	procedure Put (M     : in out Map;
			Key   : Key_Type;
			Value : Value_Type) is

		i: Natural:= 1;
		Pos_Ins : Natural := 0;
		P_Aux : Cell_Array_A := null;
		Found : Boolean := False;
	begin
	-- Si ya existe Key, cambiamos su Value

		if M.P_Array = null then
			M.P_Array := new Cell_Array;
		end if;
		P_Aux := M.P_Array;

		while not Found loop 
			if P_Aux(i).Busy = True then
				if P_Aux(i).Key = Key then
					P_Aux(i).Value := Value;
					Found := True;
				elsif P_Aux(i).Key < Key then
					i := i+1;
				else
					-- mueves todos uno hacia adelante
					Pos_Ins := i;
					i := M.Length; 
					while Pos_Ins /= i+1 loop
						P_Aux(i+1).Key := P_Aux(i).Key;
						P_Aux(i+1).Value := P_Aux(i).Value;
						P_Aux(i+1).Busy := True;
						i := i-1;
					end loop;
					P_Aux(Pos_Ins).Key := Key;
					P_Aux(Pos_Ins).Value := Value;
					P_Aux(Pos_Ins).Busy := True;
					Found := True;
					M.Length := M.Length +1;
				end if;
			else
				P_Aux(i).Key := Key;
				P_Aux(i).Value := Value;
				P_Aux(i).Busy := True;
				M.Length := M.Length +1;
				Found := True;
			end if;
		end loop;

		if M.Length = Max_Users and not Found then 
			raise Full_Map;
		end if;
	end Put;

	procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
		i_Min: Natural:= 1;
		i_Max: Natural:= Map_Length(M);
		i_Bus: Natural:= Map_Length(M)/2;
		Num_Bus : Integer:= 1;
		P_Aux: Cell_Array_A:= M.P_Array;
	begin
		Success := False;
		if P_Aux /= null then
			i_Bus := (i_Max-i_Min)/2;
			while not Success and Num_Bus < Map_Length(M) loop				
				if P_Aux(i_Bus).Key = Key then
					if i_Bus = Map_Length(M) then
						P_Aux(i_Bus).Busy := False;
						Success := True;
					else
						while i_Bus /= i_Max+1 loop
						P_Aux(i_Bus).Key := P_Aux(i_Bus+1).Key;
						P_Aux(i_Bus).Value := P_Aux(i_Bus+1).Value;
						P_Aux(i_Bus).Busy := P_Aux(i_Bus+1).Busy;
						i_Bus := i_Bus+1;
						end loop;
					end if;
				elsif P_Aux(i_Bus).Key < Key then
					i_Min := i_Bus;
					if (i_Max-i_Min) = 1 then
						i_Bus := i_Bus+1;
					else
						i_Bus := i_Bus + (i_Max-i_Min)/2;
					end if;
				else
					i_Max := i_Bus;
					if (i_Max-i_Min) = 1 then
						i_Bus := i_Bus-1;
					else
						i_Bus := i_Bus - (i_Max-i_Min)/2;
					end if;
				end if;
				Num_Bus := Num_Bus+1;
			end loop;
		end if;
	end Delete;


	function Map_Length (M : Map) return Natural is
	begin
		return M.Length;
	end Map_Length;


	function First (M: Map) return Cursor is
		i: Natural := 1;
		P_Aux : Cell_Array_A := M.P_Array;
		Found: Boolean:= False;
	begin
		if P_Aux /= null then
			while i /= Max_Users+1 and not Found loop
				if P_Aux(i).Busy = False then 
					i:= i+1;
				else
					Found:= True;
				end if;
			end loop;
				if not Found then
						return (M => M, Element_A => 0);
					else
						return (M => M, Element_A => i);

					end if;
		else
			return (M => M, Element_A => 0);
		end if;
	end First;

	procedure Next (C: in out Cursor) is
		i : Natural := C.Element_A+1;
		Found: Boolean := False;	
	begin
		if C.M.P_Array(i).Busy = True then 
			C.Element_A:= i;
		else
			C.Element_A := 0;
		end if;
	end Next;

	function Element (C: Cursor) return Element_Type is
		begin
		if C.Element_A /= 0 then
			return (Key   => C.M.P_Array(C.Element_A).Key,
		            Value => C.M.P_Array(C.Element_A).Value);
		else
			raise No_Element;
		end if;
	end Element;

	function Has_Element (C: Cursor) return Boolean is
	begin
		if C.M.P_Array /= null and C.Element_A/= 0 then
			return C.M.P_Array(C.Element_A).Busy;
		else
			return False;
		end if;
	end Has_Element;

end Ordered_Maps_G;
