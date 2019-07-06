(******************************************************************************
 *                                PasMultiLang                                *
 ******************************************************************************
 *                  Version see PASMULTILANG_VERSION code constant            *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2003-2019, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 ******************************************************************************
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

const PASMULTILANG_VERSION='1.00.2019.07.06.0000';

type TPasMultiLangSizeInt={$if declared(NativeInt)}NativeInt{$elseif declared(PtrInt)}PtrInt{$else}Int32{$ifend};
     TPasMultiLangSizeUInt={$if declared(NativeUInt)}NativeUInt{$elseif declared(PtrUInt)}PtrUInt{$else}UInt32{$ifend};

     TPasMultiLangUInt64=UInt64;

     TPasMultiLangUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     TPasMultiLangUTF8Char=AnsiChar;

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
              fOriginal:array of TPasMultiLangUTF8String;
              fTranslated:array of TPasMultiLangUTF8String;
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
      protected
       class function RoundUpToPowerOfTwoSizeUInt(x:TPasMultiLangSizeUInt):TPasMultiLangSizeUInt; static;
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
        fTranslationItemHashMap[TranslationItem.fOriginal[Index]]:=TranslationItem;
       end;
      end;
     end;
    end;
   end;
  end;
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
    fTranslationItemHashMap[TranslationItem.fOriginal[Index]]:=TranslationItem;
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
             while length(TranslationItem.fTranslated)<Value do begin
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
var MOFileHeader:TMOFileHeader;
    OriginalStringTable,TranslatedStringTable:TMOStringTable;
    Index:UInt32;
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
     if MOFileHeader.Revision=MOFileHeaderMagic then begin
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
        TranslationItem:=TTranslationItem.Create;
        try
         SetLength(TranslationItem.fOriginal,1);
         SetLength(TranslationItem.fOriginal[0],OriginalStringTable[Index].Length);
         if OriginalStringTable[Index].Length>0 then begin
          if aStream.Seek(OriginalStringTable[Index].Offset,soBeginning)<>OriginalStringTable[Index].Offset then begin
           raise EInOutError.Create('Seek error');
          end;
          aStream.ReadBuffer(TranslationItem.fOriginal[0][1],OriginalStringTable[Index].Length);
         end;
         SetLength(TranslationItem.fTranslated,1);
         SetLength(TranslationItem.fTranslated[0],TranslatedStringTable[Index].Length);
         if TranslatedStringTable[Index].Length>0 then begin
          if aStream.Seek(TranslatedStringTable[Index].Offset,soBeginning)<>TranslatedStringTable[Index].Offset then begin
           raise EInOutError.Create('Seek error');
          end;
          aStream.ReadBuffer(TranslationItem.fTranslated[0][1],TranslatedStringTable[Index].Length);
         end;
        finally
         fTranslationItemList.Add(TranslationItem);
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

function TPasMultiLang.Translate(const aOriginal:TPasMultiLangUTF8String;const aPluralIndex:TPasMultiLangSizeInt=0;const aCreateIfNotExist:boolean=false):TPasMultiLangUTF8String;
var TranslationItem:TTranslationItem;
begin
 result:=aOriginal;
 fMultipleReaderSingleWriterLock.AcquireRead;
 try
  TranslationItem:=fTranslationItemHashMap[aOriginal];
  if assigned(TranslationItem) then begin
   result:=TranslationItem.GetTranslated(aPluralIndex);
  end else if aCreateIfNotExist then begin
   fMultipleReaderSingleWriterLock.ReadToWrite;
   try
    TranslationItem:=TTranslationItem.Create;
    try
     SetLength(TranslationItem.fOriginal,1);
     TranslationItem.fOriginal[0]:=aOriginal;
     SetLength(TranslationItem.fTranslated,1);
     TranslationItem.fTranslated[0]:=aOriginal;
    finally
     try
      fTranslationItemList.Add(TranslationItem);
     finally
      fTranslationItemHashMap[aOriginal]:=TranslationItem;
     end;
    end;
   finally
    fMultipleReaderSingleWriterLock.WriteToRead;
   end;
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

end.
