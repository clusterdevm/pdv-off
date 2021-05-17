unit pnl.botoes;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, Buttons;

type

  { TframeBotoes }

  TframeBotoes = class(TFrame)
    Panel1: TPanel;
    btNovo: TSpeedButton;
    btEditar: TSpeedButton;
    btInativar: TSpeedButton;
    btBuscar: TSpeedButton;
  private

  public

  end;

implementation

{$R *.lfm}

end.

