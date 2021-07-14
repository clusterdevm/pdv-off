unit cluster_pdv.sessao;

{$mode delphi}

interface

uses
  Classes, SysUtils ,jsons, Dialogs, forms, controls, uf_fechamentoCaixa, DateUtils, clipbrd;

type

{ TSessao }

TSessao = Class
private
  fbearerems: String;
  FCaixa_Id: Integer;
  fcidade: string;
  fcnpj: string;
  fdatetimeformat: string;
  FempresaID: Integer;
  fempresalogada: integer;
  fgetID: String;
  FgradeID: String;
  fnomeFantasia: string;
  fnomeResumido: string;
  frazao: string;
  fsegundoplano: boolean;
  fsenha: String;
  ftoken: String;
  fusuario: String;
  FusuarioName: String;
  fusuario_id: integer;

      _simbolo : string;
      DecimalTotal : Integer;
      DecimalUnitario : Integer;
      DecimalQuantidade : Integer;
      TabelaArmazenamentoID : Integer;
      MoedaPadrao : Integer;
      TabelaPrecoID : Integer;

      Property caixa_id : Integer Read FCaixa_Id Write FCaixa_id;
      Function getCaixID : String;
      Function GetPDVID : Integer;
    public

      property bearerems : String read fbearerems write fbearerems;
      property usuario : String read fusuario write fusuario;
      property senha : String read fsenha write fsenha;
      property empresalogada : integer read fempresalogada write fempresalogada;
      property getID : String read fgetID write fgetID;
      property gradeID : String Read FgradeID write fgradeID ;
      property segundoplano : boolean read fsegundoplano write fsegundoplano;
      property token : String read ftoken write ftoken;
      property usuario_id : integer read fusuario_id write fusuario_id;


      Procedure InicializaConfigPadrao;

      function tabela_preco_id : integer;
      function estoque_id : integer ;

      Function GetUtcOFF : integer;

      function datetimeformat : string;
      function formatsubtotal(_loadSimbolo:boolean = true ): string;
      function formatunitario(_loadSimbolo:boolean = true): string;
      function formatquantidade : string;
      function formatAliquota(_loadSimbolo : boolean = false):string;
      function TotalCasasDecimal : Integer;
      function TotalCasasQuantidade : Integer;
      function TotalCasasUnitario : Integer;

      function Getsimbolo : string;

      property razao : string read frazao write frazao;
      property cnpj : string read fcnpj write fcnpj;
      property nomeFantasia : string read fnomeFantasia write fnomeFantasia;
      property n_unidade : string read fnomeResumido write fnomeResumido;
      property cidade : string read fcidade write fcidade;

      Property usuarioName : String Read FusuarioName Write FusuarioName;

      Function DateToLocal(value:string):TDateTime;overload;
      Function DateToLocal(value:TDateTime):TDateTime;overload;

      Function GetSerieID(_Cpf : Boolean = false ; Orcamento : Boolean = false): integer;

      Function GetNewDocumento : Integer;


      Function PDV_ConfBalanca : String;
      Function GetCaixa : string;

      Function CaixaAberto : Boolean;

      Procedure AbreCaixa ;
      Procedure FechaCaixa;
      Procedure Suprimento;
      Procedure Sangria;

      Function GetmoedaPadrao : integer;

      Function DataServidor : TDate;

      Function schema : string;

      Constructor create;
end;

implementation

uses ems.conexao, ems.utils, uf_saidaCaixa, form.principal;

function TSessao.getCaixID: String;
var _db : TConexao;
begin
   try
        _db := TConexao.Create;
        Result := '0';

        with _db.qrySelect do
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
     with _db.qrySelect do
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

procedure TSessao.InicializaConfigPadrao;
begin
  _simbolo := '';
  DecimalQuantidade:= -1;
  DecimalTotal:= -1;
  DecimalUnitario:= -1;
  TabelaArmazenamentoID := -1;
  TabelaPrecoID:= -1;
  MoedaPadrao := -1;
end;

function TSessao.tabela_preco_id: integer;
var _db : TConexao;
   i : integer;
begin

  if TabelaPrecoID = -1 then
  Begin
      try
          _db := TConexao.Create;
          with _db.qrySelect do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('select pv.default_tabela_preco_id from empresa e inner join parametros_venda pv ');
              Sql.Add('           on pv.id = e.parametros_venda_id');
              open;

              TabelaPrecoID := FieldByName('default_tabela_preco_id').AsInteger;
          end;
      finally
          FreeAndNil(_db);
      end;
  end;

  Result := TabelaPrecoID;
