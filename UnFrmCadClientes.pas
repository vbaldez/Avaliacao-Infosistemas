unit UnFrmCadClientes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, System.MaskUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids;

type
  TFrmCadClientes = class(TForm)
    pnlHeader: TPanel;
    pnlFooter: TPanel;
    btnSair: TBitBtn;
    pgcPrincipal: TPageControl;
    Tab_Clientes: TTabSheet;
    Tab_ConfigEmail: TTabSheet;
    LabTitulo: TLabel;
    labNome: TLabel;
    edtNome: TEdit;
    edtIdentidade: TEdit;
    labIdentidade: TLabel;
    labCPF: TLabel;
    edtCPF: TEdit;
    edtTelefone: TEdit;
    labTelefone: TLabel;
    edtEmail: TEdit;
    labEmail: TLabel;
    GrpBox_Endereco: TGroupBox;
    edtCEP: TEdit;
    labCEP: TLabel;
    labLogradouro: TLabel;
    edtLogradouro: TEdit;
    edtNumero: TEdit;
    labNumero: TLabel;
    edtComplemento: TEdit;
    labComplemento: TLabel;
    edtBairro: TEdit;
    labBairro: TLabel;
    labCidade: TLabel;
    edtCidade: TEdit;
    edtPais: TEdit;
    labPais: TLabel;
    labEstado: TLabel;
    cbxEstado: TComboBox;
    btnPesquisaCEP: TBitBtn;
    dsMemTable_Clientes: TDataSource;
    FDMemTable_Clientes: TFDMemTable;   // Guarda os dados em Memória
    FDMemTable_ClientesCEP: TStringField;
    FDMemTable_ClientesENDERECO: TStringField;
    FDMemTable_ClientesCOMPLEMENTO: TStringField;
    FDMemTable_ClientesBAIRRO: TStringField;
    FDMemTable_ClientesLOCALIDADE: TStringField;
    FDMemTable_ClientesUF: TStringField;
    FDMemTable_ClientesNOME: TStringField;
    FDMemTable_ClientesIDENTIDADE: TStringField;
    FDMemTable_ClientesCPF: TStringField;
    FDMemTable_ClientesTELEFONE: TStringField;
    FDMemTable_ClientesEMAIL: TStringField;
    FDMemTable_ClientesPAIS: TStringField;
    FDMemTable_ClientesNUMERO: TStringField;
    pnlCadastrados: TPanel;
    labCadastrados: TLabel;
    pnlManutCadastro: TPanel;
    gridCadastrados: TDBGrid;
    btnDeleteCliente: TBitBtn;
    btnIncluirCliente: TBitBtn;
    edtServidorSMTP: TEdit;
    labServidorSMTP: TLabel;
    labUsuario: TLabel;
    edtUsuario: TEdit;
    edtPorta: TEdit;
    labPorta: TLabel;
    edtSenha: TEdit;
    labSenha: TLabel;
    chkConexaoSegura: TCheckBox;
    labDica_Porta: TLabel;
    procedure btnSairClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure edtCPFExit(Sender: TObject);
    procedure edtCPFEnter(Sender: TObject);
    procedure btnDeleteClienteClick(Sender: TObject);
    procedure btnPesquisaCEPClick(Sender: TObject);
    procedure btnIncluirClienteClick(Sender: TObject);
    procedure gridCadastradosDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure Inicializa_Objetos;   // Limpa dados dos Obejtos do Cliente/Endereço
  public
    { Public declarations }
  end;

var
  FrmCadClientes: TFrmCadClientes;

implementation

{$R *.dfm}

uses UnPesquisaCEP, unFrmEnviarEmail, UnGerarXML, UnEnviaEmail;

