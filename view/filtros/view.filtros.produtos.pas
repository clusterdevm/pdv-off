unit view.filtros.produtos;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  DBGrids, ActnList, ACBrEnterTab, ems.conexao, ems.utils, DB, BufDataset,
  clipbrd, LCLType;

type

  { Tf_produtosPesquisa }

  Tf_produtosPesquisa = class(TForm)
    ac_fechar: TAction;
    ac_buscar: TAction;
    ActionList1: TActionList;
    qItens: TBufDataset;
    ds: TDataSource;
    gridProdutos: TDBGrid;
    edt_descricao: TLabeledEdit;
    edt_marca: TLabeledEdit;
    edt_referencia: TLabeledEdit;
    edt_GTIN: TLabeledEdit;
    Panel1: TPanel;
    qItensdescricao: TStringField;
    qItensgrade_id: TLongintField;
    qItensid: TLongintField;
    qItensn_marca: TStringField;
    qItenssaldo: TFloatField;
    qItensun_medida: TStringField;
    qItensvalor: TFloatField;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure ac_buscarExecute(Sender: TObject);
    procedure ac_fecharExecute(Sender: TObject);
    procedure edt_descricaoChange(Sender: TObject);
    procedure edt_descricaoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edt_GTINKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure edt_marcaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edt_referenciaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridProdutosDblClick(Sender: TObject);
    procedure gridProdutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
     _db : TConexao;
     a , b : Integer;
    Procedure Pesquisa;
  public

  end;

var
  f_produtosPesquisa: Tf_produtosPesquisa;

implementation

{$R *.lfm}