end;

function TSessao.estoque_id: integer;
var _db : TConexao;
begin

  if TabelaArmazenamentoID = -1 then
  Begin
      try
          _db := TConexao.Create;
          with _db.qrySelect do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('select pv.default_armazenamento_id from empresa e inner join parametros_venda pv ');
              Sql.Add('           on pv.id = e.parametros_venda_id');
              open;

              TabelaArmazenamentoID := FieldByName('default_armazenamento_id').AsInteger;
          end;
      finally
          FreeAndNil(_db);
      end;
  end;

  Result := TabelaArmazenamentoID;
end;

function TSessao.GetUtcOFF: integer;
begin
   Result := -3;
end;

function TSessao.datetimeformat: string;
begin
     Result :=  'dd/mm/yyyy hh:mm';
end;

function TSessao.formatsubtotal(_loadSimbolo: boolean): string;
var _db : TConexao;
   i : integer;
begin

  if DecimalTotal = -1 then
  Begin
      try
          _db := TConexao.Create;
          with _db.qrySelect do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('select pv.casadecimal_totalizador from empresa e inner join parametros_venda pv ');
              Sql.Add('           on pv.id = e.parametros_venda_id');
              open;

              DecimalTotal := FieldByName('casadecimal_totalizador').AsInteger;
          end;
      finally
          FreeAndNil(_db);
      end;
  end;


  Result := '';
  for i := 1 to DecimalTotal do
     Result := Result + '0';

  result := '#0.'+Result+',';

  if _loadSimbolo then
     result := Getsimbolo+' '+Result;

end;

function TSessao.formatunitario(_loadSimbolo: boolean): string;
var _db : TConexao;
   i : integer;
begin

  if DecimalUnitario = -1 then
  Begin
      try
          _db := TConexao.Create;
          with _db.qrySelect do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('select pv.casadecimal_unitario from empresa e inner join parametros_venda pv ');
              Sql.Add('           on pv.id = e.parametros_venda_id');
              open;

              DecimalUnitario := FieldByName('casadecimal_unitario').AsInteger;
          end;
      finally
          FreeAndNil(_db);
      end;
  end;

  Result := '';
  for i := 1 to DecimalUnitario do
     Result := Result + '0';

  result := '#0.'+Result+',';

  if _loadSimbolo then
     result := Getsimbolo+' '+Result;

end;

function TSessao.formatquantidade: string;
var _db : TConexao;
   i : integer;
begin

  if DecimalQuantidade = -1 then
  Begin
      try
          _db := TConexao.Create;
          with _db.qrySelect do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('select pv.casadecimal_quantidade from empresa e inner join parametros_venda pv ');
              Sql.Add('           on pv.id = e.parametros_venda_id');
              open;

              DecimalQuantidade := FieldByName('casadecimal_quantidade').AsInteger;
          end;
      finally
          FreeAndNil(_db);
      end;
  end;

  Result := '';
  for i := 1 to DecimalQuantidade do
     Result := Result + '0';

  result := '#0.'+Result+',';

end;

function TSessao.formatAliquota(_loadSimbolo: boolean): string;
begin
  if _loadSimbolo then
      Result :=  '% #0.00,'
  else
      Result := '#0.00,'
end;

function TSessao.TotalCasasDecimal: Integer;
begin
  formatsubtotal;
  result := DecimalTotal;
end;

function TSessao.TotalCasasQuantidade: Integer;
begin
  formatquantidade;
  result := DecimalQuantidade;
end;

function TSessao.TotalCasasUnitario: Integer;
begin
  formatunitario();
  result := DecimalUnitario;
end;

function TSessao.Getsimbolo: string;
var _db : TConexao;
begin

  if _simbolo <> '' then
  Begin
     Result := _simbolo;
     exit;
  end;

  try
      _db := TConexao.Create;
      with _db.qrySelect do
      Begin
          Close;
          Sql.Clear;
          Sql.Add('select m.simbolo from empresa e inner join parametros_geral pg ');
          Sql.Add('           on pg.id = e.parametros_geral_id');
          Sql.Add('           inner join moeda m');
          Sql.Add('           on pg.moeda_padrao_id = m.id');
          open;

          result := trim(FieldByName('simbolo').AsString);
      end;

  finally
      FreeAndNil(_db);
  end;
end;

