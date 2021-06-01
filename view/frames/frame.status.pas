unit frame.status;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

type

  { TFrame2 }

  TFrame2 = class(TFrame)
    cb_status: TComboBox;
    Label1: TLabel;
  private

  public
      Function GetArray : String;
      Function GetString : String;
  end;

implementation

{$R *.lfm}

{ TFrame2 }

function TFrame2.GetArray: String;
begin
    Result := LowerCase(cb_status.Text);
end;

function TFrame2.GetString: String;
begin
    Result := LowerCase(cb_status.Text);
end;

end.

