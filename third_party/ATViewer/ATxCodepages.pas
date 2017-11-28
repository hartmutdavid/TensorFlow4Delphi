//
// Codepages info:
// http://msdn2.microsoft.com/en-us/library/ms776446.aspx
//

unit ATxCodepages;

interface

uses
  Windows;

type
  TATEncoding = type Integer;

const
  //indexes in cCodepages list
  vEncANSI = 0;
  vEncOEM = 1;
  vEncMac = 2;
  vEncUnicodeLE = -1;
  vEncUnicodeBE = -2;

function CodepageName(Enc: TATEncoding): AnsiString;
function IsCodepageSupported(Enc: TATEncoding): Boolean;
function SCodepageToUnicode(const S: AnsiString; Enc: TATEncoding): WideString;


implementation

uses
  SysUtils,
  ATxCodepageList;

//-------------------------------------------------
function CodepageID(Enc: TATEncoding): Integer;
begin
  Assert(Enc >= 0, 'Invalid codepage specified: CodepageID');
  Result := cCodepages[Enc].ID;
end;

//-------------------------------------------------
function CodepageName(Enc: TATEncoding): AnsiString;
begin
  case Enc of
    vEncUnicodeBE:
      Result := 'Unicode (UTF-16 BE)';
    vEncUnicodeLE:
      Result := 'Unicode (UTF-16 LE)';
    else
      with cCodepages[Enc] do
        Result := Name;//Family + ' (' + Name + ')';
  end;
end;

//-------------------------------------------------
(*
function EnumCodePagesProc(S: PAnsiChar): Integer; stdcall;
var
  ID: Integer;
  Enc: TATEncoding;
begin
  Result := 1;
  ID := StrToIntDef(S, 0);
  for Enc := Low(TATEncoding) to High(TATEncoding) do
    if cATEncodings[Enc].ID = ID then
    begin
      CodepagesSupported[Enc] := True;
      Break;
    end;
end;

procedure InitCodepagesSupported;
begin
  FillChar(CodepagesSupported, SizeOf(CodepagesSupported), 0);
  EnumSystemCodePagesA(@EnumCodePagesProc, CP_INSTALLED);
end;
*)

function IsCodepageSupported(Enc: TATEncoding): Boolean;
const
  p: AnsiString = 'pppp';
begin
  Result:= MultiByteToWideChar(
    CodepageID(Enc), 0,
    PAnsiChar(p), Length(p),
    nil, 0) > 0;
end;

//-------------------------------------------------
function SCodepageToUnicodeAPI(const S: AnsiString; Enc: TATEncoding): WideString;
var
  WS: WideString;
  N: Integer;
  ID: Integer;
begin
  Result := '?';
  if IsCodepageSupported(Enc) then
    case Enc of
      vEncANSI:
        begin
          Result := S;
        end;
      else
        begin
          WS := '';
          ID := CodepageID(Enc);
          N := MultiByteToWideChar(ID, 0, PAnsiChar(S), Length(S), nil, 0);
          if N = 0 then Exit;
          SetLength(WS, N);
          N := MultiByteToWideChar(ID, 0, PAnsiChar(S), Length(S), PWChar(WS), Length(WS));
          if N = 0 then Exit;
          Result := WS;
        end;
    end;
end;

//-------------------------------------------------
function SUnicodeToCodepage(const WS: WideString; Enc: TATEncoding): AnsiString;
var
  RS: AnsiString;
  N: Integer;
  ID: Integer;
begin
  Result := '?';
  if IsCodepageSupported(Enc) then
    case Enc of
      vEncANSI:
        begin
          Result := WS;
        end;
      else
        begin
          RS := '';
          ID := CodepageID(Enc);
          N := WideCharToMultiByte(ID, 0, PWChar(WS), Length(WS), nil, 0, nil, nil);
          if N = 0 then Exit;
          SetLength(RS, N);
          N := WideCharToMultiByte(ID, 0, PWChar(WS), Length(WS), PAnsiChar(RS), Length(RS), nil, nil);
          if N = 0 then Exit;
          Result := RS;
        end;
    end;
end;

//-------------------------------------------------
function SConvertOEMToANSI(const S: AnsiString): AnsiString;
begin
  SetLength(Result, Length(S));
  OemToCharBuffA(PAnsiChar(S), PAnsiChar(Result), Length(S));
end;

//--------------------------------------------------
type
  TCodepageMap128 = array[0 .. 127] of AnsiChar;
  TCodepageMap256 = array[0 .. 255] of AnsiChar;

function SConvertByMap128(const S: AnsiString; const Map: TCodepageMap128): AnsiString;
var
  i: Integer;
begin
  Result := S;
  for i := 1 to Length(S) do
    if Ord(S[i]) >= 128 then
      Result[i] := Map[Ord(S[i]) - 128];
end;

function SConvertByMap256(const S: AnsiString; const Map: TCodepageMap256): AnsiString;
var
  i: Integer;
begin
  Result := S;
  for i := 1 to Length(S) do
    Result[i] := Map[Ord(S[i])];
