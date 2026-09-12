(******************************************************************************
 *                                PasMultiLang                                *
 ******************************************************************************
 *                  Version see PASMULTILANG_VERSION code constant            *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2003-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasmultilang                                 *
 * 4. Write code, which is compatible with newer modern Delphi versions and   *
 *    FreePascal >= 3.0.4, but if needed, make it out-ifdef-able.             *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 * 10. Make sure the code runs on platforms with weak and strong memory       *
 *     models without any issues.                                             *
 *                                                                            *
 ******************************************************************************)
unit PasMultiLang;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
 {-$pic off}
 {$define caninline}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
{$else}
 {$legacyifend on}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi}
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
{$endif}
{$if defined(win32) or defined(win64) or defined(wince) or defined(windows) or defined(win)}
 {$define windows}
 {$define win}
{$ifend}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define caninline}
{$else}
 {$undef caninline}
 {$ifdef ver180}
  {$define caninline}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define caninline}
   {$ifend}
  {$endif}
 {$endif}
{$endif}
{$scopedenums on}

interface

uses SysUtils,Classes,Math,PasMP;

const PASMULTILANG_VERSION='1.00.2026.09.12.0000';

type TPasMultiLangSizeInt={$if declared(NativeInt)}NativeInt{$elseif declared(PtrInt)}PtrInt{$else}Int32{$ifend};
     TPasMultiLangSizeUInt={$if declared(NativeUInt)}NativeUInt{$elseif declared(PtrUInt)}PtrUInt{$else}UInt32{$ifend};

     TPasMultiLangUInt64=UInt64;

     TPasMultiLangUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     TPasMultiLangUTF8Char=AnsiChar;

     TPasMultiLangUTF8StringArray=array of TPasMultiLangUTF8String;

     // The plural form expression of a PO file header is a C-like expression, which is compiled here into a simple
     // reverse polish notation instruction list, so that it can be evaluated afterwards without any reparsing and
     // without any memory allocations at all
     TPasMultiLangPluralFormOperation=
      (
       PushConstant,
       PushCount,
       LogicalNot,
       Multiply,
       Divide,
       Modulo,
       Add,
       Subtract,
       Less,
       LessOrEqual,
       Greater,
       GreaterOrEqual,
       Equal,
       NotEqual,
       LogicalAnd,
       LogicalOr,
       Select
      );

     PPasMultiLangPluralFormInstruction=^TPasMultiLangPluralFormInstruction;
     TPasMultiLangPluralFormInstruction=record
      Operation:TPasMultiLangPluralFormOperation;
      Value:TPasMultiLangUInt64;
     end;

     TPasMultiLangPluralFormInstructions=array of TPasMultiLangPluralFormInstruction;

     PPasMultiLangUInt8=^UInt8;

     TPasMultiLangUInt8Array=array[0..65535] of UInt8;
     PPasMultiLangUInt8Array=^TPasMultiLangUInt8Array;

     TPasMultiLangObjectGenericList<T:class>=class
      private
       type TValueEnumerator=record
             private
              fObjectList:TPasMultiLangObjectGenericList<T>;
              fIndex:TPasMultiLangSizeInt;
              function GetCurrent:T; inline;
             public
              constructor Create(const aObjectList:TPasMultiLangObjectGenericList<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fItems:array of T;
       fCount:TPasMultiLangSizeInt;
       fAllocated:TPasMultiLangSizeInt;
       fOwnsObjects:boolean;
       procedure SetCount(const pNewCount:TPasMultiLangSizeInt);
       function GetItem(const pIndex:TPasMultiLangSizeInt):T;
       procedure SetItem(const pIndex:TPasMultiLangSizeInt;const pItem:T);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear;
       function IndexOf(const pItem:T):TPasMultiLangSizeInt;
       function Add(const pItem:T):TPasMultiLangSizeInt;
       procedure Insert(const pIndex:TPasMultiLangSizeInt;const pItem:T);
       procedure Delete(const pIndex:TPasMultiLangSizeInt);
       procedure Remove(const pItem:T);
       procedure Exchange(const pIndex,pWithIndex:TPasMultiLangSizeInt);
       function GetEnumerator:TValueEnumerator;
       property Count:TPasMultiLangSizeInt read fCount write SetCount;
       property Allocated:TPasMultiLangSizeInt read fAllocated;
       property Items[const pIndex:TPasMultiLangSizeInt]:T read GetItem write SetItem; default;
       property OwnsObjects:boolean read fOwnsObjects write fOwnsObjects;
     end;

     TPasMultiLangHashMapEntityIndices=array of Int32;

     TPasMultiLangUTF8StringHashMap<THashMapValue>=class
      private
       const CELL_EMPTY=-1;
             CELL_DELETED=-2;
             ENT_EMPTY=-1;
             ENT_DELETED=-2;
       type THashMapKey=TPasMultiLangUTF8String;
            PHashMapEntity=^THashMapEntity;
            THashMapEntity=record
             Key:THashMapKey;
             Value:THashMapValue;
            end;
            THashMapEntities=array of THashMapEntity;
      private
       fRealSize:Int32;
       fLogSize:Int32;
       fSize:Int32;
       fEntities:THashMapEntities;
       fEntityToCellIndex:TPasMultiLangHashMapEntityIndices;
       fCellToEntityIndex:TPasMultiLangHashMapEntityIndices;
       fDefaultValue:THashMapValue;
       fCanShrink:boolean;
      private
       function HashKey(const Key:THashMapKey):UInt32;
       function FindCell(const Key:THashMapKey):UInt32;
       procedure Resize;
      protected
       function GetValue(const Key:THashMapKey):THashMapValue;
       procedure SetValue(const Key:THashMapKey;const Value:THashMapValue);
      public
       constructor Create(const DefaultValue:THashMapValue);
       destructor Destroy; override;
       procedure Clear;
       function Add(const Key:THashMapKey;const Value:THashMapValue):PHashMapEntity;
       function Get(const Key:THashMapKey;const CreateIfNotExist:boolean=false):PHashMapEntity;
       function TryGet(const Key:THashMapKey;out Value:THashMapValue):boolean;
       function ExistKey(const Key:THashMapKey):boolean;
       function Delete(const Key:THashMapKey):boolean;
       property Values[const Key:THashMapKey]:THashMapValue read GetValue write SetValue; default;
       property CanShrink:boolean read fCanShrink write fCanShrink;
     end;

     TPasMultiLang=class
      private
       type TTranslationItem=class
             private
              fContext:TPasMultiLangUTF8String;
              fOriginal:TPasMultiLangUTF8StringArray;
              fTranslated:TPasMultiLangUTF8StringArray;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              function GetTranslated(const aPluralIndex:TPasMultiLangSizeInt=0):TPasMultiLangUTF8String;
            end;
            TTranslationItemList=TPasMultiLangObjectGenericList<TTranslationItem>;
            TTranslationItemHashMap=TPasMultiLangUTF8StringHashMap<TTranslationItem>;
      private
       fMultipleReaderSingleWriterLock:TPasMPMultipleReaderSingleWriterLock;
       fTranslationItemList:TTranslationItemList;
       fTranslationItemHashMap:TTranslationItemHashMap;
       fCountPluralForms:TPasMultiLangSizeInt;
       fPluralFormInstructions:TPasMultiLangPluralFormInstructions;
      protected
       class function RoundUpToPowerOfTwoSizeUInt(x:TPasMultiLangSizeUInt):TPasMultiLangSizeUInt; static;
       class function GetHashMapKey(const aContext,aOriginal:TPasMultiLangUTF8String):TPasMultiLangUTF8String; static;
       class function ParsePluralFormExpression(const aExpression:TPasMultiLangUTF8String;out aInstructions:TPasMultiLangPluralFormInstructions):boolean; static;
       class function EvaluatePluralFormExpression(const aInstructions:TPasMultiLangPluralFormInstructions;const aCount:TPasMultiLangUInt64):TPasMultiLangUInt64; static;
       procedure SetDefaultPluralFormsUnlocked;
       procedure ParsePluralFormsFromHeaderUnlocked;
       function GetPluralFormIndexUnlocked(const aCount:TPasMultiLangUInt64):TPasMultiLangSizeInt;
       function TranslateUnlocked(const aContext,aOriginal,aOriginalPlural:TPasMultiLangUTF8String;const aPluralIndex,aFallbackIndex:TPasMultiLangSizeInt;const aCreateIfNotExist:boolean):TPasMultiLangUTF8String;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear(const aLock:boolean=true);
       procedure LoadFromStream(const aStream:TStream);
       procedure LoadFromFile(const aFileName:string);
       procedure SaveToStream(const aStream:TStream);
       procedure SaveToFile(const aFileName:string);
       procedure LoadPOFromStream(const aStream:TStream);
       procedure LoadPOFromFile(const aFileName:string);
       procedure SavePOToStream(const aStream:TStream);
       procedure SavePOToFile(const aFileName:string);
       procedure LoadMOFromStream(const aStream:TStream);
       procedure LoadMOFromFile(const aFileName:string);
       function Translate(const aOriginal:TPasMultiLangUTF8String;const aPluralIndex:TPasMultiLangSizeInt=0;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String; overload;
       function Translate(const aContext,aOriginal:TPasMultiLangUTF8String;const aPluralIndex:TPasMultiLangSizeInt=0;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String; overload;
       function TranslatePlural(const aOriginal,aOriginalPlural:TPasMultiLangUTF8String;const aCount:TPasMultiLangUInt64;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String; overload;
       function TranslatePlural(const aContext,aOriginal,aOriginalPlural:TPasMultiLangUTF8String;const aCount:TPasMultiLangUInt64;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String; overload;
       function GetPluralFormIndex(const aCount:TPasMultiLangUInt64):TPasMultiLangSizeInt;
       function SetPluralForms(const aCountPluralForms:TPasMultiLangSizeInt;const aExpression:TPasMultiLangUTF8String):boolean;
       property CountPluralForms:TPasMultiLangSizeInt read fCountPluralForms;
     end;

implementation

class function TPasMultiLang.RoundUpToPowerOfTwoSizeUInt(x:TPasMultiLangSizeUInt):TPasMultiLangSizeUInt;
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
{$ifdef CPU64}
 x:=x or (x shr 32);
{$endif}
 result:=x+1;
end;

// Two translation items can share the same original string as long as they do have different contexts, so the
// context must be a part of the hash map key as well. The used separator character is the same as the one which
// GNU gettext does use inside MO files for the very same purpose, namely the EOT character.
class function TPasMultiLang.GetHashMapKey(const aContext,aOriginal:TPasMultiLangUTF8String):TPasMultiLangUTF8String;
begin
 if length(aContext)>0 then begin
  result:=aContext+TPasMultiLangUTF8Char(#4)+aOriginal;
 end else begin
  result:=aOriginal;
 end;
end;

// Compiles a C-like plural form expression as it is found inside the "Plural-Forms:" header field of PO and MO
// files, for example "n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2", into a
// reverse polish notation instruction list. The supported subset is the one which GNU gettext does support for
// this purpose as well, namely the variable n, unsigned integer literals, the unary operators ! + - , the binary
// operators * / % + - < <= > >= == != && || and the ternary ?: operator together with parentheses.
class function TPasMultiLang.ParsePluralFormExpression(const aExpression:TPasMultiLangUTF8String;out aInstructions:TPasMultiLangPluralFormInstructions):boolean;
var Position,Len,CountInstructions:TPasMultiLangSizeInt;
 procedure Emit(const aOperation:TPasMultiLangPluralFormOperation;const aValue:TPasMultiLangUInt64=0);
 begin
  if CountInstructions>=length(aInstructions) then begin
   SetLength(aInstructions,(CountInstructions+1)*2);
  end;
  aInstructions[CountInstructions].Operation:=aOperation;
  aInstructions[CountInstructions].Value:=aValue;
  inc(CountInstructions);
 end;
 procedure SkipWhiteSpace;
 begin
  while (Position<=Len) and (aExpression[Position] in [#0..#32]) do begin
   inc(Position);
  end;
 end;
 function ParseSubExpression(const aMinimumPrecedence:TPasMultiLangSizeInt):boolean;
 var Operation:TPasMultiLangPluralFormOperation;
     Precedence,OperatorLength:TPasMultiLangSizeInt;
     Value:TPasMultiLangUInt64;
  function ParseValue:boolean;
  begin
   result:=false;
   SkipWhiteSpace;
   if Position>Len then begin
    exit;
   end;
   case aExpression[Position] of
    '!':begin
     inc(Position);
     if not ParseValue then begin
      exit;
     end;
     Emit(TPasMultiLangPluralFormOperation.LogicalNot);
     result:=true;
    end;
    '+':begin
     inc(Position);
     result:=ParseValue;
    end;
    '-':begin
     inc(Position);
     Emit(TPasMultiLangPluralFormOperation.PushConstant,0);
     if not ParseValue then begin
      exit;
     end;
     Emit(TPasMultiLangPluralFormOperation.Subtract);
     result:=true;
    end;
    '(':begin
     inc(Position);
     if not ParseSubExpression(1) then begin
      exit;
     end;
     SkipWhiteSpace;
     if (Position>Len) or (aExpression[Position]<>')') then begin
      exit;
     end;
     inc(Position);
     result:=true;
    end;
    '0'..'9':begin
     Value:=0;
     while (Position<=Len) and (aExpression[Position] in ['0'..'9']) do begin
      Value:=(Value*10)+TPasMultiLangUInt64(UInt8(TPasMultiLangUTF8Char(aExpression[Position]))-UInt8(TPasMultiLangUTF8Char('0')));
      inc(Position);
     end;
     Emit(TPasMultiLangPluralFormOperation.PushConstant,Value);
     result:=true;
    end;
    'n':begin
     inc(Position);
     if (Position<=Len) and (aExpression[Position] in ['a'..'z','A'..'Z','0'..'9','_']) then begin
      exit; // Since it is then a longer and therefore unknown identifier
     end;
     Emit(TPasMultiLangPluralFormOperation.PushCount);
     result:=true;
    end;
    else begin
     exit;
    end;
   end;
  end;
 begin
  result:=false;
  if not ParseValue then begin
   exit;
  end;
  repeat
   SkipWhiteSpace;
   if Position>Len then begin
    break;
   end;
   OperatorLength:=1;
   case aExpression[Position] of
    '*':begin
     Operation:=TPasMultiLangPluralFormOperation.Multiply;
     Precedence:=7;
    end;
    '/':begin
     Operation:=TPasMultiLangPluralFormOperation.Divide;
     Precedence:=7;
    end;
    '%':begin
     Operation:=TPasMultiLangPluralFormOperation.Modulo;
     Precedence:=7;
    end;
    '+':begin
     Operation:=TPasMultiLangPluralFormOperation.Add;
     Precedence:=6;
    end;
    '-':begin
     Operation:=TPasMultiLangPluralFormOperation.Subtract;
     Precedence:=6;
    end;
    '<':begin
     if (Position<Len) and (aExpression[Position+1]='=') then begin
      Operation:=TPasMultiLangPluralFormOperation.LessOrEqual;
      OperatorLength:=2;
     end else begin
      Operation:=TPasMultiLangPluralFormOperation.Less;
     end;
     Precedence:=5;
    end;
    '>':begin
     if (Position<Len) and (aExpression[Position+1]='=') then begin
      Operation:=TPasMultiLangPluralFormOperation.GreaterOrEqual;
      OperatorLength:=2;
     end else begin
      Operation:=TPasMultiLangPluralFormOperation.Greater;
     end;
     Precedence:=5;
    end;
    '=':begin
     if (Position<Len) and (aExpression[Position+1]='=') then begin
      Operation:=TPasMultiLangPluralFormOperation.Equal;
      OperatorLength:=2;
      Precedence:=4;
     end else begin
      exit; // Since a single = is not a valid operator here
     end;
    end;
    '!':begin
     if (Position<Len) and (aExpression[Position+1]='=') then begin
      Operation:=TPasMultiLangPluralFormOperation.NotEqual;
      OperatorLength:=2;
      Precedence:=4;
     end else begin
      exit; // Since a single ! is not a valid binary operator here
     end;
    end;
    '&':begin
     if (Position<Len) and (aExpression[Position+1]='&') then begin
      Operation:=TPasMultiLangPluralFormOperation.LogicalAnd;
      OperatorLength:=2;
      Precedence:=3;
     end else begin
      exit; // Since the bitwise and operator is not supported here
     end;
    end;
    '|':begin
     if (Position<Len) and (aExpression[Position+1]='|') then begin
      Operation:=TPasMultiLangPluralFormOperation.LogicalOr;
      OperatorLength:=2;
      Precedence:=2;
     end else begin
      exit; // Since the bitwise or operator is not supported here
     end;
    end;
    else begin
     Precedence:=0;
    end;
   end;
   if Precedence<Max(aMinimumPrecedence,1) then begin
    break;
   end;
   inc(Position,OperatorLength);
   if not ParseSubExpression(Precedence+1) then begin // Plus one, since all these binary operators are left associative
    exit;
   end;
   Emit(Operation);
  until false;
  if aMinimumPrecedence<=1 then begin
   SkipWhiteSpace;
   if (Position<=Len) and (aExpression[Position]='?') then begin
    inc(Position);
    if not ParseSubExpression(1) then begin
     exit;
    end;
    SkipWhiteSpace;
    if (Position>Len) or (aExpression[Position]<>':') then begin
     exit;
    end;
    inc(Position);
    if not ParseSubExpression(1) then begin // Not plus one here, since the ternary operator is right associative
     exit;
    end;
    Emit(TPasMultiLangPluralFormOperation.Select);
   end;
  end;
  result:=true;
 end;
begin
 aInstructions:=nil;
 CountInstructions:=0;
 Position:=1;
 Len:=length(aExpression);
 result:=ParseSubExpression(1);
 if result then begin
  SkipWhiteSpace;
  result:=Position>Len; // Since trailing garbage does mean that the expression was not understood completely
 end;
 if result then begin
  SetLength(aInstructions,CountInstructions);
 end else begin
  aInstructions:=nil;
 end;
end;

class function TPasMultiLang.EvaluatePluralFormExpression(const aInstructions:TPasMultiLangPluralFormInstructions;const aCount:TPasMultiLangUInt64):TPasMultiLangUInt64;
var Index,StackPointer:TPasMultiLangSizeInt;
    Left,Right:TPasMultiLangUInt64;
    Stack:array[0..31] of TPasMultiLangUInt64;
begin
 result:=0;
 StackPointer:=0;
 for Index:=0 to length(aInstructions)-1 do begin
  case aInstructions[Index].Operation of
   TPasMultiLangPluralFormOperation.PushConstant,
   TPasMultiLangPluralFormOperation.PushCount:begin
    if StackPointer>=length(Stack) then begin
     exit; // Since the expression is too complex for the fixed size evaluation stack
    end;
    if aInstructions[Index].Operation=TPasMultiLangPluralFormOperation.PushCount then begin
     Stack[StackPointer]:=aCount;
    end else begin
     Stack[StackPointer]:=aInstructions[Index].Value;
    end;
    inc(StackPointer);
   end;
   TPasMultiLangPluralFormOperation.LogicalNot:begin
    if StackPointer<1 then begin
     exit;
    end;
    Stack[StackPointer-1]:=ord(Stack[StackPointer-1]=0) and 1;
   end;
   TPasMultiLangPluralFormOperation.Select:begin
    if StackPointer<3 then begin
     exit;
    end;
    dec(StackPointer,2);
    if Stack[StackPointer-1]<>0 then begin
     Stack[StackPointer-1]:=Stack[StackPointer];
    end else begin
     Stack[StackPointer-1]:=Stack[StackPointer+1];
    end;
   end;
   else begin
    if StackPointer<2 then begin
     exit;
    end;
    dec(StackPointer);
    Left:=Stack[StackPointer-1];
    Right:=Stack[StackPointer];
    case aInstructions[Index].Operation of
     TPasMultiLangPluralFormOperation.Multiply:begin
      Left:=Left*Right;
     end;
     TPasMultiLangPluralFormOperation.Divide:begin
      if Right=0 then begin
       Left:=0; // Since a division by zero must not crash here, a malformed expression is enough of a problem already
      end else begin
       Left:=Left div Right;
      end;
     end;
     TPasMultiLangPluralFormOperation.Modulo:begin
      if Right=0 then begin
       Left:=0;
      end else begin
       Left:=Left mod Right;
      end;
     end;
     TPasMultiLangPluralFormOperation.Add:begin
      Left:=Left+Right;
     end;
     TPasMultiLangPluralFormOperation.Subtract:begin
      Left:=Left-Right;
     end;
     TPasMultiLangPluralFormOperation.Less:begin
      Left:=ord(Left<Right) and 1;
     end;
     TPasMultiLangPluralFormOperation.LessOrEqual:begin
      Left:=ord(Left<=Right) and 1;
     end;
     TPasMultiLangPluralFormOperation.Greater:begin
      Left:=ord(Left>Right) and 1;
     end;
     TPasMultiLangPluralFormOperation.GreaterOrEqual:begin
      Left:=ord(Left>=Right) and 1;
     end;
     TPasMultiLangPluralFormOperation.Equal:begin
      Left:=ord(Left=Right) and 1;
     end;
     TPasMultiLangPluralFormOperation.NotEqual:begin
      Left:=ord(Left<>Right) and 1;
     end;
     TPasMultiLangPluralFormOperation.LogicalAnd:begin
      Left:=ord((Left<>0) and (Right<>0)) and 1;
     end;
     else {TPasMultiLangPluralFormOperation.LogicalOr:}begin
      Left:=ord((Left<>0) or (Right<>0)) and 1;
     end;
    end;
    Stack[StackPointer-1]:=Left;
   end;
  end;
 end;
 if StackPointer>0 then begin
  result:=Stack[StackPointer-1];
 end;
end;

// The default is the same one which GNU gettext does assume when a catalog does not contain any plural form
// information at all, namely the two form Germanic rule
procedure TPasMultiLang.SetDefaultPluralFormsUnlocked;
begin
 fCountPluralForms:=2;
 ParsePluralFormExpression('n != 1',fPluralFormInstructions);
end;

// The plural form information is stored inside the "Plural-Forms:" field of the header entry, which is the entry
// with an empty original string
procedure TPasMultiLang.ParsePluralFormsFromHeaderUnlocked;
var Position,LineEnd,Len:TPasMultiLangSizeInt;
    CountPluralForms:TPasMultiLangUInt64;
    Header,Line,Expression:TPasMultiLangUTF8String;
    Instructions:TPasMultiLangPluralFormInstructions;
    TranslationItem:TTranslationItem;
 // Only ASCII is lowercased here on purpose, since the header field names and the expression itself are ASCII only
 function LowerCaseASCII(const aString:TPasMultiLangUTF8String):TPasMultiLangUTF8String;
 var Index:TPasMultiLangSizeInt;
 begin
  result:=aString;
  for Index:=1 to length(result) do begin
   if result[Index] in ['A'..'Z'] then begin
    inc(PPasMultiLangUInt8(@result[Index])^,ord('a')-ord('A'));
   end;
  end;
 end;
 // Searches for a "<name> = " assignment and returns the position just after the equal sign, or otherwise zero
 function FindAssignment(const aLine,aName:TPasMultiLangUTF8String):TPasMultiLangSizeInt;
 var Index,NameLength:TPasMultiLangSizeInt;
 begin
  result:=0;
  NameLength:=length(aName);
  Index:=1;
  while Index<=(length(aLine)-(NameLength-1)) do begin
   if (Copy(aLine,Index,NameLength)=aName) and
      ((Index=1) or not (aLine[Index-1] in ['a'..'z','A'..'Z','0'..'9','_'])) then begin
    Index:=Index+NameLength;
    while (Index<=length(aLine)) and (aLine[Index] in [#0..#32]) do begin
     inc(Index);
    end;
    if (Index<=length(aLine)) and (aLine[Index]='=') then begin
     result:=Index+1;
     exit;
    end;
   end else begin
    inc(Index);
   end;
  end;
 end;
begin
 SetDefaultPluralFormsUnlocked;
 TranslationItem:=fTranslationItemHashMap[GetHashMapKey('','')];
 if assigned(TranslationItem) and (length(TranslationItem.fTranslated)>0) then begin
  Header:=LowerCaseASCII(TranslationItem.fTranslated[0]);
  Position:=Pos(TPasMultiLangUTF8String('plural-forms:'),Header);
  if Position>0 then begin
   LineEnd:=Position;
   while (LineEnd<=length(Header)) and not (Header[LineEnd] in [#10,#13]) do begin
    inc(LineEnd);
   end;
   Line:=Copy(Header,Position,LineEnd-Position);
   CountPluralForms:=0;
   Position:=FindAssignment(Line,'nplurals');
   if Position>0 then begin
    Len:=length(Line);
    while (Position<=Len) and (Line[Position] in [#0..#32]) do begin
     inc(Position);
    end;
    while (Position<=Len) and (Line[Position] in ['0'..'9']) do begin
     CountPluralForms:=(CountPluralForms*10)+TPasMultiLangUInt64(UInt8(TPasMultiLangUTF8Char(Line[Position]))-UInt8(TPasMultiLangUTF8Char('0')));
     inc(Position);
    end;
   end;
   Position:=FindAssignment(Line,'plural');
   if (Position>0) and (CountPluralForms>0) then begin
    Len:=length(Line);
    LineEnd:=Position;
    while (LineEnd<=Len) and (Line[LineEnd]<>';') do begin
     inc(LineEnd);
    end;
    Expression:=Copy(Line,Position,LineEnd-Position);
    if ParsePluralFormExpression(Expression,Instructions) then begin
     fCountPluralForms:=CountPluralForms;
     fPluralFormInstructions:=Instructions;
    end;
   end;
  end;
 end;
end;

function TPasMultiLang.GetPluralFormIndexUnlocked(const aCount:TPasMultiLangUInt64):TPasMultiLangSizeInt;
begin
 result:=TPasMultiLangSizeInt(EvaluatePluralFormExpression(fPluralFormInstructions,aCount));
 if result<0 then begin
  result:=0;
 end else if result>=fCountPluralForms then begin
  result:=fCountPluralForms-1; // The very same guard as the one inside the GNU gettext runtime
 end;
 if result<0 then begin
  result:=0;
 end;
end;

{ TPasMultiLangObjectGenericList<T>.TValueEnumerator }

constructor TPasMultiLangObjectGenericList<T>.TValueEnumerator.Create(const aObjectList:TPasMultiLangObjectGenericList<T>);
begin
 fObjectList:=aObjectList;
 fIndex:=-1;
end;

function TPasMultiLangObjectGenericList<T>.TValueEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=fIndex<fObjectList.fCount;
end;

function TPasMultiLangObjectGenericList<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fObjectList.fItems[fIndex];
end;

{ TPasMultiLang.TPasMultiLangObjectGenericList<T> }

constructor TPasMultiLangObjectGenericList<T>.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 fOwnsObjects:=true;
end;

destructor TPasMultiLangObjectGenericList<T>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TPasMultiLangObjectGenericList<T>.Clear;
var Index:TPasMultiLangSizeInt;
begin
 if fOwnsObjects then begin
  for Index:=fCount-1 downto 0 do begin
   FreeAndNil(fItems[Index]);
  end;
 end;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
end;

procedure TPasMultiLangObjectGenericList<T>.SetCount(const pNewCount:TPasMultiLangSizeInt);
var Index,NewAllocated:TPasMultiLangSizeInt;
    Item:Pointer;
begin
 if fCount<pNewCount then begin
  NewAllocated:=TPasMultiLang.RoundUpToPowerOfTwoSizeUInt(pNewCount);
  if fAllocated<NewAllocated then begin
   SetLength(fItems,NewAllocated);
   FillChar(fItems[fAllocated],(NewAllocated-fAllocated)*SizeOf(T),#0);
   fAllocated:=NewAllocated;
  end;
  FillChar(fItems[fCount],(pNewCount-fCount)*SizeOf(T),#0);
  fCount:=pNewCount;
 end else if fCount>pNewCount then begin
  if fOwnsObjects then begin
   for Index:=fCount-1 downto pNewCount do begin
    FreeAndNil(fItems[Index]);
   end;
  end;
  fCount:=pNewCount;
  if pNewCount<(fAllocated shr 2) then begin
   if pNewCount=0 then begin
    fItems:=nil;
    fAllocated:=0;
   end else begin
    NewAllocated:=fAllocated shr 1;
    SetLength(fItems,NewAllocated);
    fAllocated:=NewAllocated;
   end;
  end;
 end;
end;

function TPasMultiLangObjectGenericList<T>.GetItem(const pIndex:TPasMultiLangSizeInt):T;
begin
 if (pIndex<0) or (pIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=fItems[pIndex];
end;

procedure TPasMultiLangObjectGenericList<T>.SetItem(const pIndex:TPasMultiLangSizeInt;const pItem:T);
begin
 if (pIndex<0) or (pIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 fItems[pIndex]:=pItem;
end;

function TPasMultiLangObjectGenericList<T>.IndexOf(const pItem:T):TPasMultiLangSizeInt;
var Index:TPasMultiLangSizeInt;
begin
 for Index:=0 to fCount-1 do begin
  if fItems[Index]=pItem then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function TPasMultiLangObjectGenericList<T>.Add(const pItem:T):TPasMultiLangSizeInt;
begin
 result:=fCount;
 inc(fCount);
 if fAllocated<fCount then begin
  fAllocated:=fCount+fCount;
  SetLength(fItems,fAllocated);
 end;
 fItems[result]:=pItem;
end;

procedure TPasMultiLangObjectGenericList<T>.Insert(const pIndex:TPasMultiLangSizeInt;const pItem:T);
var OldCount:TPasMultiLangSizeInt;
{$ifdef fpc}
    a,b:pointer;
{$endif}
begin
 if pIndex>=0 then begin
  OldCount:=fCount;
  if fCount<pIndex then begin
   fCount:=pIndex+1;
  end else begin
   inc(fCount);
  end;
  if fAllocated<fCount then begin
   fAllocated:=fCount shl 1;
   SetLength(fItems,fAllocated);
  end;
  if OldCount<fCount then begin
   FillChar(fItems[OldCount],(fCount-OldCount)*SizeOf(T),#0);
  end;
  if pIndex<OldCount then begin
{$ifdef fpc}
  // Workaround for older FPC versions
   a:=@fItems[pIndex];
   b:=@fItems[pIndex+1];
   System.Move(a^,b^,(OldCount-pIndex)*SizeOf(T));
{$else}
   System.Move(fItems[pIndex],fItems[pIndex+1],(OldCount-pIndex)*SizeOf(T));
{$endif}
   FillChar(fItems[pIndex],SizeOf(T),#0);
  end;
  fItems[pIndex]:=pItem;
 end;
end;

procedure TPasMultiLangObjectGenericList<T>.Delete(const pIndex:TPasMultiLangSizeInt);
var Old:T;
{$ifdef fpc}
    a,b:pointer;
{$endif}
begin
 if (pIndex<0) or (pIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Old:=fItems[pIndex];
 dec(fCount);
 FillChar(fItems[pIndex],SizeOf(T),#0);
 if pIndex<>fCount then begin
{$ifdef fpc}
  // Workaround for older FPC versions
  a:=@fItems[pIndex+1];
  b:=@fItems[pIndex];
  System.Move(a^,b^,(fCount-pIndex)*SizeOf(T));
{$else}
  System.Move(fItems[pIndex+1],fItems[pIndex],(fCount-pIndex)*SizeOf(T));
{$endif}
  FillChar(fItems[fCount],SizeOf(T),#0);
 end;
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
 if fOwnsObjects then begin
  FreeAndNil(Old);
 end;
end;

procedure TPasMultiLangObjectGenericList<T>.Remove(const pItem:T);
var Index:TPasMultiLangSizeInt;
begin
 Index:=IndexOf(pItem);
 if Index>=0 then begin
  Delete(Index);
 end;
end;

procedure TPasMultiLangObjectGenericList<T>.Exchange(const pIndex,pWithIndex:TPasMultiLangSizeInt);
var Temporary:T;
begin
 if ((pIndex<0) or (pIndex>=fCount)) or ((pWithIndex<0) or (pWithIndex>=fCount)) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Temporary:=fItems[pIndex];
 fItems[pIndex]:=fItems[pWithIndex];
 fItems[pWithIndex]:=Temporary;
end;

function TPasMultiLangObjectGenericList<T>.GetEnumerator:TPasMultiLangObjectGenericList<T>.TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

{ TPasMultiLang.TPasMultiLangUTF8StringHashMap }

constructor TPasMultiLangUTF8StringHashMap<THashMapValue>.Create(const DefaultValue:THashMapValue);
begin
 inherited Create;
 fRealSize:=0;
 fLogSize:=0;
 fSize:=0;
 fEntities:=nil;
 fEntityToCellIndex:=nil;
 fCellToEntityIndex:=nil;
 fDefaultValue:=DefaultValue;
 fCanShrink:=true;
 Resize;
end;

destructor TPasMultiLangUTF8StringHashMap<THashMapValue>.Destroy;
var Counter:Int32;
begin
 Clear;
 for Counter:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Counter].Key);
  Finalize(fEntities[Counter].Value);
 end;
 SetLength(fEntities,0);
 SetLength(fEntityToCellIndex,0);
 SetLength(fCellToEntityIndex,0);
 inherited Destroy;
end;

procedure TPasMultiLangUTF8StringHashMap<THashMapValue>.Clear;
var Counter:Int32;
begin
 for Counter:=0 to length(fEntities)-1 do begin
  Finalize(fEntities[Counter].Key);
  Finalize(fEntities[Counter].Value);
 end;
 if fCanShrink then begin
  fRealSize:=0;
  fLogSize:=0;
  fSize:=0;
  SetLength(fEntities,0);
  SetLength(fEntityToCellIndex,0);
  SetLength(fCellToEntityIndex,0);
  Resize;
 end else begin
  for Counter:=0 to length(fCellToEntityIndex)-1 do begin
   fCellToEntityIndex[Counter]:=ENT_EMPTY;
  end;
  for Counter:=0 to length(fEntityToCellIndex)-1 do begin
   fEntityToCellIndex[Counter]:=CELL_EMPTY;
  end;
 end;
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.HashKey(const Key:THashMapKey):UInt32;
// xxHash32
const PRIME32_1=UInt32(2654435761);
      PRIME32_2=UInt32(2246822519);
      PRIME32_3=UInt32(3266489917);
      PRIME32_4=UInt32(668265263);
      PRIME32_5=UInt32(374761393);
      Seed=UInt32($1337c0d3);
      v1Initialization=UInt32(TPasMultiLangUInt64(TPasMultiLangUInt64(Seed)+TPasMultiLangUInt64(PRIME32_1)+TPasMultiLangUInt64(PRIME32_2)));
      v2Initialization=UInt32(TPasMultiLangUInt64(TPasMultiLangUInt64(Seed)+TPasMultiLangUInt64(PRIME32_2)));
      v3Initialization=UInt32(TPasMultiLangUInt64(TPasMultiLangUInt64(Seed)+TPasMultiLangUInt64(0)));
      v4Initialization=UInt32(TPasMultiLangUInt64(Int64(Int64(Seed)-Int64(PRIME32_1))));
      HashInitialization=UInt32(TPasMultiLangUInt64(TPasMultiLangUInt64(Seed)+TPasMultiLangUInt64(PRIME32_5)));
var v1,v2,v3,v4,DataLength:UInt32;
    p,e,Limit:PPasMultiLangUInt8;
begin
 p:=Pointer(@Key[1]);
 DataLength:=length(Key)*SizeOf(Key[1]);
 if DataLength>=16 then begin
  v1:=v1Initialization;
  v2:=v2Initialization;
  v3:=v3Initialization;
  v4:=v4Initialization;
  e:=@PPasMultiLangUInt8Array(Pointer(@Key[1]))^[DataLength-16];
  repeat
{$if defined(fpc) or declared(ROLDWord)}
   v1:=ROLDWord(v1+(UInt32(Pointer(p)^)*UInt32(PRIME32_2)),13)*UInt32(PRIME32_1);
{$else}
   inc(v1,UInt32(Pointer(p)^)*UInt32(PRIME32_2));
   v1:=((v1 shl 13) or (v1 shr 19))*UInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(UInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v2:=ROLDWord(v2+(UInt32(Pointer(p)^)*UInt32(PRIME32_2)),13)*UInt32(PRIME32_1);
{$else}
   inc(v2,UInt32(Pointer(p)^)*UInt32(PRIME32_2));
   v2:=((v2 shl 13) or (v2 shr 19))*UInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(UInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v3:=ROLDWord(v3+(UInt32(Pointer(p)^)*UInt32(PRIME32_2)),13)*UInt32(PRIME32_1);
{$else}
   inc(v3,UInt32(Pointer(p)^)*UInt32(PRIME32_2));
   v3:=((v3 shl 13) or (v3 shr 19))*UInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(UInt32));
{$if defined(fpc) or declared(ROLDWord)}
   v4:=ROLDWord(v4+(UInt32(Pointer(p)^)*UInt32(PRIME32_2)),13)*UInt32(PRIME32_1);
{$else}
   inc(v4,UInt32(Pointer(p)^)*UInt32(PRIME32_2));
   v4:=((v4 shl 13) or (v4 shr 19))*UInt32(PRIME32_1);
{$ifend}
   inc(p,SizeOf(UInt32));
  until {%H-}TPasMultiLangSizeUInt(p)>{%H-}TPasMultiLangSizeUInt(e);
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(v1,1)+ROLDWord(v2,7)+ROLDWord(v3,12)+ROLDWord(v4,18);
{$else}
  result:=((v1 shl 1) or (v1 shr 31))+
          ((v2 shl 7) or (v2 shr 25))+
          ((v3 shl 12) or (v3 shr 20))+
          ((v4 shl 18) or (v4 shr 14));
{$ifend}
 end else begin
  result:=HashInitialization;
 end;
 inc(result,DataLength);
 e:=@PPasMultiLangUInt8Array(Pointer(@Key[1]))^[DataLength];
 while ({%H-}TPasMultiLangSizeUInt(p)+SizeOf(UInt32))<={%H-}TPasMultiLangSizeUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(UInt32(Pointer(p)^)*UInt32(PRIME32_3)),17)*UInt32(PRIME32_4);
{$else}
  inc(result,UInt32(Pointer(p)^)*UInt32(PRIME32_3));
  result:=((result shl 17) or (result shr 15))*UInt32(PRIME32_4);
{$ifend}
  inc(p,SizeOf(UInt32));
 end;
 while {%H-}TPasMultiLangSizeUInt(p)<{%H-}TPasMultiLangSizeUInt(e) do begin
{$if defined(fpc) or declared(ROLDWord)}
  result:=ROLDWord(result+(UInt8(Pointer(p)^)*UInt32(PRIME32_5)),11)*UInt32(PRIME32_1);
{$else}
  inc(result,UInt8(Pointer(p)^)*UInt32(PRIME32_5));
  result:=((result shl 11) or (result shr 21))*UInt32(PRIME32_1);
{$ifend}
  inc(p,SizeOf(UInt8));
 end;
 result:=(result xor (result shr 15))*UInt32(PRIME32_2);
 result:=(result xor (result shr 13))*UInt32(PRIME32_3);
 result:=result xor (result shr 16);
{$if defined(CPU386) or defined(CPUAMD64)}
 // Special case: The hash value may be never zero
 result:=result or (-UInt32(ord(result=0) and 1));
{$else}
 if result=0 then begin
  // Special case: The hash value may be never zero
  result:=$ffffffff;
 end;
{$ifend}
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.FindCell(const Key:THashMapKey):UInt32;
var HashCode,Mask,Step:UInt32;
    Entity:Int32;
begin
 HashCode:=HashKey(Key);
 Mask:=(2 shl fLogSize)-1;
 Step:=((HashCode shl 1)+1) and Mask;
 if fLogSize<>0 then begin
  result:=HashCode shr (32-fLogSize);
 end else begin
  result:=0;
 end;
 repeat
  Entity:=fCellToEntityIndex[result];
  if (Entity=ENT_EMPTY) or ((Entity<>ENT_DELETED) and (fEntities[Entity].Key=Key)) then begin
   exit;
  end;
  result:=(result+Step) and Mask;
 until false;
end;

procedure TPasMultiLangUTF8StringHashMap<THashMapValue>.Resize;
var NewLogSize,NewSize,Cell,Entity,Counter:Int32;
    OldEntities:THashMapEntities;
    OldCellToEntityIndex:TPasMultiLangHashMapEntityIndices;
    OldEntityToCellIndex:TPasMultiLangHashMapEntityIndices;
begin
 NewLogSize:=0;
 NewSize:=fRealSize;
 while NewSize<>0 do begin
  NewSize:=NewSize shr 1;
  inc(NewLogSize);
 end;
 if NewLogSize<1 then begin
  NewLogSize:=1;
 end;
 fSize:=0;
 fRealSize:=0;
 fLogSize:=NewLogSize;
 OldEntities:=fEntities;
 OldCellToEntityIndex:=fCellToEntityIndex;
 OldEntityToCellIndex:=fEntityToCellIndex;
 fEntities:=nil;
 fCellToEntityIndex:=nil;
 fEntityToCellIndex:=nil;
 SetLength(fEntities,2 shl fLogSize);
 SetLength(fCellToEntityIndex,2 shl fLogSize);
 SetLength(fEntityToCellIndex,2 shl fLogSize);
 for Counter:=0 to length(fCellToEntityIndex)-1 do begin
  fCellToEntityIndex[Counter]:=ENT_EMPTY;
 end;
 for Counter:=0 to length(fEntityToCellIndex)-1 do begin
  fEntityToCellIndex[Counter]:=CELL_EMPTY;
 end;
 for Counter:=0 to length(OldEntityToCellIndex)-1 do begin
  Cell:=OldEntityToCellIndex[Counter];
  if Cell>=0 then begin
   Entity:=OldCellToEntityIndex[Cell];
   if Entity>=0 then begin
    Add(OldEntities[Counter].Key,OldEntities[Counter].Value);
   end;
  end;
 end;
 for Counter:=0 to length(OldEntities)-1 do begin
  Finalize(OldEntities[Counter].Key);
  Finalize(OldEntities[Counter].Value);
 end;
 SetLength(OldEntities,0);
 SetLength(OldCellToEntityIndex,0);
 SetLength(OldEntityToCellIndex,0);
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.Add(const Key:THashMapKey;const Value:THashMapValue):PHashMapEntity;
var Entity:Int32;
    Cell:UInt32;
begin
 result:=nil;
 while fRealSize>=(1 shl fLogSize) do begin
  Resize;
 end;
 Cell:=FindCell(Key);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@fEntities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
  exit;
 end;
 Entity:=fSize;
 inc(fSize);
 if Entity<(2 shl fLogSize) then begin
  fCellToEntityIndex[Cell]:=Entity;
  fEntityToCellIndex[Entity]:=Cell;
  inc(fRealSize);
  result:=@fEntities[Entity];
  result^.Key:=Key;
  result^.Value:=Value;
 end;
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.Get(const Key:THashMapKey;const CreateIfNotExist:boolean=false):PHashMapEntity;
var Entity:Int32;
    Cell:UInt32;
    Value:THashMapValue;
begin
 result:=nil;
 Cell:=FindCell(Key);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=@fEntities[Entity];
 end else if CreateIfNotExist then begin
  Initialize(Value);
  result:=Add(Key,Value);
 end;
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.TryGet(const Key:THashMapKey;out Value:THashMapValue):boolean;
var Entity:Int32;
begin
 Entity:=fCellToEntityIndex[FindCell(Key)];
 result:=Entity>=0;
 if result then begin
  Value:=fEntities[Entity].Value;
 end else begin
  Initialize(Value);
 end;
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.ExistKey(const Key:THashMapKey):boolean;
begin
 result:=fCellToEntityIndex[FindCell(Key)]>=0;
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.Delete(const Key:THashMapKey):boolean;
var Entity:Int32;
    Cell:UInt32;
begin
 result:=false;
 Cell:=FindCell(Key);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  Finalize(fEntities[Entity].Key);
  Finalize(fEntities[Entity].Value);
  fEntityToCellIndex[Entity]:=CELL_DELETED;
  fCellToEntityIndex[Cell]:=ENT_DELETED;
  result:=true;
 end;
end;

function TPasMultiLangUTF8StringHashMap<THashMapValue>.GetValue(const Key:THashMapKey):THashMapValue;
var Entity:Int32;
    Cell:UInt32;
begin
 Cell:=FindCell(Key);
 Entity:=fCellToEntityIndex[Cell];
 if Entity>=0 then begin
  result:=fEntities[Entity].Value;
 end else begin
  result:=fDefaultValue;
 end;
end;

procedure TPasMultiLangUTF8StringHashMap<THashMapValue>.SetValue(const Key:THashMapKey;const Value:THashMapValue);
begin
 Add(Key,Value);
end;

{ TPasMultiLang.TTranslationItem }

constructor TPasMultiLang.TTranslationItem.Create;
begin
 inherited Create;
 fContext:='';
 fOriginal:=nil;
 fTranslated:=nil;
end;

destructor TPasMultiLang.TTranslationItem.Destroy;
begin
 fContext:='';
 fOriginal:=nil;
 fTranslated:=nil;
 inherited Destroy;
end;

function TPasMultiLang.TTranslationItem.GetTranslated(const aPluralIndex:TPasMultiLangSizeInt):TPasMultiLangUTF8String;
var Index:TPasMultiLangSizeInt;
begin
 if aPluralIndex<0 then begin
  Index:=0;
 end else if aPluralIndex>=length(fTranslated) then begin
  Index:=length(fTranslated)-1;
 end else begin
  Index:=aPluralIndex;
 end;
 if (Index>=0) and (Index<length(fTranslated)) then begin
  result:=fTranslated[Index];
 end else begin
  result:='';
 end;
 if length(result)=0 then begin
  if aPluralIndex<0 then begin
   Index:=0;
  end else if aPluralIndex>=length(fOriginal) then begin
   Index:=length(fOriginal)-1;
  end else begin
   Index:=aPluralIndex;
  end;
  if (Index>=0) and (Index<length(fOriginal)) then begin
   result:=fOriginal[Index];
  end else begin
   result:='';
  end;
 end;
end;

{ TPasMultiLang }

constructor TPasMultiLang.Create;
begin
 inherited Create;
 fMultipleReaderSingleWriterLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fTranslationItemList:=TTranslationItemList.Create;
 fTranslationItemList.OwnsObjects:=true;
 fTranslationItemHashMap:=TTranslationItemHashMap.Create(nil);
 fPluralFormInstructions:=nil;
 SetDefaultPluralFormsUnlocked;
end;

destructor TPasMultiLang.Destroy;
begin
 FreeAndNil(fTranslationItemHashMap);
 FreeAndNil(fTranslationItemList);
 FreeAndNil(fMultipleReaderSingleWriterLock);
 inherited Destroy;
end;

procedure TPasMultiLang.Clear(const aLock:boolean);
begin
 if aLock then begin
  fMultipleReaderSingleWriterLock.AcquireWrite;
 end;
 try
  fTranslationItemList.Clear;
  fTranslationItemHashMap.Clear;
  SetDefaultPluralFormsUnlocked;
 finally
  if aLock then begin
   fMultipleReaderSingleWriterLock.ReleaseWrite;
  end;
 end;
end;

procedure TPasMultiLang.LoadFromStream(const aStream:TStream);
 function ReadDWord:UInt32;
 begin
  aStream.ReadBuffer(result,SizeOf(UInt32));
{$ifdef BIG_ENDIAN}
  result:=(result shl 24) or
          ((result and $ff00) shl 8) or
          ((result and $ff0000) shr 8) or
          (result shr 24);
{$endif}
 end;
 function ReadString:TPasMultiLangUTF8String;
 begin
  SetLength(result,ReadDWord);
  if length(result)>0 then begin
   aStream.ReadBuffer(result[1],length(result));
  end;
 end;
var Count:UInt32;
    Index,SubCount:TPasMultiLangSizeInt;
    TranslationItem:TTranslationItem;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
  Clear(false);
  if ReadDWord=$32717e47 then begin
   if ReadDWord=0 then begin
    Count:=ReadDWord;
    while Count>0 do begin
     dec(Count);
     TranslationItem:=TTranslationItem.Create;
     try
      TranslationItem.fContext:=ReadString;
      SubCount:=ReadDWord;
      SetLength(TranslationItem.fOriginal,SubCount);
      Index:=0;
      while Index<SubCount do begin
       TranslationItem.fOriginal[Index]:=ReadString;
       inc(Index);
      end;
      // The count of the translated strings is stored separately and must be read separately as well, since it can
      // differ from the count of the original strings, for example two original strings for the singular form and
      // the plural form in English but three translated strings for the plural forms in Russian
      SubCount:=ReadDWord;
      SetLength(TranslationItem.fTranslated,SubCount);
      Index:=0;
      while Index<SubCount do begin
       TranslationItem.fTranslated[Index]:=ReadString;
       inc(Index);
      end;
     finally
      try
       fTranslationItemList.Add(TranslationItem);
      finally
       for Index:=0 to length(TranslationItem.fOriginal)-1 do begin
        fTranslationItemHashMap[GetHashMapKey(TranslationItem.fContext,TranslationItem.fOriginal[Index])]:=TranslationItem;
       end;
      end;
     end;
    end;
   end;
  end;
  ParsePluralFormsFromHeaderUnlocked;
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

procedure TPasMultiLang.LoadFromFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TPasMultiLang.SaveToStream(const aStream:TStream);
 procedure WriteDWord(const aValue:UInt32);
{$ifdef BIG_ENDIAN}
 var Value:UInt32;
{$endif}
 begin
{$ifdef BIG_ENDIAN}
  Value:=(aValue shl 24) or
         ((aValue and $ff00) shl 8) or
         ((aValue and $ff0000) shr 8) or
         (aValue shr 24);
  aStream.WriteBuffer(Value,SizeOf(UInt32));
{$else}
  aStream.WriteBuffer(aValue,SizeOf(UInt32));
{$endif}
 end;
 procedure WriteString(const aValue:TPasMultiLangUTF8String);
 begin
  WriteDWord(length(aValue));
  if length(aValue)>0 then begin
   aStream.WriteBuffer(aValue[1],length(aValue));
  end;
 end;
var TranslationItem:TTranslationItem;
    Index:TPasMultiLangSizeInt;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  WriteDWord($32717e47);
  WriteDWord(0);
  WriteDWord(fTranslationItemList.Count);
  if fTranslationItemList.Count>0 then begin
   for TranslationItem in fTranslationItemList do begin
    WriteString(TranslationItem.fContext);
    WriteDWord(length(TranslationItem.fOriginal));
    for Index:=0 to length(TranslationItem.fOriginal)-1 do begin
     WriteString(TranslationItem.fOriginal[Index]);
    end;
    WriteDWord(length(TranslationItem.fTranslated));
    for Index:=0 to length(TranslationItem.fTranslated)-1 do begin
     WriteString(TranslationItem.fTranslated[Index]);
    end;
   end;
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

procedure TPasMultiLang.SaveToFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TPasMultiLang.LoadPOFromStream(const aStream:TStream);
var Data,Identifier,Context:TPasMultiLangUTF8String;
    CurrentChar:TPasMultiLangUTF8Char;
    Index,Len,Value:TPasMultiLangSizeInt;
 procedure SkipWhiteSpace;
 begin
  while (Index<=Len) and (Data[Index] in [#0..#9,#11..#12,#14..#32]) do begin
   inc(Index);
  end;
 end;
 procedure SkipLine;
 begin
  while (Index<=Len) and not (Data[Index] in [#10,#13]) do begin
   inc(Index);
  end;
 end;
 procedure SkipNewLine;
 begin
  while (Index<=Len) and (Data[Index] in [#10,#13]) do begin
   inc(Index);
  end;
 end;
 procedure ParseIdentifier;
 begin
  Identifier:='';
  while (Index<=Len) and (Data[Index] in ['a'..'z','_']) do begin
   Identifier:=Identifier+TPasMultiLangUTF8String(Data[Index]);
   inc(Index);
  end;
 end;
 function ParseString:TPasMultiLangUTF8String;
  function UTF32CharToUTF8(CharValue:UInt32):TPasMultiLangUTF8String;
  var Data:array[0..{$ifdef strictutf8}3{$else}5{$endif}] of TPasMultiLangUTF8Char;
      ResultLen:TPasMultiLangSizeInt;
  begin
   if CharValue=0 then begin
    result:=#0;
   end else begin
    if CharValue<=$7f then begin
     Data[0]:=TPasMultiLangUTF8Char(UInt8(CharValue));
     ResultLen:=1;
    end else if CharValue<=$7ff then begin
     Data[0]:=TPasMultiLangUTF8Char(UInt8($c0 or ((CharValue shr 6) and $1f)));
     Data[1]:=TPasMultiLangUTF8Char(UInt8($80 or (CharValue and $3f)));
     ResultLen:=2;
  {$ifdef strictutf8}
    end else if CharValue<=$d7ff then begin
     Data[0]:=TUTF8Char(UInt8($e0 or ((CharValue shr 12) and $0f)));
     Data[1]:=TUTF8Char(UInt8($80 or ((CharValue shr 6) and $3f)));
     Data[2]:=TUTF8Char(UInt8($80 or (CharValue and $3f)));
     ResultLen:=3;
    end else if CharValue<=$dfff then begin
     Data[0]:=#$ef; // $fffd
     Data[1]:=#$bf;
     Data[2]:=#$bd;
     ResultLen:=3;
  {$endif}
    end else if CharValue<=$ffff then begin
     Data[0]:=TPasMultiLangUTF8Char(UInt8($e0 or ((CharValue shr 12) and $0f)));
     Data[1]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 6) and $3f)));
     Data[2]:=TPasMultiLangUTF8Char(UInt8($80 or (CharValue and $3f)));
     ResultLen:=3;
    end else if CharValue<=$1fffff then begin
     Data[0]:=TPasMultiLangUTF8Char(UInt8($f0 or ((CharValue shr 18) and $07)));
     Data[1]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 12) and $3f)));
     Data[2]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 6) and $3f)));
     Data[3]:=TPasMultiLangUTF8Char(UInt8($80 or (CharValue and $3f)));
     ResultLen:=4;
  {$ifndef strictutf8}
    end else if CharValue<=$3ffffff then begin
     Data[0]:=TPasMultiLangUTF8Char(UInt8($f8 or ((CharValue shr 24) and $03)));
     Data[1]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 18) and $3f)));
     Data[2]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 12) and $3f)));
     Data[3]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 6) and $3f)));
     Data[4]:=TPasMultiLangUTF8Char(UInt8($80 or (CharValue and $3f)));
     ResultLen:=5;
    end else if CharValue<=$7fffffff then begin
     Data[0]:=TPasMultiLangUTF8Char(UInt8($fc or ((CharValue shr 30) and $01)));
     Data[1]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 24) and $3f)));
     Data[2]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 18) and $3f)));
     Data[3]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 12) and $3f)));
     Data[4]:=TPasMultiLangUTF8Char(UInt8($80 or ((CharValue shr 6) and $3f)));
     Data[5]:=TPasMultiLangUTF8Char(UInt8($80 or (CharValue and $3f)));
     ResultLen:=6;
  {$endif}
    end else begin
     Data[0]:=#$ef; // $fffd
     Data[1]:=#$bf;
     Data[2]:=#$bd;
     ResultLen:=3;
    end;
    SetString(result,pansichar(@Data[0]),ResultLen);
   end;
  end;
 begin
  result:='';
  while Index<=Len do begin
   SkipWhiteSpace;
   if (Index<=Len) and (Data[Index]='"') then begin
    inc(Index);
    while Index<=Len do begin
     case Data[Index] of
      '"':begin
       inc(Index);
       break;
      end;
      '\':begin
       inc(Index);
       if Index<=Len then begin
        case Data[Index] of
         '0':begin
          result:=result+#0;
          inc(Index);
         end;
         'a':begin
          result:=result+#7;
          inc(Index);
         end;
         'b':begin
          result:=result+#8;
          inc(Index);
         end;
         't':begin
          result:=result+#9;
          inc(Index);
         end;
         'n':begin
          result:=result+#10;
          inc(Index);
         end;
         'v':begin
          result:=result+#11;
          inc(Index);
         end;
         'f':begin
          result:=result+#12;
          inc(Index);
         end;
         'r':begin
          result:=result+#13;
          inc(Index);
         end;
         'x':begin
          result:=result+UTF32CharToUTF8(StrToIntDef('$'+string(Data[Index+1]+Data[Index+2]),0));
          inc(Index,3);
         end;
         'u':begin
          result:=result+UTF32CharToUTF8(StrToIntDef('$'+string(Data[Index+1]+Data[Index+2]+Data[Index+3]+Data[Index+4]),0));
          inc(Index,5);
         end;
         'U':begin
          result:=result+UTF32CharToUTF8(StrToInt64Def('$'+string(Data[Index+1]+Data[Index+2]+Data[Index+3]+Data[Index+4]+Data[Index+5]+Data[Index+6]+Data[Index+7]+Data[Index+8]),0));
          inc(Index,9);
         end;
         else begin
          result:=result+TPasMultiLangUTF8String(Data[Index]);
          inc(Index);
         end;
        end;
       end;
      end;
      else begin
       result:=result+TPasMultiLangUTF8String(Data[Index]);
       inc(Index);
      end;
     end;
    end;
    SkipWhiteSpace;
    SkipNewLine;
   end else begin
    break;
   end;
  end;
 end;
