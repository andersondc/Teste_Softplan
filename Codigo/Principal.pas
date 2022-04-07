{*************************************************************************
* Teste SoftPlan - Gerenciador de Downloads                              *
*************************************************************************}

unit Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, StrUtils,
  Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.DBCGrids, Comp, Vcl.Imaging.pngimage,
  System.ImageList, Vcl.ImgList, Vcl.Samples.Gauges, IdAntiFreezeBase,
  IdAntiFreeze, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, UrlMon, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL ;

type
  TFPrincipal = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Pags: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Panel5: TPanel;
    Ico3: TImage;
    Ico1: TImage;
    Ico2: TImage;
    i1On: TImage;
    I1Off: TImage;
    i2Off: TImage;
    i2On: TImage;
    i3Off: TImage;
    i3On: TImage;
    IdHTTP: TIdHTTP;
    IdAntiFreeze: TIdAntiFreeze;
    SaveDialog: TSaveDialog;
    Barra: TGauge;
    Image1: TImage;
    Label7: TLabel;
    lStatus: TLabel;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    Image4: TImage;
    bIniciarDown: TButton;
    bPararDown: TButton;
    PanelLista: TPanel;
    ScrollBox1: TScrollBox;
    P1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Progresso: TGauge;
    Label8: TLabel;
    lPorcentagem: TLabel;
    Label10: TLabel;
    lNomedoArquivo: TLabel;
    Label14: TLabel;
    lURL: TLabel;
    Image2: TImage;
    eURL: TComboBox;
    Panel2: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Ico1Click(Sender: TObject);
    procedure Ico2Click(Sender: TObject);
    procedure Ico3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdHTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure bIniciarDownClick(Sender: TObject);
    procedure bPararDownClick(Sender: TObject);
    procedure eURLChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure IconeAtivo(vOpcao: integer);

    procedure IniciarDownload;
    procedure PararDownload;

    procedure AtualizaListaDownload;

    function RetornaPorcentagem(ValorMaximo, ValorAtual: real): string;
    function RetornaKiloBytes(ValorAtual: real): string;
    function DownloadEmAndamento: boolean;
  end;

var
  FPrincipal: TFPrincipal;
  vDiretorio: string;         // Diretório do Programa
  vID: integer;               // Código do Download para Tratamento
  VDownload: boolean;         // Auxiliar para Sinalizar se Download está Ativo

implementation

{$R *.dfm}

uses Dados;

// Atualiza Lista de Histórico de Downloads
procedure TFPrincipal.AtualizaListaDownload;
var
  pd: TComp;
begin
  pd := Comp.TComp.Create;
  pd.AtualizaListaDownload(PanelLista);
  pd.Free;
end;

// Botão Iniciar Download
procedure TFPrincipal.bIniciarDownClick(Sender: TObject);
begin
  Application.ProcessMessages;

  // Chama em segundo Plano o Procedure "IniciarDownload"
  TThread.CreateAnonymousThread(
   procedure()
  begin
    TThread.Synchronize(TThread.CurrentThread, IniciarDownload);
  end).Start;
end;

// Botao Parar Download
procedure TFPrincipal.bPararDownClick(Sender: TObject);
begin
  PararDownload;
end;

// Evento para Encerrar Aplicação (Verifica se há Download em Andamento antes)
procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if DownloadEmAndamento then
  begin
    IdHTTP.Disconnect;
    Application.Terminate;
  end
  else
    Action := caNone;
end;

// Evendo de Criação do Form (definir Parametros Padrões)
procedure TFPrincipal.FormCreate(Sender: TObject);
begin
  vDiretorio := ParamStr(0);
  vDiretorio := LeftStr(vDiretorio,length(vDiretorio)-
                length(ExtractFileName(vDiretorio)));
end;

// Evento de Apresentação do Form (posiciona para o inicio dos processos)
procedure TFPrincipal.FormShow(Sender: TObject);
begin
  iconeAtivo(1);

  // Configura Bando de Dados
  Dados.FDados.ConfigurarDados(vDiretorio);

  // Variável auxiliar para verificar download em andamento
  VDownload := false;
end;

// OnClick dos Icones do Menu Lateral
procedure TFPrincipal.Ico1Click(Sender: TObject);
begin
  iconeAtivo(1);
end;

procedure TFPrincipal.Ico2Click(Sender: TObject);
begin
  iconeAtivo(2);
end;

procedure TFPrincipal.Ico3Click(Sender: TObject);
begin
  iconeAtivo(3);
end;

// Personaliza e acessa as opções do Menu Lateral
procedure TFPrincipal.IconeAtivo(vOpcao: integer);
var
  vIm: TImage;
