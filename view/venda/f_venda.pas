unit f_venda;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Menus, ComCtrls, DBGrids, ActnList, Grids,
  view.condicional.filtrar, view.devolucao.filtrar, uf_crediario, VTHeaderPopup,
  BGRAShape, atshapelinebgra, BGRAResizeSpeedButton, BCButton, ColorSpeedButton, jsons,
  clipbrd;

type

  { Tform_venda }

  Tform_venda = class(TForm)
    Action1: TAction;
    ac_recebimento: TAction;
    ac_devolucao: TAction;
    ac_condicional: TAction;
    ac_suprimento: TAction;
    ac_sangria: TAction;
    ac_fechaCaixa: TAction;
    ac_abreCaixa: TAction;
    ac_sair: TAction;
    ActionList1: TActionList;
    BCButton1: TBCButton;
    BCButton10: TBCButton;
    BCButton11: TBCButton;
    BCButton2: TBCButton;
    BCButton3: TBCButton;
    BCButton4: TBCButton;
    BCButton5: TBCButton;
    BCButton6: TBCButton;
    BCButton8: TBCButton;
    BCButton9: TBCButton;
    dsItens: TDataSource;
    qryItens: TBufDataset;
    gridItens: TDBGrid;
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    lblUsuario: TLabel;
    Label2: TLabel;
    lblCodigo: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ed_cliente: TLabeledEdit;
    ed_vendedor: TLabeledEdit;
    ed_cpf: TLabeledEdit;
    lblDadosEmpresa: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    pnlBase: TPanel;
    Panel11: TPanel;
    pnlBotoes: TPanel;
    pnlTitle: TPanel;
    pnlGrid: TPanel;
    pnlColCodigo: TPanel;
    pnlColQuantidade: TPanel;
    pnlColUnitario: TPanel;
    pnlColDescricao: TPanel;
    pnlColUnitario1: TPanel;
    pnlTotal: TPanel;
    PnlCadatro: TPanel;
    pnlTotalizador: TPanel;
    pnlDireito: TPanel;
    pnlGridVendas: TPanel;
    pnlVendas: TPanel;
    pnlLateral: TPanel;
    pnlCodigo: TPanel;
    pnlImagem: TPanel;
    PopupMenu1: TPopupMenu;
    qryItensdescricao: TStringField;
    qryItensproduto_id: TLongintField;
    qryItensquantidade: TFloatField;
    qryItenssub_total: TFloatField;
    qryItensvalor_unitario: TFloatField;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    SpeedButton1: TSpeedButton;
    TabControl1: TTabControl;
    procedure Action1Execute(Sender: TObject);
    procedure ac_abreCaixaExecute(Sender: TObject);
    procedure ac_condicionalExecute(Sender: TObject);
    procedure ac_devolucaoExecute(Sender: TObject);
    procedure ac_fechaCaixaExecute(Sender: TObject);
    procedure ac_recebimentoExecute(Sender: TObject);
    procedure ac_sairExecute(Sender: TObject);
    procedure ac_sangriaExecute(Sender: TObject);
    procedure ac_suprimentoExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridItensKeyPress(Sender: TObject; var Key: char);
    procedure Shape3Resize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
  private
        Procedure LimpaTela;
        Procedure GetVendasAndamento;
        Procedure ShowLayout;

        Procedure SetNovaAba;
        Procedure RegistraItem;
  public
         Procedure ShowInfProduto;
         Procedure BuscaItem;
         Procedure listaOperacoes;
         Procedure SetVenda;

  end;

var
  form_venda: Tform_venda;

implementation

{$R *.lfm}

uses classe.utils, model.conexao;

procedure Tform_venda.SpeedButton1Click(Sender: TObject);
begin
  PopupMenu1.PopUp(mouse.CursorPos.X-120, mouse.CursorPos.y-20);
end;

procedure Tform_venda.TabControl1Change(Sender: TObject);
begin
   SetVenda;
end;

