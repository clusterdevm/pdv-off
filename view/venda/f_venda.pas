unit f_venda;

{$mode delphi}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Menus, ComCtrls, DBGrids, ActnList, Grids,
  view.condicional.filtrar, view.devolucao.filtrar, uf_crediario,
  view.filtros.cliente, view.filtros.produtos, uf_venda.fechamento,
  VTHeaderPopup, BGRAShape, atshapelinebgra, BGRAResizeSpeedButton, BCButton,
  ColorSpeedButton, jsons, clipbrd, LCLtype, LCLProc;

type

  { Tform_venda }

  Tform_venda = class(TForm)
    Action1: TAction;
    ac_alteraPreco: TAction;
    ac_filtroProdutos: TAction;
    ac_fechavenda: TAction;
    ac_remover: TAction;
    ac_alterarCPF: TAction;
    ac_alterarVendedor: TAction;
    ac_alterarCliente: TAction;
    ac_cancelamento: TAction;
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
    lblPecas: TLabel;
    MainMenu1: TMainMenu;
    MainMenu2: TMainMenu;
    MenuItem8: TMenuItem;
    Panel1: TPanel;
    PopupMenu2: TPopupMenu;
    qryItens: TBufDataset;
    gridItens: TDBGrid;
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    lblUsuario: TLabel;
    Label2: TLabel;
    lblCodigo: TLabel;
    lblSubTotal: TLabel;
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
    qryItensid: TLongintField;
    qryItensproduto_id: TLongintField;
    qryItenspromocional: TBooleanField;
    qryItensquantidade: TFloatField;
    qryItenssequencia: TLongintField;
    qryItenssub_total: TFloatField;
    qryItensvalor_unitario: TFloatField;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    SpeedButton1: TSpeedButton;
    btVendedor: TSpeedButton;
    btCPF: TSpeedButton;
    bt_cliente: TSpeedButton;
    TabControl1: TTabControl;
    procedure Action1Execute(Sender: TObject);
    procedure ac_alteraPrecoExecute(Sender: TObject);
    procedure ac_filtroProdutosExecute(Sender: TObject);
    procedure ac_abreCaixaExecute(Sender: TObject);
    procedure ac_alterarClienteExecute(Sender: TObject);
    procedure ac_alterarCPFExecute(Sender: TObject);
    procedure ac_alterarVendedorExecute(Sender: TObject);
    procedure ac_cancelamentoExecute(Sender: TObject);
    procedure ac_condicionalExecute(Sender: TObject);
    procedure ac_devolucaoExecute(Sender: TObject);
    procedure ac_fechaCaixaExecute(Sender: TObject);
    procedure ac_fechavendaExecute(Sender: TObject);
    procedure ac_recebimentoExecute(Sender: TObject);
    procedure ac_removerExecute(Sender: TObject);
    procedure ac_sairExecute(Sender: TObject);
    procedure ac_sangriaExecute(Sender: TObject);
    procedure ac_suprimentoExecute(Sender: TObject);
    procedure ed_cpfChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gridItensDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure gridItensKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Shape3Resize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
  private
        _valorBruto, _valorPromocao : Double;
        _Pecas : Double;
        Procedure LimpaTela;
        Procedure GetVendasAndamento;
        Procedure ShowLayout;

        Procedure SetNovaAba;
        Procedure RegistraItem;

        Procedure Redimensionar;

        Function GetVendaID : String;
        Function GetVendaUUID :String;


  public
         Procedure ShowInfProduto;
         Procedure listaOperacoes;
         Procedure SetVenda;

  end;

var
  form_venda: Tform_venda;

implementation

{$R *.lfm}

uses ems.utils, ems.conexao, controller.venda;

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
//    pnlTotal.Caption:= FormatFloat(sessao.formatsubtotal,0);
    ed_cliente.Text:=  'Consumidor';
    ed_vendedor.Text:=  'Não Definido';
    ed_cpf.Text:= '';
    lblCodigo.Caption:= '';
    pnlBase.Visible:= sessao.GetCaixa <> '';

    TabControl1.Tabs.Clear;
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
     with _db.qrySelect do
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

  btCPF.Left:= ed_cpf.Left;
  btVendedor.Left:=  ed_vendedor.Left;
  bt_cliente.Left:=  ed_cliente.Left;

