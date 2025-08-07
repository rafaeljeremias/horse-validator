unit middleware.validator.interfaces;

interface

uses
  System.JSON;

type
  TMiddleWareValidatorItemType = (mvtBody, mvtInt, mvtString, mvtDate, mvtNumeric);

  IMiddleWareValidatorItem = Interface
    ['{D1DFD2E7-2006-4388-B7C0-76D2AB095C9D}']
    function body: string;
    function getExists: Boolean;
    function config: TJSONValue;
    function withMessage: string; overload;
    function getType: TMiddlewareValidatorItemType;
    function isInt(AValue: string): IMiddleWareValidatorItem;
    function isDate(AValue: string): IMiddleWareValidatorItem;
    function isString(AValue: string): IMiddleWareValidatorItem;
    function isNumeric(AValue: string): IMiddleWareValidatorItem;
    function exists(AValue: Boolean = true): IMiddlewareValidatorItem;
    function withMessage(AValue: string): IMiddlewareValidatorItem; overload;
  End;

  IMiddleWareValidator = Interface
    ['{EE17012E-9172-409B-B026-5CD577789E5F}']
    function body(AValue: string): IMiddleWareValidatorItem;
    function Execute: IMiddleWareValidator;
  End;

implementation

end.