procedure Tform_venda.LimpaTela;
begin
    pnlTotal.Caption:= FormatFloat(sessao.formatsubtotal,0);
    ed_cliente.Text:=  'Consumidor';
    ed_vendedor.Text:=  'Não Definido';
    ed_cpf.Text:= '';
    lblCodigo.Caption:= '';
    pnlBase.Visible:= sessao.GetCaixa <> '';

    pnlCodigo.Visible:= false;
    pnlImagem.Visible:= false;
    pnlDireito.Visible:= false;
end;

procedure Tform_venda.GetVendasAndamento;
var _db : TConexao;
begin
   LimpaTela;

   try
     _db := TConexao.Create;
     with _db.Query do
     Begin
          Close;
          Sql.Clear;
          Sql.Add('select * from vendas ');
          Sql.Add(' where lower(status) = ''rascunho'' ');
          Sql.Add(' order by data_emissao ');
          open;

          while not eof do
          Begin
               TabControl1.Tabs.Add('Venda '+FormatFloat('000000000',FieldByName('documento').AsInteger));
               Next;
          end;
          SetVenda;
     end;
   finally
       FreeAndNil(_db);
   end;
end;

procedure Tform_venda.ShowLayout;
begin
  pnlCodigo.Visible:= TabControl1.Tabs.Count > 0;
  pnlImagem.Visible:= TabControl1.Tabs.Count > 0;
  pnlDireito.Visible:= TabControl1.Tabs.Count > 0;
end;

procedure Tform_venda.SetNovaAba;
var _db : TConexao;
     _nota : TJsonObject;
     _cpf : string;
begin

  _cpf := '';

  if messagedlg('CPF na Nota ?',mtInformation,[mbyes,mbno],0) = mryes then
  Begin
      InputQuery('Cluster Sistemas','CPF Na Nota',_cpf);
  end;


    try
       _db := TConexao.Create;
       _nota := TJsonObject.Create();
       _nota['cliente_id'].AsInteger:= 1;
       _nota['vendedor_id'].AsInteger:= 0;
       _nota['data_emissao'].AsString:= getDataUTC;
       _nota['id'].AsInteger:= Sessao.GetNewDocumento;
       _nota['documento'].AsInteger:= _nota['id'].AsInteger;
       _nota['serie_id'].AsInteger:= sessao.GetSerieID(_cpf <> '' );
       _nota['prazo_id'].AsInteger:= 1;
       _nota['coi_id'].AsInteger:= 1;
       _nota['entrada_saida'].AsString:= 'S';
       _nota['status'].AsString:= 'rascunho';
       _nota['cpf'].AsString:= _cpf;
       _db.InserirDados('vendas',_nota);
       TabControl1.Tabs.Add('Venda '+FormatFloat('000000000',_nota['documento'].AsInteger));
       TabControl1.TabIndex:= TabControl1.Tabs.Count-1;
       SetVenda;
    finally
        FreeAndNil(_db);
        FreeAndNil(_nota);
    end;

end;

procedure Tform_venda.RegistraItem;
var _item : TJsonObject;
     _db : TConexao;
     _produtoID : Integer;
     _quantidade : Double;
begin
  if TabControl1.Tabs.Count = 0 then
     SetNovaAba;



  try

      _produtoID:= 1;
      _quantidade:= 1;

     _item := TJsonObject.Create();
     _db:= TConexao.Create;
     _item['venda_id'].AsString:= getNumeros(TabControl1.Tabs[TabControl1.TabIndex]);
     _item['produto_id'].AsInteger:= _produtoID;
     _item['quantidade'].AsNumber:= _quantidade;
     _item['descricao'].AsString:= 'Produto Teste';
     _item['valor_unitario'].AsNumber:= 10.52;
     _item['sub_total'].AsNumber:=  50.00;
     _db.InserirDados('venda_itens',_item);

     SetVenda;

     lblCodigo.Caption:= '';

  finally
      FreeAndNIl(_item);
      FreeAndNIl(_db);
  end;
end;

