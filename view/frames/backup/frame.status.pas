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
    Result := IntTostr(StrToInt(copy(cb_status.Text,6)));
end;

function TFrame2.GetString: String;
begin
    Result := IntTostr(StrToInt(copy(cb_status.Text,6)));
end;

end.