//  gridItens.SelectedColor:= clWhite;
//  gridItens.Font.Color:= clBlack;
  gridItens.SelectedColor:= $00BEEDF2;

    if not pnlDireito.visible then
    Begin
       ac_abreCaixa.ShortCut := TextToShortCut('f1');
       ac_alterarCliente.ShortCut:= TextToShortCut('+');
    end else
    Begin
      ac_abreCaixa.ShortCut := TextToShortCut('+');
      ac_alterarCliente.ShortCut:= TextToShortCut('f1');
    end;

end;

procedure Tform_venda.SetNovaAba;
var _db : TConexao;
     _nota : TJsonObject;
     _cpf : string;
begin

    if not Sessao.CaixaAberto then
     exit;

  _cpf := '';
  if Application.MessageBox('CPF Na Nota','Cluster Sistemas',mb_yesno + mb_iconquestion) = id_yes then
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
       _nota['sinc_pendente'].AsString:= 'S';
       _nota['tabela_preco_id'].AsInteger:= sessao.tabela_preco_id;
       _nota['armazenamento_id'].AsInteger:= sessao.estoque_id;
       _nota['status'].AsString:= 'rascunho';
       _nota['cpf'].AsString:= _cpf;
       _nota['uuid'].AsString:= GetUUID;
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
var  _produtoID : string;
     _quantidade : Double;
begin

  if TabControl1.Tabs.Count = 0 then
     SetNovaAba;

  if lblCodigo.Caption = '' then
     exit;

      _produtoID:= lblCodigo.Caption;

      SeparaQuantidade(_produtoID,_quantidade);
      //SeparaQuantidade
      lblCodigo.Caption:= '';

      if _quantidade = 0 then
        FinalizaProcesso('Quantidade Invalida');

      if RegistraItemVenda(_produtoID,GetVendaUUID,_quantidade) then
         SetVenda;
end;

procedure Tform_venda.Redimensionar;
begin
  pnlLateral.Width:= trunc((pnlVendas.Width * 0.35));

  pnlImagem.Height:= trunc((pnlLateral.Height * 0.80));
  pnlCodigo.Height:= pnlLateral.Height - pnlImagem.Height;

  pnlGridVendas.Height:= trunc((pnlDireito.Height * 0.80));

  pnlTotal.Width:= trunc((pnlTotalizador.Width * 0.35));
  PnlCadatro.Width:= trunc((pnlTotalizador.Width * 0.30));
end;

function Tform_venda.GetVendaID: String;
begin
   Result := getNumeros(TabControl1.Tabs[TabControl1.TabIndex]);
end;

function Tform_venda.GetVendaUUID: String;
var _db : TConexao;
begin
   try
      _db := TConexao.Create;
      with _db.qrySelect do
      Begin
          Close;
          Sql.Clear;
          Sql.Add('select uuid from vendas ');
          Sql.add(' where documento = '+QuotedStr(GetVendaID));
          open;

          result := FieldByName('uuid').AsString;
      end;
   finally
       FreeANdNil(_db);
   end;
end;

procedure Tform_venda.Shape3Resize(Sender: TObject);
begin
    gridItens.DefaultRowHeight:= trunc((Shape3.Height * 0.08));
    pnlTitle.Height:= gridItens.DefaultRowHeight;

    gridItens.Columns[1].Width:= trunc((Shape3.Width * 0.145));
   // gridItens.Columns[2].Width:= trunc((Shape3.Width * 0.37));
    gridItens.Columns[3].Width:= trunc((Shape3.Width * 0.11));
    gridItens.Columns[4].Width:= trunc((Shape3.Width * 0.175));
    gridItens.Columns[5].Width:= trunc((Shape3.Width * 0.175));
    gridItens.TitleFont.Size := trunc((Shape3.Height * 0.030));

    //pnlColCodigo.Width:= trunc((Shape3.Width * 0.145));
    //pnlColDescricao.Width:= trunc((Shape3.Width * 0.37));
    //pnlColQuantidade.Width:= trunc((Shape3.Width * 0.11));
    //pnlColUnitario.Width:= trunc((Shape3.Width * 0.175));
    //pnlColUnitario1.Width := trunc((Shape3.Width * 0.175));

    if  gridItens.TitleFont.Size < 12 then
      gridItens.TitleFont.Size := 12;

    //pnlColCodigo.Font.Size:= gridItens.TitleFont.Size ;
    //pnlColDescricao.Font.Size:= gridItens.TitleFont.Size ;
    //pnlColQuantidade.Font.Size:= gridItens.TitleFont.Size ;
    //pnlColUnitario.Font.Size:= gridItens.TitleFont.Size ;
    //pnlColUnitario1.Font.Size := gridItens.TitleFont.Size ;

    gridItens.Columns[2].Width:= pnlGrid.Width -( gridItens.Columns[0].Width +
                                                  gridItens.Columns[1].Width +
                                                  gridItens.Columns[3].Width +
                                                  gridItens.Columns[4].Width +
                                                  gridItens.Columns[5].Width +
                                                  40
                                                 );
