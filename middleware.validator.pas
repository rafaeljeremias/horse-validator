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
  System.RegularExpressions,
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

    procedure ValidateJSONArray(AValue: IMiddleWareValidatorItem);
    procedure ValidateInt(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
    procedure ValidateBody(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
    procedure ValidateDate(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
    procedure ValidateEmail(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
    procedure ValidateString(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
    procedure ValidateNumeric(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);

    function key: Boolean;
    function getExists: Boolean;
    function body: string; overload;
    function config: TJSONValue; overload;
    function withMessage: string; overload;
    function getType: TMiddlewareValidatorItemType;
    function config(AValue: TJSONValue): IMiddleWareValidatorItem; overload;
    function MiddlewareValidatorItemType(AValue: TMiddleWareValidatorItemType): IMiddleWareValidatorItem;
  public
    constructor Create(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    destructor Destroy; override;
    class function New(Req: THorseRequest; Res: THorseResponse; Next: TProc): IMiddleWareValidator;

    function body(AValue: string): IMiddleWareValidatorItem; overload;
    function Execute: IMiddleWareValidator;

    function isEmail: IMiddleWareValidatorItem;
    function jsonArray: IMiddleWareValidatorJSONArray;
    function &EndJSONArray: IMiddleWareValidatorJSONArray;
    function isInt(AValue: string): IMiddleWareValidatorItem;
    function isDate(AValue: string): IMiddleWareValidatorItem;
    function isString(AValue: string): IMiddleWareValidatorItem;
    function isNumeric(AValue: string): IMiddleWareValidatorItem;
    function exists(AValue: Boolean = true): IMiddlewareValidatorItem;
    function withMessage(AValue: string): IMiddlewareValidatorItem; overload;
  End;

implementation

{ TMiddleWareValidator }

function TMiddleWareValidator.body(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems.Add(TMiddlewareValidatorItem.body(AValue, FReq, FRes, FNext));

  FIndex := FItems.Count -1;
end;

function TMiddleWareValidator.config(AValue: TJSONValue): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].config(AValue);
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

function TMiddleWareValidator.EndJSONArray: IMiddleWareValidatorJSONArray;
begin
  result := FItems[FIndex].EndJSONArray;
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
      ValidateBody(FBody, LValidatorItem);

      if LValidatorItem.getType = mvtInt then
        ValidateInt(FBody, LValidatorItem);

      if LValidatorItem.getType = mvtString then
        ValidateString(FBody, LValidatorItem);

      if LValidatorItem.getType = mvtDate then
        ValidateDate(FBody, LValidatorItem);

      if LValidatorItem.getType = mvtNumeric then
        ValidateNumeric(FBody, LValidatorItem);

      if LValidatorItem.getType = mvtEmail then
        ValidateEmail(FBody, LValidatorItem);

      if LValidatorItem.getType = mvtJSONArray then
        ValidateJSONArray(LValidatorItem);
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

function TMiddleWareValidator.isEmail: IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].isEmail;
end;

function TMiddleWareValidator.isInt(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].isInt(AValue);
end;

function TMiddleWareValidator.jsonArray: IMiddleWareValidatorJSONArray;
begin
  result := FItems[FIndex].jsonArray;
end;

function TMiddleWareValidator.key: Boolean;
begin
  result := FItems[FIndex].key;
end;

function TMiddleWareValidator.MiddlewareValidatorItemType(
  AValue: TMiddleWareValidatorItemType): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].MiddlewareValidatorItemType(AValue);
end;

function TMiddleWareValidator.isNumeric(AValue: string): IMiddleWareValidatorItem;
begin
  result := Self;

  FItems[FIndex].isNumeric(AValue);
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

procedure TMiddleWareValidator.ValidateBody(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
var
  LExiste: Boolean;
begin
  LExiste := ABody.FindValue(AValue.body) <> nil;

  if AValue.getType = mvtJSONArray then
  begin
    if not LExiste then
      raise Exception.Create(AnsiReplaceStr( Format('JSONArray "%s" deve ser informado!', [AValue.body]), '"', ''''));
  end
  else
  if AValue.getExists <> LExiste then
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
end;

procedure TMiddleWareValidator.ValidateDate(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
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

      LDateJSONValue := (ABody as TJSONObject).GetValue('dt_venda');

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

      LDateJSONValue := (ABody as TJSONObject).GetValue('dt_venda');

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

procedure TMiddleWareValidator.ValidateEmail(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
const
  EmailRegex = '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$';
begin
  try
    if not TRegEx.IsMatch(ABody.GetValue<string>(AValue.body), EmailRegex, [roIgnoreCase]) then
      Abort;
  except
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
  end;
end;

procedure TMiddleWareValidator.ValidateInt(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
begin
  try
    if AValue.config.FindValue('min') <> nil then
      if ABody.GetValue<Integer>(AValue.body) < AValue.config.GetValue<Integer>('min') then
        Abort;
  except
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
  end;
end;

procedure TMiddleWareValidator.ValidateJSONArray(AValue: IMiddleWareValidatorItem);
var
  LValorKey: string;
  LNumberkeys: Integer;
  LJSONValue: TJSONValue;
  LJSONArray: TJSONArray;
  LSubItem: IMiddleWareValidatorItem;
begin
  try
    LJSONArray := FBody.GetValue<TJSONArray>(AValue.body);

    LNumberkeys := AValue.jsonArray.Count;

    if LNumberkeys > 0 then
    begin
      if LJSONArray.Count = 0 then
        raise Exception.Create(Format('Nenhum item encontrado em "%s".', [AValue.body]));

      for LJSONValue in LJSONArray do
      begin
        LValorKey := '';

        for var X := 0 to Pred(LNumberkeys) do
        begin
          LSubItem := AValue.jsonArray.GetIndex(X);

          ValidateBody(LJSONValue, LSubItem);

          if LSubItem.Key then
            LValorKey := LJSONValue.GetValue<string>(LSubItem.body);

          if LSubItem.getType = mvtInt then
            ValidateInt(LJSONValue, LSubItem);

          if LSubItem.getType = mvtString then
            ValidateString(LJSONValue, LSubItem);

          if LSubItem.getType = mvtDate then
            ValidateDate(LJSONValue, LSubItem);

          if LSubItem.getType = mvtNumeric then
            ValidateNumeric(LJSONValue, LSubItem);

          if LSubItem.getType = mvtEmail then
            ValidateEmail(LJSONValue, LSubItem);
        end;
      end;
    end;

  except
    on e:Exception do
    begin
      raise Exception.Create(ifThen(Trim(LValorKey) <> '', Format('Key: %s - ', [LValorKey]), '') +
         AnsiReplaceStr(E.message, '"', ''''));
    end;
  end;
end;

procedure TMiddleWareValidator.ValidateNumeric(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
begin
  try
    if AValue.config.FindValue('min') <> nil then
    begin
      var LFieldValue := ABody.GetValue<Double>(AValue.body, 0);
      var LFieldMinValue := AValue.config.GetValue<Double>('min', 0);

      if LFieldValue < LFieldMinValue then
        Abort;
    end;

    if AValue.config.FindValue('max') <> nil then
    begin
      var LFieldValue := ABody.GetValue<Double>(AValue.body, 0);
      var LFieldMaxValue := AValue.config.GetValue<Double>('max', 0);

      if LFieldValue > LFieldMaxValue then
        Abort;
    end;

  except
    raise Exception.Create(AnsiReplaceStr(AValue.withMessage, '"', ''''));
  end;
end;

procedure TMiddleWareValidator.ValidateString(ABody: TJSONValue; AValue: IMiddleWareValidatorItem);
begin
  try
    if AValue.config.FindValue('min') <> nil then
    begin
      var LFieldLength := Length(Trim(ABody.GetValue<string>(AValue.body)));
      var LFieldMinValue := AValue.config.GetValue<Integer>('min');

      if LFieldLength < LFieldMinValue then
        Abort;
    end;

    if AValue.config.FindValue('max') <> nil then
    begin
      var LFieldLength := Length(Trim(ABody.GetValue<string>(AValue.body)));
      var LFieldMaxValue := AValue.config.GetValue<Integer>('max');

      if LFieldLength > LFieldMaxValue then
        Abort;
    end;

    if AValue.config.FindValue('in') <> nil then
    begin
      var LMathValue := False;

      var LArrayJSON := AValue.config.GetValue<TJSONArray>('in');
      for var LItem in LArrayJSON do
        if LItem.Value = ABody.GetValue<string>(AValue.body) then
          LMathValue := True;

      if not LMathValue then
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
