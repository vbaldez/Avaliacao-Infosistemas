program CadClientes;

uses
  Vcl.Forms,
  UnFrmCadClientes in 'UnFrmCadClientes.pas' {FrmCadClientes},
  UnPesquisaCEP in 'UnPesquisaCEP.pas',
  unFrmEnviarEmail in 'unFrmEnviarEmail.pas' {FrmEnviarEmail},
  UnGerarXML in 'UnGerarXML.pas',
  UnEnviaEmail in 'UnEnviaEmail.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmCadClientes, FrmCadClientes);
  Application.Run;
end.
