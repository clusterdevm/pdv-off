unit frame.empresa;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, StdCtrls, CheckLst,
  ComboEx, DBCtrls;

type

  { TFrame1 }

  TFrame1 = class(TFrame)
    DBLookupComboBox2: TDBLookupComboBox;
    qEmpresa: TBufDataset;
    qEmpresadescricao: TStringField;
    qEmpresaid: TLongintField;
    dsempresa: TDataSource;
    Label1: TLabel;
  private

  public
       function GetArray : String;
       function GetItem : String;
       Procedure carregaEmpresa;
  end;

implementation

{$R *.lfm}
 uses model.conexao;

function TFrame1.GetArray: String;
begin
     result := DBLookupComboBox2.KeyValue;
end;

function TFrame1.GetItem: String;
begin
  result := DBLookupComboBox2.KeyValue;
end;

procedure TFrame1.carregaEmpresa;
var _db : TConexao;
begin
try
  try
     _db := TConexao.Create;
     qEmpresa.CreateDataset;
     qEmpresa.Open;
     with _db.Query do
     Begin
         Close;
         Sql.Clear;
         Sql.Add('select * from empresa ');
         open;

         while not eof do
         Begin
             qEmpresa.Append;
             qEmpresaid.Value:= FieldBYName('id').AsInteger;
             qEmpresadescricao.Value:= FieldBYName('nomeresumido').AsString;
             qEmpresa.Post;
             Next;
         end;
         first;
         DBLookupComboBox2.KeyValue:= FieldByName('id').AsInteger;
     end;
  finally
     FreeAndNil(_db);
  end;
except
   on e:Exception do
   Begin
      Showmessage('Get Empresa:' +e.message);
   end;
end;
end;

end.

