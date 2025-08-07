unit middleware.validator.item;

interface

uses
  System.JSON,
  middleware.validator.interfaces;

type
  TMiddlewareValidatorItem = class(TInterfacedObject, IMiddlewareValidatorItem)
  strict private
     FExists: Boolean;
     FNamePair: string;
     FWithMessage: string;
     FConfigJSON: TJSONValue;
     FMiddlewareValidatorItemType: TMiddlewareValidatorItemType;

     constructor Create(AValue: string; AMiddleWareType: TMiddlewareValidatorItemType); overload;
     constructor Create(AValue: TJSONValue; AMiddleWareType: TMiddlewareValidatorItemType); overload;

     function getExists: Boolean;
     function config: TJSONValue;
     function body: string; overload;
     function withMessage: string; overload;
     function getType: TMiddlewareValidatorItemType;
  public
    class function body(AValue: string): IMiddlewareValidatorItem; overload;

    function isInt(AValue: string): IMiddleWareValidatorItem;
    function isDate(AValue: string): IMiddleWareValidatorItem;
    function isString(AValue: string): IMiddleWareValidatorItem;
    function isNumeric(AValue: string): IMiddleWareValidatorItem;
    function exists(AValue: Boolean): IMiddlewareValidatorItem; overload;
    function withMessage(AValue: string): IMiddlewareValidatorItem; overload;
  End;

implementation

{ TMiddlewareValidatorItem }

class function TMiddlewareValidatorItem.body(AValue: string): IMiddlewareValidatorItem;
begin
  result := Self.Create(AValue, mvtBody);
end;

function TMiddlewareValidatorItem.config: TJSONValue;
begin
  result := FConfigJSON;
end;

constructor TMiddlewareValidatorItem.Create(AValue: string; AMiddleWareType: TMiddlewareValidatorItemType);
begin
  inherited Create;

  FNamePair := AValue;
  FMiddlewareValidatorItemType := AMiddleWareType;
end;

function TMiddlewareValidatorItem.body: string;
begin
  result := FNamePair;
end;

constructor TMiddlewareValidatorItem.Create(AValue: TJSONValue; AMiddleWareType: TMiddlewareValidatorItemType);
begin
  inherited Create;

  FConfigJSON := AValue;
  FMiddlewareValidatorItemType := AMiddleWareType;
end;

function TMiddlewareValidatorItem.getExists: Boolean;
begin
  result := FExists;
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

  FExists := True;
  FMiddlewareValidatorItemType := mvtDate;
  FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
end;

function TMiddlewareValidatorItem.isInt(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FExists := True;
  FMiddlewareValidatorItemType := mvtInt;
  FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
end;

function TMiddlewareValidatorItem.isNumeric(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FExists := True;
  FMiddlewareValidatorItemType := mvtNumeric;
  FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
end;

function TMiddlewareValidatorItem.isString(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FExists := True;
  FMiddlewareValidatorItemType := mvtString;
  FConfigJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
end;

function TMiddlewareValidatorItem.withMessage: string;
begin
  result := FWithMessage;
end;

function TMiddlewareValidatorItem.withMessage(AValue: string): IMiddlewareValidatorItem;
begin
  result := Self;

  FWithMessage := AValue;
end;

end.
