with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;

package body Hash_Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : in out Map;
                  Key     : in Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
   	  P_Aux : Cell_A;
	  i: Hash_Range;
   begin
	  i:= Hash(Key);
      P_Aux := M(i).P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is
      P_Aux : Cell_A;
	  i: Hash_Range;
      Found : Boolean;
   begin
      -- Si ya existe Key, cambiamos su Value
	  i:= Hash(Key);
      P_Aux := M(i).P_First;
      Found := False;
      while not Found and P_Aux /= null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Found := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;

      -- Si no hemos encontrado Key añadimos al principio
      if not Found then
         M(i).P_First := new Cell'(Key, Value, M(i).P_First);
         M(i).Length := M(i).Length + 1;
      end if;
		if Map_Length(M) > Max then
			Ada.Text_IO.Put_Line("Full MAP");
			raise Full_Map;
		end if;	
   end Put;


   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
      P_Previous : Cell_A;
	  i: Hash_Range;
   begin
      Success := False;
	  i:= Hash(Key);
      P_Previous := null;
      P_Current  := M(i).P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M(i).Length := M(i).Length - 1;
            if P_Previous /= null then
               P_Previous.Next := P_Current.Next;
            end if;
            if M(i).P_First = P_Current then
               M(i).P_First := M(i).P_First.Next;
            end if;
            Free (P_Current);
         else
            P_Previous := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;
   end Delete;


   function Map_Length (M : Map) return Natural is
		i: Hash_Range;
		tot: Natural := 0;
   begin
		i := Hash_Range'first;
      while i /= Hash_Range'last loop
		if M(i).P_First /= null then
			tot := tot + M(i).Length;
	  	end if;
			i := i+1;
      end loop;
      return tot;
   end Map_Length;


   function First (M: Map) return Cursor is
		i: Hash_Range;
		Found: Boolean:= False;
   begin
		i := Hash_Range'first;
		while not Found and i < Hash_Range'last loop
			if M(i).P_First /= null then
				Found := True;
			else
				i := i+1;
			end if;
		end loop;

		if not Found then
				return (M => M, Pos => i, Element_A => null);
			else
				return (M => M, Pos => i, Element_A => M(i).P_First);
			end if;
   end First;

   procedure Next (C: in out Cursor) is
		Encontrado : Boolean := False;
		i : Hash_Range := C.Pos;
	begin
      if C.Element_A.Next /= null Then
         C.Element_A := C.Element_A.Next;
	  else
		loop
			C.Pos := C.Pos+1;
			if C.M(C.Pos).P_First /= null and C.Pos /= i then
				C.Element_A := C.M(C.Pos).P_First;
				Encontrado := True;
			end if;
			exit when Encontrado or i = C.Pos;
		end loop;
		if not Encontrado then
			C.Element_A := null;
		end if;
      end if;
   end Next;

   function Element (C: Cursor) return Element_Type is
   begin
      if C.Element_A /= null then
         return (Key   => C.Element_A.Key,
                 Value => C.Element_A.Value);
      else
         raise No_Element;
      end if;
   end Element;

   function Has_Element (C: Cursor) return Boolean is
   begin
      return (C.Element_A /= null);
   end Has_Element;

end Hash_Maps_G;
