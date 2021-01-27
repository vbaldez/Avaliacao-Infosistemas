unit unFrmEnviarEmail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls;

type
  TFrmEnviarEmail = class(TForm)
    Grpbox_Remetente: TGroupBox;
    labNome_Rem: TLabel;
    edtNome_Rem: TEdit;
    labEmail_Rem: TLabel;
    edtEmail_Rem: TEdit;
    Grpbox_Destinatario: TGroupBox;
    edtEmail_Dest: TEdit;
    Grpbox_Assunto: TGroupBox;
    edtAssunto: TEdit;
    Grpbox_Anexo: TGroupBox;
    lstAnexos: TListBox;
    pnlFooter: TPanel;
    richMSG: TRichEdit;
    imgEmail: TImage;
    btnSair: TBitBtn;
    btnEnviar: TBitBtn;
    pnlHeader: TPanel;
    LabTitulo: TLabel;
    procedure btnSairClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Bo_Enviar: Boolean;  // Variável p/ controlar se foi confirmado o Envio do E-mail
  end;

var
  FrmEnviarEmail: TFrmEnviarEmail;

implementation

{$R *.dfm}

procedure TFrmEnviarEmail.btnEnviarClick(Sender: TObject);
begin
   Bo_Enviar := true;  // Confirmou o Envio
   Close;  // Fecha o Formulário;
end;

procedure TFrmEnviarEmail.btnSairClick(Sender: TObject);
begin
   Bo_Enviar := False;  // Não Confirmou o Envio
   Close;  // Fecha o Formulário;
end;

end.