procedure Tform_venda.Shape3Resize(Sender: TObject);
begin
    gridItens.DefaultRowHeight:= trunc((Shape3.Height * 0.08));
    pnlTitle.Height:= gridItens.DefaultRowHeight;

    gridItens.Columns[0].Width:= trunc((Shape3.Width * 0.145));
    gridItens.Columns[1].Width:= trunc((Shape3.Width * 0.37));
    gridItens.Columns[2].Width:= trunc((Shape3.Width * 0.11));
    gridItens.Columns[3].Width:= trunc((Shape3.Width * 0.175));
    gridItens.Columns[4].Width:= trunc((Shape3.Width * 0.175));
    gridItens.TitleFont.Size := trunc((Shape3.Height * 0.030));


    pnlColCodigo.Width:= trunc((Shape3.Width * 0.145));
    pnlColDescricao.Width:= trunc((Shape3.Width * 0.37));
    pnlColQuantidade.Width:= trunc((Shape3.Width * 0.11));
    pnlColUnitario.Width:= trunc((Shape3.Width * 0.175));
    pnlColUnitario1.Width := trunc((Shape3.Width * 0.175));



    if  gridItens.TitleFont.Size < 12 then
      gridItens.TitleFont.Size := 12;

    pnlColCodigo.Font.Size:= gridItens.TitleFont.Size ;
    pnlColDescricao.Font.Size:= gridItens.TitleFont.Size ;
    pnlColQuantidade.Font.Size:= gridItens.TitleFont.Size ;
    pnlColUnitario.Font.Size:= gridItens.TitleFont.Size ;
    pnlColUnitario1.Font.Size := gridItens.TitleFont.Size ;
end;

procedure Tform_venda.FormResize(Sender: TObject);
begin
    pnlLateral.Width:= trunc((pnlVendas.Width * 0.35));

    pnlImagem.Height:= trunc((pnlLateral.Height * 0.80));
    pnlCodigo.Height:= pnlLateral.Height - pnlImagem.Height;

    pnlGridVendas.Height:= trunc((pnlDireito.Height * 0.80));

    pnlTotal.Width:= trunc((pnlTotalizador.Width * 0.35));
    PnlCadatro.Width:= trunc((pnlTotalizador.Width * 0.30));


    //gridItens.Columns[1].Width:= gridItens.Width -( gridItens.Columns[0].Width +
    //                                                gridItens.Columns[2].Width +
    //                                                gridItens.Columns[3].Width +
    //                                                gridItens.Columns[4].Width
    //                                               );
end;

procedure Tform_venda.FormShow(Sender: TObject);
begin
  TabControl1.Tabs.Clear;
  lblUsuario.Caption:= 'Usuario: '+ Sessao.usuarioName;
  lblDadosEmpresa.Caption:= sessao.cidade+'  '+FormatDateTime('dddd "," dd "de" mmmm "de" yyyy',Now) +'   ('+
                             sessao.n_unidade+')';
  GetVendasAndamento;
end;

procedure Tform_venda.gridItensKeyPress(Sender: TObject; var Key: char);
begin
   form_venda.SetFocus;
   qryItens.Cancel;
   key := #0;
end;

procedure Tform_venda.ac_sairExecute(Sender: TObject);
begin
    self.Close;
end;

procedure Tform_venda.ac_sangriaExecute(Sender: TObject);
begin
    sessao.Sangria;
end;

procedure Tform_venda.ac_suprimentoExecute(Sender: TObject);
begin
  //
  sessao.suprimento;
end;

procedure Tform_venda.FormCreate(Sender: TObject);
begin
  qryItens.CreateDataset;
  qryItens.Open;
end;

procedure Tform_venda.ac_abreCaixaExecute(Sender: TObject);
begin
    if pnlBase.Visible  = false then
    Begin
        sessao.AbreCaixa;
        GetVendasAndamento;
    end else
    Begin
         messagedlg('Ja Existe um caixa aberto em andamento',mtWarning,[mbok],0);
    end;
end;

procedure Tform_venda.Action1Execute(Sender: TObject);
begin
   SetNovaAba;
   lblCodigo.Caption:= '';
end;

procedure Tform_venda.ac_condicionalExecute(Sender: TObject);
begin
  CriarForm(Tfrm_CondicionalFIltrar);
end;

