unit ufrmCondicional;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  DBGrids, StdCtrls;

type

  { TfrmCondicionalFiltro }

  TfrmCondicionalFiltro = class(TForm)
    BufDataset1: TBufDataset;
    Button1: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    procedure Button1Click(Sender: TObject);
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
    // Filtrar(BufDataset1,'','rascunho','6','','','','');
end;

end.

