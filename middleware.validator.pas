unit middleware.validator;

interface

uses
  Horse,
  System.JSON,
  Horse.Jhonson,
  Horse.Commons,
  System.StrUtils,
  System.SysUtils,
  System.DateUtils,
  Generics.Collections,
  middleware.validator.item,
  middleware.validator.consts,
  middleware.validator.interfaces;

type
  TMiddleWareValidator = class(TInterfacedObject, IMiddleWareValidator,
    IMiddleWareValidatorItem)
  strict private
    FNext: TProc;
    FIndex: Integer;
    FBody: TJSONValue;
    FReq: THorseRequest;
    FRes: THorseResponse;
    FItems: TList<IMiddleWareValidatorItem>;

    procedure ValidateInt(AValue: IMiddleWareValidatorItem);
    procedure ValidateBody(AValue: IMiddleWareValidatorItem);
    procedure ValidateDate(AValue: IMiddleWareValidatorItem);
    procedure ValidateString(AValue: IMiddleWareValidatorItem);

    function getExists: Boolean;
    function config: TJSONValue;
    function body: string; overload;
    function withMessage: string; overload;
    function getType: TMiddlewareValidatorItemType;
  public
    constructor Create(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    destructor Destroy; override;
    class function New(Req: THorseRequest; Res: THorseResponse; Next: TProc): IMiddleWareValidator;

    function body(AValue: string): IMiddleWareValidatorItem; overload;
    function Execute: IMiddleWareValidator;

    function isInt(AValue: string): IMiddleWareValidatorItem;
    function isDate(AValue: string): IMiddleWareValidatorItem;
    function isString(AValue: string): IMiddleWareValidatorItem;
    function exists(AValue: Boolean = true): IMiddlewareValidatorItem;
    function withMessage(AValue: string): IMiddlewareValidatorItem; overload;
  End;

implementation

{ TMiddleWareValidator }

function TMiddleWareValidator.body(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems.Add(TMiddlewareValidatorItem.body(AValue));

  FIndex := FItems.Count -1;
end;

function TMiddleWareValidator.config: TJSONValue;
begin
  result := FItems[FIndex].config;
end;

function TMiddleWareValidator.body: string;
begin
  FItems[FIndex].body;
end;

constructor TMiddleWareValidator.Create(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  inherited Create;

  FReq := Req;
  FRes := Res;
  FNext := Next;
  FItems := TList<IMiddleWareValidatorItem>.Create;
  FBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
end;

destructor TMiddleWareValidator.Destroy;
begin
  FBody.Free;
  FItems.Free;
  inherited;
end;

function TMiddleWareValidator.Execute: IMiddleWareValidator;
var
  LValidatorItem: IMiddleWareValidatorItem;
begin
  result := Self;

  try
    if not Assigned(FBody) then
      raise Exception.Create(ERRO_BODY_NAO_INFORMADO);

    for LValidatorItem in FItems do
    begin
      ValidateBody(LValidatorItem);

      if LValidatorItem.getType = mvtInt then
        ValidateInt(LValidatorItem);

      if LValidatorItem.getType = mvtString then
        ValidateString(LValidatorItem);

      if LValidatorItem.getType = mvtDate then
        ValidateDate(LValidatorItem);
    end;

  except
    on e:exception do
    begin
      FRes.Send<TJSONObject>(TJSONObject.ParseJSONValue(Format('{ "error": "%s" }', [E.Message])) AS TJSONObject)
        .Status(THTTPStatus.BadRequest)
          .RawWebResponse;

      raise EHorseCallbackInterrupted.Create(E.Message);
    end;
  end;
end;

function TMiddleWareValidator.exists(AValue: Boolean): IMiddlewareValidatorItem;
begin
  result := Self;

  FItems[FIndex].exists(AValue);
end;

function TMiddleWareValidator.getExists: Boolean;
begin
  result := FItems[FIndex].getExists;
end;

function TMiddleWareValidator.getType: TMiddlewareValidatorItemType;
begin
  result := FItems[FIndex].getType;
end;

function TMiddleWareValidator.isDate(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].isDate(AValue);
end;

function TMiddleWareValidator.isInt(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].isInt(AValue);
end;

function TMiddleWareValidator.isString(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].isString(AValue);
end;

class function TMiddleWareValidator.New(Req: THorseRequest; Res: THorseResponse; Next: TProc): IMiddleWareValidator;
begin
  result := Self.Create(Req, Res, Next);
end;

procedure TMiddleWareValidator.ValidateBody(AValue: IMiddleWareValidatorItem);
var
  LExiste: Boolean;
begin
  LExiste := FBody.FindValue(AValue.body) <> nil;

  if AValue.getExists <> LExiste then
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
end;

procedure TMiddleWareValidator.ValidateDate(AValue: IMiddleWareValidatorItem);
var
  LDateStr: string;
  LDataMinField: TDateTime;
  LDataMaxField: TDateTime;
  LDataFieldBody: TDateTime;
  LDateJSONValue: TJSONValue;
  LFormatSettings: TFormatSettings;
begin
  try
    LFormatSettings := TFormatSettings.Create;
    LFormatSettings.DateSeparator := '-';
    LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';

    if AValue.config.FindValue('min') <> nil then
    begin
      var LDateMinJSON := AValue.config.FindValue('min');

      if LDateMinJSON is TJSONString then
        LDateStr := TJSONString(LDateMinJSON).Value
      else
        LDateStr := StringReplace(LDateMinJSON.ToString, '"', '', [rfReplaceAll]);

      LDataMinField := StrToDateTimeDef(LDateStr, 0, LFormatSettings);

      LDateJSONValue := (FBody as TJSONObject).GetValue('dt_venda');

      if LDateJSONValue is TJSONString then
        LDateStr := TJSONString(LDateJSONValue).Value
      else
        LDateStr := StringReplace(LDateJSONValue.ToString, '"', '', [rfReplaceAll]);

      LDataFieldBody := StrToDateTimeDef(LDateStr, 0, LFormatSettings);

      if LDataFieldBody < LDataMinField then
        Abort;
    end;

    if AValue.config.FindValue('max') <> nil then
    begin
      var LDateMaxJSON := AValue.config.FindValue('max');

      if LDateMaxJSON is TJSONString then
        LDateStr := TJSONString(LDateMaxJSON).Value
      else
        LDateStr := StringReplace(LDateMaxJSON.ToString, '"', '', [rfReplaceAll]);

      LDataMaxField := StrToDateTimeDef(LDateStr, 0, LFormatSettings);

      LDateJSONValue := (FBody as TJSONObject).GetValue('dt_venda');

      if LDateJSONValue is TJSONString then
        LDateStr := TJSONString(LDateJSONValue).Value
      else
        LDateStr := StringReplace(LDateJSONValue.ToString, '"', '', [rfReplaceAll]);

      LDataFieldBody := StrToDateTimeDef(LDateStr, 0, LFormatSettings);

      if LDataFieldBody > LDataMaxField then
        Abort;
    end;

  except
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage +' - Data deve ser no formato "YYYY-MM-DD HH:NN:SS"', '"', ''''));
  end;
end;

procedure TMiddleWareValidator.ValidateInt(AValue: IMiddleWareValidatorItem);
begin
  try
    if AValue.config.FindValue('min') <> nil then
      if FBody.GetValue<Integer>(AValue.body) < AValue.config.GetValue<Integer>('min') then
        Abort;
  except
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
  end;
end;

procedure TMiddleWareValidator.ValidateString(AValue: IMiddleWareValidatorItem);
begin
  try
    if AValue.config.FindValue('min') <> nil then
    begin
      var LFieldLength := Length(Trim(FBody.GetValue<string>(AValue.body)));
      var LFieldMinValue := AValue.config.GetValue<Integer>('min');

      if LFieldLength < LFieldMinValue then
        Abort;
    end;

    if AValue.config.FindValue('max') <> nil then
    begin
      var LFieldLength := Length(Trim(FBody.GetValue<string>(AValue.body)));
      var LFieldMaxValue := AValue.config.GetValue<Integer>('min');

      if LFieldLength > LFieldMaxValue then
        Abort;
    end;

  except
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
  end;
end;

function TMiddleWareValidator.withMessage: string;
begin
  result := FItems[FIndex].withMessage;
end;

function TMiddleWareValidator.withMessage(AValue: string): IMiddlewareValidatorItem;
begin
  result := Self;

  FItems[FIndex].withMessage(AValue);
end;

end.
