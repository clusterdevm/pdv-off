unit view.pendentes.baixa;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, DBGrids;

type

  { Tf_pendente }

  Tf_pendente = class(TForm)
    ac_sair: TAction;
    ac_liquidar: TAction;
    ActionList1: TActionList;
    ds: TDataSource;
    qry: TBufDataset;
    Button1: TButton;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    qrybaixar: TBooleanField;
    qrydata_emissao: TDateTimeField;
    qryn_cliente: TStringField;
    qryn_vendedor: TStringField;
    qryvalor: TFloatField;
    qryvenda_id: TLongintField;
    procedure FormShow(Sender: TObject);
  private
        Procedure Listar;
  public

  end;

var
  f_pendente: Tf_pendente;

implementation

{$R *.lfm}

{ Tf_pendente }

procedure Tf_pendente.FormShow(Sender: TObject);
begin
     Listar;
end;

procedure Tf_pendente.Listar;
begin
    Messagedlg('Não Há vendas Pendentes de baixa',mtInformation,[mbok],0);
end;

end.