end;

procedure Tform_venda.FormResize(Sender: TObject);
begin
    Redimensionar;
end;

procedure Tform_venda.FormShow(Sender: TObject);
begin
  TabControl1.Tabs.Clear;
  lblUsuario.Caption:= 'Usuario: '+ Sessao.usuarioName;
  lblDadosEmpresa.Caption:= sessao.cidade+'  '+FormatDateTime('dddd "," dd "de" mmmm "de" yyyy',Now) +'   ('+
                             sessao.n_unidade+')';
  GetVendasAndamento;
end;

procedure Tform_venda.gridItensDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
    if gdSelected in State then
    begin
       TDBGrid( Sender ).Canvas.Brush.Color := $00EAE3DA;
       TDBGrid( Sender ).Canvas.Font.Color  := clBlack;
       //TDBGrid( Sender ).Canvas.Pen.Color := Brush.Color;
    end;

    if (Column.Field.FieldName = 'promocional')  then // Aqui o campo a colorir
    begin
          //if Column.Field.Value = true then // coloque aqui sua condição de quando colorir
          //   TDBGrid( Sender ).Canvas.Font.Color  := clGreen
          //else
             TDBGrid( Sender ).Canvas.Font.Color  := clRed;

          gridItens.Canvas.FillRect(Rect);
    end;

    TDBGrid( Sender ).DefaultDrawColumnCell( Rect, DataCol, Column, State );
end;

procedure Tform_venda.gridItensKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var _char : Char;
begin
  if (key = VK_RETURN) then
  Begin
     _char := #13;
     FormKeyPress(self,_char);
  end;

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

procedure Tform_venda.ed_cpfChange(Sender: TObject);
begin
  if trim(ed_cpf.Text) = '' then
     ed_cpf.Color := clRed
  else
     ed_cpf.Color := clGreen;
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
       messagedlg('Ja Existe um caixa aberto em andamento',mtWarning,[mbok],0);
end;

procedure Tform_venda.ac_alterarClienteExecute(Sender: TObject);
var _venda : TJsonObject;
    _db : TConexao;
begin

  frmFiltroCliente := TfrmFiltroCliente.Create(nil);

  Sessao.getID:='';
  frmFiltroCliente._FiltroID := true;
  //frmFiltroCliente._OnlyCustomer:= self.onlyColaborador;
  frmFiltroCliente.ShowModal;

  if Sessao.getID = '' then
     exit;

    try
        _venda := TJsonObject.Create();
        _db := TConexao.Create;
        _venda['id'].AsString:= GetVendaID;
        _venda['sinc_pendente'].AsString:= 'S';
        _venda['cliente_id'].AsString:= sessao.getID;
        _db.updateSQl('vendas',_venda);
        SetVenda;
    finally
        FreeAndNil(_venda);
        FreeAndNil(_db);
    end;
end;

procedure Tform_venda.ac_alterarCPFExecute(Sender: TObject);
var _venda : TJsonObject;
 _db : TConexao;
    _cpf : string;
begin
   _cpf := ed_cpf.Text;
   if not InputQuery('Cluster Sistemas','Informe CPF',_cpf) then
      exit;


    try
        _db := TConexao.Create;
        _venda := TJsonObject.Create();
        _venda['id'].AsString:= GetVendaID;
        _venda['sinc_pendente'].AsString:= 'S';
        _venda['cpf'].AsString:= _cpf;
        _db.updateSQl('vendas',_venda);
        SetVenda;
    finally
        FreeAndNil(_venda);

    end;
end;

procedure Tform_venda.ac_alterarVendedorExecute(Sender: TObject);
var _venda : TJsonObject;
    _db : TConexao;
begin

  frmFiltroCliente := TfrmFiltroCliente.Create(nil);

  Sessao.getID:='';
  frmFiltroCliente._FiltroID := true;
  frmFiltroCliente._OnlyCustomer:= true;
  frmFiltroCliente.ShowModal;

  if Sessao.getID = '' then
     exit;

    try
        _venda := TJsonObject.Create();
        _db := TConexao.Create;
        _venda['id'].AsString:= GetVendaID;
        _venda['sinc_pendente'].AsString:= 'S';
        _venda['vendedor_id'].AsString:= sessao.getID;
        _db.updateSQl('vendas',_venda);
        SetVenda;
    finally
        FreeAndNil(_venda);
        FreeAndNil(_db);
    end;
