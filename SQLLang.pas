unit SQLLang;

interface
 uses
  System.Classes, System.SysUtils, System.Generics.Collections;

 type
  TFieldType = (ftInteger, ftString, ftFloat, ftDateTime, ftBlob, ftBoolean, ftParam);
  TDIType = (diInc, diDec, diDiv, diMul);
  TWhereUnion = (wuAnd, wuOr, wuNotAnd, wuNotOr);

  TField = record
   private
    function GetSQL: string;
   public
    FieldType:TFieldType;
    FieldName:string;
    PrimaryKey:Boolean;
    AutoInc:Boolean;
    NotNull:Boolean;
    property SQL:string read GetSQL;
  end;
  TFields = TList<TField>;
  TFieldNames = TStringList;
  TUnionWhere = TStringList;

  TInsertValue = record
   public
    FieldType:TFieldType;
    FieldName:string;
    Value:Variant;
  end;
  TInsertValues = TList<TInsertValue>;

  TDIValue = record
   public
    FieldType:TFieldType;
    DIType:TDIType;
    FieldName:string;
    Value:Variant;
  end;
  TDIValues = TList<TDIValue>;

  TTable      = class;
  TInsertInto = class;
  TUpdate     = class;
  TSelect     = class;
  TDelete     = class;
  TDropTable  = class;
  TUpdateBlob  = class;

  BaseSQL = class
   private
    FName:string;
    procedure SetName(const Value: string);
   public
    property TableName:string read FName write SetName;
  end;

  SQL = class(BaseSQL)
   private
    FWhereStr:string;
    FUWheres:TUnionWhere;
    function GetWhere: string;
   public
    function GetSQL:string; virtual; abstract;
    procedure EndCreate; virtual;
    procedure Clear; virtual;
    procedure WhereField(FieldName, Oper: string; FieldValue: string; Union:TWhereUnion = wuAnd); overload;
    procedure WhereField(FieldName, Oper: string; FieldValue: Extended; Union:TWhereUnion = wuAnd); overload;
    procedure WhereField(FieldName, Oper: string; FieldValue: Integer; Union:TWhereUnion = wuAnd); overload;
    procedure WhereField(FieldName, Oper: string; FieldValue: TDateTime; Union:TWhereUnion = wuAnd); overload;
    procedure WhereField(FieldName, Oper: string; FieldValue: Boolean; Union:TWhereUnion = wuAnd); overload;

    procedure WhereFieldWOQ(FieldName, Oper: string; FieldValue: string; Union:TWhereUnion = wuAnd);

    procedure WhereFieldIN(FieldName: string; FieldValues:array of string; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldIN(FieldName: string; FieldValues:array of Extended; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldIN(FieldName: string; FieldValues:array of Integer; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldIN(FieldName: string; FieldValues:array of TDateTime; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldIN(FieldName: string; FieldValues:array of Boolean; Union:TWhereUnion = wuAnd); overload;

    procedure WhereFieldEqual(FieldName: string; FieldValue: string; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldEqual(FieldName: string; FieldValue: Extended; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldEqual(FieldName: string; FieldValue: Integer; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldEqual(FieldName: string; FieldValue: TDateTime; Union:TWhereUnion = wuAnd); overload;
    procedure WhereFieldEqual(FieldName: string; FieldValue: Boolean; Union:TWhereUnion = wuAnd); overload;
    procedure WhereNotFieldEqual(FieldName: string; FieldValue: string; Union:TWhereUnion = wuAnd); overload;
    procedure WhereNotFieldEqual(FieldName: string; FieldValue: Extended; Union:TWhereUnion = wuAnd); overload;
    procedure WhereNotFieldEqual(FieldName: string; FieldValue: Integer; Union:TWhereUnion = wuAnd); overload;
    procedure WhereNotFieldEqual(FieldName: string; FieldValue: TDateTime; Union:TWhereUnion = wuAnd); overload;
    procedure WhereNotFieldEqual(FieldName: string; FieldValue: Boolean; Union:TWhereUnion = wuAnd); overload;
    procedure WhereStr(Value:string);
    constructor Create; virtual;
    property Where:string read GetWhere;
   public
    class function CreateField:TField;
    class function CreateTable:TTable; overload;
    class function CreateTable(TableName:string):TTable; overload;
    class function InsertInto:TInsertInto; overload;
    class function InsertInto(TableName:string):TInsertInto; overload;
    class function Delete:TDelete; overload;
    class function Delete(TableName:string):TDelete; overload;
    class function DropTable:TDropTable;
    class function Update:TUpdate; overload;
    class function Update(TableName:string):TUpdate; overload;
    class function Select:TSelect; overload;
    class function Select(TableName:string):TSelect; overload;
    class function UpdateBlob:TUpdateBlob; overload;
    class function UpdateBlob(TableName:string):TUpdateBlob; overload;
    //
    class function PRAGMA(Key, Value:string):string;
    class function SelectLastInsertID:string;
    //
  end;

  TTable = class(BaseSQL)
   private
    function GetField(Index: Integer): TField;
    procedure SetField(Index: Integer; const Value: TField);
   protected
    FFields:TFields;
   public
    function GetSQL:string; virtual;
    procedure AddField(Name:string; FieldType:TFieldType; PrimaryKey:Boolean = False; NotNull:Boolean = False; AutoInc:Boolean = False); virtual;
    procedure EndCreate; virtual;
    procedure Clear; virtual;
    constructor Create; overload; virtual;
    constructor Create(pTableName:string); overload; virtual;
    property Fields[Index:Integer]:TField read GetField write SetField;
    property TableName;
  end;

  TInsertInto = class(BaseSQL)
   protected
    FFieldValues:TInsertValues;
   public
    function GetSQL:string;
    procedure EndCreate;
    procedure Clear;
    procedure AddValue(FieldName:string; FieldValue:Integer); overload;
    procedure AddValue(FieldName:string; FieldValue:string); overload;
    procedure AddValue(FieldName:string; FieldValue:Extended); overload;
    procedure AddValue(FieldName:string; FieldValue:TDateTime); overload;
    procedure AddValue(FieldName:string; FieldValue:Boolean); overload;
    procedure AddValueAsParam(FieldName:string; ParamChar:string = ':'; CharOnly:Boolean = False);
    constructor Create; virtual;
    property TableName;
  end;

  TUpdate = class(SQL)
   protected
    FFieldValues:TInsertValues;
    FDIValues:TDIValues;
   public
    function GetSQL:string; override;
    procedure Clear; override;
    procedure AddValue(FieldName:string; FieldValue:Integer); overload;
    procedure AddValue(FieldName:string; FieldValue:string); overload;
    procedure AddValue(FieldName:string; FieldValue:Extended); overload;
    procedure AddValue(FieldName:string; FieldValue:TDateTime); overload;
    procedure AddValue(FieldName:string; FieldValue:Boolean); overload;
    procedure IncValue(FieldName:string; Value:Integer); overload;
    procedure IncValue(FieldName:string; Value:Extended); overload;
    procedure DecValue(FieldName:string; Value:Integer); overload;
    procedure DecValue(FieldName:string; Value:Extended); overload;
    procedure MulValue(FieldName:string; Value:Integer); overload;
    procedure MulValue(FieldName:string; Value:Extended); overload;
    procedure DivValue(FieldName:string; Value:Integer); overload;
    procedure DivValue(FieldName:string; Value:Extended); overload;
    procedure AddValueAsParam(FieldName:string; ParamChar:string = ':'; CharOnly:Boolean = False);
    constructor Create; override;
    property TableName;
  end;

  TSelect = class(SQL)
   private
    FOrderBy:TStringList;
    FJoins:TStringList;
    FLimitInt:Integer;
    FDistinct:Boolean;
    function GetField(Index: Integer): string;
    procedure SetField(Index: Integer; const Value: string);
    function GetOrderBy: string;
   protected
    FFields:TFieldNames;
   public
    function GetSQL:string; override;
    procedure AddField(Name:string);
    procedure AddFieldCount(Name:string; Alias:string = '');
    procedure InnerJoin(JoinTable, BaseField, JoinField:string);
    procedure LeftJoin(JoinTable, BaseField, JoinField:string);
    procedure RightJoin(JoinTable, BaseField, JoinField:string);
    procedure OrderBy(FieldName:string; DESC:Boolean = False);
    procedure Clear; override;
    constructor Create; override;
    property Fields[Index:Integer]:string read GetField write SetField;
    property Distinct:Boolean read FDistinct write FDistinct;
    property Limit:Integer read FLimitInt write FLimitInt;
    property OrderByStr:string read GetOrderBy;
    property TableName;
  end;

  TDelete = class(SQL)
   public
    function GetSQL:string; override;
    procedure Clear; override;
    constructor Create; override;
    property Where;
    property TableName;
  end;

  TDropTable = class(BaseSQL)
   public
    function GetSQL:string;
    procedure EndCreate;
    procedure Clear;
    constructor Create; virtual;
    property TableName;
  end;

  TUpdateBlob = class(SQL)
   private
    FBlobField:string;
   public
    function GetSQL:string; override;
    property BlobField:string read FBlobField write FBlobField;
    property Where;
    property TableName;
  end;

  function Field(Name:string; FieldType:TFieldType; PrimaryKey, NotNull, AutoInc:Boolean):TField;
  function InsertValue(Name:string; FieldType:TFieldType; Value:Variant):TInsertValue;
  function FloatToSQLStr(Value:Extended):string;
  function FieldTypeToStr(Value:TFieldType):string;
  function FieldTypeToString(Value:TFieldType):string;

implementation

function FloatToSQLStr(Value:Extended):string;
begin
 Result:=FloatToStr(Value);
 Result:=StringReplace(Result, ',', '.', [rfReplaceAll]);
end;

function FieldTypeToStr(Value:TFieldType):string;
begin
 case Value of
  ftInteger:  Result:='INTEGER';
  ftString:   Result:='TEXT';
  ftFloat:    Result:='REAL';
  ftDateTime: Result:='REAL';
  ftBlob:     Result:='BLOB';
  ftBoolean:  Result:='INTEGER';
 end;
end;

function FieldTypeToString(Value:TFieldType):string;
begin
 case Value of
  ftInteger:  Result:='ftInteger';
  ftString:   Result:='ftString';
  ftFloat:    Result:='ftFloat';
  ftDateTime: Result:='ftDateTime';
  ftBlob:     Result:='ftBlob';
  ftBoolean:  Result:='ftBoolean';
 end;
end;

function Field;
begin
 Result.FieldType:=FieldType;
 Result.FieldName:=Name;
 Result.PrimaryKey:=PrimaryKey;
 Result.AutoInc:=AutoInc;
 Result.NotNull:=NotNull;
end;

function InsertValue(Name:string; FieldType:TFieldType; Value:Variant):TInsertValue; overload;
begin
 Result.FieldName:=Name;
 Result.FieldType:=FieldType;
 Result.Value:=Value;
end;

function DIValue(Name:string; FieldType:TFieldType; DIType:TDIType; Value:Variant):TDIValue; overload;
begin
 Result.FieldName:=Name;
 Result.FieldType:=FieldType;
 Result.DIType:=DIType;
 Result.Value:=Value;
end;

{ SQL }

class function SQL.CreateField: TField;
begin
 Result:=Field('', ftInteger, False, False, False);
end;

class function SQL.CreateTable: TTable;
begin
 Result:=TTable.Create;
end;

class function SQL.Delete: TDelete;
begin
 Result:=TDelete.Create;
end;

class function SQL.CreateTable(TableName: string): TTable;
begin
 Result:=TTable.Create;
 Result.TableName:=TableName;
end;

class function SQL.Delete(TableName: string): TDelete;
begin
 Result:=TDelete.Create;
 Result.TableName:=TableName;
end;

class function SQL.DropTable:TDropTable;
begin
 Result:=TDropTable.Create;
end;

class function SQL.InsertInto(TableName: string): TInsertInto;
begin
 Result:=TInsertInto.Create;
 Result.TableName:=TableName;
end;

class function SQL.InsertInto: TInsertInto;
begin
 Result:=TInsertInto.Create;
end;

class function SQL.PRAGMA(Key, Value: string): string;
begin
 //'PRAGMA key = "123456"'
 Result:='PRAGMA '+Key+' = "'+Value+'"';
end;

class function SQL.Select(TableName: string): TSelect;
begin
 Result:=TSelect.Create;
 Result.TableName:=TableName;
end;

class function SQL.SelectLastInsertID:string;
begin
 Result:='SELECT LAST_INSERT_ID();';
end;

class function SQL.Select:TSelect;
begin
 Result:=TSelect.Create;
end;

class function SQL.Update: TUpdate;
begin
 Result:=TUpdate.Create;
end;

class function SQL.Update(TableName: string): TUpdate;
begin
 Result:=TUpdate.Create;
 Result.TableName:=TableName;
end;

class function SQL.UpdateBlob: TUpdateBlob;
begin
 Result:=TUpdateBlob.Create;
end;

class function SQL.UpdateBlob(TableName: string): TUpdateBlob;
begin
 Result:=TUpdateBlob.Create;
 Result.TableName:=TableName;
end;

{ TTable }

constructor TTable.Create(pTableName: string);
begin
 Create;
 TableName:=pTableName;
end;

constructor TTable.Create;
begin
 inherited;
 FFields:=TFields.Create;
end;

function TTable.GetField(Index: Integer): TField;
begin
 Result:=FFields[Index];
end;

function TTable.GetSQL: string;
var i:Integer;
begin
 //CREATE TABLE FirstTable (ID INTEGER PRIMARY KEY, MYTEXT TEXT, MYBLOB BLOB)
 Result:='CREATE TABLE '+TableName+' (';         //CREATE TABLE FirstTable (
 for i:= 0 to FFields.Count - 1 do
  begin
   Result:=Result+FFields[i].GetSQL;
   if i <> FFields.Count - 1 then Result:=Result+', ';
  end;
 Result:=Result+')';
end;

procedure TTable.AddField;
begin
 FFields.Add(Field(Name, FieldType, PrimaryKey, NotNull, AutoInc));
end;

procedure TTable.Clear;
begin
 TableName:='';
 FFields.Clear;
end;

procedure TTable.EndCreate;
begin
 Clear;
 Free;
end;

procedure TTable.SetField(Index: Integer; const Value: TField);
begin
 FFields[Index]:=Value;
end;

{ TField }

function TField.GetSQL: string;
begin
 Result:=FieldName+' '+FieldTypeToStr(FieldType);
 if PrimaryKey then Result:=Result+' PRIMARY KEY';
 if NotNull then Result:=Result+' NOT NULL';
 if AutoInc then Result:=Result+' AUTOINCREMENT';
end;

{ TInsertInto }

constructor TInsertInto.Create;
begin
 inherited;
 FFieldValues:=TInsertValues.Create;
end;

function TInsertInto.GetSQL: string;
var i:Integer;
begin
 //insert into FirstTable (MYTEXT) values("��� ��������!")
 Result:='INSERT INTO '+TableName+' (';         //INSERT INTO FirstTable (
 for i:= 0 to FFieldValues.Count - 1 do
  begin
   Result:=Result+FFieldValues[i].FieldName;
   if i <> FFieldValues.Count - 1 then Result:=Result+', ';
  end;
 Result:=Result+') VALUES (';                   //INSERT INTO FirstTable (FIELDNAMES) VALUES (
 for i:= 0 to FFieldValues.Count - 1 do
  begin
   case FFieldValues[i].FieldType of
    ftInteger: Result:=Result+QuotedStr(IntToStr(FFieldValues[i].Value));
    ftString:  Result:=Result+QuotedStr(FFieldValues[i].Value);
    ftFloat:   Result:=Result+QuotedStr(FloatToSQLStr(FFieldValues[i].Value));
    ftDateTime:Result:=Result+QuotedStr(FloatToSQLStr(FFieldValues[i].Value));
    ftBoolean: Result:=Result+QuotedStr(IntToStr(FFieldValues[i].Value));
    ftParam:   Result:=Result+FFieldValues[i].Value;
   end;
   if i <> FFieldValues.Count - 1 then Result:=Result+', ';
  end;
 Result:=Result+')';
end;

procedure TInsertInto.AddValue(FieldName: string; FieldValue: Extended);
begin
 FFieldValues.Add(InsertValue(FieldName, ftFloat, FieldValue));
end;

procedure TInsertInto.AddValue(FieldName, FieldValue: string);
begin
 FieldValue:=StringReplace(FieldValue, '"', '""', [rfReplaceAll]);
 FFieldValues.Add(InsertValue(FieldName, ftString, FieldValue));
end;

procedure TInsertInto.AddValue(FieldName: string; FieldValue: Integer);
begin
 FFieldValues.Add(InsertValue(FieldName, ftInteger, FieldValue));
end;

procedure TInsertInto.AddValue(FieldName: string; FieldValue: Boolean);
begin
 FFieldValues.Add(InsertValue(FieldName, ftBoolean, FieldValue));
end;

procedure TInsertInto.AddValueAsParam(FieldName:string; ParamChar:string = ':'; CharOnly:Boolean = False);
begin
 if CharOnly then
  FFieldValues.Add(InsertValue(FieldName, ftParam, ParamChar))
 else
  FFieldValues.Add(InsertValue(FieldName, ftParam, ParamChar+FieldName));
end;

procedure TInsertInto.AddValue(FieldName: string; FieldValue: TDateTime);
begin
 FFieldValues.Add(InsertValue(FieldName, ftDateTime, FieldValue));
end;

procedure TInsertInto.Clear;
begin
 TableName:='';
 FFieldValues.Clear;
end;

procedure TInsertInto.EndCreate;
begin
 Clear;
 Free;
end;

{ TSelect }

procedure TSelect.AddField(Name:string);
begin
 FFields.Add(Name);
end;

procedure TSelect.AddFieldCount(Name, Alias: string);
begin
 Name:='COUNT('+Name+')';
 if Alias <> '' then Name:=Name+' as '+Alias;
 FFields.Add(Name);
end;

procedure TSelect.Clear;
begin
 FName:='';
 FFields.Clear;
 FJoins.Clear;
 FOrderBy.Clear;
end;

constructor TSelect.Create;
begin
 inherited;
 FFields:=TFieldNames.Create;
 FJoins:=TStringList.Create;
 FOrderBy:=TStringList.Create;
 FLimitInt:=0;
end;

function TSelect.GetField(Index: Integer): string;
begin
 Result:=FFields[Index];
end;

function TSelect.GetOrderBy: string;
var i:Integer;
begin
 if FOrderBy.Count <= 0 then Exit('');
 Result:=' ORDER BY ';
 for i:= 0 to FOrderBy.Count-1 do
  begin
   Result:=Result+FOrderBy[i];
   if i <> FOrderBy.Count - 1 then Result:=Result+', ';
  end;
end;

function TSelect.GetSQL: string;
var i:Integer;
    FieldsStr, ALimit, AJoins:string;
begin
 //'SELECT MYBLOB FROM FirstTable WHERE ID='+IntToStr(id);
 if FLimitInt > 0 then ALimit:=' LIMIT '+IntToStr(FLimitInt);

 if FDistinct then Result:='SELECT DISTINCT ' else Result:='SELECT ';

 FieldsStr:='';
 for i:= 0 to FFields.Count - 1 do
  begin
   FieldsStr:=FieldsStr+FFields[i];
   if i <> FFields.Count - 1 then FieldsStr:=FieldsStr+', ';
  end;
 AJoins:='';
 for i:= 0 to FJoins.Count-1 do AJoins:=AJoins+FJoins[i]+' ';
 if AJoins <> '' then AJoins:=' '+AJoins;
 Result:=Result+FieldsStr+' FROM '+TableName+AJoins+Where+OrderByStr+ALimit;  //SELECT %s FROM FirstTable WHERE ID=1
// Result:=Format(Result, [FieldsStr]);
end;

procedure TSelect.InnerJoin(JoinTable, BaseField, JoinField:string);
begin
 //SELECT EMP_ID, NAME, DEPT FROM COMPANY
 //INNER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID
 FJoins.Add('INNER JOIN '+JoinTable+' ON '+FName+'.'+BaseField+'='+JoinTable+'.'+JoinField);
end;

procedure TSelect.LeftJoin(JoinTable, BaseField, JoinField: string);
begin
 FJoins.Add('LEFT JOIN '+JoinTable+' ON '+FName+'.'+BaseField+'='+JoinTable+'.'+JoinField);
end;

procedure TSelect.OrderBy(FieldName: string; DESC: Boolean);
begin
 if DESC then FieldName:=FieldName+' DESC';
 FOrderBy.Add(FieldName);
end;

procedure TSelect.RightJoin(JoinTable, BaseField, JoinField: string);
begin
 FJoins.Add('RIGHT JOIN '+JoinTable+' ON '+FName+'.'+BaseField+'='+JoinTable+'.'+JoinField);
end;

procedure TSelect.SetField(Index: Integer; const Value: string);
begin
 FFields[Index]:=Value;
end;

{ TDelete }

procedure TDelete.Clear;
begin
 FName:='';
end;

constructor TDelete.Create;
begin
 inherited;
end;

function TDelete.GetSQL: string;
begin
 Result:='DELETE FROM '+FName+Where;
end;

{ TUpdate }

procedure TUpdate.AddValue(FieldName: string; FieldValue: Extended);
begin
 FFieldValues.Add(InsertValue(FieldName, ftFloat, FieldValue));
end;

procedure TUpdate.AddValue(FieldName, FieldValue: string);
begin
 FieldValue:=StringReplace(FieldValue, '"', '""', [rfReplaceAll]);
 FFieldValues.Add(InsertValue(FieldName, ftString, FieldValue));
end;

procedure TUpdate.AddValue(FieldName: string; FieldValue: Integer);
begin
 FFieldValues.Add(InsertValue(FieldName, ftInteger, FieldValue));
end;

procedure TUpdate.AddValue(FieldName: string; FieldValue: Boolean);
begin
 FFieldValues.Add(InsertValue(FieldName, ftBoolean, FieldValue));
end;

procedure TUpdate.AddValueAsParam(FieldName: string; ParamChar:string = ':'; CharOnly:Boolean = False);
begin
 if CharOnly then
  FFieldValues.Add(InsertValue(FieldName, ftParam, ParamChar))
 else
  FFieldValues.Add(InsertValue(FieldName, ftParam, ParamChar+FieldName));
end;

procedure TUpdate.AddValue(FieldName: string; FieldValue: TDateTime);
begin
 FFieldValues.Add(InsertValue(FieldName, ftDateTime, FieldValue));
end;

procedure TUpdate.Clear;
begin
 TableName:='';
 FFieldValues.Clear;
end;

constructor TUpdate.Create;
begin
 inherited;
 FFieldValues:=TInsertValues.Create;
 FDIValues:=TDIValues.Create;
end;

procedure TUpdate.DecValue(FieldName: string; Value: Extended);
begin
 FDIValues.Add(DIValue(FieldName, ftFloat, diDec, Value));
end;

procedure TUpdate.DivValue(FieldName: string; Value: Integer);
begin
 FDIValues.Add(DIValue(FieldName, ftInteger, diDiv, Value));
end;

procedure TUpdate.DivValue(FieldName: string; Value: Extended);
begin
 FDIValues.Add(DIValue(FieldName, ftFloat, diDiv, Value));
end;

procedure TUpdate.DecValue(FieldName: string; Value: Integer);
begin
 FDIValues.Add(DIValue(FieldName, ftInteger, diDec, Value));
end;

procedure TUpdate.IncValue(FieldName: string; Value: Extended);
begin
 FDIValues.Add(DIValue(FieldName, ftFloat, diInc, Value));
end;

procedure TUpdate.IncValue(FieldName: string; Value: Integer);
begin
 FDIValues.Add(DIValue(FieldName, ftInteger, diInc, Value));
end;

procedure TUpdate.MulValue(FieldName: string; Value: Integer);
begin
 FDIValues.Add(DIValue(FieldName, ftInteger, diMul, Value));
end;

procedure TUpdate.MulValue(FieldName: string; Value: Extended);
begin
 FDIValues.Add(DIValue(FieldName, ftFloat, diMul, Value));
end;

function TUpdate.GetSQL: string;
var i:Integer;
    str:string;
begin
 //insert into FirstTable (MYTEXT) values("��� ��������!")
 Result:='UPDATE '+TableName+' SET ';         //INSERT INTO FirstTable (
 for i:= 0 to FFieldValues.Count - 1 do
  begin
   str:='';
   case FFieldValues[i].FieldType of
    ftInteger: str:=QuotedStr(IntToStr(FFieldValues[i].Value));
    ftString:  str:=QuotedStr(FFieldValues[i].Value);
    ftFloat:   str:=QuotedStr(FloatToSQLStr(FFieldValues[i].Value));
    ftDateTime:str:=QuotedStr(FloatToSQLStr(FFieldValues[i].Value));
    ftBoolean: str:=QuotedStr(IntToStr(Ord(FFieldValues[i].Value <> 0)));
    ftParam:   str:=FFieldValues[i].Value;
   end;
   Result:=Result+FFieldValues[i].FieldName + ' = '+str;
   if i <> FFieldValues.Count - 1 then Result:=Result+', ';
  end;
 for i:= 0 to FDIValues.Count - 1 do
  begin
   str:='';
   case FDIValues[i].FieldType of
    ftInteger: str:=QuotedStr(IntToStr(FDIValues[i].Value));
    ftFloat:   str:=QuotedStr(FloatToSQLStr(FDIValues[i].Value));
   end;
   case FDIValues[i].DIType of
    diInc: Result:=Result+FDIValues[i].FieldName+' = '+FDIValues[i].FieldName+' + '+str;
    diDec: Result:=Result+FDIValues[i].FieldName+' = '+FDIValues[i].FieldName+' - '+str;
    diMul: Result:=Result+FDIValues[i].FieldName+' = '+FDIValues[i].FieldName+' * '+str;
    diDiv: Result:=Result+FDIValues[i].FieldName+' = '+FDIValues[i].FieldName+' / '+str;
   end;
   if i <> FDIValues.Count - 1 then Result:=Result+', ';
  end;
 Result:=Result+Where;
end;

{ TDropTable }

procedure TDropTable.Clear;
begin
 TableName:='';
end;

constructor TDropTable.Create;
begin
 inherited;
end;

procedure TDropTable.EndCreate;
begin
 Clear;
 Free;
end;

function TDropTable.GetSQL:string;
begin
 Result:='DROP TABLE '+TableName;
end;

{ SQL }

procedure SQL.Clear;
begin
 FUWheres.Clear;
end;

constructor SQL.Create;
begin
 inherited;
 FUWheres:=TUnionWhere.Create;
end;

procedure SQL.EndCreate;
begin
 Clear;
 FUWheres.Free;
 Free;
end;

function SQL.GetWhere: string;
var i:Integer;
begin
 for i:= 0 to FUWheres.Count-1 do Result:=Result+FUWheres[i];
 if FWhereStr <> '' then Result:=Result+' '+FWhereStr;
 if Result <> '' then Result:=' WHERE '+Result;
end;

procedure BaseSQL.SetName(const Value: string);
begin
 FName:=Value;
end;

procedure SQL.WhereField(FieldName, Oper: string; FieldValue: Extended; Union:TWhereUnion);
var UnionStr:string;
begin
 case Union of
  wuAnd: UnionStr:=' AND ';
  wuOr: UnionStr:=' OR ';
  wuNotAnd: UnionStr:=' NOT AND ';
  wuNotOr: UnionStr:=' NOT OR ';
 end;
 if FUWheres.Count <= 0 then UnionStr:='';
 FUWheres.Add(UnionStr+FieldName+Oper+QuotedStr(FloatToSQLStr(FieldValue)));
end;

procedure SQL.WhereField(FieldName, Oper, FieldValue: string; Union:TWhereUnion);
var UnionStr:string;
begin
 case Union of
  wuAnd: UnionStr:=' AND ';
  wuOr: UnionStr:=' OR ';
  wuNotAnd: UnionStr:=' NOT AND ';
  wuNotOr: UnionStr:=' NOT OR ';
 end;
 if FUWheres.Count <= 0 then UnionStr:='';
 FUWheres.Add(UnionStr+FieldName+Oper+QuotedStr(FieldValue));
end;

procedure SQL.WhereField(FieldName, Oper: string; FieldValue: Integer; Union:TWhereUnion);
var UnionStr:string;
begin
 case Union of
  wuAnd: UnionStr:=' AND ';
  wuOr: UnionStr:=' OR ';
  wuNotAnd: UnionStr:=' NOT AND ';
  wuNotOr: UnionStr:=' NOT OR ';
 end;
 if FUWheres.Count <= 0 then UnionStr:='';
 FUWheres.Add(UnionStr+FieldName+Oper+QuotedStr(IntToStr(FieldValue)));
end;

procedure SQL.WhereField(FieldName, Oper: string; FieldValue: Boolean; Union:TWhereUnion);
var UnionStr:string;
begin
 case Union of
  wuAnd: UnionStr:=' AND ';
  wuOr: UnionStr:=' OR ';
  wuNotAnd: UnionStr:=' NOT AND ';
  wuNotOr: UnionStr:=' NOT OR ';
 end;
 if FUWheres.Count <= 0 then UnionStr:='';
 FUWheres.Add(UnionStr+FieldName+Oper+QuotedStr(IntToStr(Ord(FieldValue))));
end;

procedure SQL.WhereField(FieldName, Oper: string; FieldValue: TDateTime; Union:TWhereUnion);
var UnionStr:string;
begin
 case Union of
  wuAnd: UnionStr:=' AND ';
  wuOr: UnionStr:=' OR ';
  wuNotAnd: UnionStr:=' NOT AND ';
  wuNotOr: UnionStr:=' NOT OR ';
 end;
 if FUWheres.Count <= 0 then UnionStr:='';
 FUWheres.Add(UnionStr+FieldName+Oper+QuotedStr(FloatToSQLStr(FieldValue)));
end;

procedure SQL.WhereFieldEqual(FieldName: string; FieldValue: string; Union:TWhereUnion);
begin
 WhereField(FieldName, '=', FieldValue, Union);
end;

procedure SQL.WhereFieldEqual(FieldName: string; FieldValue: Integer; Union:TWhereUnion);
begin
 WhereField(FieldName, '=', FieldValue, Union);
end;

procedure SQL.WhereFieldEqual(FieldName: string; FieldValue: Extended; Union:TWhereUnion);
begin
 WhereField(FieldName, '=', FieldValue, Union);
end;

procedure SQL.WhereFieldEqual(FieldName: string; FieldValue: Boolean; Union:TWhereUnion);
begin
 WhereField(FieldName, '=', FieldValue, Union);
end;

procedure SQL.WhereFieldIN(FieldName: string; FieldValues: array of Extended; Union: TWhereUnion);
var FieldValue:string;
    i:Integer;
begin
 FieldValue:='';
 for i:= Low(FieldValues) to High(FieldValues) do
  begin
   FieldValue:=FieldValue+QuotedStr(FloatToSQLStr(FieldValues[i]));
   if i <> High(FieldValues) then FieldValue:=FieldValue+', ';
  end;
 WhereFieldWOQ(FieldName, ' IN ', '('+FieldValue+')', Union);
end;

procedure SQL.WhereFieldIN(FieldName: string; FieldValues: array of string; Union: TWhereUnion);
var FieldValue:string;
    i:Integer;
begin
 FieldValue:='';
 for i:= Low(FieldValues) to High(FieldValues) do
  begin
   FieldValue:=FieldValue+QuotedStr(FieldValues[i]);
   if i <> High(FieldValues) then FieldValue:=FieldValue+', ';
  end;
 WhereFieldWOQ(FieldName, ' IN ', '('+FieldValue+')', Union);
end;

procedure SQL.WhereFieldIN(FieldName: string; FieldValues: array of Integer; Union: TWhereUnion);
var FieldValue:string;
    i:Integer;
begin
 FieldValue:='';
 for i:= Low(FieldValues) to High(FieldValues) do
  begin
   FieldValue:=FieldValue+QuotedStr(IntToStr(FieldValues[i]));
   if i <> High(FieldValues) then FieldValue:=FieldValue+', ';
  end;
 WhereFieldWOQ(FieldName, ' IN ', '('+FieldValue+')', Union);
end;

procedure SQL.WhereFieldIN(FieldName: string; FieldValues: array of Boolean; Union: TWhereUnion);
var FieldValue:string;
    i:Integer;
begin
 FieldValue:='';
 for i:= Low(FieldValues) to High(FieldValues) do
  begin
   FieldValue:=FieldValue+QuotedStr(IntToStr(Ord(FieldValues[i])));
   if i <> High(FieldValues) then FieldValue:=FieldValue+', ';
  end;
 WhereFieldWOQ(FieldName, ' IN ', '('+FieldValue+')', Union);
end;

procedure SQL.WhereFieldIN(FieldName: string; FieldValues: array of TDateTime; Union: TWhereUnion);
var FieldValue:string;
    i:Integer;
begin
 FieldValue:='';
 for i:= Low(FieldValues) to High(FieldValues) do
  begin
   FieldValue:=FieldValue+QuotedStr(FloatToSQLStr(FieldValues[i]));
   if i <> High(FieldValues) then FieldValue:=FieldValue+', ';
  end;
 WhereFieldWOQ(FieldName, ' IN ', '('+FieldValue+')', Union);
end;

procedure SQL.WhereFieldWOQ(FieldName, Oper, FieldValue: string; Union: TWhereUnion);
var UnionStr:string;
begin
 case Union of
  wuAnd: UnionStr:=' AND ';
  wuOr: UnionStr:=' OR ';
  wuNotAnd: UnionStr:=' NOT AND ';
  wuNotOr: UnionStr:=' NOT OR ';
 end;
 if FUWheres.Count <= 0 then UnionStr:='';
 FUWheres.Add(UnionStr+FieldName+Oper+FieldValue);
end;

procedure SQL.WhereFieldEqual(FieldName: string; FieldValue: TDateTime; Union:TWhereUnion);
begin
 WhereField(FieldName, '=', FieldValue, Union);
end;

procedure SQL.WhereNotFieldEqual(FieldName: string; FieldValue: Extended; Union:TWhereUnion);
begin
 WhereField(FieldName, '<>', FieldValue, Union);
end;

procedure SQL.WhereNotFieldEqual(FieldName, FieldValue: string; Union:TWhereUnion);
begin
 WhereField(FieldName, '<>', FieldValue, Union);
end;

procedure SQL.WhereNotFieldEqual(FieldName: string; FieldValue: Integer; Union:TWhereUnion);
begin
 WhereField(FieldName, '<>', FieldValue, Union);
end;

procedure SQL.WhereNotFieldEqual(FieldName: string; FieldValue: Boolean; Union:TWhereUnion);
begin
 WhereField(FieldName, '<>', FieldValue, Union);
end;

procedure SQL.WhereStr(Value: string);
begin
 FWhereStr:=Value;
end;

procedure SQL.WhereNotFieldEqual(FieldName: string; FieldValue: TDateTime; Union:TWhereUnion);
begin
 WhereField(FieldName, '<>', FieldValue, Union);
end;

{ TUpdateBlob }

function TUpdateBlob.GetSQL: string;
begin
 //SQLBase.UpdateBlob('UPDATE FirstTable SET MYBLOB = ? WHERE ID = '+IntToStr(id), BlobData)
 Result:='UPDATE '+FName+' SET '+FBlobField+' = ? '+Where;
 //SQLDB.UpdateBlob('UPDATE '+Table+' SET '+BlobField+' = ? '+Where, BlobData);
end;

end.
