program Teste_Softplan;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {FPrincipal},
  Dados in 'Dados.pas' {FDados: TDataModule},
  Comp in 'Comp.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.CreateForm(TFDados, FDados);
  Application.Run;
end.
