object FDados: TFDados
  OldCreateOrder = False
  Height = 241
  Width = 261
  object Trans: TFDTransaction
    Connection = Conexao
    Left = 48
    Top = 88
  end
  object QryAux: TFDQuery
    Connection = Conexao
    Transaction = Trans
    SQL.Strings = (
      'select * from notas')
    Left = 152
    Top = 16
  end
  object SQLiteDriverLink: TFDPhysSQLiteDriverLink
    VendorLib = 'C:\Users\Anderson\Desktop\Teste Softplan\Codigo\DLL\sqlite3.dll'
    Left = 48
    Top = 160
  end
  object Conexao: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      
        'Database=C:\Users\Anderson\Desktop\Teste Softplan\Codigo\Banco\l' +
        'ogdownload.db')
    LoginPrompt = False
    Left = 48
    Top = 24
  end
  object dsQryAux: TDataSource
    DataSet = QryAux
    Left = 152
    Top = 80
  end
end