procedure Tform_venda.ac_devolucaoExecute(Sender: TObject);
begin
  CriarForm(Tf_devolucaoFiltrar);
end;

procedure Tform_venda.ac_fechaCaixaExecute(Sender: TObject);
begin
    if pnlBase.Visible  = false then
        messagedlg('Este Checkout não possui caixa em aberto',mtWarning,[mbok],0)
    else
    Begin
        sessao.FechaCaixa;
        GetVendasAndamento;
    end;


end;

procedure Tform_venda.ac_recebimentoExecute(Sender: TObject);
begin
  CriarForm(Tf_crediario);
end;

procedure Tform_venda.FormKeyPress(Sender: TObject; var Key: char);
begin

  if pnlBase.Visible = false then

      exit;

  if Key = '.' then
    Key := ',';

  if Key = #13 then
  Begin
      Key := #0;
      if Length(lblCodigo.Caption) > 0 then
         RegistraItem;

  end
  else if Key = #08 then
  begin
    Key := #0;
    self.SetFocus;
    lblCodigo.Caption := Copy(lblCodigo.Caption, 0, Length(lblCodigo.Caption) - 1);
  end
  else if Key = #27 then
  begin
    Key := #0;
    self.SetFocus;
    if trim(lblCodigo.Caption) <> '' then
      lblCodigo.Caption := ''
  end
  else
  Begin
    if not(Key in ['0' .. '9', Chr(8), 'A'..'Z','a'..'z', '*', ',']) then
      Key := #0
    else
    Begin
      self.SetFocus;
      lblCodigo.Caption := lblCodigo.Caption + Key;
    end;

    Key := #0;
  End;

  if TabControl1.Tabs.Count = 0  then
     pnlCodigo.Visible := trim(lblCodigo.Caption) <> '';
end;


procedure Tform_venda.ShowInfProduto;
begin

end;

procedure Tform_venda.BuscaItem;
begin

end;

procedure Tform_venda.listaOperacoes;
begin

end;

procedure Tform_venda.SetVenda;
var _db : TConexao;
begin
    if TabControl1.Tabs.Count > 0 then
    Begin
         try
             _db := TConexao.Create;
             qryItens.DisableControls;
             with _db.Query do
             Begin
                  Close;
                  Sql.Clear;
                  Sql.Add('select * from venda_itens ');
                  Sql.Add(' where venda_id = '+QuotedStr(getNumeros(TabControl1.Tabs[TabControl1.TabIndex])));
                  Open;
                  first;
                  Limpa(qryItens);

                  while not eof do
                  Begin
                     qryItens.Append;
                     qryItensdescricao.Value:=  FieldByName('descricao').AsString;
                     qryItensproduto_id.Value:= FieldByName('produto_id').AsInteger;
                     qryItensquantidade.Value:= FieldByName('quantidade').AsFloat;
                     qryItensvalor_unitario.Value:= FieldByName('valor_unitario').AsFloat;
                     qryItens.Post;
                     Next;
                  end;

                  Close;
                  Sql.Clear;
                  Sql.Add('select v.cliente_id, p.nome n_cliente, v.cpf, ');
                  Sql.Add(' vend.nome n_vendedor, v.vendedor_id ');
                  Sql.Add(' from vendas v left join pessoas p ');
                  Sql.Add('               on p.id  = v.cliente_id');
                  Sql.Add('               left join pessoas vend ');
                  Sql.Add('               on vend.id  = v.vendedor_id');
                  Sql.Add(' where v.id = '+QuotedStr(getNumeros(TabControl1.Tabs[TabControl1.TabIndex])));
                  Open;

                  ed_cliente.Text:= FormatFloat('000000',FieldByName('cliente_id').AsInteger) + ' ' + trim(FieldByName('n_cliente').AsString);
                  ed_vendedor.Text:= FormatFloat('000000',FieldByName('vendedor_id').AsInteger) + ' ' + trim(FieldByName('n_vendedor').AsString);
                  ed_cpf.Text:= trim(FieldByName('cpf').AsString);
             end;
         finally
             FreeAndnil(_db);
             qryItens.EnableControls;
         end;
    end;
    ShowLayout;
end;



end.