function TSessao.DateToLocal(value: string): TDateTime;
begin
  result := DateToLocal(getDataBanco(value));
end;

function TSessao.DateToLocal(value: TDateTime): TDateTime;
begin
   Result := UniversalTimeToLocal(value,GetUtcOFF);;
end;

function TSessao.GetSerieID(_Cpf : Boolean ; Orcamento : Boolean = false): integer;
var _db : TConexao;
begin
  try
      _db := TConexao.Create;
      with _db.qrySelect do
      Begin
          Close;
          Sql.Clear;
          Sql.Add('select sf.id from modelo_documento md ');
          Sql.Add('  inner join serie_fiscal sf ');
          Sql.Add('  on sf.modelo_documento_id = md.id ');

          if _cpf then
            Sql.Add(' and md.modelo = 65 ')
          else
          Begin
             Sql.Add('  inner join ems_pdv ep ');
             Sql.Add('  on ep.modelo_default = md.modelo ');

             if orcamento then
               Sql.Add(' and  md.abreviacao IN (''ORC'',''NFC'',''NFE'') ')
             else
               Sql.Add(' and  md.abreviacao IN (''DAV'',''NFC'',''NFE'') ')
          end;

          Open;

          if IsEmpty then
          Begin
             messagedlg('Modelo De Documento Default não definido',mtError,[mbok],0);
             abort;
          end else
             result := FieldByName('id').AsInteger;
      end;
  finally
      FreeAndNil(_db);
  end;
end;

function TSessao.GetNewDocumento: Integer;
var _db : TConexao;
begin
   try
       _db := TConexao.Create;
       with _db.qryPost do
       Begin
            Close;
            Sql.Clear;
            Sql.Add('update serie_fiscal set documento = documento + 1');
            Sql.Add(' where id = '+QuotedStr(IntToStr(GetSerieID())));
            ExecSQL;

            Close;
            Sql.Clear;
            Sql.Add('select documento from serie_fiscal');
            Sql.Add(' where id = '+QuotedStr(IntToStr(GetSerieID)));
            open;

            Result := FieldByName('documento').AsInteger;
       end;
   finally
       FreeAndNIl(_db);
   end;
end;


function TSessao.PDV_ConfBalanca: String;
begin
   Result := '';
end;

function TSessao.GetCaixa: string;
var _db : TConexao;
begin
  try
      _db := TConexao.Create;
      result := '';

      With _db.qrySelect do
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

function TSessao.CaixaAberto: Boolean;
begin
    result := trim(GetCaixa) <> '';

    if not result then
       Messagedlg('Não possui caixa Aberto !!!!' , mtError,[mbok],0);
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
  CriarForm(Tf_fechamentoCaixa);
end;

procedure TSessao.Suprimento;
begin
    f_saidaCaixa := Tf_saidaCaixa.Create(nil);
    f_saidaCaixa._endpoint:= 'suprimento';
    f_saidaCaixa._caixaID:= getCaixID;
    f_saidaCaixa.Caption:= 'Suprimento de Caixa';
    f_saidaCaixa.ShowModal;
    f_saidaCaixa.Release;
    f_saidaCaixa := nil;
end;

procedure TSessao.Sangria;
begin
  f_saidaCaixa := Tf_saidaCaixa.Create(nil);
  f_saidaCaixa._endpoint:= 'sangria';
  f_saidaCaixa._caixaID:= getCaixID;
  f_saidaCaixa.Caption:= 'Sangria de Caixa';
  f_saidaCaixa.ShowModal;
  f_saidaCaixa.Release;
  f_saidaCaixa := nil;
end;

function TSessao.GetmoedaPadrao: integer;
var _db : TConexao;
begin

  if MoedaPadrao = -1 then
  Begin
      try
          _db := TConexao.Create;
          with _db.qrySelect do
          Begin
              Close;
              Sql.Clear;
              Sql.Add('select pg.moeda_padrao_id from empresa e inner join parametros_geral pg ');
              Sql.Add('           on pg.id = e.parametros_geral_id');
              open;

              MoedaPadrao := FieldByName('moeda_padrao_id').AsInteger;
          end;
      finally
          FreeAndNil(_db);
      end;
  end;

  Result := MoedaPadrao;
end;

function TSessao.DataServidor: TDate;
begin
  Result := date;
end;

function TSessao.schema: string;
begin
  // Compatibilidade
end;


constructor TSessao.create;
begin
  InicializaConfigPadrao;
end;

end.

