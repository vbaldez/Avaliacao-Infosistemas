unit UnPesquisaCEP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, Vcl.StdCtrls, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope,
  Data.DBXJSONReflect, REST.Json, JSON, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageXML, Xml.xmldom, Xml.XmlTransform;

  type
     TTPesquisaCEP = class
        // Define vari�veis para armazenar dados do Endere�o retornados pelo ViaCep
        FCep: String;
        FLogradouro: String;
        FComplemento: String;
        FBairro: String;
        FLocalidade: String;
        FUf: String;
        FIbge: String;
        FGia: String;
        FDdd: String;
        FSiafi: String;

     private
        // Define objetos para pesquisa do CEP
        FRESTClient1: TRESTClient;      // p/ Conex�o
        FRESTRequest1: TRESTRequest;    // p/ Requisi��o
        FRESTResponse1: TRESTResponse;  // p/ Respopsta

     public
        // Construtor Default
        constructor Create;
        // Destrutor Default
        Destructor Destory;

        // Pesquisa o CEP no ViaCep
        function Pesquisa_CEP(sCEP_Pesquisa: String): Boolean;
     end;


implementation

{ TTPesquisaCEP }

constructor TTPesquisaCEP.Create;
begin
    inherited;  // Construtor Default

    // Inicializa vari�veis
    FCep         := '';
    FLogradouro  := '';
    FComplemento := '';
    FBairro      := '';
    FLocalidade  := '';
    FUf          := '';
    FIbge        := '';
    FGia         := '';
    FDdd         := '';
    FSiafi       := '';

    // Inst�ncia objetos para pesquisa do CEP
    FRESTClient1           := TRESTClient.Create(nil);   // p/ Conex�o
    FRESTResponse1         := TRESTResponse.Create(nil); // p/ Respopsta
    FRESTRequest1          := TRESTRequest.Create(nil);  // p/ Requisi��o
    FRESTRequest1.Client   := FRESTClient1;              // Liga ao objeto de conex�o
    FRESTRequest1.Response := FRESTResponse1;            // Liga ao objeto de resposta
end;

destructor TTPesquisaCEP.Destory;
begin
    // Destr�i objetos utilizados p/ pesquisar o CEP
    FreeAndNil(FRESTRequest1);
    FreeAndNil(FRESTResponse1);
    FreeAndNil(FRESTClient1);

    inherited; //Destrutor Default
end;

function TTPesquisaCEP.Pesquisa_CEP(sCEP_Pesquisa: String): Boolean;
var
  Data: TJSONObject;  // vari�vel p/ guardar os dados em JSON
  sCEP: String;
begin
    // Inicializa o Retorno
    Result := False;

    // Remove poss�veis mascaras
    sCEP := sCEP_Pesquisa;
    sCEP := StringReplace(sCEP, '.', '', [rfReplaceAll]);
    sCEP := StringReplace(sCEP, '-', '', [rfReplaceAll]);

    try
      // Define URL base
      FRESTClient1.BaseURL   := 'https://viacep.com.br';

      // Define URL de pesquisa
      FRESTRequest1.Resource := 'ws/' + sCEP + '/json';

      // Define o m�todo, no caso GET
      FRESTRequest1.Method   := rmGET;

      // Define que o conte�do de resposta p/ o objeto ser� um JSON
      FRESTRequest1.Response.ContentType := 'application/json';

      // Executa pesquisa
      FRESTRequest1.Execute;

      // Cria um JSONObject que conter� os dados do CEP pesquisado
      Data := FRESTResponse1.JSONValue as TJSONObject;

      // Verifica se objeto foi inst�nciado, isso somente se foi informado um cep v�lido, nesse caso ser� inst�nciado
      if Assigned(Data) then
      begin
          // Estrutura JSON definida pelo ViaCep
          {
            "cep": "01001-000",
            "logradouro": "Pra�a da S�",
            "complemento": "lado �mpar",
            "bairro": "S�",
            "localidade": "S�o Paulo",
            "uf": "SP",
            "ibge": "3550308",
            "gia": "1004",
            "ddd": "11",
            "siafi": "7107"
          }
          // Atribui valores �s Vari�veis da Classe
          FCep         := data.Values['cep'].Value;
          FLogradouro  := data.Values['logradouro'].Value;
          FComplemento := data.Values['complemento'].Value;
          FBairro      := data.Values['bairro'].Value;
          FLocalidade  := data.Values['localidade'].Value;
          FUf          := data.Values['uf'].Value;
          FIbge        := data.Values['ibge'].Value;
          FGia         := data.Values['gia'].Value;
          FDdd         := data.Values['ddd'].Value;
          FSiafi       := data.Values['siafi'].Value;

          // Pesquisa OK, CEP localizado
          Result := True;
      end;
    except
      On E: Exception do  // Caso haja algum erro
       begin
           // Exibe mensagem de Erro
           Application.MessageBox(pChar('Erro ao pesquisar o CEP: ' + sCEP_Pesquisa + '.' + #13#13 + e.Message), 'Aten��o', MB_ICONERROR + MB_OK );
       end;
    end;
end;

end.
