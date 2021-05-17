unit model.pessoa;

{$mode delphi}

interface

uses
  Classes, SysUtils, model.conexao, classe.utils, Dialogs;

type

  { TPessoa }

  TPessoa  = Class
    private
      fativo: boolean;
      fcliente: boolean;
      fcolaborador: boolean;
      fdocumento: string;
      ffantasia: string;
      ffornecedor: boolean;
      frazao: string;
      ftelefone: string;
    public
       property fantasia : string read ffantasia write ffantasia;
       property telefone : string read ftelefone write ftelefone;
       property razao : string read frazao write frazao;
       property documento : string read fdocumento write fdocumento;
       property ativo : boolean read fativo write fativo;
       property cliente : boolean read fcliente write fcliente;
       property colaborador : boolean read fcolaborador write fcolaborador;
       property fornecedor : boolean read ffornecedor write ffornecedor;
       Procedure Listar(_db:TConexao);

       function get(value:string):boolean;

       constructor create;
  end;

implementation

{ TPessoa }

procedure TPessoa.Listar(_db: TConexao);
begin
    with _db.Query  do
    Begin
        Close;
        Sql.Clear;
        Sql.Add('select p.id, p.nome , p.fantasia , p.cpf_cnpj ');
        Sql.Add(' from pessoas p');
        Sql.Add(' where 1  = 1 ');

        if self.fantasia <> '' then
           Sql.Add(' and p.fantasia like '+QuotedStr('%'+SubsString(self.fantasia,' ','%')+'%'));

        if self.razao <> '' then
           Sql.Add(' and p.nome like '+QuotedStr('%'+SubsString(self.razao,' ','%')+'%'));

        if self.documento <> '' then
           Sql.Add(' and p.cpf_cnpj like '+QuotedStr('%'+SubsString(self.documento,' ','%')+'%'));

        if self.ativo then
            Sql.Add(' and p.ativo ='+QuotedStr('true'))
        else
            Sql.Add(' and p.ativo ='+QuotedStr('false'));

        Sql.Add(' order by p.nome');
        open;

    end;
end;

function TPessoa.get(value: string): boolean;
var _db : TConexao;
begin
   try
     _db := TConexao.Create;
     Result := false;
     with _db.query do
     Begin
         Close;
         Sql.Clear;
         Sql.Add('select nome from pessoas where id = '+QuotedStr(value));
         open;
         if IsEmpty then
         Begin
              Showmessage('Codigo invalido');
         end else
         Begin
             result := true;
             self.razao := fieldbyName('nome').AsString;
         end;
     end;
   finally
     FreeAndNil(_db);
   end;
end;

constructor TPessoa.create;
begin
  self.ativo := true;
end;

end.

