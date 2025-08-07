unit middleware.validator.interfaces;

interface

uses
  System.JSON;

type
  TMiddleWareValidatorItemType = (mvtBody, mvtInt, mvtString, mvtDate, mvtNumeric, mvtEmail, mvtJSONArray);

  IMiddleWareValidatorItem = Interface;

  IMiddleWareValidatorJSONArray = Interface
    ['{8F2307E1-9138-46AA-9079-58BA3E98C32A}']
    function Count: Integer;
    function GetIndex(AValue: Integer): IMiddleWareValidatorItem;
    function Pair(AName: string; AKey: Boolean = False): IMiddleWareValidatorItem;
  End;

  IMiddleWareValidatorItem = Interface
    ['{D1DFD2E7-2006-4388-B7C0-76D2AB095C9D}']
    function body: string;
    function key: Boolean;
    function getExists: Boolean;
    function config: TJSONValue; overload;
    function withMessage: string; overload;
    function isEmail: IMiddleWareValidatorItem;
    function getType: TMiddlewareValidatorItemType;
    function jsonArray: IMiddleWareValidatorJSONArray;
    function &EndJSONArray: IMiddleWareValidatorJSONArray;
    function isInt(AValue: string): IMiddleWareValidatorItem;
    function isDate(AValue: string): IMiddleWareValidatorItem;
    function isString(AValue: string): IMiddleWareValidatorItem;
    function isNumeric(AValue: string): IMiddleWareValidatorItem;
    function exists(AValue: Boolean = true): IMiddlewareValidatorItem;
    function Config(AValue: TJSONValue): IMiddleWareValidatorItem; overload;
    function withMessage(AValue: string): IMiddlewareValidatorItem; overload;
    function MiddlewareValidatorItemType(AValue: TMiddleWareValidatorItemType): IMiddleWareValidatorItem;
  End;

  IMiddleWareValidator = Interface
    ['{EE17012E-9172-409B-B026-5CD577789E5F}']
    function body(APairName: string): IMiddleWareValidatorItem;
    function Execute: IMiddleWareValidator;
  End;

implementation

end.
