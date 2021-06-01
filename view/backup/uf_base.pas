unit uf_base;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, ActnList;

type

  { TForm1 }

  TForm1 = class(TForm)
    b_editar: TSpeedButton;
    b_localizar: TSpeedButton;
    b_Inativar: TSpeedButton;
    img_32: TImageList;
    Panel1: TPanel;
    b_novo: TSpeedButton;
    StatusBar1: TStatusBar;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

