unit UnGerarXML;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, Vcl.StdCtrls, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope,
  Data.DBXJSONReflect, REST.Json, JSON, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageXML, Xml.xmldom, Xml.XmlTransform, XMLDoc, XMLIntf;

  type
     TTGerarXML = class
        FNome_Arquivo: String;  // Nome do Arquivo
        FPath_Arquivo: String;  // Local onde o arquivo ser� salvo

        // Dados pessoais
        FNOME: String;
        FIDENTIDADE: String;
        FCPF: String;
        FTELEFONE: String;
        FEMAIL: String;
        FPAIS: String;

        // Dados do Endere�o
        FCEP: String;
        FENDERECO: String;
        FCOMPLEMENTO: String;
        FBAIRRO: String;
        FLOCALIDADE: String;
        FUF: String;
        FNUMERO: String;
     private
        // Define objetos para gera��o do XML
        FXMLDocument: TXMLDocument;
        FNodeTabela, FNodeRegistro, FNodeEndereco: IXMLNode;

     public
        // Create recebe os par�metros do Nome do Arquivo e Local p/ Salvar
        constructor Create(sNome_Arquivo, sPath_Arquivo: String);

        // Destrutor da Classe
        Destructor Destory;

        // Gera o arquivo XML, retorno indica se tudo deu certo ou n�o
        function Gerar_Arquivo: Boolean;
     end;

implementation

{ TTGerarXML }

constructor TTGerarXML.Create(sNome_Arquivo, sPath_Arquivo: String);
begin
    inherited Create;  // Construtor Default

    // Inicializa Vari�veis
    FNome_Arquivo := sNome_Arquivo;  // armazena o nome do arquivo
    FPath_Arquivo := sPath_Arquivo;  // armazena o path p/ salvamento do arquivo

    // Verifica se tem uma barra no final do Path, se houver, retira
    if Copy(FPath_Arquivo, Length(FPath_Arquivo), 1) = '\' then
       FPath_Arquivo := Copy(FPath_Arquivo, 1, Length(FPath_Arquivo) - 1); // Retira barra no final do Path

    // Dados do Pessoais
    FNOME         := '';
    FIDENTIDADE   := '';
    FCPF          := '';
    FTELEFONE     := '';
    FEMAIL        := '';

    // Dados do Endere�o
    FPAIS         := '';
    FCEP          := '';
    FENDERECO     := '';
    FCOMPLEMENTO  := '';
    FBAIRRO       := '';
    FLOCALIDADE   := '';
    FUF           := '';
    FNUMERO       := '';

    // Componente p/ gera��o do XML
    FXMLDocument := TXMLDocument.Create(nil);
end;

destructor TTGerarXML.Destory;
begin
    FreeAndNil(FXMLDocument);  // Destr�i objeto utilizado p/ gerar o XML

    inherited; //Destrutor Default
end;

function TTGerarXML.Gerar_Arquivo: Boolean;
begin
    Result := False; // Inicializa vari�vel de retorno

    try
      // Ativa o objeto de gera��o do XML
      FXMLDocument.Active := True;

      // Cria Grupo principal
      FNodeTabela := FXMLDocument.AddChild('Cliente');

      // Cria subgrupo Pessoal
      FNodeRegistro := FNodeTabela.AddChild('Pessoal');

      // Prrenche dados pessoais
      FNodeRegistro.ChildValues['Nome']       := FNOME;
      FNodeRegistro.ChildValues['Identidade'] := FIDENTIDADE;
      FNodeRegistro.ChildValues['CPF']        := FCPF;
      FNodeRegistro.ChildValues['Telefone']   := FTELEFONE;
      FNodeRegistro.ChildValues['Email']      := FEMAIL;

      // Cria subgrupo Endereco
      FNodeEndereco := FNodeRegistro.AddChild('Endereco');

      // Preenche dados do Endere�o
      FNodeEndereco.ChildValues['Pais']        := FPAIS;
      FNodeEndereco.ChildValues['CEP']         := FCEP;
      FNodeEndereco.ChildValues['Logradouro']  := FENDERECO;
      FNodeEndereco.ChildValues['Complemento'] := FCOMPLEMENTO;
      FNodeEndereco.ChildValues['Bairro']      := FBAIRRO;
      FNodeEndereco.ChildValues['Localidade']  := FLOCALIDADE;
      FNodeEndereco.ChildValues['UF']          := FUF;
      FNodeEndereco.ChildValues['Numero']      := FNUMERO;

      // Gera o arquivo XML
      FXMLDocument.SaveToFile( FPath_Arquivo + '\' + FNome_Arquivo );

      Result := True;  // Arquivo gerado com sucesso
    except
      On E: Exception do // caso algo d� errado
        begin
            // Exibe mensagem
            Application.MessageBox(pChar('Erro ao criar arquivo : ' + FPath_Arquivo + '\' + FNome_Arquivo + #13#13 + e.Message), 'Aten��o', MB_ICONERROR + MB_OK );

            // Retorna false, algo deu errado
            Result := False;
        end;
    end;
end;

end.