var TranslationItem:TTranslationItem;
 procedure FlushTranslationItem;
 var Index:TPasMultiLangSizeInt;
 begin
  if (length(TranslationItem.fOriginal)>0) and (length(TranslationItem.fTranslated)>0) then begin
   fTranslationItemList.Add(TranslationItem);
   for Index:=0 to length(TranslationItem.fOriginal)-1 do begin
    fTranslationItemHashMap[GetHashMapKey(TranslationItem.fContext,TranslationItem.fOriginal[Index])]:=TranslationItem;
   end;
   TranslationItem:=TTranslationItem.Create;
  end;
 end;
begin
 try
  Context:='';
  try
   fMultipleReaderSingleWriterLock.AcquireWrite;
   try
    Clear(false);
    Data:='';
    try
     SetLength(Data,aStream.Size);
     if aStream.Size>0 then begin
      aStream.ReadBuffer(Data[1],aStream.Size);
      TranslationItem:=TTranslationItem.Create;
      try
       Index:=1;
       Len:=length(Data);
       while Index<=Len do begin
          SkipWhiteSpace;
        if Index<=Len then begin
         case Data[Index] of
          'm':begin
           ParseIdentifier;
           if Identifier='msgctxt' then begin
            SkipWhiteSpace;
            Context:=ParseString;
           end else if Identifier='msgid' then begin
            FlushTranslationItem;
            SkipWhiteSpace;
            SetLength(TranslationItem.fOriginal,length(TranslationItem.fOriginal)+1);
            TranslationItem.fContext:=Context;
            Context:=''; // Since a msgctxt line does belong to the directly following msgid line only
            TranslationItem.fOriginal[length(TranslationItem.fOriginal)-1]:=ParseString;
           end else if Identifier='msgid_plural' then begin
            SkipWhiteSpace;
            SetLength(TranslationItem.fOriginal,length(TranslationItem.fOriginal)+1);
            TranslationItem.fOriginal[length(TranslationItem.fOriginal)-1]:=ParseString;
           end else if Identifier='msgstr' then begin
            if (Index<=Len) and (Data[Index]='[') then begin
             inc(Index);
             Value:=0;
             while (Index<=Len) and (Data[Index] in ['0'..'9']) do begin
              Value:=(Value*10)+(byte(TPasMultiLangUTF8Char(Data[Index]))-byte(TPasMultiLangUTF8Char('0')));
              inc(Index);
             end;
             if (Index<=Len) and (Data[Index]=']') then begin
              inc(Index);
             end else begin
              break;
             end;
            end else begin
             Value:=-1;
            end;
            SkipWhiteSpace;
            if Value<0 then begin
             SetLength(TranslationItem.fTranslated,length(TranslationItem.fTranslated)+1);
             TranslationItem.fTranslated[length(TranslationItem.fTranslated)-1]:=ParseString;
            end else begin
             while length(TranslationItem.fTranslated)<=Value do begin // Must be <= here, since index Value itself must exist as well
              SetLength(TranslationItem.fTranslated,length(TranslationItem.fTranslated)+1);
              TranslationItem.fTranslated[length(TranslationItem.fTranslated)-1]:='';
             end;
             TranslationItem.fTranslated[Value]:=ParseString;
            end;
           end else begin
            SkipLine;
           end;
          end;
          else begin
           SkipLine;
          end;
         end;
        end;
        SkipNewLine;
       end;
       FlushTranslationItem;
      finally
       FreeAndNil(TranslationItem);
      end;
     end;
    finally
     Data:='';
    end;
    ParsePluralFormsFromHeaderUnlocked;
   finally
    fMultipleReaderSingleWriterLock.ReleaseWrite;
   end;
  finally
  end;
 finally
 end;
