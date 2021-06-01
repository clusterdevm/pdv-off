program Cluster_PDV;

{$mode delphi}{$H+}

uses
  cthreads,cmem,   SysUtils,
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols,
  form.login, view.filtros.cliente, view.venda, model.request.http,
  model.conexao, classe.utils, model.sinc.down, model.login, model.usuarios,
  dateutils, controller.condicional,

  model.request.jsons, view.condicional.filtrar,

  view.condicional.criar, model.pessoa, cluster_pdv.sessao, uf_aguarde,
  thread.wait, wcursos, view.condicional;

{$R *.res}

begin

  FormatSettings.DateSeparator := '/';
  FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  FormatSettings.CurrencyString := '';
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ThousandSeparator := '.';

  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrm_login, frm_login);
  Application.CreateForm(Treport_condicional, report_condicional);
  Application.Run;

end.

