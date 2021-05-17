unit udm;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, DB, IdHTTP, ZConnection, ZDataset;

type

  { Tdm }

  Tdm = class(TDataModule)
    IdHTTP1: TIdHTTP;
    zusuarioid: TLargeintField;
    zusuarionivel_id: TLargeintField;
    zusuariosenha: TMemoField;
    zusuariousuario: TMemoField;
    zSqlLite: TZConnection;
  private

  public

  end;

var
  dm: Tdm;

implementation

{$R *.lfm}

end.

