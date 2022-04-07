{*************************************************************************
* Arquivo com Funções e Processos para Tratamento de Componentes Visuais *
* e Criação de Listas                                                    *
*************************************************************************}

unit Comp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, StrUtils,
  Vcl.Grids, Vcl.DBGrids, Vcl.DBCGrids;

type
  TComp = class

  private
    {}
  public
    procedure InsereLista(vURL, vDataIni, vDataFim: string; vParent: TScrollBox);

    procedure AtualizaListaDownload(vParent: TPanel);
    procedure CriaPanel(vLeft, vTop, vWidth, vHeight: integer; vParent: TScrollBox);
    procedure CriaLabel(vTexto: string; vLeft, vTop, vStyle: integer; vParent: TPanel);

    function RetornaNomeArquivo(vArq: string): string;
  end;

var
  p: TPanel;

implementation

uses Dados;

// Cria Lista na Aba Exibir Histórico de Downloads
procedure TComp.InsereLista(vURL, vDataIni, vDataFim: string; vParent: TScrollBox);
begin
  // Gera Panel dentro de ScrollBox
  CriaPanel(0, 0, 100, 65, vParent);

  // Gera Label dentro de Panel
  CriaLabel('URL:', 3, 1, 1, p);
  CriaLabel(vURL, 3, 15, 0, p);
  CriaLabel('Data Inicio:', 3, 34, 1, p);
  CriaLabel(vDataIni, 3, 47, 0, p);
  CriaLabel('Data Fim:', 280, 34, 1, p);
  CriaLabel(vDataFim, 280, 47, 0, p);
end;

// Cria "Panel" em Tempo de Execução
procedure TComp.CriaPanel(vLeft, vTop, vWidth, vHeight: integer; vParent: TScrollBox);
begin
  P := TPanel.Create(nil);

  P.Left := vLeft;
  P.Top := vTop;
  P.Width := vWidth;
  P.Height := vHeight;
  P.Align := alTop;
  P.AlignWithMargins := true;
  P.Parent := vParent;
end;

// Cria "Label" em Tempo de Execução
procedure TComp.CriaLabel(vTexto: string; vLeft, vTop, vStyle: integer; vParent: TPanel);
var
  l: TLabel;
begin
  L := tLabel.Create(nil);
  L.Left := vLeft;
  L.Top := vTop;
  L.Caption := vTexto;

  if vStyle = 1 then L.Font.Style := [fsBold];

  L.Parent := vParent;
end;

// Retonar Nome do Arquivo Extraindo da URL Enviada
function TComp.RetornaNomeArquivo(vArq: string): string;
var
  i: integer;
  vResp: string;
begin
  vResp := '';
  for i := 0 to Length(vArq) do
  begin
    if (LeftStr(RightStr(vArq,i),1) = '/') and (vResp = '') then
    begin
      vResp := RightStr(vArq,i-1);
      break;
    end;
  end;

  result := vResp;
end;

// Atualiza Lista de Downloads, Criando os Componentes Visuais em Tempo de
// Execução e Consumindo Informações da Tabela
procedure TComp.AtualizaListaDownload(vParent: TPanel);
var
  S: TScrollBox;
begin
  // Gera ScrollBox para Exibição da Lista
  S := TScrollBox.Create(nil);
  S.Align := alClient;
  S.Name := 'ScrollBox1';
  S.Parent := vParent;
  S.Color := clWhite;

  with Dados.FDados do
  begin
    // Deixa em ordem decrescente para Listar Inicialmente o Último Download Ativo
    QryAux.Close;
    QryAux.SQL.Text := ' select * from logdownload order by codigo desc';
    QryAux.Open;

    QryAux.First;

    while not QryAux.Eof do
    begin
      // Insere na Lista os Dados Gerando Componentes Visuais
      InsereLista(QryAux.FieldByName('url').AsString,
                     QryAux.FieldByName('datainicio').AsString,
                     QryAux.FieldByName('datafim').AsString,
                     S);

      QryAux.Next;
    end;
  end;
end;

end.

