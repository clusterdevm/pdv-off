unit report.sangria;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport, RLBarcode,
  RLPDFFilter, jsons, RLTypes;

type

  { Tf_sangriaReport }

  Tf_sangriaReport = class(TForm)
    bandCabecalho: TRLBand;
    bandInfoSangria: TRLBand;
    bandRodape: TRLBand;
    lblData: TRLLabel;
    lCaixaID: TRLMemo;
    lEmissao: TRLLabel;
    lEndereco: TRLMemo;
    lID: TRLLabel;
    lLABEL: TRLLabel;
    lNomeFantasia: TRLMemo;
    lObservacao: TRLMemo;
    lOperador: TRLMemo;
    lRazaoSocial: TRLMemo;
    lRelacionado: TRLMemo;
    lSistema: TRLLabel;
    lSistema1: TRLLabel;
    lTelefone: TRLMemo;
    lUnidade: TRLMemo;
    lValorSangria: TRLLabel;
    pnlData: TRLPanel;
    pnlObservacao: TRLPanel;
    pnlValor: TRLPanel;
    qrCode: TRLBarcode;
    RLLabel1: TRLLabel;
    RLLabel28: TRLLabel;
    RLLabel30: TRLLabel;
    RLPanel1: TRLPanel;
    RLPDFFilter1: TRLPDFFilter;
    RLReport1: TRLReport;
    procedure bandCabecalhoBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bandInfoSangriaBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bandRodapeBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure RLReport1DataRecord(Sender: TObject; RecNo: Integer;
      CopyNo: Integer; var Eof: Boolean; var RecordAction: TRLRecordAction);
  private
       _Objeto : TJsonObject;
  public
       Procedure GetSangriaReport(_dados:TJsonObject;lSangria : Boolean = true);
  end;

var
  f_sangriaReport: Tf_sangriaReport;

implementation

{$R *.lfm}
uses ems.utils;

{ Tf_sangriaReport }

procedure Tf_sangriaReport.bandCabecalhoBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lNomeFantasia.Lines.Text := _Objeto['empresa'].AsObject['fantasia'].AsString;
  lUnidade.Lines.Text :=  _Objeto['empresa'].AsObject['nomeresumido'].AsString;
  lRazaoSocial.Lines.Text :=  _Objeto['empresa'].AsObject['empresa'].AsString;
  lEndereco.Lines.Text :=  _Objeto['empresa'].AsObject['endereco'].AsString+','+_Objeto['empresa'].AsObject['numero'].AsString;
  lTelefone.Lines.Text := _Objeto['empresa'].AsObject['telefone'].AsString;
  lLABEL.Caption := _Objeto['label'].AsString;
end;

procedure Tf_sangriaReport.bandInfoSangriaBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  lValorSangria.Caption :=  FormatFloat(sessao.formatsubtotal,_Objeto['valor'].AsNumber);
  lObservacao.lines.Text := _Objeto['obs'].AsString;
  lCaixaID.Lines.Text := 'Caixa ID: '+_Objeto['caixa_id'].AsString;

  lOperador.lines.Text := 'Operador: '+ _Objeto['operador_id'].AsString+
                       ' ' + _Objeto['n_operador'].AsString;

  lRelacionado.Lines.Text := 'Relacionado: ' + _Objeto['pessoa_id'].AsString +
                          ' '+_Objeto['n_pessoa'].AsString;

  lEmissao.Caption :='Data:' +FormatDateTime('dd/mm/yyyy hh:mm',sessao.DateToLocal(_Objeto['datacriacao'].AsString));
  lID.Caption := 'Numero : '+_Objeto['id'].AsString   ;

  lObservacao.Lines.Text := _Objeto['obs'].AsString
end;

procedure Tf_sangriaReport.bandRodapeBeforePrint(Sender: TObject;
  var PrintIt: Boolean);
begin
  qrCode.Caption :=  FormatFloat('000000000000',_Objeto['id'].AsInteger);

  lblData.Caption:= 'Usuario: '+ _Objeto['payload'].AsObject['iss'].asstring
                    +' - Impresso em :'+ FormatDateTime('dd/mm/yyyy hh:mm', now);
end;

procedure Tf_sangriaReport.RLReport1DataRecord(Sender: TObject; RecNo: Integer;
  CopyNo: Integer; var Eof: Boolean; var RecordAction: TRLRecordAction);
begin
  Eof := (RecNo > 1);
end;

procedure Tf_sangriaReport.GetSangriaReport(_dados: TJsonObject;
  lSangria: Boolean);
begin
  _Objeto := _dados;
  RLReport1.PageBreaking := pbNone;
  RLReport1.PageSetup.PaperSize   := fpCustom ;
  RLReport1.UnlimitedHeight:= true;

  if lSangria then
     _Objeto['label'].AsString := 'S A N G R I A'
  else
     _Objeto['label'].AsString := 'S U P R I M E N T O';

  RLReport1.PreviewModal;
end;

end.