end;

const
  //Cyrillic (KOI8-R) --> Cyrillic (Windows-1251)
  cMapKOI8ToANSI: TCodepageMap128 = (
    #$2D, #$A6, #$2D, #$AC, #$4C, #$2D, #$2B, #$2B,
    #$54, #$2B, #$2B, #$2D, #$2D, #$2D, #$A6, #$A6,
    #$2D, #$2D, #$2D, #$3F, #$A6, #$95, #$76, #$3F,
    #$3F, #$3F, #$A0, #$3F, #$B0, #$3F, #$B7, #$3F,
    #$3D, #$A6, #$2D, #$B8, #$E3, #$E3, #$AC, #$AC,
    #$AC, #$4C, #$4C, #$4C, #$2D, #$2D, #$2D, #$A6,
    #$A6, #$A6, #$A6, #$A8, #$A6, #$A6, #$54, #$54,
    #$54, #$A6, #$A6, #$A6, #$2B, #$2B, #$2B, #$A9,
    #$FE, #$E0, #$E1, #$F6, #$E4, #$E5, #$F4, #$E3,
    #$F5, #$E8, #$E9, #$EA, #$EB, #$EC, #$ED, #$EE,
    #$EF, #$FF, #$F0, #$F1, #$F2, #$F3, #$E6, #$E2,
    #$FC, #$FB, #$E7, #$F8, #$FD, #$F9, #$F7, #$FA,
    #$DE, #$C0, #$C1, #$D6, #$C4, #$C5, #$D4, #$C3,
    #$D5, #$C8, #$C9, #$CA, #$CB, #$CC, #$CD, #$CE,
    #$CF, #$DF, #$D0, #$D1, #$D2, #$D3, #$C6, #$C2,
    #$DC, #$DB, #$C7, #$D8, #$DD, #$D9, #$D7, #$DA
    );

  //From recode 3.5
  cMapMacToANSI: TCodepageMap128 = (
    #$C4, #$C5, #$C7, #$C9, #$D1, #$D6, #$DC, #$E1,
    #$E0, #$E2, #$E4, #$E3, #$E5, #$E7, #$E9, #$E8,
    #$EA, #$EB, #$ED, #$EC, #$EE, #$EF, #$F1, #$F3,
    #$F2, #$F4, #$F6, #$F5, #$FA, #$F9, #$FB, #$FC,
    #$A0, #$B0, #$A2, #$A3, #$A7, #$B4, #$B6, #$DF,
    #$AE, #$A9, #$8E, #$82, #$8C, #$AD, #$C6, #$D8,
    #$8D, #$B1, #$B2, #$B3, #$A5, #$B5, #$A6, #$B7,
    #$B8, #$B9, #$BC, #$AA, #$BA, #$BD, #$E6, #$F8,
    #$BF, #$A1, #$AC, #$92, #$80, #$81, #$A8, #$AB,
    #$BB, #$83, #$BE, #$C0, #$C3, #$D5, #$91, #$93,
    #$D0, #$84, #$96, #$94, #$95, #$90, #$F7, #$D7,
    #$FF, #$DD, #$98, #$97, #$86, #$99, #$DE, #$A4,
    #$88, #$87, #$89, #$8B, #$8A, #$C2, #$CA, #$C1,
    #$CB, #$C8, #$CD, #$CE, #$CF, #$CC, #$D3, #$D4,
    #$F0, #$D2, #$DA, #$DB, #$D9, #$9B, #$9A, #$85,
    #$8F, #$9D, #$9C, #$9E, #$9F, #$FD, #$FE, #$AF
    );

  //From recode 3.5
  cMapEBCDICToANSI: TCodepageMap256 = (
    #$00, #$01, #$02, #$03, #$F7, #$09, #$D2, #$7F,
    #$F2, #$A8, #$93, #$0B, #$0C, #$0D, #$0E, #$0F,
    #$10, #$11, #$12, #$13, #$D3, #$A1, #$08, #$D7,
    #$18, #$19, #$96, #$D0, #$1C, #$1D, #$1E, #$1F,
    #$7C, #$D6, #$81, #$C0, #$D1, #$0A, #$17, #$1B,
    #$D4, #$E9, #$E0, #$D5, #$92, #$05, #$06, #$07,
    #$F0, #$F1, #$16, #$F3, #$F4, #$F5, #$F6, #$04,
    #$F8, #$F9, #$A9, #$94, #$14, #$15, #$95, #$1A,
    #$20, #$C1, #$C2, #$C3, #$C4, #$C5, #$C6, #$C7,
    #$C8, #$C9, #$5B, #$2E, #$3C, #$28, #$2B, #$21,
    #$26, #$D8, #$D9, #$E2, #$E3, #$E4, #$E5, #$E6,
    #$E7, #$E8, #$5D, #$24, #$2A, #$29, #$3B, #$5E,
    #$2D, #$2F, #$82, #$83, #$84, #$85, #$86, #$87,
    #$88, #$89, #$A6, #$2C, #$25, #$5F, #$3E, #$3F,
    #$97, #$98, #$99, #$A2, #$A3, #$A4, #$A5, #$91,
    #$A7, #$60, #$3A, #$23, #$40, #$27, #$3D, #$22,
    #$80, #$61, #$62, #$63, #$64, #$65, #$66, #$67,
    #$68, #$69, #$8A, #$8B, #$8C, #$8D, #$8E, #$8F,
    #$90, #$6A, #$6B, #$6C, #$6D, #$6E, #$6F, #$70,
    #$71, #$72, #$9A, #$9B, #$9C, #$9D, #$9E, #$9F,
    #$A0, #$7E, #$73, #$74, #$75, #$76, #$77, #$78,
    #$79, #$7A, #$AA, #$AB, #$AC, #$AD, #$AE, #$AF,
    #$B0, #$B1, #$B2, #$B3, #$B4, #$B5, #$B6, #$B7,
    #$B8, #$B9, #$BA, #$BB, #$BC, #$BD, #$BE, #$BF,
    #$7B, #$41, #$42, #$43, #$44, #$45, #$46, #$47,
    #$48, #$49, #$CA, #$CB, #$CC, #$CD, #$CE, #$CF,
    #$7D, #$4A, #$4B, #$4C, #$4D, #$4E, #$4F, #$50,
    #$51, #$52, #$DA, #$DB, #$DC, #$DD, #$DE, #$DF,
    #$5C, #$E1, #$53, #$54, #$55, #$56, #$57, #$58,
    #$59, #$5A, #$EA, #$EB, #$EC, #$ED, #$EE, #$EF,
    #$30, #$31, #$32, #$33, #$34, #$35, #$36, #$37,
    #$38, #$39, #$FA, #$FB, #$FC, #$FD, #$FE, #$FF
    );

