unit view.balcao;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, Buttons, StdCtrls, ComCtrls,
  DBGrids;

type

  { Tfrm_balcao }

  Tfrm_balcao = class(TFrame)
    cb_operacao: TComboBox;
    cb_tabela: TComboBox;
    CheckBox1: TCheckBox;
    ComboBox3: TComboBox;
    DBGrid1: TDBGrid;
    Edit6: TEdit;
    edt_IdCliente: TEdit;
    edt_IdCliente1: TEdit;
    edt_IdCliente2: TEdit;
    edt_nomecliente: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label18: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    pnlCliente: TPanel;
    pnlProdutos: TPanel;
    pnlVendedor: TPanel;
    pnl_cabecalho: TPanel;
    pnl_opcaovenda: TPanel;
  private

  public

  end;

implementation

{$R *.lfm}

end.