Procedure Tf_produtosPesquisa.Pesquisa;
begin
try
     qItens.DisableControls;
     if sessao.estoque_id =0 then
        FinalizaProcesso('Tabela de Armazenamento não informado(armazenamento_id)');

     if sessao.tabela_preco_id = 0 then
        FinalizaProcesso('Tabela de Preço padrão não informado(tabela_preco_id)');

     with _db.qrySelect do
     Begin
        Close;
        Sql.Clear;
        Sql.Add('select p.id, ');
        Sql.Add(' trim(case when pgri_1.descricao <> '''' and pgri_2.descricao <> '''' then ');
        Sql.Add('          p.descricao||'' ''||grd_1.descricao_resumida||'' ''||');
        Sql.Add('                   pgri_1.descricao|| '' ''||grd_2.descricao_resumida||'' ''||pgri_2.descricao');
        Sql.Add('      when pgri_1.descricao <> ''''  then');
        Sql.Add('            p.descricao||'' ''||pgri_1.descricao');
        Sql.Add('            else');
        Sql.Add('            p.descricao end) as descricao,');

        Sql.Add('       p.gtin, p.referencia, p.ativo, p.ncm_id ncm,');
        Sql.Add('       p.tipo_produto,');
        Sql.Add('       sg.descricao n_subgrupo,');
        Sql.Add('       pg.descricao n_grupo, trim(pm.descricao) n_marca,');
        Sql.Add('       pu.un n_unidade, pc.descricao n_colecao,');

        Sql.Add('       case when pgri_1.descricao <> '''' then peg.saldo_gerencial');
        Sql.Add('	        else pes.saldo_gerencial');
        Sql.Add('	   end as saldo,');

        Sql.Add('       pa.descricao n_estoque,');
        Sql.Add('       ppv.valor, tp.descricao n_tabela,');
        Sql.Add('       ncm.descricao n_ncm,');
        Sql.Add('       pgrd.id gradeamento_id');

        Sql.Add('from produtos p inner join produtos_empresa pe');
        Sql.Add('                on pe.produto_id = p.id');
        Sql.Add('                inner join produtos_estoque pes');
        Sql.Add('                on pes.produto_empresa_id = pe.id');
        Sql.Add('                and pes.produto_armazenamento_id = '+QuotedStr(IntToStr(Sessao.estoque_id)));

        Sql.Add('                inner join produtos_armazenamento pa');
        Sql.Add('                on pa.id  = pes.produto_armazenamento_id');
        Sql.Add('                and pa.empresa_id = pe.empresa_id');

        Sql.Add('                left join produtos_preco_venda ppv');
        Sql.Add('                on ppv.produto_empresa_id = pe.id');
        Sql.Add('                and ppv.tabela_id = '+QuotedStr(IntToStr(Sessao.tabela_preco_id)));

        Sql.Add('                left join tabela_preco tp');
        Sql.Add('                on tp.id = ppv.tabela_id');
        Sql.Add('                left join produtos_subgrupos sg');
        Sql.Add('                on sg.id = p.subgrupo_id');
        Sql.Add('                left join produtos_grupos pg');
        Sql.Add('                on pg.id = sg.grupo_id');
        Sql.Add('                left join produtos_marcas pm');
        Sql.Add('                on pm.id = p.marca_id');
        Sql.Add('                left join produtos_unidades pu');
        Sql.Add('                on pu.id = p.unidade_id');
        Sql.Add('                left join produtos_colecoes pc');
        Sql.Add('                on pc.id = p.colecao_id');
        Sql.Add('                left join lista_ncm ncm');
        Sql.Add('                on ncm.ncm = p.ncm_id');
        Sql.Add('                left join produtos_gradeamento pgrd');
        Sql.Add('                on pgrd.produto_id  = p.id');
        Sql.Add('		 left join produtos_estoque_grade peg');
        Sql.Add('		 on peg.produto_gradeamento_id = pgrd.id');
        Sql.Add('		 and peg.produto_estoque_id = pes.id');
        Sql.Add('                left join produtos_grades_itens pgri_1');
        Sql.Add('                on pgri_1.id = pgrd.grade_item_id');
        Sql.Add('                left join produtos_grades grd_1');
        Sql.Add('                on grd_1.id = pgri_1.grade_id');
        Sql.Add('                left join produtos_grades_itens pgri_2');
        Sql.Add('                on pgri_2.id = pgrd.grade_item2_id');
        Sql.Add('                left join produtos_grades grd_2');
        Sql.Add('                on grd_2.id = pgri_2.grade_id');
        Sql.Add('where');
        Sql.Add(' p.ativo = ''true''');

        if trim(edt_descricao.Text) <> '' then
          Sql.Add(' and p.descricao like '+QuotedStr('%'+SubsString(edt_descricao.Text,' ','%')+'%'));

        if trim(edt_GTIN.Text) <> '' then
          Sql.Add(' and p.gtin like '+QuotedStr('%'+SubsString(edt_GTIN.Text,' ','%'))+'%');

        if trim(edt_marca.Text) <> '' then
          Sql.Add(' and pm.descricao like '+QuotedStr('%'+SubsString(edt_marca.Text,' ','%'))+'%');

        if trim(edt_referencia.Text) <> '' then
          Sql.Add(' and p.referencia like '+QuotedStr('%'+SubsString(edt_referencia.Text,' ','%'))+'%');

        Sql.Add('order by p.descricao');
        Sql.Add(' limit 1000');
        Sql.Add('COLLATE NOCASE');
        gridProdutos.Columns[3].DisplayFormat:= sessao.formatquantidade;
        gridProdutos.Columns[5].DisplayFormat:= sessao.formatunitario();

        qItens.Close;
        qItens.Open;
        open;
        first;

        while not eof do
        begin
            qItens.Append;
            qItensid.Value := _db.qrySelect.FieldByName('id').AsInteger;
            qItensdescricao.Value:= _db.qrySelect.FieldByName('descricao').AsString;
            qItensgrade_id.Value:= _db.qrySelect.FieldByName('gradeamento_id').AsInteger;
            qItensn_marca.Value:= _db.qrySelect.FieldByName('n_marca').AsString;
            qItenssaldo.Value:= _db.qrySelect.FieldByName('saldo').AsFloat;
            qItensun_medida.Value:= _db.qrySelect.FieldByName('n_unidade').AsString;
            qItensvalor.Value:= _db.qrySelect.FieldByName('valor').AsFloat;
            qItens.Post;
            Next;
        end;
        StatusBar1.Panels[0].Text:='Registro(s) Encontrado(s): '+IntTostr(RecordCount);
     end;