const
  //Western European (ISO 8859-1) --> Western European (Windows-1252)
  cMapISOToANSI: TCodepageMap128 = (
    #$3F, #$81, #$3F, #$3F, #$3F, #$3F, #$3F, #$3F,
    #$3F, #$3F, #$3F, #$3F, #$3F, #$8D, #$3F, #$8F,
    #$90, #$3F, #$3F, #$3F, #$3F, #$3F, #$3F, #$3F,
    #$3F, #$3F, #$3F, #$3F, #$3F, #$9D, #$3F, #$3F,
    #$A0, #$A1, #$A2, #$A3, #$A4, #$A5, #$A6, #$A7,
    #$A8, #$A9, #$AA, #$AB, #$AC, #$AD, #$AE, #$AF,
    #$B0, #$B1, #$B2, #$B3, #$B4, #$B5, #$B6, #$B7,
    #$B8, #$B9, #$BA, #$BB, #$BC, #$BD, #$BE, #$BF,
    #$C0, #$C1, #$C2, #$C3, #$C4, #$C5, #$C6, #$C7,
    #$C8, #$C9, #$CA, #$CB, #$CC, #$CD, #$CE, #$CF,
    #$D0, #$D1, #$D2, #$D3, #$D4, #$D5, #$D6, #$D7,
    #$D8, #$D9, #$DA, #$DB, #$DC, #$DD, #$DE, #$DF,
    #$E0, #$E1, #$E2, #$E3, #$E4, #$E5, #$E6, #$E7,
    #$E8, #$E9, #$EA, #$EB, #$EC, #$ED, #$EE, #$EF,
    #$F0, #$F1, #$F2, #$F3, #$F4, #$F5, #$F6, #$F7,
    #$F8, #$F9, #$FA, #$FB, #$FC, #$FD, #$FE, #$FF
    );

//-------------------------------------------------
function SConvertKOI8ToANSI(const S: AnsiString): AnsiString;
begin
  Result := SConvertByMap128(S, cMapKOI8ToANSI);
end;

function SConvertMacToANSI(const S: AnsiString): AnsiString;
begin
  Result := SConvertByMap128(S, cMapMacToANSI);
end;

function SConvertEBCDICToANSI(const S: AnsiString): AnsiString;
begin
  Result := SConvertByMap256(S, cMapEBCDICToANSI);
end;

function SConvertISOToANSI(const S: AnsiString): AnsiString;
begin
  Result := SConvertByMap128(S, cMapISOToANSI);
end;

//-------------------------------------------------
function SCodepageToUnicode(const S: AnsiString; Enc: TATEncoding): WideString;
begin
  Result := '';
  Assert(Enc >= 0, 'Unicode encodings can''t be passed to CodepageToUnicode');

  if (S <> '') then
    case Enc of
      vEncANSI:
        Result := S;

      vEncMac:
        begin
          //CP_MACCP codepage supported only under NT:
          if (Win32Platform = VER_PLATFORM_WIN32_NT) then
            Result := SCodepageToUnicodeAPI(S, vEncMac)
          else
            Result := SConvertMacToANSI(S);
        end;

      else
        Result := SCodepageToUnicodeAPI(S, Enc);
    end;
end;

end.
