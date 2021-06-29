unit frame.pagamento;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, DBGrids, ComCtrls;

type

  { TframePagamento }

  TframePagamento = class(TFrame)
    Button1: TButton;
    ComboBox1: TComboBox;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    tabDinheiro: TTabSheet;
    tabCredito: TTabSheet;
    tabDebito: TTabSheet;
    tabCheque: TTabSheet;
    tabTEF: TTabSheet;
    tabValeCredito: TTabSheet;
    procedure PageControl1Change(Sender: TObject);
  private

  public

  end;

implementation

{$R *.lfm}

{ TframePagamento }

procedure TframePagamento.PageControl1Change(Sender: TObject);
begin

end;

end.

