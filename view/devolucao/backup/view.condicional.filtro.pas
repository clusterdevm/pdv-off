unit view.condicional.filtro;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids, ExtCtrls, ComboEx, ActnList, ComCtrls,
  controller.condicional;

type

  { TfrmCondicionalFiltro }

  TfrmCondicionalFiltro = class(TForm)
    acBuscar: TAction;
    ActionList1: TActionList;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmCondicionalFiltro: TfrmCondicionalFiltro;

implementation

{$R *.lfm}

{ TfrmCondicionalFiltro }

procedure TfrmCondicionalFiltro.Button1Click(Sender: TObject);
begin
   Filtrar(cds_condicional,'','rascunho','6','','','','');
end;

procedure TfrmCondicionalFiltro.FormCreate(Sender: TObject);
begin

   cds_condicional.CreateDataset;
   cds_condicional.Open;
end;

end.