procedure TFrmCadClientes.btnDeleteClienteClick(Sender: TObject);
begin
    if not(FDMemTable_Clientes.State in [dsInactive]) And   // Verifica se a tabela está aberta
          (FDMemTable_Clientes.RecordCount > 0) And         // Verifica se tem registros
          (Application.MessageBox(pChar('Confirma Exclusão do Cliente: ' + FDMemTable_ClientesNOME.AsString + ' ?'),'Atenção', MB_ICOnQUESTION + MB_YESNO) = ID_YES ) then // Pede confirmação p/ Excluir
    begin
        try
          FDMemTable_Clientes.Delete;  // Deleta o registro
        except // caso algo dê errado, exibe mensagem
           On E: Exception do
           begin
               // Exibe mensagem de Erro
               Application.MessageBox(PChar('Erro ao Excluir o Cliente!' + #13 + #13 + e.Message), 'Atenção', MB_ICONERROR );

               // Seta o foco p/ nome
               edtNome.SetFocus;
           end;
        end;
    end;
end;

procedure TFrmCadClientes.btnIncluirClienteClick(Sender: TObject);
var
  sMsgErro: String;             // Vai armazenar os erros encontrados
  FGerarXML: TTGerarXML;        // Classe p/ gerar XML
  FEnviarEmail: TTEnviarEmail;  // Classe p/ Enviar o E-mail

begin
    sMsgErro := '';  // Inicializa variável
    // Valida alguns campos necessários p/ que seja permitida a inclusão
    {if Trim(edtNome.Text) = '' then  // Verifica o Nome
       sMsgErro := '  - Nome do Cliente não informado.' + #13;

    if Trim(edtCPF.Text) = '' then  // Verifica o CPF/CNPJ
       sMsgErro := '  - CPF/CNPJ não informado.' + #13;

    if Trim(edtEmail.Text) = '' then  // Verifica o E-Mail
       sMsgErro := sMsgErro + '  - Estado não informado.' + #13;

    if Trim(edtCEP.Text) = '' then  // Verifica o CEP
       sMsgErro := sMsgErro + '  - CEP não informado.' + #13;

    if Trim(edtLogradouro.Text) = '' then  // Verifica o Logradouro
       sMsgErro := sMsgErro + '  - Logradouro não informado.' + #13;

    if Trim(edtBairro.Text) = '' then  // Verifica o Bairro
       sMsgErro := sMsgErro + '  - Bairro não informado.' + #13;

    if Trim(edtCidade.Text) = '' then  // Verifica a Cidade
       sMsgErro := sMsgErro + '  - Cidade não informada.' + #13;

    if Trim(cbxEstado.Text) = '' then  // Verifica a Cidade
       sMsgErro := sMsgErro + '  - Estado não informado.' + #13;

    if Trim(edtServidorSMTP.Text) = '' then  // Verifica o Servidor SMTP
       sMsgErro := sMsgErro + '  - E-Mail: Servidor SMTP não informado.' + #13;

    if Trim(edtPorta.Text) = '' then  // Verifica a Porta
       sMsgErro := sMsgErro + '  - E-Mail: Porta não informada.' + #13;

    if Trim(edtUsuario.Text) = '' then  // Verifica o Usuário
       sMsgErro := sMsgErro + '  - E-Mail: Usuário não informado.' + #13;

    if Trim(edtSenha.Text) = '' then  // Verifica a Senha
       sMsgErro := sMsgErro + '  - E-Mail: Senha não informada.' + #13; }

    // Se Falta alguma informação
    if Trim(sMsgErro) <> '' then
    begin
        // Exibe Mensagem
        Application.MessageBox(PChar('O(s) Campo(s) abaixo são de preenchimento Obrigatório: ' + #13#13 + sMsgErro), 'Atenção', MB_ICONINFORMATION + MB_OK );

        // Sai
        exit;
    end;

    // Verifica se DataSet que armazenará os dados em memória está aberto, se não, abre
    if FDMemTable_Clientes.State in [dsInactive] then
       FDMemTable_Clientes.Open;  // Abre

    try
      // Insere o novo Cliente e Atribui valores aos campos
      FDMemTable_Clientes.Append;
      FDMemTable_ClientesNOME.AsString        := edtNome.Text;
      FDMemTable_ClientesIDENTIDADE.AsString  := edtIdentidade.Text;
      FDMemTable_ClientesCPF.AsString         := edtCPF.Text;
      FDMemTable_ClientesTELEFONE.AsString    := edtTelefone.Text;
      FDMemTable_ClientesEMAIL.AsString       := edtEmail.Text;
      FDMemTable_ClientesPAIS.AsString        := edtPais.Text;
      FDMemTable_ClientesCEP.AsString         := edtCEP.Text;
      FDMemTable_ClientesENDERECO.AsString    := edtLogradouro.Text;
      FDMemTable_ClientesCOMPLEMENTO.AsString := edtComplemento.Text;
      FDMemTable_ClientesBAIRRO.AsString      := edtBairro.Text;
      FDMemTable_ClientesLOCALIDADE.AsString  := edtCidade.Text;
      FDMemTable_ClientesUF.AsString          := cbxEstado.Text;
      FDMemTable_ClientesNUMERO.AsString      := edtNumero.Text;
      FDMemTable_Clientes.Post; // Grava dados no DataSet

      // Se fosse pra gerar o XML do FDMemTable, o código abaixo o faria
      //TFDStorageFormat = (sfAuto, sfXML, sfBinary, sfJSON);
      //FDMemTable_Clientes.SaveToFile('C:\Teste1.xml', sfXML);

      // Instância a Classe p/ gerar o XML
      FGerarXML := TTGerarXML.Create('Dados.xml',   // Nome do Arquivo
                                     ExtractFilePath(ParamStr(0)) );  // Passa o Path de onde o executável está sendo executado p/ criar o XML

      // Preenche a classe com os Dados do Cliente
      FGerarXML.FNOME         := edtNome.Text;
      FGerarXML.FIDENTIDADE   := edtIdentidade.Text;
      FGerarXML.FCPF          := edtCPF.Text;
      FGerarXML.FTELEFONE     := edtTelefone.Text;
      FGerarXML.FEMAIL        := edtEmail.Text;
      FGerarXML.FPAIS         := edtPais.Text;
      FGerarXML.FCEP          := edtCEP.Text;
      FGerarXML.FENDERECO     := edtLogradouro.Text;
      FGerarXML.FCOMPLEMENTO  := edtComplemento.Text;
      FGerarXML.FBAIRRO       := edtBairro.Text;
      FGerarXML.FLOCALIDADE   := edtCidade.Text;
      FGerarXML.FUF           := cbxEstado.Text;
      FGerarXML.FNUMERO       := edtNumero.Text;

      // Gera o arquivo XML
      if FGerarXML.Gerar_Arquivo() = True then // Se Gerou o Arquivo, chama tela de Envio de E-mail
      begin
          try
            // Instância tela de envio de e-mail
            FrmEnviarEmail := TFrmEnviarEmail.Create(Self);
            // Nome do Remetente
            FrmEnviarEmail.edtNome_Rem.Text     := 'Infosistemas';
            // E-mail do remetente
            FrmEnviarEmail.edtEmail_Rem.Text    := edtUsuario.Text;
            // E-mail do destinatário
            FrmEnviarEmail.edtEmail_Dest.Text   := edtEmail.Text;
            // Assunto do E-mail
            FrmEnviarEmail.edtAssunto.Text      := 'Cliente Cadastrado na Infosistemas';
            // Anexa o arquivo XML
            FrmEnviarEmail.lstAnexos.Items.Text := FGerarXML.FPath_Arquivo + '\' + FGerarXML.FNome_Arquivo;
            // Monta o corpo do E-mail com os dados cadastrados
            FrmEnviarEmail.richMSG.Lines.Text   := 'Informações Cadastrais: ' + #13#10 +
                                                   '  Nome: ' + edtNome.Text + #13#10 +
                                                   '  Identidade: ' + edtIdentidade.Text + #13#10 +
                                                   '  CPF/CNPJ: ' + edtCPF.Text + #13#10 +
                                                   '  Telefone: ' + edtTelefone.Text + #13#10 +
                                                   '  E-mail: ' + edtEmail.Text + #13#10 +
                                                   '  País: ' + edtPais.Text + #13#10 +
                                                   '  CEP: ' + edtCEP.Text + #13#10 +
                                                   '  Logradouro: ' + edtLogradouro.Text + #13#10 +
                                                   '  Complemento: ' + edtComplemento.Text + #13#10 +
                                                   '  Bairro: ' + edtBairro.Text + #13#10 +
                                                   '  Cidade: ' + edtCidade.Text + #13#10 +
                                                   '  Estado: ' + cbxEstado.Text + #13#10 +
                                                   '  Número: ' + edtNumero.Text + #13#10;

            // Exibe tela de Envio de E-mail
            FrmEnviarEmail.ShowModal;

            // Verifica se confirmou o envio do E-mail
            if FrmEnviarEmail.Bo_Enviar = True then
            begin
                try
                  // Instância Classe de Envio de E-mail passando a configuração do Servidor de E-mail
                  FEnviarEmail := TTEnviarEmail.Create(edtServidorSMTP.Text, edtPorta.Text,
                                                       edtUsuario.Text, edtSenha.Text,
                                                       chkConexaoSegura.Checked);

                  // Dados do Remetente
                  FEnviarEmail.FRemetente_Nome  := FrmEnviarEmail.edtNome_Rem.Text;
                  FEnviarEmail.FRemetente_Email := FrmEnviarEmail.edtEmail_Rem.Text;

                  // Dados do Envio
                  FEnviarEmail.FDest_Email      := FrmEnviarEmail.edtEmail_Dest.Text;
                  FEnviarEmail.FAssunto         := FrmEnviarEmail.edtAssunto.Text;
                  FEnviarEmail.FMensagem        := FrmEnviarEmail.richMSG.Lines.Text;
                  FEnviarEmail.FAnexo           := FGerarXML.FPath_Arquivo + '\' + FGerarXML.FNome_Arquivo;

                  // Envia o E-mail
                  if FEnviarEmail.EnviaEmail = True then
                     Application.MessageBox('E-mail enviado com sucesso!', 'Atenção', MB_ICONERROR + MB_OK );  // Exibe mensagem de Envio OK

                  // Destrói a Classe de Envio
                  FreeAndNil(FEnviarEmail);
                except
                  On E: Exception do    // Caso algo dê errado
                    begin
                       // Exibe mensagem
                       Application.MessageBox(pChar('Erro ao Enviar E-mail p/ o Cliente.' + #13#13 + e.Message), 'Atenção', MB_ICONERROR + MB_OK );
                       FreeAndNil(FEnviarEmail);  // Destrói a Classe de Envio
                    end;
                end;
            end;
            // Destrói o Formulário de Envio de Email
            FreeAndNil(FrmEnviarEmail);
          except
            On E: Exception do   // Caso algo dê errado
            begin
                // Exibe mensagem
                Application.MessageBox(pChar('Erro ao Enviar E-mail p/ o Cliente.' + #13#13 + e.Message), 'Atenção', MB_ICONERROR + MB_OK );
                FreeAndNil(FrmEnviarEmail); // Destrói o Formulário de Envio de Email
            end;
          end;
      end
      else // Não gerou o XML, exibe mensagem
         Application.MessageBox('Arquivo XML não foi gerado, E-mail com os Dados do Cliente não Enviado!', 'Atenção', MB_ICONINFORMATION + MB_OK);

      // Destrói classe de geração do XML
      FreeAndNil(FGerarXML);

      // Limpa dados dos Obejtos do Cliente/Endereço
      Inicializa_Objetos;

      // Exibe mensagem de cliente cadfastrado com sucesso
      Application.MessageBox('Cliente Incluido com Sucesso!', 'Atenção', MB_ICONINFORMATION + MB_OK );
    Except   // Caso haja algum erro
      On E: Exception do
      begin
          // Destrói classe de geração do XML caso esteja instânciada
          if Assigned(FGerarXML) then
             FreeAndNil(FGerarXML);

          // Caso o DataSet esteja em modo de Edição, cancela
          if FDMemTable_Clientes.State in [dsEdit, dsInsert] then
             FDMemTable_Clientes.Cancel;  // Cancela Edição

          // Exibe mensagem
          Application.MessageBox(pChar('Erro ao Cadastrar o Cliente.' + #13#13 + e.Message), 'Atenção', MB_ICONERROR + MB_OK );

          // Set foco no Nome
          edtNome.SetFocus;
      end;
    end;
end;

procedure TFrmCadClientes.btnPesquisaCEPClick(Sender: TObject);
var
  FPesquisaCEP: TTPesquisaCEP; // Cria variável p/ a classe de pesquisa de CEP

begin
    try
      // Verifica se foi informado o CEP
      if Trim(edtCEP.Text) = '' then
      begin
          // exibe mensagem de alerta
          Application.MessageBox('CEP não Informado!', 'Atenção', MB_ICONINFORMATION + MB_OK);

          // Seta o Foco no edit do CEP
          edtCEP.SetFocus;
          // sai da procedure
          exit;
      end;

      // Instância a classe de pesquisa
      FPesquisaCEP := TTPesquisaCEP.Create;

      // Faz a pesquisa do CEP
      if FPesquisaCEP.Pesquisa_CEP(edtCEP.Text) = True then
      begin
          // Localizou o CEP, preenche objetos do Endereço
          edtCep.Text         := FPesquisaCEP.FCep;
          edtLogradouro.Text  := FPesquisaCEP.FLogradouro;
          edtComplemento.Text := FPesquisaCEP.FComplemento;
          edtBairro.Text      := FPesquisaCEP.FBairro;
          edtCidade.Text      := FPesquisaCEP.FLocalidade;
          cbxEstado.Text      := FPesquisaCEP.FUf;
      end
      else // Não encontrou o CEP
      begin
          // Exibe Mensagem
          Application.MessageBox('CEP não Localizado ou Inválido!', 'Atenção', MB_ICONINFORMATION + MB_OK);

          // Seta o foco no edit do CEP
          edtCEP.SetFocus;
      end;

      // Destrói a Classe de pesquisa de Cep
      FPesquisaCEP.Destory;
    except  // caso haja algum erro
      On E: Exception do
        begin
            // caso tenha instânciado a Classe de Pesquisa, destrói
            if Assigned(FPesquisaCEP) then
               FPesquisaCEP.Destory;

            // Exibe a Mensagem
            Application.MessageBox(pChar('Houve erro ao localizar o CEP!' + #13#13 + e.Message), 'Atenção', MB_ICOnERROR + MB_OK);

            // Seta o foco no edit do CEP
            edtCEP.SetFocus;
        end;
    end;
end;

procedure TFrmCadClientes.btnSairClick(Sender: TObject);
begin
    // Fecha o Sistema
    Close;
end;

procedure TFrmCadClientes.edtCPFEnter(Sender: TObject);
begin
    if Trim(edtCPF.Text) <> '' then  // Verifica se foi informado o CPF
    begin
        // Remove mascaras p/ edição, caso existam
        edtCPF.Text := StringReplace(edtCPF.Text, '.', '', [rfReplaceAll]);
        edtCPF.Text := StringReplace(edtCPF.Text, '-', '', [rfReplaceAll]);
    end;
end;

procedure TFrmCadClientes.edtCPFExit(Sender: TObject);
var
  sCPF: String;  // Declara variável local p/ tratar o CPF/CNPJ
begin
    if Trim(edtCPF.Text) <> '' then  // Verifica se foi informado o CPF/CNPJ, se sim, Formata
    begin
        // Remove mascaras, caso existam
        sCPF := edtCPF.Text;
        sCPF := StringReplace(sCPF, '.', '', [rfReplaceAll]);
        sCPF := StringReplace(sCPF, '-', '', [rfReplaceAll]);

        if Length(Trim(sCPF)) > 11 then  // mais de 11 digitos, formata como CNPJ
           edtCPF.Text := FormatMaskText('99.999.999/9999-99;0;_', sCPF)
        else  // Formata como CPF
           edtCPF.Text := FormatMaskText('999.999.999-99;0;_', sCPF);
    end;
end;

procedure TFrmCadClientes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    // Fecha o DataSet
    FDMemTable_Clientes.Close;

    // Libera o Form  da memória
    Action := caFree;
end;

procedure TFrmCadClientes.FormCreate(Sender: TObject);
begin
    // Posiciona na aba do Cliente
    pgcPrincipal.ActivePageIndex := 0;

    // Limpa dados dos Obejtos do Cliente/Endereço
    Inicializa_Objetos;
end;

procedure TFrmCadClientes.gridCadastradosDblClick(Sender: TObject);
begin
    // Apenas transfere dados do DataSet p/ os Edits, foi pra facilitar os testes
    if not(FDMemTable_Clientes.State in [dsInactive]) And // Verifica se a tabela está aberta
       (FDMemTable_Clientes.RecordCount > 0) then         // Verifica se tem registros
    begin
        // Atribui valores do DataSet p/ os Edits
        edtNome.Text       := FDMemTable_ClientesNOME.AsString;
        edtIdentidade.Text := FDMemTable_ClientesIDENTIDADE.AsString;
        edtCPF.Text        := FDMemTable_ClientesCPF.AsString;
        edtTelefone.Text   := FDMemTable_ClientesTELEFONE.AsString;
        edtEmail.Text      := FDMemTable_ClientesEMAIL.AsString;
        edtPais.Text       := FDMemTable_ClientesPAIS.AsString;
        edtCEP.Text        := FDMemTable_ClientesCEP.AsString;
        edtLogradouro.Text := FDMemTable_ClientesENDERECO.AsString;
        edtComplemento.Text:= FDMemTable_ClientesCOMPLEMENTO.AsString;
        edtBairro.Text     := FDMemTable_ClientesBAIRRO.AsString;
        edtCidade.Text     := FDMemTable_ClientesLOCALIDADE.AsString;
        cbxEstado.Text     := FDMemTable_ClientesUF.AsString;
        edtNumero.Text     := FDMemTable_ClientesNUMERO.AsString;
    end;
end;

procedure TFrmCadClientes.Inicializa_Objetos;
begin
    // Limpa dados do Cliente
    edtNome.Text        := '';
    edtIdentidade.Text  := '';
    edtCPF.Text         := '';
    edtTelefone.Text    := '';
    edtEmail.Text       := '';

    // Limpa dados do Endereço do Cliente
    edtCEP.Text         := '';
    edtLogradouro.Text  := '';
    edtNumero.Text      := '';
    edtComplemento.Text := '';
    edtBairro.Text      := '';
    edtCidade.Text      := '';
    edtPais.Text        := 'BRASIL';
    cbxEstado.Text      := '';
end;

end.
