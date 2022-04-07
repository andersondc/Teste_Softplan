{*************************************************************************
* DataModule para Tratamento de Dados de Lista de Downloads              *
*************************************************************************}

unit Dados;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFDados = class(TDataModule)
    Trans: TFDTransaction;
    QryAux: TFDQuery;
    SQLiteDriverLink: TFDPhysSQLiteDriverLink;
    Conexao: TFDConnection;
    dsQryAux: TDataSource;
  private
    { Private declarations }
  public
    procedure ConfigurarDados(vDiretorio: string);

    procedure InsereFinalizacaoDownload(vID: integer);
    procedure ExcluiDownload(vID: integer);
    procedure LimparHistorico;

    function InsereDadosDownload(vURL: string): integer;
    function RetornaID: integer;
  end;

var
  FDados: TFDados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

// Configura Conexões com o Banco de Dados SQLite
procedure TFDados.ConfigurarDados(vDiretorio: string);
begin
  // DLL
  SQLiteDriverLink.VendorLib := vDiretorio+'DLL\sqlite3.dll';

  // Banco de Dados
  Conexao.Connected:=false;
  Conexao.Params.Database := vDiretorio+'Banco\logdownload.db';
  Conexao.Connected:=true;
end;

// Insere Dados do Download na Tabela e Retonar ID (Codigo) Gerado
function TFDados.InsereDadosDownload(vURL: string): integer;
var
  vID: integer;
begin
  vID := RetornaID;

  QryAux.Close;
  QryAux.SQL.Text := ' insert into logdownload (' +
                     ' codigo,' +
                     ' url,' +
                     ' datainicio)' +
                     ' values (' +
                     IntToStr(vId) + ', ' +
                     QuotedStr(vURL) + ', ' +
                     QuotedStr(FormatDateTime('yyyy-mm-dd',date)) + ')';
  QryAux.ExecSQL;

  result := vID;
end;

// Atualiza Tabela com Data de Finalização do Download
procedure TFDados.InsereFinalizacaoDownload(vID: integer);
begin
  QryAux.Close;
  QryAux.SQL.Text := ' update logdownload set' +
                     ' datafim=' + QuotedStr(FormatDateTime('yyyy-mm-dd',date)) +
                     ' where codigo=' + IntToStr(vID);
  QryAux.ExecSQL;
end;

// Exclui Download da Tabela Quando Cancelado ou Apresenta Irregulariedades
procedure TFDados.ExcluiDownload(vID: integer);
begin
  QryAux.Close;
  QryAux.SQL.Text := ' delete from logdownload' +
                     ' where codigo=' + IntToStr(vID);
  QryAux.ExecSQL;
end;

// Retona ID para Codigo
function TFDados.RetornaID: integer;
var
  VResp: integer;
begin
  QryAux.Close;
  QryAux.SQL.Text := ' select max(codigo) as IdMax from logdownload';
  QryAux.Open;

  try
    if QryAux.RecordCount > 0 then
      vResp := QryAux.FieldByName('idMax').AsInteger + 1;
  except
    vResp := 1;
  end;
  result := vResp;
end;

// Limpa Histórico
procedure TFDados.LimparHistorico;
begin
  QryAux.Close;
  QryAux.SQL.Text:='delete from logdownload';
  QryAux.ExecSQL;
end;

end.
