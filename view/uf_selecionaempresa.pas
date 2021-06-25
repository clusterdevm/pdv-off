unit uf_selecionaEmpresa;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tf_selecionaEmpresa }

  Tf_selecionaEmpresa = class(TForm)
    Button1: TButton;
    cbEmpresa: TComboBox;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  f_selecionaEmpresa: Tf_selecionaEmpresa;

implementation

{$R *.lfm}

{ Tf_selecionaEmpresa }

procedure Tf_selecionaEmpresa.Button1Click(Sender: TObject);
begin
   self.close
end;

end.

