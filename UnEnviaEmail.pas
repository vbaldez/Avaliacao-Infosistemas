unit UnEnviaEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, Vcl.StdCtrls, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope,
  Data.DBXJSONReflect, REST.Json, JSON, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageXML,
  IniFiles, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdBaseComponent, IdMessage, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdAttachmentFile, IdText;

  type
     TTEnviarEmail = class
        // Dados do Remetente
        FRemetente_Nome: String;
        FRemetente_Email: String;

        // Configuração do E-mail
        FServidor_SMTP: String;
        FServidor_Porta: String;
        FUsuario: String;
        FSenha: String;
        FConexao_Segura: Boolean;

        FDest_Email: String;
        FAssunto: String;
        FMensagem: String;
        FAnexo: String;
     private
        // Define objetos para pesquisa do CEP
        FIdMsg                : TIdMessage;  // Configuração da mensagem
        FIdText               : TIdText;     // Configuração do corpo do e-mail
        FidSMTP               : TIdSMTP;     // Configuração do servidor SMTP

        // Configuração do protocolo SSL.
        // SSL é um padrão de segurança global que utiliza a criptografia entre o servidor web e o navegador
        FIdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;

     public
        // Create recebe os parâmetros p/ configurar o servidor
        constructor Create(sServidorSMTP, sPorta, sUsuario, sSenha: String; bo_ConexaoSegura: Boolean);

        // Destrutor Default
        Destructor Destory;

        // Envia o E-mail, retorna um booleano indicando o sucesso ou não do envio
        function EnviaEmail: Boolean;
     end;


implementation

{ TTEnviarEmail }

constructor TTEnviarEmail.Create(sServidorSMTP, sPorta, sUsuario, sSenha: String; bo_ConexaoSegura: Boolean);
begin
    inherited Create; // Construtor Default

    // Dados do Remetente
    FRemetente_Nome  := '';
    FRemetente_Email := '';

    // Configuração do E-mail
    FServidor_SMTP   := sServidorSMTP;
    FServidor_Porta  := sPorta;
    FUsuario         := sUsuario;
    FSenha           := sSenha;
    FConexao_Segura  := bo_ConexaoSegura;

    // Dados do Envio
    FDest_Email      := '';
    FAssunto         := '';
    FMensagem        := '';
    FAnexo           := '';

    // Instância e Configura os parâmetros necessários para SSL
    FIdSSLIOHandlerSocket                   := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FIdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
    FIdSSLIOHandlerSocket.SSLOptions.Mode   := sslmClient;

    // Instância e configura variável referente a mensagem
    FIdMsg                            := TIdMessage.Create(nil);
    FIdMsg.CharSet                    := 'utf-8';
    FIdMsg.Encoding                   := meMIME;
    FIdMsg.Priority                   := mpNormal;

    // Instância e configura Variável do texto
    FIdText := TIdText.Create(FIdMsg.MessageParts);
    FIdText.ContentType := 'text/html; text/plain; charset=iso-8859-1';

    //Instância e configura objeto p/ conexão com servidor
    FIdSMTP                           := TIdSMTP.Create(nil);
    // Associa ao SMTP a configuração para segurança
    FIdSMTP.IOHandler                 := FIdSSLIOHandlerSocket;
    FIdSMTP.UseTLS                    := utUseImplicitTLS;
    if FConexao_Segura then  // Verifica o tipo de autenticação
       FIdSMTP.AuthType                  := satSASL
    else
       FIdSMTP.AuthType                  := satDefault;

    // Configura o objeto de conexão com Servidor
    FIdSMTP.Host                      := FServidor_SMTP;
    FIdSMTP.AuthType                  := satDefault;
    FIdSMTP.Port                      := StrToIntDef(sPorta, 25);  // Caso porta inválida, utiliza a 25, pode ser qualquer uma
    FIdSMTP.Username                  := FUsuario;
    FIdSMTP.Password                  := FSenha;
end;

destructor TTEnviarEmail.Destory;
begin
    // liberação das DLLs ssleay32.dll e libeay32.dll, utilizadas pelo protocolo de segurança
    UnLoadOpenSSLLibrary;

    // Destrói objetos utilizados p/ montagem do e-mail
    FreeAndNil(FIdMsg);
    FreeAndNil(FIdSSLIOHandlerSocket);
    FreeAndNil(FIdSMTP);

    inherited; //Destrutor Default
end;

function TTEnviarEmail.EnviaEmail: Boolean;
begin
    Result := False;  // Inicializa Retorno
    try
      // Nome do Remetente
      FIdMsg.From.Name                  := FRemetente_Nome;
      // E-mail do Remetente
      FIdMsg.From.Address               := FRemetente_Email;
      // Assunto do E-mail
      FIdMsg.Subject                    := FAssunto;

      //Destinatário(s)
      FidMsg.Recipients.Add;
      FidMsg.Recipients.EMailAddresses := FDest_Email;

      // Corpo do E-mail
      FidText.Body.Text := FMensagem;

      // Conecta e Autentica no Servidor SMTP
      FIdSMTP.Connect;
      FIdSMTP.Authenticate;

      // Adiciona o Anexo no E-mail
      TIdAttachmentFile.Create(FidMsg.MessageParts, FAnexo);

      // Se a conexão foi bem sucedida, envia o E-mail
      if FIdSMTP.Connected then
      begin
          try
            // Envia o E-mail
            FIdSMTP.Send(FidMsg);

            // Tudo certo, e-mail enviado
            Result := True;
          except  // Se algo deu errado
            on E:Exception do
             begin
                // Exibe mensagem
                Application.MessageBox(pChar('Erro ao enviar e-mail' + #13 + E.Message), 'Atenção', MB_ICONERROR + MB_OK);

                // Não enviou
                Result := False;
             end;
          end;
      end;

      // Se conectado ao Servidor SMTP, desconecta
      if FIdSMTP.Connected then
         FIdSMTP.Disconnect;  // Desconecta
    Except  // Se algo deu errado
      On E: Exception do
        begin
            // Exibe mensagem
            Application.MessageBox(pChar('Erro ao enviar e-mail' + #13 + E.Message), 'Atenção', MB_ICONERROR + MB_OK);

            // Não Enviou
            Result := False;
        end;
    end;
end;

end.
