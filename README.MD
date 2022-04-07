- Teste de Admissão para Vaga de Programador Delphi Pleno - Softplan
- Candidato: Anderson Domanoski de Camargo 

Sistema Desenvolvido em Delphi 10.3 com Componentes Nativos.

Arquivos Relacionados:
- Codigo:
. Teste_Softplan.dpr (projeto)
. Principal.pas (form principal)
. Dados.pas (datamodule)
. Comp.pas (funções para componentes)

O projeto tem as DLL´s necessárias para conexão com o Banco SQLite e recursos HTTP para gerenciar os Downloads.

Funcionamento básico:
- Tela Inicial com Menus Laterais (Iniciar Doanload, Exibir Histórico de Downloads e Exibir Mensagem)

- Iniciar Downloads 
.Entra com a URL no Campo disponível em Tela, esse por sua vez, é um Combobox que já contém as URLs sugeridas para testes no PDF
da descrição do Teste para facilitar a utilização.
. Botão "Iniciar Download" só é liberado se campo com URL esteja preenchido, caso haja erro ao tentar efetuar Download, o sistema irá
apresentar mensagem informando irregulariedades.
. Botão "Para Download" só fica ativo caso haja algum Download em andamento.

- Exbir Histórico de Downloads
. Mostrará a relação de Downloads contendo URL e Datas de Inicio e Fim, e duranteo o download atual, ele já irá preencher as informações disponíveis.
. Incluído um botão para Limpar Histórico caso haja necessidade. 

- Progresso
. Mostra um gráfico com a porcentagem atual do Download e o nome do Arquivo em andamento.