begin
  ico1.Picture := i1Off.Picture;
  ico2.Picture := i2Off.Picture;
  ico3.Picture := i3Off.Picture;

  case vOpcao of
    1:  // Iniciar Download
    begin
      ico1.Picture := i1On.Picture;
      Pags.ActivePageIndex := 0;
    end;
    2:  // Histórico de Downloads
    begin
      ico2.Picture := i2On.Picture;
      Pags.ActivePageIndex := 1;
      AtualizaListaDownload;
    end;
    3: // Exibir Porcentagem do Download Ativo
    begin
      ico3.Picture := i3On.Picture;
      Pags.ActivePageIndex := 2;
    end;
  end;

  Application.ProcessMessages;
end;

// Eventos do processo de Download
procedure TFPrincipal.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  Barra.Progress := AWorkCount;
  Progresso.Progress := Barra.Progress;

  lStatus.Caption := 'Baixando ... ' + RetornaKiloBytes(AWorkCount);
  lPorcentagem.Caption := RetornaPorcentagem(Barra.Maxvalue, AWorkCount);
end;

procedure TFPrincipal.IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  Barra.MaxValue := AWorkCountMax;
  Progresso.MaxValue := Barra.MaxValue;

  AtualizaListaDownload;
  VDownload := true;
end;

procedure TFPrincipal.IdHTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  Barra.Progress := 0;
  Progresso.Progress := Progresso.MaxValue;

  lStatus.Caption := 'Download Finalizado ...';

  // Insere Data Final no Download na Tabela
  Dados.FDados.InsereFinalizacaoDownload(vID);
  AtualizaListaDownload;

  bIniciarDown.Enabled := true;
  bPararDown.Enabled := false;
  VDownload := false;
end;

// Processo que Inicia o Download
procedure TFPrincipal.IniciarDownload;
var
  fileDownload : TFileStream;
  vNomeArq: string;
  pd: TComp;
begin
  bIniciarDown.Enabled := false;
  bPararDown.Enabled := true;

  pd := Comp.TComp.Create;
  vNomeArq := pd.RetornaNomeArquivo(eURL.Text); // Retonar Nome do Arquivo
  lNomedoArquivo.Caption := vNomeArq;
  lURL.Caption := eURL.Text;

  // Janela para Salvar Arquivo
  SaveDialog.Filter := 'Arquivo ' + ExtractFileExt(eURL.Text) + '|*' + ExtractFileExt(eURL.Text);
  SaveDialog.FileName := vNomeArq;

  if SaveDialog.Execute then
  begin
    // Insere Download na Tabela e Retorna ID Gerada
    vID := Dados.FDados.InsereDadosDownload(eURL.Text);

    fileDownload := TFileStream.Create(SaveDialog.FileName + ExtractFileExt(eURL.Text), fmCreate);
    try
      IdHTTP.Get(eURL.Text, fileDownload);
    except
      // Tratamento de Erro
      ShowMessage('URL para Download com Irregulariedades!'+ #13 +
                  'Verifique o Endereço ou a Disponibilidade do Caminho.');
      bIniciarDown.Enabled := true;
      bPararDown.Enabled := false;

      // Exclui Download da Tabela
      Dados.FDados.ExcluiDownload(vID);
    end;

    FreeAndNil(fileDownload);
  end;
end;

// Encerra Download
procedure TFPrincipal.PararDownload;
begin
  Dados.FDados.ExcluiDownload(vID);   // Exclui Download Atual da Tabela
  IdHTTP.Disconnect;
  bIniciarDown.Enabled := true;
  bPararDown.Enabled := false;
end;

// Retorna Porcentagem do Progresso de Download
function TFPrincipal.RetornaPorcentagem(ValorMaximo, ValorAtual: real): string;
var
  resultado: Real;
begin
  resultado := ((ValorAtual * 100) / ValorMaximo);
  Result := FormatFloat('0%', resultado);
end;

// Retorna Kilobytes Baixados do Progresso de Download
function TFPrincipal.RetornaKiloBytes(ValorAtual: real): string;
var
  resultado : real;
begin
  resultado := ((ValorAtual / 1024) / 1024);
  Result := FormatFloat('0.000 KBs', resultado);
end;

// Retonar Situação do Download Atual para Encerrar Programa
function TFPrincipal.DownloadEmAndamento: boolean;
var
  vResp: boolean;
begin
  if ((VDownload = true) and
     (Application.MessageBox('Existe um download em andamento, '+
                             'deseja interrompe-lo?',
                             'Gerenciador de Download',
                              MB_ICONQUESTION + MB_YESNO) = idYes)) or
     (VDownload = false) then

    vResp := true
  else
    vResp := false;

  result := vResp;
end;

// Tratamento para Não Liberar Botão de Download sem Informação no eURL (Edit)
procedure TFPrincipal.eURLChange(Sender: TObject);
begin
  if Length(eURL.Text)=0 then
    bIniciarDown.Enabled := false
  else
    bIniciarDown.Enabled := true;
end;

// Limpa Histórico
procedure TFPrincipal.Button1Click(Sender: TObject);
begin
  Dados.FDados.LimparHistorico;
  AtualizaListaDownload;
end;

end.
