program Cluster_PDV;

{$mode delphi}{$H+}

uses
  {$IFDEF MSWINDOWS}
  {$else}
      cthreads,
  {$ENDIF}
  cmem,   SysUtils,
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, lazcontrols, form.login, model.vendas.config,
  model.vendas.imposto, view.filtros.cliente, view.venda, model.request.http,
  ems.conexao, ems.utils, model.sinc.down, model.login, model.usuarios,
  dateutils, controller.condicional,

  model.request.jsons, view.condicional.filtrar,

  view.condicional.criar, model.pessoa, cluster_pdv.sessao, uf_aguarde,
  view.devolucao.filtrar, view.devolucao.criar, thread.wait, wcursos,
  view.condicional;

{$R *.res}

begin
  FormatSettings.DateSeparator := '/';
  FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  FormatSettings.CurrencyString := '';
  FormatSettings.DecimalSeparator := '.';


  //RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrm_login, frm_login);
  Application.CreateForm(Tf_produtosPesquisaSelecao, f_produtosPesquisaSelecao);
  Application.Run;

end.


