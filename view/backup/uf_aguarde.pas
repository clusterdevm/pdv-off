unit uf_aguarde;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  BCRadialProgressBar;

type

  { Tf_aguarde }

  Tf_aguarde = class(TForm)
    _progress: TBCRadialProgressBar;
    lblMSG: TLabel;
    Panel1: TPanel;
  private

  public

  end;

var
  f_aguarde: Tf_aguarde;

implementation

{$R *.lfm}

end.