end;

procedure TPasMultiLang.LoadPOFromFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadPOFromStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TPasMultiLang.SavePOToStream(const aStream:TStream);
var TranslationItem:TTranslationItem;
 function EscapeString(const aString:TPasMultiLangUTF8String):TPasMultiLangUTF8String;
 var Index,Len:TPasMultiLangSizeInt;
 begin
  result:='';
  Index:=1;
  Len:=length(aString);
  while Index<=Len do begin
   case aString[Index] of
    '''':begin
     result:=result+'\''';
     inc(Index);
    end;
    '"':begin
     result:=result+'\"';
     inc(Index);
    end;
    #0:begin
     result:=result+'\0';
     inc(Index);
    end;
    #7:begin
     result:=result+'\a';
     inc(Index);
    end;
    #8:begin
     result:=result+'\b';
     inc(Index);
    end;
    #9:begin
     result:=result+'\t';
     inc(Index);
    end;
    #10:begin
     result:=result+'\n';
     inc(Index);
    end;
    #11:begin
     result:=result+'\v';
     inc(Index);
    end;
    #12:begin
     result:=result+'\f';
     inc(Index);
    end;
    #13:begin
     result:=result+'\r';
     inc(Index);
    end;
    else begin
     result:=result+TPasMultiLangUTF8String(aString[Index]);
     inc(Index);
    end;
   end;
  end;
 end;
 procedure WriteString(const aString:TPasMultiLangUTF8String);
 begin
  if length(aString)>0 then begin
   aStream.WriteBuffer(aString[1],length(aString));
  end;
 end;
var Index:TPasMultiLangSizeInt;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  for TranslationItem in fTranslationItemList do begin
   if length(TranslationItem.fOriginal)>0 then begin
    if length(TranslationItem.fContext)>0 then begin
     WriteString('msgctxt "'+EscapeString(TranslationItem.fContext)+'"'#10);
    end;
    WriteString('msgid "'+EscapeString(TranslationItem.fOriginal[0])+'"'#10);
    if length(TranslationItem.fOriginal)>1 then begin
     WriteString('msgid_plural "'+EscapeString(TranslationItem.fOriginal[1])+'"'#10);
    end;
    if length(TranslationItem.fTranslated)=1 then begin
     WriteString('msgstr "'+EscapeString(TranslationItem.fTranslated[0])+'"'#10);
    end else if length(TranslationItem.fTranslated)>1 then begin
     for Index:=0 to length(TranslationItem.fTranslated)-1 do begin
      WriteString('msgstr['+TPasMultiLangUTF8String(IntToStr(Index))+'] "'+EscapeString(TranslationItem.fTranslated[Index])+'"'#10);
     end;
    end;
    WriteString(#10);
   end;
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

procedure TPasMultiLang.SavePOToFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SavePOToStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

procedure TPasMultiLang.LoadMOFromStream(const aStream:TStream);
const MOFileHeaderMagic=UInt32($950412de);
type TMOFileHeader=packed record
      Magic:UInt32;
      Revision:UInt32;
      CountStrings:UInt32;
      OriginalTableOffset:UInt32;
      TranslatedTableOffset:UInt32;
      HashTableSize:UInt32;
      HashTableOffset:UInt32;
     end;
     TMOStringInfo=packed record
      Length:UInt32;
      Offset:UInt32;
     end;
     TMOStringTable=array of TMOStringInfo;
 function ReadDWord:UInt32;
 begin
  aStream.ReadBuffer(result,SizeOf(UInt32));
{$ifdef BIG_ENDIAN}
  result:=(result shl 24) or
          ((result and $ff00) shl 8) or
          ((result and $ff0000) shr 8) or
          (result shr 24);
{$endif}
 end;
 // The singular form and the possible plural forms are stored as NUL character separated substrings inside one
 // and the same string blob, so they must be split apart again here
 procedure SplitAtNullCharacters(const aString:TPasMultiLangUTF8String;out aStrings:TPasMultiLangUTF8StringArray);
 var StartPosition,CurrentPosition,Count:TPasMultiLangSizeInt;
 begin
  aStrings:=nil;
  Count:=0;
  StartPosition:=1;
  for CurrentPosition:=1 to length(aString)+1 do begin
   if (CurrentPosition>length(aString)) or (aString[CurrentPosition]=TPasMultiLangUTF8Char(#0)) then begin
    SetLength(aStrings,Count+1);
    aStrings[Count]:=Copy(aString,StartPosition,CurrentPosition-StartPosition);
    inc(Count);
    StartPosition:=CurrentPosition+1;
   end;
  end;
 end;
var MOFileHeader:TMOFileHeader;
    OriginalStringTable,TranslatedStringTable:TMOStringTable;
    Index:UInt32;
    SubIndex,Position:TPasMultiLangSizeInt;
    RawOriginal,RawTranslated:TPasMultiLangUTF8String;
    TranslationItem:TTranslationItem;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
  OriginalStringTable:=nil;
  try
   TranslatedStringTable:=nil;
   try
    Clear(false);
    MOFileHeader.Magic:=ReadDWord;
    if MOFileHeader.Magic=MOFileHeaderMagic then begin
     MOFileHeader.Revision:=ReadDWord;
     // The major revision is stored in the upper 16 bits and the minor revision in the lower 16 bits, where only
     // the major revisions 0 and 1 do exist so far
     if (MOFileHeader.Revision shr 16)<=1 then begin
      MOFileHeader.CountStrings:=ReadDWord;
      MOFileHeader.OriginalTableOffset:=ReadDWord;
      MOFileHeader.TranslatedTableOffset:=ReadDWord;
      MOFileHeader.HashTableSize:=ReadDWord;
      MOFileHeader.HashTableOffset:=ReadDWord;
      if MOFileHeader.CountStrings>0 then begin
       if aStream.Seek(MOFileHeader.OriginalTableOffset,soBeginning)<>MOFileHeader.OriginalTableOffset then begin
        raise EInOutError.Create('Seek error');
       end;
       SetLength(OriginalStringTable,MOFileHeader.CountStrings);
       aStream.ReadBuffer(OriginalStringTable[0],MOFileHeader.CountStrings*SizeOf(TMOStringInfo));
       if aStream.Seek(MOFileHeader.TranslatedTableOffset,soBeginning)<>MOFileHeader.TranslatedTableOffset then begin
        raise EInOutError.Create('Seek error');
       end;
       SetLength(TranslatedStringTable,MOFileHeader.CountStrings);
       aStream.ReadBuffer(TranslatedStringTable[0],MOFileHeader.CountStrings*SizeOf(TMOStringInfo));
       Index:=0;
       while Index<MOFileHeader.CountStrings do begin
        RawOriginal:='';
        SetLength(RawOriginal,OriginalStringTable[Index].Length);
        if OriginalStringTable[Index].Length>0 then begin
         if aStream.Seek(OriginalStringTable[Index].Offset,soBeginning)<>OriginalStringTable[Index].Offset then begin
          raise EInOutError.Create('Seek error');
         end;
         aStream.ReadBuffer(RawOriginal[1],OriginalStringTable[Index].Length);
        end;
        RawTranslated:='';
        SetLength(RawTranslated,TranslatedStringTable[Index].Length);
        if TranslatedStringTable[Index].Length>0 then begin
         if aStream.Seek(TranslatedStringTable[Index].Offset,soBeginning)<>TranslatedStringTable[Index].Offset then begin
          raise EInOutError.Create('Seek error');
         end;
         aStream.ReadBuffer(RawTranslated[1],TranslatedStringTable[Index].Length);
        end;
        TranslationItem:=TTranslationItem.Create;
        try
         // A context is stored as context + EOT character + original string in front of the original string itself
         Position:=Pos(TPasMultiLangUTF8String(#4),RawOriginal);
         if Position>0 then begin
          TranslationItem.fContext:=Copy(RawOriginal,1,Position-1);
          RawOriginal:=Copy(RawOriginal,Position+1,length(RawOriginal)-Position);
         end else begin
          TranslationItem.fContext:='';
         end;
         SplitAtNullCharacters(RawOriginal,TranslationItem.fOriginal);
         SplitAtNullCharacters(RawTranslated,TranslationItem.fTranslated);
        finally
         try
          fTranslationItemList.Add(TranslationItem);
         finally
          for SubIndex:=0 to length(TranslationItem.fOriginal)-1 do begin
           fTranslationItemHashMap[GetHashMapKey(TranslationItem.fContext,TranslationItem.fOriginal[SubIndex])]:=TranslationItem;
          end;
         end;
        end;
        inc(Index);
       end;
      end;
     end;
    end;
   finally
    TranslatedStringTable:=nil;
   end;
  finally
   OriginalStringTable:=nil;
  end;
  ParsePluralFormsFromHeaderUnlocked;
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

procedure TPasMultiLang.LoadMOFromFile(const aFileName:string);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadMOFromStream(FileStream);
 finally
  FreeAndNil(FileStream);
 end;
end;

// Expects that the read lock is already acquired by the caller, so that a plural form index and the translation
// itself are always fetched from one and the same state. An empty aOriginalPlural does mean that the caller does
// not know any plural form at all, and aFallbackIndex is the form which is used when the catalog does not contain
// the string, where the plural rule of the source language does apply then, which is the English one, just like
// the GNU gettext runtime does it.
function TPasMultiLang.TranslateUnlocked(const aContext,aOriginal,aOriginalPlural:TPasMultiLangUTF8String;const aPluralIndex,aFallbackIndex:TPasMultiLangSizeInt;const aCreateIfNotExist:boolean):TPasMultiLangUTF8String;
var HashMapKey:TPasMultiLangUTF8String;
    TranslationItem:TTranslationItem;
begin
 HashMapKey:=GetHashMapKey(aContext,aOriginal);
 TranslationItem:=fTranslationItemHashMap[HashMapKey];
 if assigned(TranslationItem) then begin
  result:=TranslationItem.GetTranslated(aPluralIndex);
 end else begin
  if (length(aOriginalPlural)>0) and (aFallbackIndex>0) then begin
   result:=aOriginalPlural;
  end else begin
   result:=aOriginal;
  end;
  if aCreateIfNotExist then begin
   fMultipleReaderSingleWriterLock.ReadToWrite;
   try
    TranslationItem:=TTranslationItem.Create;
    try
     TranslationItem.fContext:=aContext;
     if length(aOriginalPlural)>0 then begin
      SetLength(TranslationItem.fOriginal,2);
      TranslationItem.fOriginal[0]:=aOriginal;
      TranslationItem.fOriginal[1]:=aOriginalPlural;
      SetLength(TranslationItem.fTranslated,2);
      TranslationItem.fTranslated[0]:=aOriginal;
      TranslationItem.fTranslated[1]:=aOriginalPlural;
     end else begin
      SetLength(TranslationItem.fOriginal,1);
      TranslationItem.fOriginal[0]:=aOriginal;
      SetLength(TranslationItem.fTranslated,1);
      TranslationItem.fTranslated[0]:=aOriginal;
     end;
    finally
     try
      fTranslationItemList.Add(TranslationItem);
     finally
      fTranslationItemHashMap[HashMapKey]:=TranslationItem;
     end;
    end;
   finally
    fMultipleReaderSingleWriterLock.WriteToRead;
   end;
  end;
 end;
end;

function TPasMultiLang.Translate(const aOriginal:TPasMultiLangUTF8String;const aPluralIndex:TPasMultiLangSizeInt=0;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String;
begin
 result:=Translate('',aOriginal,aPluralIndex,aCreateIfNotExist);
end;

function TPasMultiLang.Translate(const aContext,aOriginal:TPasMultiLangUTF8String;const aPluralIndex:TPasMultiLangSizeInt=0;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  result:=TranslateUnlocked(aContext,aOriginal,'',aPluralIndex,0,aCreateIfNotExist);
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

function TPasMultiLang.TranslatePlural(const aOriginal,aOriginalPlural:TPasMultiLangUTF8String;const aCount:TPasMultiLangUInt64;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String;
begin
 result:=TranslatePlural('',aOriginal,aOriginalPlural,aCount,aCreateIfNotExist);
end;

function TPasMultiLang.TranslatePlural(const aContext,aOriginal,aOriginalPlural:TPasMultiLangUTF8String;const aCount:TPasMultiLangUInt64;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  result:=TranslateUnlocked(aContext,
                            aOriginal,
                            aOriginalPlural,
                            GetPluralFormIndexUnlocked(aCount),
                            ord(aCount<>1) and 1,
                            aCreateIfNotExist);
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

function TPasMultiLang.GetPluralFormIndex(const aCount:TPasMultiLangUInt64):TPasMultiLangSizeInt;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  result:=GetPluralFormIndexUnlocked(aCount);
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

// For catalogs which are built up at runtime instead of being loaded from a PO or MO file, where no header entry
// with the plural form information does exist
function TPasMultiLang.SetPluralForms(const aCountPluralForms:TPasMultiLangSizeInt;const aExpression:TPasMultiLangUTF8String):boolean;
var Instructions:TPasMultiLangPluralFormInstructions;
begin
 result:=(aCountPluralForms>0) and ParsePluralFormExpression(aExpression,Instructions);
 if result then begin
  fMultipleReaderSingleWriterLock.AcquireWrite;
  try
   fCountPluralForms:=aCountPluralForms;
   fPluralFormInstructions:=Instructions;
  finally
   fMultipleReaderSingleWriterLock.ReleaseWrite;
  end;
 end;
end;

end.
