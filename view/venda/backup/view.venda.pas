unit view.venda;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, DBGrids, ComCtrls, Menus, Arrow, ActnList, LCLType,
  view.filtros.cliente, view.pdv, view.balcao, jsons, clipbrd,
  IniFiles;

type

  { Tfrmvendabalcao }

  Tfrmvendabalcao = class(TForm)
    ac_filtrarcliente: TAction;
    ac_delete: TAction;
    ac_imprimir: TAction;
    ac_gravar: TAction;
    ac_cancelar: TAction;
    ac_novo: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblnome: TLabel;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Panel13: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    pnl_venda: TPanel;
    Panel10: TPanel;
    Panel12: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    pnl_menu_suspenso: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel11: TPanel;
    pnlcaixa: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    sped_telacheia: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    TabControle_Abas: TTabControl;
    Timer1: TTimer;
    procedure ac_cancelarExecute(Sender: TObject);
    procedure ac_deleteExecute(Sender: TObject);
    procedure ac_filtrarclienteExecute(Sender: TObject);
    procedure ac_gravarExecute(Sender: TObject);
    procedure ac_imprimirExecute(Sender: TObject);
    procedure ac_novoExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cb_operacaoSelect(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure edt_IdClienteEnter(Sender: TObject);
    procedure edt_IdClienteExit(Sender: TObject);
    procedure edt_IdClienteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sped_telacheiaClick(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
    procedure tab_operacaoChange(Sender: TObject);
    procedure tab_operacaoChanging(Sender: TObject; var AllowChange: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private

       vCliente_uf       : String;
       vClienteAplicacao : integer;

       _Frame_Pdv : TFrame_Pdv;
       _Frame_balcao : Tfrm_balcao;

       //SearchObjeto : TClassProdutos;

       Procedure GravaPedido;
       Procedure DeleteAba(msg_confirma : Boolean = false);
       Procedure ChecaOperacaoAndamento;
       Procedure GetNovaOperacao;
       procedure GetVenda(aIndex:Integer);
       Procedure SomarItem;
       Procedure SalvaGrid;
       Procedure FiltraCliente;


       //Ações Grid
       Procedure SelecaoIndex0;
       Procedure SelecaoIndex1;
       Procedure SelecaoIndex6;
       Procedure SelecaoIndex7;
       Procedure SelecionaTabela1(sTabela:Integer);
       Procedure GravaCliente;

       Procedure ShowNomeAba;
  public

  end;

var
  frmvendabalcao: Tfrmvendabalcao;

implementation

{$R *.lfm}

{ Tfrmvendabalcao }

procedure Tfrmvendabalcao.FormCreate(Sender: TObject);
begin
     //pnlBase.Color  := clDefault;
     Timer1.Enabled := true;

     Caption := ' Cluster Sistemas :: Store ';
end;

procedure Tfrmvendabalcao.cb_operacaoSelect(Sender: TObject);
begin
    //case cb_operacao.ItemIndex of
    //   0 : pnlBase.Color:= clDefault; // DAV
    //   1 : pnlBase.Color:= $00F3EDDC; // Orçamento
    //   2 : pnlBase.Color:= $0096BEDD; // Condicional
    //   3 : pnlBase.Color:= clWhite; // NF-e
    //   4 : pnlBase.Color:= clWhite; // NFC-e
    //end;

end;

procedure Tfrmvendabalcao.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{         if key = VK_ESCAPE then
         Begin
              Key:=0;
              if (DataSource1.DataSet.State in [dsInsert,dsEdit]) then
              Begin
                  dm.qItens.Cancel;
              end;
         End;

         If Key = vk_return Then
         Begin
             Key := 0;
             case DBGrid1.SelectedIndex of
                  0:SelecaoIndex0;
                  1:SelecaoIndex1;
                  6:SelecaoIndex6;
                  7:SelecaoIndex7;
                  else
                  Begin
                       dbgrid1.SelectedIndex:=0;
                  End;
             end;
         end;      }
end;

procedure Tfrmvendabalcao.DBGrid1TitleClick(Column: TColumn);
begin
   SalvaGrid;
end;

procedure Tfrmvendabalcao.edt_IdClienteEnter(Sender: TObject);
begin
//   auxStringTemp := trim(edt_IdCliente.Text);
end;

procedure Tfrmvendabalcao.ac_novoExecute(Sender: TObject);
begin
    GetNovaOperacao;
end;

procedure Tfrmvendabalcao.ac_cancelarExecute(Sender: TObject);
begin
     DeleteAba(True);
end;

procedure Tfrmvendabalcao.ac_deleteExecute(Sender: TObject);
begin
     //if dm.qitens.IsEmpty then
     //  exit;
     //
     //if messagedlg('Remover Ester Item '+#13+ dm.qItensDESCRICAO.Value ,
     //              mtInformation,[mbno,mbyes],0) = mryes then
     //Begin
     //    dm.qItens.Delete;
     //    SomarItem;
     //end;
end;

procedure Tfrmvendabalcao.ac_filtrarclienteExecute(Sender: TObject);
begin
      //if pnlBase.Visible then
      //   FiltraCliente;
end;

procedure Tfrmvendabalcao.ac_gravarExecute(Sender: TObject);
begin    {
      if not Assigned(frmFechaVendaBalcao) then
       frmFechaVendaBalcao := tfrmFechaVendaBalcao.Create(nil);


    if (frameBalcao1.dsItens.DataSet.State in [dsInsert,dsEdit]) then
    Begin
        dm.qItens.Cancel;
        frameBalcao1.SomarItem;
    end;



    if GetValor(frameBalcao1.lblBruto.Caption) = 0 then
        messagedlg('Não existe venda para ser gravada',mtInformation,[mbok],0)
    else
    Begin
        frmfechaVEndaBalcao.sVendaOK := false;
        frmFechaVendaBalcao.ShowModal;

        if frmFechaVendaBalcao.sVendaOK then
            DeleteAba;
    end;}
end;

procedure Tfrmvendabalcao.ac_imprimirExecute(Sender: TObject);
//var Objeto : TClassVenda ;
   //vNumero : String;
begin
  {    inputQuery('','',vNumero);

       try
          objeto := TClassVEnda.Create;
          objeto.Obj.id  := StrToInt(vNumero);
          objeto.Imprimir(true);
       finally
          FreeAndNil(objeto);
       end;}
end;

procedure Tfrmvendabalcao.Button1Click(Sender: TObject);
begin
   DataSource1.DataSet.Append;
end;

procedure Tfrmvendabalcao.edt_IdClienteExit(Sender: TObject);
//var objPessoa : TClassPessoa;
begin
  //if trim(edt_IdCliente.Text) = '' then
  //Begin
  //    FiltraCliente;
  //end else
  //Begin
  //    if trim(edt_IdCliente.Text) <> '' then
  //    Begin
  //         if trim(auxStringTemp) <> trim(edt_IdCliente.text) then
  //         Begin
  //              try
  //                  objPessoa := TClassPessoa.create;
  //                  objPessoa.Obj.id := StrTointDef(edt_IdCliente.text,0);
  //
  //                  if objPessoa.get then
  //                  Begin
  //                      edt_nomecliente.Text   := objPessoa.Obj.Nome;
  //                      gravaCliente;
  //                      dm.qitens.Last;
  //                      DBGrid1.SetFocus;
  //                      DBGrid1.SelectedIndex := 0;
  //                  end else
  //                  Begin
  //                  end;
  //              finally
  //                  FreeAndNil(ObjPessoa);
  //              end;
  //         end;
  //    end;
  //end;
end;

procedure Tfrmvendabalcao.edt_IdClienteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   //if key= vk_return then
   //Begin
   //      key := 0;
   //      DBGrid1.SetFocus;
   //end;
end;

procedure Tfrmvendabalcao.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
   frmvendabalcao.Release;
   frmvendabalcao := nil;
end;

procedure Tfrmvendabalcao.FormShow(Sender: TObject);
begin
    //Checando Abas em Andamento
    //tab_operacao.Tabs.Clear;
    ChecaOperacaoAndamento;
end;

procedure Tfrmvendabalcao.sped_telacheiaClick(Sender: TObject);
begin
   case sped_telacheia.ImageIndex of
       2 : Begin
           frmvendabalcao.WindowState := wsFullScreen;
           sped_telacheia.ImageIndex  := 3;
       end;

       3:Begin
           frmvendabalcao.WindowState := wsMaximized;
           sped_telacheia.ImageIndex  := 2;
       end;

   end;
end;

procedure Tfrmvendabalcao.SpeedButton14Click(Sender: TObject);
begin
   pnl_menu_suspenso.Top:=56;
   pnl_menu_suspenso.Left:=8;
   pnl_menu_suspenso.Visible:= not pnl_menu_suspenso.Visible;

end;

procedure Tfrmvendabalcao.tab_operacaoChange(Sender: TObject);
begin
  //GetVenda(tab_operacao.TabIndex);
end;

procedure Tfrmvendabalcao.tab_operacaoChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
//   GravaPedido;
end;

procedure Tfrmvendabalcao.Timer1Timer(Sender: TObject);
begin
   //lblnome.Caption :=parametros.Empresa.Item[0].Cidade+
   //                 formatdatetime(',   dd "de" mmmm "de" yyyy.   hh:mm:ss',now);
end;

procedure Tfrmvendabalcao.GravaPedido;
begin
   //dm.qVenda.Edit;
   //dm.qVendaIDCLIENTE.Value       := StrToIntDef(edt_IdCliente.text,0);
   //dm.qVendaCLI_NOMECLIENTE.Value := edt_nomecliente.Text;
   ////dm.qVendaCLI_CIDADE.Value      := frameBalcao1.edtcidade.Text;
   ////dm.qVendaCLI_TELEFONE.Value    := frameBalcao1.edtfone.Text;
   ////dm.qVendaCLI_CPF.value         := frameBalcao1.edtCPFCnpj.Text;
   //dm.qVendaTABELA.Value          := cb_tabela.ItemIndex +1 ;
   //dm.Qvenda.Post;
end;

procedure Tfrmvendabalcao.DeleteAba(msg_confirma : Boolean = false);
//var Requisicao : TRequisicao;
//    objBody : TjsonObject;
//    abaIndex, idAba: Integer;
begin
//
//    if not tab_operacao.Tabs.Count > 0 then
//       exit;
//
//    if msg_confirma then
//    Begin
//         if not (messagedlg('Deseja Cancelar esta operação?',mtInformation,[mbno,mbyes],0) = mryes) then
//            exit;
//    end;
//
//    try
//       idAba := StrToIntDef(Copy(tab_operacao.Tabs[tab_operacao.TabIndex],0,6),0);
//
//       abaIndex := tab_operacao.TabIndex;
//
//
//       objBody := TJSONObject.Create;
//       objBody.Add('id',IntToStr(idAba));
//
//       Requisicao := TRequisicao.Create;
//       Requisicao.Metodo := rPost;
//       Requisicao.Body.Add(objBody.AsJSON);
//       Requisicao.URL := 'venda';
//       Requisicao.Funcao := 'vendadel';
//       Requisicao.Execute;
//
//
//       if (Requisicao.Return.Get('status','') = '200')then
//          tab_operacao.Tabs.Delete(tab_operacao.TabIndex);
//
//
//       if tab_operacao.Tabs.Count = 0 then
//          pnlBase.Visible := false;
//
//
//       if abaIndex <= tab_operacao.Tabs.Count-1 then
//          tab_operacao.TabIndex := abaIndex
//       else
//       Begin
//            if tab_operacao.Tabs.Count > 0 Then
//               tab_operacao.TabIndex := abaIndex-1;
//       end;
//
//
//    finally
//        if tab_operacao.Tabs.Count > 0 then
//           GetVenda(tab_operacao.tabindex);
//
//
//        Requisicao.Free;
//        objBody.Free;
//    end;

end;

procedure Tfrmvendabalcao.ChecaOperacaoAndamento;
//var Servidor : TRequisicao;
//     objBody : TJSONObject;
//     qryIDS : TRESTDWClientSQL;
begin
    //try
    //   qryIDS  := TRESTDWClientSQL.Create(nil);
    //   objBody := TJSONObject.Create;
    //   objBody.Add('mac',GetTokenPDV);
    //
    //   Servidor        := TRequisicao.Create;
    //   Servidor.Metodo := rPost;
    //   Servidor.URL    := 'venda';
    //   Servidor.Funcao := 'vendalist';
    //   Servidor.Body.Add(objBody.AsJSON);
    //   Servidor.Execute;
    //
    //
    //   if (Servidor.Return.Get('Status','') = '200')then
    //   Begin
    //        qryIDS.OpenJson(Servidor.Return.Elements['resultado'].AsJSON);
    //
    //        qryIDS.First;
    //        tab_operacao.tabs.Clear;
    //        While Not qryIDS.Eof do
    //        Begin
    //             tab_operacao.Tabs.Add(FormatFloat('000000',qryIDS.FieldByName('id').AsInteger));
    //             qryIDS.Next;
    //        end;
    //   end else
    //     tab_operacao.Tabs.Clear;
    //
    //   if tab_operacao.Tabs.Count = 0 then
    //      pnlBase.Visible := false
    //   else
    //      tab_operacao.TabIndex := 0;
    //
    //   GetVenda(tab_operacao.tabIndex);
    //finally
    //    Servidor.Free;
    //    objBody.Free;
    //    qryIDS.Free;
    //end;
    //
    //// Format
    //dm.qItensVALOR.DisplayFormat            := parametros.Format_Unit;
    //dm.qItensVALORUNITARIO.DisplayFormat    := parametros.Format_Unit;
    //dm.qItensVALORMINIMO.DisplayFormat      := parametros.Format_Unit;
    //dm.qItensSUB_TOTAL.DisplayFormat        := parametros.Format_Geral;
    //dm.qItensQUANTIDADE.DisplayFormat       := parametros.Format_Quantidade;
    //dm.qItensALIQ_DESCONTO.DisplayFormat    := '0.00,';
end;

procedure Tfrmvendabalcao.GetNovaOperacao;
//var Servidor : TRequisicao;
//     objBody : TjsonObject;
begin
   TabControle_Abas.Tabs.Add(FormatFloat('000000',1)
                     +' '+'Consumidor');

   //if not Assigned(_Frame_Pdv) then
   //   _Frame_Pdv := Tframe_pdv.Create(pnl_venda);
   //
   //_Frame_Pdv.Parent := pnl_venda;
   //_Frame_Pdv.Align:=alClient;


  if not Assigned(_Frame_balcao) then
     _Frame_balcao := Tfrm_balcao.Create(pnl_venda);

  _Frame_balcao.Parent := pnl_venda;
  _Frame_balcao.Align:=alClient;





   //try
   //   objBody := TJSONObject.Create;
    //   objBody.Add('mac',GetTokenPDV);
    //
    //   Servidor        := TRequisicao.Create;
    //   Servidor.Metodo := rPost;
    //   Servidor.URL    := 'venda';
    //   Servidor.Funcao := 'vendanovoput';
    //   Servidor.Body.Add(objBody.AsJSON);
    //   Servidor.Execute;
    //
    //
    //   if (Servidor.Return.Get('status','') = '200')then
    //   Begin
   //tab_operacao.Tabs.Add(FormatFloat('000000',StrToIntDef(Servidor.Return.Get('return_id','0'),0))
            //tab_operacao.Tabs.Add(FormatFloat('000000',1)
            //                  +' '+'Consumidor');
    //   end else
         //tab_operacao.Tabs.Clear;
    //
       //tab_operacao.TabIndex := tab_operacao.Tabs.Count-1;
       // pnlBase.Visible := tab_operacao.Tabs.Count > 0;

    //
    //   if not pnlBase.Visible then
    //      pnlBase.Visible := true;
    //
    //   edt_IdCliente.text := '1';
    //   edt_IdClienteExit(self);
    //
    //   cb_tabela.ItemIndex := parametros.TabelaDefault-1;
    //
    //   GetVenda(tab_operacao.tabindex);
    //
    //   DM.qVenda.Edit;
    //   DM.qVendaIDNOTA.Value           := 0;
    //   DM.qVendaCFOP.Value             := 5102;
    //   DM.qVendaNATUREZAOPERACAO.Value := 'Venda de Mercadoria ';
    //   DM.qVendaENTRADASAIDA.Value     := 'S';
    //   DM.qVendaFINNFE.Value           := 'normal';
    //   DM.qVendaTPEMISSAO.Value        := 'normal';
    //   DM.qVendaIDORCAMENTO.Value      := 0;
    //   DM.qVendaTABELA.Value           := cb_tabela.ItemIndex+1;
    //   dm.qvendaIDCLIENTE.Value        := StrToInt('1');
    //   DM.qVendaSTATUS.Value           := 'Salva';
    //   DM.qVenda.Post;
    //finally
    //    Servidor.Free;
    //    objBody.Free;
    //end;
end;

procedure Tfrmvendabalcao.GetVenda(aIndex: Integer);
var aux : String;
begin
    //vAux:= 0;
    //vAliquota := 0;
    //vUnitario := 0;
    //
    //if (tab_operacao.Tabs.Count > 0) and (aIndex>=0) then
    //Begin
    //    if not pnlBase.Visible then
    //       pnlBase.Visible:=true;
    //
    //    dm.ZConnection1.Connected := false;
    //    dm.qitens.Active := False;
    //    dm.qVenda.Active := False;
    //
    //
    //
    //    aux := copy(tab_operacao.Tabs[aIndex],1,6);
    //    aux := IntToStr(StrToIntDef(aux,0));
    //
    //    //dm.ZConnection1.Commit;
    //
    //    dm.qvenda.Close;
    //    dm.qvenda.SQL.Clear;
    //    dm.qvenda.Sql.Add('select * from temp_venda where id= '+QuotedStr(aux));
    //    dm.qVenda.open;
    //
    //
    //
    //    dm.qitens.Close;
    //    dm.qitens.SQL.Clear;
    //    dm.qitens.Sql.Add('select * from temp_itens where id_venda= '+QuotedStr(aux));
    //    dm.qitens.open;
    //
    //    auxStringTemp := '';
    //
    //    edt_IdCliente.text := dm.qVendaIDCLIENTE.AsString;
    //
    //
    //    if edt_IdCliente.Text = '' then
    //       edt_IdCliente.Text:=  '1';
    //
    //    case dm.qVendaTABELA.Value of
    //       1 : cb_tabela.ItemIndex := 0;
    //       2 : cb_tabela.ItemIndex := 1;
    //       3 : cb_tabela.ItemIndex := 2;
    //    end;
    //
    //    edt_IdClienteExit(self);
    //
    //
    //    SomarItem;
    //end;

end;

procedure Tfrmvendabalcao.SomarItem;
var
    vAliq ,
    vUnit : Currency;

   vGeral ,
vDesconto ,
 Vliquido : Currency;

        i : Integer;

 cPosicao : TBookmark;
begin
     //   if vUnitario > 0 then
     //   begin
     //       vAliquota := 0;
     //       vAliq := dm.qItensVALORUNITARIO.AsCurrency / dm.qItensVALOR.AsCurrency;
     //       vAliq := 100-(vAliq *100);
     //
     //       dm.qItens.Edit;
     //       dm.qItensALIQ_DESCONTO.AsCurrency   := vAliq;
     //   end;
     //
     //   if vAliquota > 0 then
     //   begin
     //       vUnitario := 0;
     //       vUnit := (100 - dm.qItensALIQ_DESCONTO.AsCurrency) /100;
     //       vUnit := dm.qItensVALOR.AsCurrency * vUnit;
     //
     //       dm.qItens.Edit;
     //       dm.qItensVALORUNITARIO.AsCurrency := vUnit;
     //   end;
     //
     //   if ( vAliquota = 0 ) and (vUnitario = 0 ) and
     //      (dm.qItensIDPRODUTO.AsString <>'') then
     //       dm.qItens.Edit
     //   else
     //   Begin
     //        if trim(dm.qItensIDPRODUTO.AsString) = '' then
     //           dm.qItens.Cancel;
     //   end;
     //
     //   if (dm.qitens.State in [dsInsert,dsEdit]) then
     //   Begin
     //       if dm.qItensVALOR.AsCurrency > dm.qItensVALORUNITARIO.AsCurrency then
     //          dm.qItensVL_DESCONTO.AsCurrency  := (dm.qItensVALOR.AsCurrency -
     //                                           dm.qItensVALORUNITARIO.AsCurrency) *
     //                                           dm.qItensQUANTIDADE.AsCurrency
     //       else
     //          dm.qItensVL_DESCONTO.Value := 0;
     //
     //       dm.qItensSUB_TOTAL.AsCurrency := dm.qItensQUANTIDADE.AsCurrency*
     //                                        dm.qItensVALORUNITARIO.AsCurrency;
     //
     //       dm.qItensSUB_TOTAL.AsCurrency := Format_Valor(FormatFloat('0.00',dm.qItensSUB_TOTAL.AsCurrency));
     //
     //
     //       dm.qItensCALC_SUBTOTAL.value  :=  dm.qItensSUB_TOTAL.AsCurrency;
     //       dm.qItensCALC_DESCONTO.Value  :=  dm.qItensVL_DESCONTO.AsCurrency;
     //
     //       dm.qItens.Post;
     //
     //   end;
     //cPosicao := dm.qItens.GetBookMark;
     //dm.qItens.DisableControls;
     //dm.qItens.First;
     //
     //vGeral    := 0;
     //vDesconto := 0;
     //Vliquido  := 0;
     //
     //while not dm.qItens.Eof do
     //Begin
     //    vGeral    := vGeral + dm.qItensQUANTIDADE.AsCurrency*dm.qItensVALOR.AsCurrency;
     //    vDesconto := vDesconto + dm.qItensVL_DESCONTO.AsCurrency;
     //    Vliquido  := Vliquido + dm.qItensSUB_TOTAL.AsCurrency;
     //    dm.qItens.Next;
     //end;
     //dm.qItens.GotoBookmark(cPosicao);
     //dm.qItens.EnableControls;
     //
     //lbl_bruto.Caption    := FormatFloat(Parametros.Sigla+' '+parametros.Format_Geral,vGeral);
     //lbl_desconto.Caption := FormatFloat(Parametros.Sigla+' '+parametros.Format_Geral,vDesconto);
     //lbl_liquido.Caption  := FormatFloat(Parametros.Sigla+' '+parametros.Format_Geral,Vliquido);

end;

procedure Tfrmvendabalcao.SalvaGrid;
var       i : Integer;
   Registro : TIniFile;
begin
//
//   if not DirectoryExists(path_diretorio) then
//      forcedirectories(path_diretorio);
//
//   Registro:=TIniFile.Create(path_diretorio+file_ini_hibrido);
//   for i := 0 to DBGrid1.Columns.Count -1 do
//   Begin
//          Registro.WriteString('gridvenda',
//                                DBGrid1.Columns[i].FieldName,
//                                IntToStr(DBGrid1.Columns[i].Width)
//                                );
//   end;
//   FreeAndNil(registro);


end;

procedure Tfrmvendabalcao.FiltraCliente;
begin
    //frmFiltroCliente:= TfrmFiltroCliente.Create(nil);
    //const_idfiltro := '';
    //frmFiltroCliente.ShowModal;
    //
    //if const_idfiltro <> '' then
    //Begin
    //   edt_IdCliente.text := const_idfiltro;
    //
    //   edt_IdClienteExit(self);
    //
    //   auxStringTemp := '';
    //
    //end else
    //Begin
    //   edt_IdCliente.SetFocus;
    //   messagedlg('Informe um Cliente para continuar',mtConfirmation,[mbok],0);
    //end;
end;

procedure Tfrmvendabalcao.SelecaoIndex0;
var sLancado:Boolean;
       s1,s2:String;
        sAux:Double;
begin
//     if (dm.qItens.State in [dsInsert,dsEdit]) then
//     Begin
//         dm.qitens.Post;
//         dm.qitens.Edit;
//
//         if dm.qItensIDPRODUTO.AsString ='' then
//         Begin
//               Parametros.IdFiltro       :=  '';
//               {frmBuscaProdutos:=TfrmBuscaProdutos.Create(nil);
//               frmBuscaProdutos.Tabela_Padrao := cxTabela.ItemIndex+1;
//               frmBuscaProdutos.ShowModal;}
//
//               if Parametros.IdFiltro <> '' Then
//               Begin
//                     dm.qitensIDPRODUTO.Value := StrTointDef(parametros.IdFiltro,0);
////                  cdsItensgrade.Value     := parametros.DadosBusca.BuscaProduto_Grade;
////                  cdsItensid_lote.Value   := parametros.DadosBusca.BuscaProduto_Lote;
//               End;
//               DBGrid1.SetFocus;
//         End;
//         if trim(dm.qItensIDPRODUTO.AsString)<>'' then
//         Begin
//
//            FreeAndNil(SearchObjeto);
//
//            if not Assigned(SearchObjeto) then
//               SearchObjeto := TClassProdutos.Create;
//
//
//
//
//            SearchObjeto.obj.id         := dm.qItensIDPRODUTO.AsString;
//            SearchObjeto.obj.idGrade    := dm.qItensIDGRADE.Value;
//            SearchObjeto.obj.id_lote    := dm.qItensIDLOTE.Value;
//            SearchObjeto.obj.Tributacao.Cenario.UFOrigem    := parametros.Empresa.Item[0].UF;
//            SearchObjeto.obj.Tributacao.Cenario.UFDestino   := vCliente_uf;
//            SearchObjeto.obj.Tributacao.Cenario.Aplicacao   := IntToStr(vClienteAplicacao);
//
//            if vClienteRegime = OptanteSimples then
//               SearchObjeto.obj.Tributacao.Cenario.Regime      := 'OS'
//            else
//            if vClienteRegime = LucroReal then
//               SearchObjeto.obj.Tributacao.Cenario.Regime      := 'LR'
//            else
//            if vClienteRegime = LucroPresumido then
//               SearchObjeto.obj.Tributacao.Cenario.Regime      := 'LP'
//            else
//            if vClienteRegime = rFisica then
//               SearchObjeto.obj.Tributacao.Cenario.Regime      := 'FI'
//            else
//            if vClienteRegime = rOutros then
//               SearchObjeto.obj.Tributacao.Cenario.Regime      := 'OU'
//            else
//            if vClienteRegime = rExterior then
//               SearchObjeto.obj.Tributacao.Cenario.Regime      := 'EX';
//
//            SearchObjeto.obj.Gestor     := true ;
//            SearchObjeto.obj.Cadastro   := false;
//            SearchObjeto.obj.Tabela     := cb_tabela.ItemIndex+1;
//
//
//            if SearchObjeto.Get then
//            Begin
//
//                if SearchObjeto.obj.Selecao.Count > 0 then
//                Begin
//                     try
//                         {frmProdutosResul_Busca := TfrmProdutosResul_Busca.Create(nil);
//                         frmProdutosResul_Busca.MontaQuery(SearchObjeto.obj);
//                         frmProdutosResul_Busca.ShowModal;
//                         SearchObjeto.obj.id       := IntToStr(frmProdutosResul_Busca.cdsProdutosid.Value);
//                         SearchObjeto.obj.idGrade  := frmProdutosResul_Busca.cdsProdutosidGrade.Value;
//                         SearchObjeto.obj.id_lote  := frmProdutosResul_Busca.cdsProdutosidLote.AsInteger;
//                         SearchObjeto.obj.Gestor     := true;
//                         SearchObjeto.obj.Cadastro   := false;}
//                         SearchObjeto.obj.Tabela     := cb_tabela.ItemIndex+1;
//
//                         SearchObjeto.obj.Tributacao.Cenario.UFOrigem   := parametros.Empresa.Item[Get_(parametros.IdEmpresa)].UF;
//                         SearchObjeto.obj.Tributacao.Cenario.UFDestino  := vCliente_uf;
//                         SearchObjeto.obj.Tributacao.Cenario.Aplicacao   := IntToStr(vClienteAplicacao);
//
//
//                          if vClienteRegime = OptanteSimples then
//                             SearchObjeto.obj.Tributacao.Cenario.Regime      := 'OS'
//                          else
//                          if vClienteRegime = LucroReal then
//                             SearchObjeto.obj.Tributacao.Cenario.Regime      := 'LR'
//                          else
//                          if vClienteRegime = LucroPresumido then
//                             SearchObjeto.obj.Tributacao.Cenario.Regime      := 'LP'
//                          else
//                          if vClienteRegime = rFisica then
//                             SearchObjeto.obj.Tributacao.Cenario.Regime      := 'FI'
//                          else
//                          if vClienteRegime = rOutros then
//                             SearchObjeto.obj.Tributacao.Cenario.Regime      := 'OU'
//                          else
//                          if vClienteRegime = rExterior then
//                             SearchObjeto.obj.Tributacao.Cenario.Regime      := 'EX';
//
//                         SearchObjeto.Get;
//                     finally
//                         {frmProdutosResul_Busca.Release;
//                         frmProdutosResul_Busca := nil;}
//                     end;
//                End;
//
//               case cb_tabela.ItemIndex of
//                  0:begin
//                    if SearchObjeto.obj.Atacado=0 then
//                    Begin
//                        Messagedlg('Item sem preço cadastrado',mtInformation,[mbok],0);
//                        dm.qItens.Cancel;
//                        exit;
//                    End;
//                  end;
//                  1:Begin
//                    if SearchObjeto.obj.Varejo=0 then
//                    Begin
//                        Messagedlg('Item sem preço cadastrado',mtInformation,[mbok],0);
//                        dm.qItens.Cancel;
//                        DBGrid1.SelectedIndex:=0;
//                        exit;
//                    End;
//                  End;
//                  2:Begin
//
//                    if SearchObjeto.obj.Auxiliar=0 then
//                    Begin
//                        Messagedlg('Item sem preço cadastrado',mtInformation,[mbok],0);
//                        dm.qItens.Cancel;
//                        DBGrid1.SelectedIndex:=0;
//                        FreeAndNil(SearchObjeto);
//                        exit;
//                    End;
//                  End;
//                  3:Begin
//
//                    if SearchObjeto.obj.custo_medio=0 then
//                    Begin
//                        Messagedlg('Item sem preço cadastrado',mtInformation,[mbok],0);
//                        dm.qItens.Cancel;
//                        DBGrid1.SelectedIndex:=0;
//                        exit;
//                    End;
//                  End;
//               end;
//
//
//                if not parametros.VendaSemEstoque then
//                Begin
//                      if  SearchObjeto.obj.Saldo_Atual <= 0 then
//                      Begin
//                            Messagedlg('Sem Estoque disponivel',mtInformation,[mbok],0);
//                            exit;
//                      End;
//                End;
//
//               s1:=trim(SearchObjeto.obj.descricao);
//               s2:=trim(SearchObjeto.obj.descricao);
//
//               if SearchObjeto.obj.TipoProduto='M' then
//                  if not InputQuery('Cluster Sistemas' , 'Alterar Nome Produto',s2) then
//                  Begin
//                     s2:=s1;
//                  End;
//
//               dm.qItensID_VENDA.Value  := dm.qVendaID.Value;
//               dm.qItensDESCRICAO.Value := trim(s2);
//               dm.qItensIDPRODUTO.Value := StrToIntDef(SearchObjeto.obj.id,0);
////               dm.qitenscomcdsItenscomposto.Value := trim(SearchObjeto.obj.TipoProduto)='C';
//
//
//
//             { if parametros.TipoLimite='desconto' then
//               Begin
//                     case cbTabela.ItemIndex of
//                        0:sAux:=CdsPdvFlexivel.FieldByName('preco_atacado').AsFloat;
//                        1:sAux:=CdsPdvFlexivel.FieldByName('preco_varejo').AsFloat;
//                        2:sAux:=CdsPdvFlexivel.FieldByName('preco_aux').AsFloat;
//                        3:sAux:=CdsPdvFlexivel.FieldByName('custo_medio').AsFloat;
//                     end;
//                     sAux := sAux * (1-(parametros.limiteDescontoVendedor/100));
//               End else
//               Begin
//                   sAux:=CdsPdvFlexivel.FieldByName('preco_atacado').AsFloat;
//               End;  }
//
//               sAux := SearchObjeto.obj.Atacado;
//
//               dm.qItensVALORMINIMO.Value := sAux;
//               dm.qItensSALDO.Value       := SearchObjeto.obj.Saldo_Atual;
////               dm.qitensnomecdsItensmarca.Value       := SearchObjeto.obj.Nome_Marca;
//               dm.qItensQUANTIDADE.Value  := 1;
//
//
//               dm.qItensATACADO.AsCurrency     := SearchObjeto.obj.Atacado;
//               dm.qItensVAREJO.AsCurrency      := SearchObjeto.obj.Varejo;
//               dm.qItensAUXILIAR.AsCurrency    := SearchObjeto.obj.Auxiliar;
//               dm.qItensCFOP.Value             := SearchObjeto.obj.Tributacao.cfop;
//               dm.qItensNCM.Value              := SearchObjeto.obj.ncm;
//               dm.qItensALIQ_IBPT.Value        := SearchObjeto.obj.Tributacao.Aliq_Ibpt;
//               dm.qItensCST_CSON.Value         := SearchObjeto.obj.Tributacao.CSOSN;
//               dm.qItensCST_ICMS.Value         := SearchObjeto.obj.Tributacao.CST_ICMS;
//               dm.qItensALIQ_ICMS.Value        := SearchObjeto.obj.Tributacao.Aliq_ICMS;
//               dm.qItensALIQ_ICMS_ST.Value     := SearchObjeto.obj.Tributacao.MVA;
//               dm.qItensCST_IPI.Value          := SearchObjeto.obj.Tributacao.CST_IPI;
//               dm.qItensALIQ_IPI.Value         := SearchObjeto.obj.Tributacao.Aliq_IPI;
//               dm.qItensCST_COFINS.Value       := SearchObjeto.obj.Tributacao.CST_Pis;
//               dm.qItensALIQ_COFINS_PERC.Value := SearchObjeto.obj.Tributacao.Aliq_Cofins;
//               dm.qItensALIQ_COFINS_R.Value    := 0;
//               dm.qItensCST_COFINS.Value       := SearchObjeto.obj.Tributacao.CST_Cofins;
//               dm.qItensALIQ_PIS_R.Value       := 0;
//               dm.qItensALIQ_PIS_PERC.Value    := SearchObjeto.obj.Tributacao.Aliq_Pis;
//               dm.qItensINF_FISCO.Value        := SearchObjeto.obj.Tributacao.Obs;
//               dm.qItensCBENEFICIO.Value       := SearchObjeto.obj.Tributacao.CodigoBeneficio;
//               dm.qItensDEFAULTVALUE.Value     := SearchObjeto.obj.Tributacao.Default_tributacao;
//               dm.qItensEAN13.Value            := SearchObjeto.obj.codigobarraean13;
//               dm.qItensORIGEMMERCADORIA.Value := SearchObjeto.obj.origemmercadoria;
//               dm.qItensCEST.Value             := SearchObjeto.obj.Cest;
////               dm.qitensiduncdsItensidunidade.Value        := SearchObjeto.obj.idunidade;
////               dm.qitens.Value          := SearchObjeto.obj.Id_Marca;
//
//               dm.qItensTIPOVALOR.Value        := SearchObjeto.Obj.TipoValor;
//
//               case cb_tabela.ItemIndex of
//                  0:dm.qItensVALOR.Value := SearchObjeto.obj.Atacado;
//                  1:dm.qItensVALOR.Value := SearchObjeto.obj.Varejo;
//                  2:dm.qItensVALOR.Value := SearchObjeto.obj.Auxiliar;
//                  3:dm.qItensVALOR.Value := SearchObjeto.obj.custo_medio;
//               end;
//
//               dm.qItensCUSTO_UNITARIO.Value   := SearchObjeto.obj.custo_medio;
//               dm.qItensCUSTOF.Value           := SearchObjeto.obj.custo;
//               dm.qItensTABELA.Value           := (cb_tabela.ItemIndex+1);
//
//               Selecionatabela1(cb_tabela.ItemIndex+1);
//
//               dm.qItensALIQ_DESCONTO.Value    := 0;
//               dm.qItensVL_DESCONTO.Value      := 0;
//               dm.qItensUNMEDIDA.Value         := SearchObjeto.obj.unMedida;
//               dm.qItensEAN13.Value            := SearchObjeto.obj.codigobarraean13;
//               dm.qItensIDGRADE.Value          := SearchObjeto.obj.codInterno;
//               dm.qItensINFLOTE.AsString       := SearchObjeto.obj.inflote;
//               dm.qItensIDLOTE.Value           := SearchObjeto.obj.id_lote;
//
//               dm.qItens.Post;
//            End else
//            Begin
//                DBGrid1.SelectedIndex:=0;
//                Exit;
//            End;
//            DBGrid1.SelectedIndex:=1;
//            //SalvaXMLItens;
//          End;
//     End else
//     Begin
//            if trim(dm.qItensIDPRODUTO.AsString)='' then
//            Begin
//                 dm.qItens.Close;
//                 dm.qItens.Open;
//                 DBGrid1.SelectedIndex  := 0;
//                 dm.qItens.Append;
//                 exit;
//            End;
//            DBGrid1.SelectedIndex:=1;
//     End;

end;

procedure Tfrmvendabalcao.SelecaoIndex1;
var pos : Integer;
begin
    //if (DataSource1.DataSet.State in [dsInsert,dsEdit]) then
    //    dm.qitens.Post;
    //
    //pos := 6;
    //if dm.qitensTIPOVALOR.Value = 'I' THEN
    //Begin
    //     if not GetValorInteiro(dm.qItensQUANTIDADE.AsString) then
    //     Begin
    //          DBGrid1.SelectedIndex:=1;
    //          pos := 1;
    //          Messagedlg('Quantidade Invalida valor deve ser inteiro',mtInformation,[mbok],0);
    //     end;
    //end;
    //
    //DBGrid1.SelectedIndex := pos;
    //vAliquota := 0;
    //vAux := dm.qItensALIQ_DESCONTO.Value;
    //SomarItem;
end;

procedure Tfrmvendabalcao.SelecaoIndex6;
begin
      //if (DataSource1.DataSet.State in [dsInsert,dsEdit]) then
      //Begin
      //     DataSource1.DataSet.Post;
      //     DataSource1.DataSet.edit;
      //
      //     if dm.qItensALIQ_DESCONTO.Value <> vAux then
      //       vAliquota := dm.qItensALIQ_DESCONTO.Value;
      //
      //
      //     if dm.qItensALIQ_DESCONTO.Value = 0 then
      //        dm.qItensVALORUNITARIO.Value := dm.qItensVALOR.Value;
      //
      //     DBGrid1.SelectedIndex:=7;
      //End else
      //     DBGrid1.SelectedIndex:=7;
      //
      //vUnitario := 0;
      //vAux      := dm.qItensVALORUNITARIO.AsCurrency;
      //SomarItem;
end;

procedure Tfrmvendabalcao.SelecaoIndex7;
begin
      //if (DataSource1.DataSet.State in [dsInsert,dsEdit]) then
      //   DataSource1.DataSet.Post;
      //
      //
      //   if  Trim(dm.qItensIDPRODUTO.AsString)<>'' then
      //   Begin
      //        if dm.qItensVALORUNITARIO.Value <> vAux then
      //           vUnitario := dm.qItensVALORUNITARIO.AsCurrency;
      //
      //        //SalvaXMLItens;
      //        SomarItem;
      //
      //        if dm.qItens.RecNo = dm.qitens.RecordCount then
      //        Begin
      //            if (DataSource1.DataSet.State in [dsInsert,dsEdit]) then
      //                DBGrid1.SelectedIndex:=0
      //            else Begin
      //                dm.qItens.Append;
      //                DBGrid1.SelectedIndex:=0
      //            End;
      //
      //        End  else
      //        Begin
      //           DBGrid1.SelectedIndex:=0;
      //           dm.qItens.Next;
      //        End;
      //   End else
      //   begin
      //       dm.qItens.Cancel;
      //       DBGrid1.SelectedIndex:=0;
      //   end;

end;

procedure Tfrmvendabalcao.SelecionaTabela1(sTabela: Integer);
var auxValor : Currency;
begin
     //dm.qItens.Edit;
     //auxValor := 0;
     //case  sTabela of
     //   1 : auxvalor := dm.qItensATACADO.AsCurrency;
     //   2 : auxvalor := dm.qItensVAREJO.AsCurrency;
     //   3 : auxvalor := dm.qItensAUXILIAR.AsCurrency;
     //end;
     //dm.qItensVALOR.AsCurrency          := auxValor;
     //dm.qItensVALORUNITARIO.AsCurrency  := auxValor;
     //dm.qItensSUB_TOTAL.AsCurrency      := auxValor;
     //dm.qItensTABELA.Value:= (sTabela);

end;

procedure Tfrmvendabalcao.GravaCliente;
begin
     //dm.qVenda.Edit;
     //dm.qVendaCOMANDA.Value         := '';
     //dm.qVendaIDCLIENTE.Value       := StrToIntDef(edt_IdCliente.text,0);
     //dm.qVendaCLI_NOMECLIENTE.Value := edt_nomecliente.Text ;{
     //dm.qVendaCPF.Value             := edtCpfCnpj.Text;
     //dm.qVendaCLI_ENDERECO.Value    := edtEndereco.Text;
     //dm.qVendaCLI_CIDADE.Value      := edtCidade.Text;
     //dm.qVendaCLI_TELEFONE.Value    := edtFone.Text;}
     //dm.qVenda.Post;
     //
     //ShowNomeAba;

end;

procedure Tfrmvendabalcao.ShowNomeAba;
var aindex: Integer;
begin
  //aindex:= tab_operacao.TabIndex;
  //tab_operacao.Tabs[aIndex] := Copy(tab_operacao.Tabs[aIndex],1,6)+' '+
  //                                    trim(Copy(edt_nomecliente.Text,1,30));
end;

end.

