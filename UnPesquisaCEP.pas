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
        // Define variáveis para armazenar dados do Endereço retornados pelo ViaCep
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
        FRESTClient1: TRESTClient;      // p/ Conexão
        FRESTRequest1: TRESTRequest;    // p/ Requisição
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

    // Inicializa variáveis
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

    // Instância objetos para pesquisa do CEP
    FRESTClient1           := TRESTClient.Create(nil);   // p/ Conexão
    FRESTResponse1         := TRESTResponse.Create(nil); // p/ Respopsta
    FRESTRequest1          := TRESTRequest.Create(nil);  // p/ Requisição
    FRESTRequest1.Client   := FRESTClient1;              // Liga ao objeto de conexão
    FRESTRequest1.Response := FRESTResponse1;            // Liga ao objeto de resposta
end;

destructor TTPesquisaCEP.Destory;
begin
    // Destrói objetos utilizados p/ pesquisar o CEP
    FreeAndNil(FRESTRequest1);
    FreeAndNil(FRESTResponse1);
    FreeAndNil(FRESTClient1);

    inherited; //Destrutor Default
end;

function TTPesquisaCEP.Pesquisa_CEP(sCEP_Pesquisa: String): Boolean;
var
  Data: TJSONObject;  // variável p/ guardar os dados em JSON
  sCEP: String;
begin
    // Inicializa o Retorno
    Result := False;

    // Remove possíveis mascaras
    sCEP := sCEP_Pesquisa;
    sCEP := StringReplace(sCEP, '.', '', [rfReplaceAll]);
    sCEP := StringReplace(sCEP, '-', '', [rfReplaceAll]);

    try
      // Define URL base
      FRESTClient1.BaseURL   := 'https://viacep.com.br';

      // Define URL de pesquisa
      FRESTRequest1.Resource := 'ws/' + sCEP + '/json';

      // Define o método, no caso GET
      FRESTRequest1.Method   := rmGET;

      // Define que o conteúdo de resposta p/ o objeto será um JSON
      FRESTRequest1.Response.ContentType := 'application/json';

      // Executa pesquisa
      FRESTRequest1.Execute;

      // Cria um JSONObject que conterá os dados do CEP pesquisado
      Data := FRESTResponse1.JSONValue as TJSONObject;

      // Verifica se objeto foi instânciado, isso somente se foi informado um cep válido, nesse caso será instânciado
      if Assigned(Data) then
      begin
          // Estrutura JSON definida pelo ViaCep
          {
            "cep": "01001-000",
            "logradouro": "Praça da Sé",
            "complemento": "lado ímpar",
            "bairro": "Sé",
            "localidade": "São Paulo",
            "uf": "SP",
            "ibge": "3550308",
            "gia": "1004",
            "ddd": "11",
            "siafi": "7107"
          }
          // Atribui valores ás Variáveis da Classe
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
           Application.MessageBox(pChar('Erro ao pesquisar o CEP: ' + sCEP_Pesquisa + '.' + #13#13 + e.Message), 'Atenção', MB_ICONERROR + MB_OK );
       end;
    end;
end;

end.
