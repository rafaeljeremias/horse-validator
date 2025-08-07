unit middleware.validator.item;

interface

uses
  Horse,
  System.JSON,
  Horse.Jhonson,
  Horse.Commons,
  Generics.Collections,
  middleware.validator.interfaces;

type
  TMiddlewareValidatorItem = class(TInterfacedObject, IMiddlewareValidatorItem,
    IMiddleWareValidatorJSONArray)
  strict private
    FNext: TProc;
    FKey: Boolean;
    FExists: Boolean;
    FNamePair: string;
    FReq: THorseRequest;
    FRes: THorseResponse;
    FWithMessage: string;
    FConfigJSON: TJSONValue;
    FListKeys: TList<IMiddleWareValidatorItem>;
    FMiddlewareValidatorItemType: TMiddlewareValidatorItemType;

    constructor Create(AValue: string; AMiddleWareType: TMiddlewareValidatorItemType; AReq: THorseRequest;
      ARes: THorseResponse; ANext: TProc; AKey: Boolean = False); overload;
    constructor Create(AValue: TJSONValue; AMiddleWareType: TMiddlewareValidatorItemType); overload;
    destructor Destroy; override;
  protected
    function key: Boolean;
    function body: string; overload;
    function getExists: Boolean;
    function config: TJSONValue; overload;
    function withMessage: string; overload;
    function getType: TMiddlewareValidatorItemType;
    function Config(AValue: TJSONValue): IMiddleWareValidatorItem; overload;
    function MiddlewareValidatorItemType(AValue: TMiddleWareValidatorItemType): IMiddleWareValidatorItem;
  public
    class function body(AValue: string; AReq: THorseRequest; ARes: THorseResponse;
      ANext: TProc; AKey: Boolean = False): IMiddlewareValidatorItem; overload;

    function isEmail: IMiddleWareValidatorItem;
    function jsonArray: IMiddleWareValidatorJSONArray;
      function Count: Integer;
      function GetIndex(AValue: Integer): IMiddleWareValidatorItem;
      function Pair(AName: string; AKey: Boolean = False): IMiddleWareValidatorItem;
    function &EndJSONArray: IMiddleWareValidatorJSONArray;
    function isInt(AValue: string): IMiddleWareValidatorItem;
    function isDate(AValue: string): IMiddleWareValidatorItem;
    function isString(AValue: string): IMiddleWareValidatorItem;
    function isNumeric(AValue: string): IMiddleWareValidatorItem;
    function exists(AValue: Boolean): IMiddlewareValidatorItem; overload;
    function withMessage(AValue: string): IMiddlewareValidatorItem; overload;
  End;

implementation

{ TMiddlewareValidatorItem }

class function TMiddlewareValidatorItem.body(AValue: string; AReq: THorseRequest; ARes: THorseResponse;
      ANext: TProc; AKey: Boolean): IMiddlewareValidatorItem;
begin
  result := Self.Create(AValue, mvtBody, AReq, ARes, ANext, AKey);
end;

function TMiddlewareValidatorItem.config(AValue: TJSONValue): IMiddleWareValidatorItem;
begin
  result := Self;

  FConfigJSON := AValue;
end;

function TMiddlewareValidatorItem.config: TJSONValue;
begin
  result := FConfigJSON;
end;

constructor TMiddlewareValidatorItem.Create(AValue: string; AMiddleWareType: TMiddlewareValidatorItemType;
  AReq: THorseRequest; ARes: THorseResponse; ANext: TProc; AKey: Boolean);
begin
  inherited Create;

  FReq := AReq;
  FRes := ARes;
  FKey := AKey;
  FNext := ANext;
  FNamePair := AValue;
  FMiddlewareValidatorItemType := AMiddleWareType;
  FListKeys := TList<IMiddleWareValidatorItem>.Create;
end;

function TMiddlewareValidatorItem.body: string;
begin
  result := FNamePair;
end;

function TMiddlewareValidatorItem.Count: Integer;
begin
  result := FListKeys.Count;
end;

constructor TMiddlewareValidatorItem.Create(AValue: TJSONValue; AMiddleWareType: TMiddlewareValidatorItemType);
begin
  inherited Create;

  FConfigJSON := AValue;
  FMiddlewareValidatorItemType := AMiddleWareType;
  FListKeys := TList<IMiddleWareValidatorItem>.Create;
end;

destructor TMiddlewareValidatorItem.Destroy;
begin
  if Assigned(FListKeys) then
    FListKeys.Free;

  inherited;
end;

function TMiddlewareValidatorItem.EndJSONArray: IMiddleWareValidatorJSONArray;
begin
  result := Self;
end;