finally
   qItens.First;
   qItens.EnableControls;
end;
end;

{ Tf_produtosPesquisa }

procedure Tf_produtosPesquisa.FormCreate(Sender: TObject);
begin
   gridProdutos.Columns[3].DisplayFormat:= sessao.formatquantidade;
   gridProdutos.Columns[5].DisplayFormat:= sessao.formatunitario();
  _db := TConexao.Create;
  qItens.CreateDataset;
  qItens.Open;
end;

procedure Tf_produtosPesquisa.FormShow(Sender: TObject);
begin
    edt_descricao.SetFocus;
    timer1.Enabled:= true;
end;

procedure Tf_produtosPesquisa.gridProdutosDblClick(Sender: TObject);
begin
     if (ds.DataSet.RecordCount > 0) then
     Begin
           sessao.getID := ds.DataSet.FieldByName('id').AsString;
           Sessao.gradeID:= ds.DataSet.FieldByName('grade_id').AsString;
           self.Close;
     end;
end;

procedure Tf_produtosPesquisa.gridProdutosKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
     if key = VK_UP then
     Begin
         KEY := 0;
         if (ds.DataSet.RecNo = 1) or (ds.DataSet.IsEmpty) then
            edt_descricao.SetFocus
          else
            ds.DataSet.Prior;
     end;

     if key = VK_RETURN then
     Begin
         key := 0;
         gridProdutosDblClick(self);
     end;
end;

procedure Tf_produtosPesquisa.Timer1Timer(Sender: TObject);
begin
     if a = b then
     Begin
         Timer1.Enabled:= false;
         ac_buscarExecute(self);
     end else
        b:= Length(edt_descricao.Text)+
            Length(edt_referencia.Text)+
            Length(edt_marca.Text)+
            Length(edt_GTIN.Text)
            ;
end;

procedure Tf_produtosPesquisa.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  FreeAndNil(_db);
end;

procedure Tf_produtosPesquisa.ac_buscarExecute(Sender: TObject);
begin
  Pesquisa;
end;

procedure Tf_produtosPesquisa.ac_fecharExecute(Sender: TObject);
begin
    self.Close;
end;

procedure Tf_produtosPesquisa.edt_descricaoChange(Sender: TObject);
begin
    a := Length(edt_descricao.Text)+
            Length(edt_referencia.Text)+
            Length(edt_marca.Text)+
            Length(edt_GTIN.Text)
            ;

    Timer1.Enabled:=true;
end;

procedure Tf_produtosPesquisa.edt_descricaoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
     IF key = VK_DOWN THEN
     bEGIN
        KEY := 0;
        gridProdutos.SetFocus
     end
     else
     if key = VK_RIGHT then
     bEGIN
        KEY := 0;
        edt_marca.SetFocus;
     end else
     if key = VK_RETURN then
     bEGIN
        KEY := 0;
        gridProdutos.SetFocus;
     end;
end;

procedure Tf_produtosPesquisa.edt_GTINKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     IF key = VK_DOWN THEN
     bEGIN
        KEY := 0;
        gridProdutos.SetFocus
     end
     else
     if key = VK_LEFT then
     bEGIN
        KEY := 0;
        edt_referencia.SetFocus;
     end;
end;

procedure Tf_produtosPesquisa.edt_marcaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     IF key = VK_DOWN THEN
     bEGIN
        KEY := 0;
        gridProdutos.SetFocus
     end
     else
     if key = VK_LEFT then
     bEGIN
        KEY := 0;
        edt_descricao.SetFocus;
     end
     else
     if key = VK_RIGHT then
     bEGIN
        KEY := 0;
        edt_referencia.SetFocus;
     end;
end;

procedure Tf_produtosPesquisa.edt_referenciaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
     IF key = VK_DOWN THEN
     bEGIN
        KEY := 0;
        gridProdutos.SetFocus
     end
     else
     if key = VK_RIGHT then
     bEGIN
        KEY := 0;
        edt_GTIN.SetFocus;
     end
     else
     if key = VK_LEFT then
     bEGIN
        KEY := 0;
        edt_marca.SetFocus;
     end;
end;


end.

