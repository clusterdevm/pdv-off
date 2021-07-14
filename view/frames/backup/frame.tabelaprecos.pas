unit frame.tabelaPrecos;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, DBCtrls, StdCtrls;

type

  { Tframe_tabelasPrecos }

  Tframe_tabelasPrecos = class(TFrame)
    ds: TDataSource;
    qry: TBufDataset;
    DBLookupComboBox1: TDBLookupComboBox;
    Label1: TLabel;
    qrydescricao: TStringField;
    qryid: TLongintField;
  private

  public
       Procedure Carrega;
       Function getID: integer ;
  end;

implementation

{$R *.lfm}

uses ems.conexao, ems.utils;

procedure Tframe_tabelasPrecos.Carrega;
var _db : TConexao;
begin
   try
      _db := TConexao.Create;
      with _db.qrySelect do
      Begin
          Close;
          Sql.Clear;
          Sql.Add('select id, descricao from tabela_preco');
          Sql.Add(' where ativo = ''true'' ');
          Sql.Add(' order by descricao');
          open;

          qry.CreateDataset;
          qry.Open;
          while not eof do
          Begin
               qry.Append;
               qryid.Value:= FieldByName('id').AsInteger;
               qrydescricao.Value:= FieldByName('descricao').AsString;
               qry.Post;

               Next;
          end;

          DBLookupComboBox1.KeyValue:= sessao.tabela_preco_id;
      end;
   finally
       FreeAndNil(_db);
   end;
end;

function Tframe_tabelasPrecos.getID: Id;
begin
  result := DBLookupComboBox1.KeyValue;
end;

end.

