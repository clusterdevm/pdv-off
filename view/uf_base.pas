unit uf_base;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, ActnList;

type

  { TForm1 }

  TForm1 = class(TForm)
    btBuscar: TSpeedButton;
    btEditar: TSpeedButton;
    btInativar: TSpeedButton;
    btNovo: TSpeedButton;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

