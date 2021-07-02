unit model.pessoa;

{$mode delphi}

interface

uses
  Classes, SysUtils, ems.conexao, ems.utils, Dialogs;

type

  { TPessoa }

  TPessoa  = Class
    private
      fativo: boolean;
      fdocumento: string;
      ffantasia: string;
      FOnlyColaborador: boolean;
      frazao: string;
      ftelefone: string;
    public
       property fantasia : string read ffantasia write ffantasia;
       property telefone : string read ftelefone write ftelefone;
       property razao : string read frazao write frazao;
       property documento : string read fdocumento write fdocumento;
       property ativo : boolean read fativo write fativo;
       Property onlyColaborador : boolean read FOnlyColaborador write fOnlyColaborador;
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

        if self.onlyColaborador then
           Sql.Add(' and p.colaborador = '+QuotedStr('true'));

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
         Sql.Add('select nome, ativo from pessoas where id = '+QuotedStr(value));
         Sql.add(' and trim(nome) <> '''' ');
         open;
         if IsEmpty then
         Begin
              messagedlg('Registro invalido',mtError,[mbok],0);
         end else
         Begin
             if lowercase(FieldByName('ativo').AsString)='false' then
                messagedlg('Cadastro esta Inativado',mtError,[mbok],0)
             else
             Begin
                 result := true;
                 self.razao := fieldbyName('nome').AsString;
             end;
         end;
     end;
   finally
     FreeAndNil(_db);
   end;
end;

constructor TPessoa.create;
begin
  self.ativo := true;
  self.onlyColaborador:= false;
end;

end.

