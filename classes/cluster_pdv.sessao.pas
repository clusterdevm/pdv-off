unit cluster_pdv.sessao;

{$mode delphi}

interface

uses
  Classes, SysUtils;

type

{ TSessao }

TSessao = Class
private
  fbearerems: String;
  fcnpj: string;
  fdatetimeformat: string;
  fempresalogada: integer;
  festoque_id: integer;
  fformatsubtotal: string;
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
      property datetimeformat : string read fdatetimeformat write fdatetimeformat;
      property formatsubtotal : string read fformatsubtotal write fformatsubtotal;

      property razao : string read frazao write frazao;
      property cnpj : string read fcnpj write fcnpj;
      property nomeFantasia : string read fnomeFantasia write fnomeFantasia;
      property nomeResumido : string read fnomeResumido write fnomeResumido;

      Property usuarioName : String Read FusuarioName Write FusuarioName;

      Constructor create;
end;

implementation

{ TSessao }

constructor TSessao.create;
begin
  self.datetimeformat := 'dd/mm/yyyy hh:mm';

  self.formatsubtotal := 'R$ #0.00,';
end;

end.

