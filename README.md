# horse-validator
Middleware para validar body em requisições http

# Instalação
Instalação utilizando o boss

```
boss install https://github.com/rafaeljeremias/horse-validator.git
```
# Declaração
Para utilizar o horse-validator você deve adicionar as uses:
```
Horse,
Horse.Commons,
middleware.validator,
middleware.validator.interfaces;
```

# Como usar
```
procedure ValidarJsonEmissaoNFe(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LValidator: IMiddleWareValidator;
begin
  LValidator := TMiddleWareValidator.New(Req, Res, Next);

  with LValidator do
  begin
     body('nr_loja').isInt('{ "min": 1 }').withMessage('Campo "nr_loja" deve ser informado e maior que zero!');
     body('id_venda').isInt('{ "min": 1 }').withMessage('Campo "id_venda" deve ser informado e maior que zero!');
     body('nm_produto').isString('{ "min": 10 }').withMessage('Campo "nr_produto" deve ser informado e maior que 9 caracteres!');
  end;

  LValidator.Execute;

  Next();
end;


THorse.Group
    .Prefix(API_VERSAO)
      .Use(ValidarJsonEmissaoNFe)
        .POST(PATH_NFE, RegistrarNFe);
```