function TMiddlewareValidatorItem.getExists: Boolean;
begin
  result := FExists;
end;

function TMiddlewareValidatorItem.GetIndex(AValue: Integer): IMiddleWareValidatorItem;
begin
  result := nil;

  if FListKeys.Count >= AValue + 1 then
    result := FListKeys[AValue];
end;

function TMiddlewareValidatorItem.exists(AValue: Boolean): IMiddlewareValidatorItem;
begin
  result := Self;

  FExists := AValue;
end;

function TMiddlewareValidatorItem.getType: TMiddlewareValidatorItemType;
begin
  result := FMiddlewareValidatorItemType;
end;

function TMiddlewareValidatorItem.isDate(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  if FMiddlewareValidatorItemType = mvtJSONArray then
  begin
    var LNumPairs := FListKeys.Count;

    if LNumPairs > 0 then
    begin
      FListKeys[LNumPairs -1].exists(True);
      FListKeys[LNumPairs -1].MiddlewareValidatorItemType(mvtDate);
      FListKeys[LNumPairs -1].Config(TJSONObject.ParseJSONValue(AValue) as TJSONObject);
    end;
  end
  else
  begin
    FExists := True;
    FMiddlewareValidatorItemType := mvtDate;
    FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
  end;
end;

function TMiddlewareValidatorItem.isEmail: IMiddleWareValidatorItem;
begin
  result := Self;

  FExists := True;
  FMiddlewareValidatorItemType := mvtEmail;
end;

function TMiddlewareValidatorItem.isInt(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  if FMiddlewareValidatorItemType = mvtJSONArray then
  begin
    var LNumPairs := FListKeys.Count;

    if LNumPairs > 0 then
    begin
      FListKeys[LNumPairs -1].exists(True);
      FListKeys[LNumPairs -1].MiddlewareValidatorItemType(mvtInt);
      FListKeys[LNumPairs -1].Config(TJSONObject.ParseJSONValue(AValue) as TJSONObject);
    end;
  end
  else
  begin
    FExists := True;
    FMiddlewareValidatorItemType := mvtInt;
    FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
  end;
end;

function TMiddlewareValidatorItem.jsonArray: IMiddleWareValidatorJSONArray;
begin
  result := Self;

  FExists := True;
  FMiddlewareValidatorItemType := mvtJSONArray;
end;

function TMiddlewareValidatorItem.key: Boolean;
begin
  result := FKey;
end;

function TMiddlewareValidatorItem.Pair(AName: string; AKey: Boolean): IMiddleWareValidatorItem;
begin
  result := Self;

  FListKeys.Add(TMiddlewareValidatorItem.body(AName, FReq, FRes, FNext, AKey));
end;

function TMiddlewareValidatorItem.MiddlewareValidatorItemType(
  AValue: TMiddleWareValidatorItemType): IMiddleWareValidatorItem;
begin
  result := Self;

  FMiddlewareValidatorItemType := AValue;
end;

function TMiddlewareValidatorItem.isNumeric(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  if FMiddlewareValidatorItemType = mvtJSONArray then
  begin
    var LNumPairs := FListKeys.Count;

    if LNumPairs > 0 then
    begin
      FListKeys[LNumPairs -1].exists(True);
      FListKeys[LNumPairs -1].MiddlewareValidatorItemType(mvtNumeric);
      FListKeys[LNumPairs -1].Config(TJSONObject.ParseJSONValue(AValue) as TJSONObject);
    end;
  end
  else
  begin
    FExists := True;
    FMiddlewareValidatorItemType := mvtNumeric;
    FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
  end;
end;

function TMiddlewareValidatorItem.isString(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  if FMiddlewareValidatorItemType = mvtJSONArray then
  begin
    var LNumPairs := FListKeys.Count;

    if LNumPairs > 0 then
    begin
      FListKeys[LNumPairs -1].exists(True);
      FListKeys[LNumPairs -1].MiddlewareValidatorItemType(mvtString);
      FListKeys[LNumPairs -1].Config(TJSONObject.ParseJSONValue(AValue) as TJSONObject);
    end;
  end
  else
  begin
    FExists := True;
    FMiddlewareValidatorItemType := mvtString;
    FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
  end;
end;

function TMiddlewareValidatorItem.withMessage: string;
begin
  result := FWithMessage;
end;

function TMiddlewareValidatorItem.withMessage(AValue: string): IMiddlewareValidatorItem;
begin
  result := Self;

  if FMiddlewareValidatorItemType = mvtJSONArray then
  begin
    var LNumPairs := FListKeys.Count;

    if LNumPairs > 0 then
      FListKeys[LNumPairs -1].withMessage(AValue);
  end
  else
    FWithMessage := AValue;
end;

end.