end;

procedure Tform_venda.ac_cancelamentoExecute(Sender: TObject);
var _db : TConexao;
     _motivo : string;
     _venda : TJsonObject;
begin
  if TabControl1.Tabs.Count > 0 then
  Begin
       if Application.MessageBox('Cancelar Venda','Cluster Sistemas',mb_yesno + mb_iconquestion) = id_yes then
       Begin
            if not InputQuery('Cluster Sistemas','Informe Motivo',_motivo) then
            Begin
                 Messagedlg('Motivo Não informado',mtWarning,[mbok],0);
                 abort;
            end;
            _motivo:= 'Cancelamento de venda em andamento Motivo > : '+_motivo;

            try
               _db := TConexao.Create;
               _venda := TJsonObject.Create();
               _venda['id'].AsString:=GetVendaID;
               _venda['dados_adicionais'].AsString:= _motivo;
               _venda['sinc_pendente'].AsString:= 'S';
               _venda['status'].AsString:= 'cancelado';
               _db.updateSQl('vendas',_venda);

               GetVendasAndamento;
            finally
                FreeAndNil(_db);
                FreeAndNIl(_venda)
            end;
       end;
  end;
end;

procedure Tform_venda.Action1Execute(Sender: TObject);
begin
   SetNovaAba;
   lblCodigo.Caption:= '';
end;

procedure Tform_venda.ac_alteraPrecoExecute(Sender: TObject);
var _sequencia : string;
    _db : TConexao;
    _itens : TJsonObject;
    _newValor : string;
begin
   if TabControl1.Tabs.Count > 0 then
   Begin
       if not InputQuery('Cluster Sistemas', 'Informe a Sequencia a ser Alterada',_sequencia) then
          exit;

       if (StrToIntDef(_sequencia,0) = 0) or (StrToIntDef(_sequencia,0) > qryItens.RecordCount) then
       Begin
          Messagedlg('Sequencia Invalida',mtError,[mbok],0);
          exit;
       end;

       if not InputQuery('Cluster Sistemas', 'Informe o Novo Valor',_newValor) then
          exit;



       try
           _db := TConexao.Create;
           qryItens.DisableControls;
           qryItens.RecNo:= StrToInt(_sequencia);

           with _db.qrySelect do
           Begin
              Close;
              Sql.Clear;
              Sql.Add('select * from venda_itens where id ='+QuotedStr(qryItensid.AsString));
              Open;

              _itens := _db.ToObjectString('',true);
           end;

           if _itens['valor_unitario'].AsNumber = ToValor(_newValor) then
              FinalizaProcesso('Valor Informado Identico valor atual');

           if _itens['valor_unitario'].AsNumber > ToValor(_newValor) then
               _itens['vl_desconto'].AsNumber:= DecimalUnitario(_itens['valor_unitario'].AsNumber- ToValor(_newValor))
           else
              _itens['valor_unitario'].AsNumber:= ToValor(_newValor);

           _itens['promocional'].AsString:= 'true';


           RegistraLogErro(_itens.Stringify);
           VendaGetItemRecalculo(_itens);
           RegistraLogErro(_itens.Stringify);
           _db.updateSQl('venda_itens',_itens);

           SetVenda;
       finally
           qryItens.EnableControls;
           FreeAndNil(_db);
       end;
   end;
end;

procedure Tform_venda.ac_filtroProdutosExecute(Sender: TObject);
begin
  if sessao.CaixaAberto then
  Begin
      sessao.getID:='';
      sessao.gradeID:='';
      CriarForm(Tf_produtosPesquisa);
      lblCodigo.Caption := lblCodigo.Caption + sessao.getID;
      RegistraItem;
  end;
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
        if TabControl1.Tabs.Count > 0 then
           FinalizaProcesso('Existe vendas em andamento feche-as primeiro');

        sessao.FechaCaixa;
        GetVendasAndamento;
    end;


end;

