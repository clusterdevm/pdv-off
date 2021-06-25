unit cluster_pdv.sessao;

{$mode delphi}

interface

uses
  Classes, SysUtils ,jsons, Dialogs, forms, controls, uf_fechamentoCaixa;

type

{ TSessao }

TSessao = Class
private
  fbearerems: String;
  FCaixa_Id: Integer;
  fcidade: string;
  fcnpj: string;
  fdatetimeformat: string;
  fempresalogada: integer;
  festoque_id: integer;
  fformatAliquota: string;
  fformatquantidade: string;
  fformatsubtotal: string;
  fformatunitario: string;
  fgetID: String;
  fnomeFantasia: string;
  fnomeResumido: string;
  frazao: string;
  fsegundoplano: boolean;
  fsenha: String;
  ftabela_preco_id: integer;
  ftoken: String;
  fusuario: String;
  FusuarioName: String;
  fusuario_id: integer;
      Property caixa_id : Integer Read FCaixa_Id Write FCaixa_id;
      Function getCaixID : String;
      Function GetPDVID : Integer;
    public
      property bearerems : String read fbearerems write fbearerems;
      property usuario : String read fusuario write fusuario;
      property senha : String read fsenha write fsenha;
      property empresalogada : integer read fempresalogada write fempresalogada;
      property getID : String read fgetID write fgetID;
      property segundoplano : boolean read fsegundoplano write fsegundoplano;
      property token : String read ftoken write ftoken;
      property usuario_id : integer read fusuario_id write fusuario_id;
      property tabela_preco_id : integer read ftabela_preco_id write ftabela_preco_id;
      property estoque_id : integer read festoque_id write festoque_id;



      function datetimeformat : string;
      function formatsubtotal(_simbolo:boolean = true ): string;
      function formatunitario(_simbolo:boolean = true): string;
      function formatquantidade : string;
      function formatAliquota(_simbolo : boolean = false):string;

      property razao : string read frazao write frazao;
      property cnpj : string read fcnpj write fcnpj;
      property nomeFantasia : string read fnomeFantasia write fnomeFantasia;
      property n_unidade : string read fnomeResumido write fnomeResumido;
      property cidade : string read fcidade write fcidade;

      Property usuarioName : String Read FusuarioName Write FusuarioName;



      Function GetCaixa : string;
      Procedure AbreCaixa ;
      Procedure FechaCaixa;
      Procedure Suprimento;
      Procedure Sangria;
      Procedure ShowForm(TFormulario: TComponentClass; var Formulario);

      Constructor create;
end;

implementation

uses model.conexao, classe.utils, uf_saidaCaixa, form.principal;

function TSessao.getCaixID: String;
var _db : TConexao;
begin
   try
        _db := TConexao.Create;
        Result := '0';

        with _db.Query do
        Begin
            Close;
            Sql.Clear;
            Sql.Add('select * from financeiro_caixa ');
            Sql.Add(' where operador_id = '+QuotedStr(IntToStr(sessao.usuario_id)));
            Sql.Add(' and trim(status) <> ''F'' ');
            Open;
            Result := IntToStr(FieldByName('id').AsInteger);
        end;
   finally
       FreeAndNIl(_db);
   end;
end;

function TSessao.GetPDVID: Integer;
var _db :TConexao;
begin
  try
     _db := TConexao.Create;
     with _db.Query do
     Begin
         Close;
         Sql.Add('select id from ems_pdv ');
         open;

         result := FieldByName('id').AsInteger;
     end;
  finally
      FreeAndNil(_db);
  end;
end;

function TSessao.datetimeformat: string;
begin
     Result :=  'dd/mm/yyyy hh:mm';
end;

function TSessao.formatsubtotal(_simbolo: boolean): string;
begin
   Result := 'R$ #0.00,';
end;

function TSessao.formatunitario(_simbolo: boolean): string;
begin
  Result :=  'R$ #0.0000,';
end;

function TSessao.formatquantidade: string;
begin
  Result :=  '#0.,';
end;

function TSessao.formatAliquota(_simbolo: boolean): string;
begin
  if _simbolo then
      Result := self.formatAliquota := '% #0.00,'
  else
      Result := self.formatAliquota := '#0.00,'
end;

function TSessao.GetCaixa: string;
var _db : TConexao;
begin
  try
      _db := TConexao.Create;
      result := '';

      With _db.Query do
      Begin
         Close;
         Sql.Clear;
         Sql.Add('select * from financeiro_caixa ');
         Sql.Add(' where operador_id = '+QuotedStr(IntToStr(sessao.usuario_id)));
         Sql.Add(' and trim(status) <> ''F'' ');
         Open;

         if not IsEmpty then
            Result := FieldByName('uuid').AsString;
      end;
  finally
    FreeAndNil(_db);
  end;
end;

procedure TSessao.AbreCaixa;
var aux : string;
  _db : TConexao;
  _objeto : TjsonObject;

begin
   if not inputQuery('Cluster Sistemas','Informe Saldo Abertura',aux) then
       exit;

   try
        _db := TConexao.Create;
        _objeto := TJsonObject.Create();
        _objeto['saldo_abertura'].AsNumber:= StrToFloatDef(aux,0);
        _objeto['data_abertura'].AsString:= getDataUTC;
        _objeto['operador_id'].AsInteger:= self.usuario_id;
        _objeto['pdv_id'].AsInteger:= GetPDVID;
        _objeto['uuid'].AsString:= GetUUID;
        _objeto['sinc_pendente'].AsString:= 'S';
        _objeto['empresa_id'].AsInteger:= sessao.empresalogada;
        _objeto['status'].AsString:= 'A';

        _db.InserirDados('financeiro_caixa',_objeto);

   finally
     FreeAndNil(_db);
     FreeAndNil(_objeto);
   end;
end;

procedure TSessao.FechaCaixa;
begin
  sessao.ShowForm(Tf_fechamentoCaixa, f_fechamentoCaixa);
end;

procedure TSessao.Suprimento;
begin
    f_saidaCaixa := Tf_saidaCaixa.Create(frmPrincipal);
    f_saidaCaixa._endpoint:= 'suprimento';
    f_saidaCaixa._caixaID:= getCaixID;
    f_saidaCaixa.Caption:= 'Suprimento de Caixa';
    f_saidaCaixa.ShowModal;
    f_saidaCaixa.Release;
    f_saidaCaixa := nil;
end;

procedure TSessao.Sangria;
begin
  f_saidaCaixa := Tf_saidaCaixa.Create(frmPrincipal);
  f_saidaCaixa._endpoint:= 'sangria';
  f_saidaCaixa._caixaID:= getCaixID;
  f_saidaCaixa.Caption:= 'Sangria de Caixa';
  f_saidaCaixa.ShowModal;
  f_saidaCaixa.Release;
  f_saidaCaixa := nil;
end;

procedure TSessao.ShowForm(TFormulario: TComponentClass; var Formulario);
begin
  Application.CreateForm(TFormulario, Formulario);
  with TForm(Formulario) do
  Begin
      BorderStyle := bsSizeable;
      BorderIcons:= BorderIcons - [biMinimize];
      ShowModal;
      release
  End;
end;

constructor TSessao.create;
begin

end;

end.

