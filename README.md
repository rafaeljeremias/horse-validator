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
  LMenorData: TDate;
  LMaiorData: TDate;
  LValidator: IMiddleWareValidator;
begin
  LValidator := TMiddleWareValidator.New(Req, Res, Next);

  with LValidator do
  begin
    LMaiorData := Now;
    LMenorData := IncDay(Date, -3);

    body('nr_loja').isInt('{ "min": 1 }').withMessage('Campo "nr_loja" deve ser informado e maior que zero!');
    body('id_venda').isInt('{ "min": 1 }').withMessage('Campo "id_venda" deve ser informado e maior que zero!');
    body('cd_venda').isInt('{ "min": 1 }').withMessage('Campo "cd_venda" deve ser informado e maior que zero!');

    body('dt_venda').isDate(Format('{ "min": "%s", "max": "%s" }',
      [FormatDateTime('YYYY-MM-DD', LMenorData), FormatDateTime('YYYY-MM-DD HH:NN:SS', LMaiorData)]))
        .withMessage(Format('Campo "dt_venda" deve ser entre "%s" e "%s"!', [FormatDateTime('DD/MM/YYYY', LMenorData),
          FormatDateTime('DD/MM/YYYY HH:NN:SS', LMaiorData)]));

    body('fg_situacao').isString('{ "min": 1, "max": 1, "in": ["F", "C", "I"] }')
      .withMessage('Campo "fg_situacao" deve ser informado com valor de "F", "C" ou "I"!');

    body('cd_pessoa_funcionario').isInt('{ "min": 1 }').withMessage('Campo "cd_pessoa_funcionario" deve ser informado e maior que zero!');
    body('nr_coo').isInt('{ "min": 1 }').withMessage('Campo "nr_coo" deve ser informado e maior que zero!');
    body('nr_serie').isString('{ "min": 1, "max": 30 }').withMessage('Campo "nr_serie" deve ter entre 1 e 30 caracteres!');
    body('nr_caixa').isInt('{ "min": 1 }').withMessage('Campo "nr_caixa" deve ser informado e maior que zero!');
    body('vl_desconto').isNumeric('{ "min": 0 }').withMessage('Campo "vl_desconto" deve ser informado e maior ou igual a zero!');
  end;

  LValidator.Execute;

  Next();
end;

THorse.Group
    .Prefix(API_VERSAO)
      .Use(ValidarJsonEmissaoNFe)
        .POST(PATH_NFE, RegistrarNFe);
```