procedure Tform_venda.ac_fechavendaExecute(Sender: TObject);
begin
  f_fechamento := Tf_fechamento.Create(nil);
  f_fechamento._vendaID:= GetVendaID;
  f_fechamento._vendaUUID:= GetVendaUUID;
  f_fechamento._valorBruto:= _valorBruto;
  f_fechamento._valorDesconto:= 0;
  f_fechamento._valorPromocao:= _valorPromocao;
  f_fechamento.ShowModal;
  f_fechamento.Release;
  f_fechamento := nil;
  GetVendasAndamento;
//  CriarForm(Tf_fechamento);
end;

procedure Tform_venda.ac_recebimentoExecute(Sender: TObject);
begin
  CriarForm(Tf_crediario);
end;

procedure Tform_venda.ac_removerExecute(Sender: TObject);
var _sequencia : string;
    _db : TConexao;
    _itens : TJsonObject;
begin
   if TabControl1.Tabs.Count > 0 then
   Begin
       if not InputQuery('Cluster Sistemas', 'Iforme a Sequencia a ser removida',_sequencia) then
          exit;

       if (StrToIntDef(_sequencia,0) = 0) or (StrToIntDef(_sequencia,0) > qryItens.RecordCount) then
       Begin
          Messagedlg('Sequencia Invalida',mtError,[mbok],0);
          exit;
       end;

       try
           _db := TConexao.Create;
           qryItens.DisableControls;
           qryItens.RecNo:= StrToInt(_sequencia);

           _itens := TJsonObject.Create();
           _itens['status'].AsString:= 'R';
           _itens['sinc_pendente'].AsString:= 'S';
           _itens['id'].AsInteger:=qryItensid.Value;
           _db.updateSQl('venda_itens',_itens);
           SetVenda;
       finally
           qryItens.EnableControls;
           FreeAndNil(_db);
       end;
   end;
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
             Limpa(qryItens);
             //qryItens.Close;
             //qryItens.Open;

             gridItens.Columns[3].DisplayFormat:= sessao.formatquantidade;
             gridItens.Columns[4].DisplayFormat:= sessao.formatunitario;
             gridItens.Columns[5].DisplayFormat:= sessao.formatsubtotal;

             qryItens.DisableControls;
             _valorBruto:= 0; _valorPromocao:= 0; _Pecas:= 0;
             with _db.qrySelect do
             Begin
                  Close;
                  Sql.Clear;
                  Sql.Add('select * from venda_itens ');
                  Sql.Add(' where uuid_venda = '+QuotedStr(GetVendaUUID));
                  Sql.Add(' and (status is null  or status = '''' )');
                  Open;
                  first;

                  while not eof do
                  Begin
                     qryItens.Append;
                     qryItensdescricao.Value:=  FieldByName('descricao').AsString;
                     qryItensproduto_id.Value:= FieldByName('produto_id').AsInteger;
                     qryItensquantidade.Value:= FieldByName('quantidade').AsFloat;
                     qryItensvalor_unitario.Value:= FieldByName('valor_final').AsFloat;
                     qryItenssub_total.Value:= FieldByName('vl_produtos').AsFloat;
                     qryItensid.Value:= FieldBYName('id').AsInteger;
                     qryItenssequencia.Value:= qryItens.RecordCount+1;
                     qryItenspromocional.Value:= LowerCase(trim(FieldByName('promocional').AsString)) = 'true';

                     _Pecas:= _Pecas  + FieldByName('quantidade').AsFloat; ;

                     if LowerCase(trim(FieldByName('promocional').AsString)) = 'true' then
                        _valorPromocao:= _valorPromocao  + FieldByName('vl_produtos').AsFloat
                     else
                        _valorBruto:= _valorBruto  + FieldByName('vl_produtos').AsFloat; ;

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
                  Sql.Add(' where v.id = '+QuotedStr(GetVendaID));
                  Open;

                  ed_cliente.Text:= FormatFloat('000000',FieldByName('cliente_id').AsInteger) + ' ' + trim(FieldByName('n_cliente').AsString);
                  ed_vendedor.Text:= FormatFloat('000000',FieldByName('vendedor_id').AsInteger) + ' ' + trim(FieldByName('n_vendedor').AsString);
                  ed_cpf.Text:= trim(FieldByName('cpf').AsString);
             end;

             lblSubTotal.Caption:=FormatFloat(sessao.formatsubtotal(),_valorBruto + _valorPromocao);
             lblPecas.Caption:='Peças: '+FormatFloat(sessao.formatquantidade,_Pecas);
         finally
             FreeAndnil(_db);
             qryItens.EnableControls;
             Redimensionar;
         end;
    end;
    ShowLayout;
end;



end.

