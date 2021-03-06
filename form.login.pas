unit form.login;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, LazHelpHTML, BCSVGButton, BCMDButton, BCButton, inifiles,
  BCImageButton, ZSqlProcessor, ems.utils, model.sinc.down, model.login,
  form.principal, TypInfo, SQLDBWebData, fphttpclient, wcursos, LCLIntf, Menus,
  ssockets, SQLDB, SQLite3Conn, DateUtils;

type

  { Tfrm_login }

  Tfrm_login = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    btLogar: TBCMDButton;
    edtSenha: TEdit;
    edtEmail: TEdit;
    edtApelido: TEdit;
    FPHTTPClient1: TFPHTTPClient;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lblRecuperaSenha: TLabel;
    Label4: TLabel;
    lblApelido: TLabel;
    mProcesso: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pnlRegistro: TPanel;
    SQLConnector1: TSQLConnector;
    Timer1: TTimer;
    procedure ApplicationProperties1Exception(Sender: TObject; E: Exception);
    procedure btLogarClick(Sender: TObject);
    procedure edtSenhaKeyPress(Sender: TObject; var Key: char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblRecuperaSenhaClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
     _statusGlobal : String;
     _cronometro : integer;
     CompAnt : TEdit;
     Procedure checaStatus;
     procedure ControlChange(Sender: TObject);
  public

  end;

var
  frm_login: Tfrm_login;

implementation

uses cluster_pdv.sessao, thread.wait, ems.conexao;

{$R *.lfm}

{ Tfrm_login }

procedure Tfrm_login.FormCreate(Sender: TObject);
Begin
   Screen.OnActiveControlChange := ControlChange;
   Sessao := TSessao.Create;
   Sessao.segundoplano:= false;
end;

procedure Tfrm_login.FormShow(Sender: TObject);
var _conf : TIniFile;
    _file : String;
Begin
   try
     {$IFDEF MSWINDOWS}
        _file := extractfiledir(paramstr(0))+'\conf.ini';
     {$else}
        _file := extractfiledir(paramstr(0))+'/conf.ini';
     {$ENDIF}

      _conf := TIniFile.Create(_file);
      appVersao := _conf.ReadString('geral','versao','');
      appProducao := not (LowerCase(_conf.ReadString('geral','teste',''))='true');

     if DownloadAtualizacao(appVersao) then
     Begin
         _conf.WriteString('geral','versao',appVersao);

         MessageDlg('Feche a Aplica????o e Abra novamente',mtInformation,[mbok],0);
         Application.Terminate;
     end;

   finally
     FreeAndnil(_conf);
   end;

   Screen.OnActiveControlChange := ControlChange;
   ChecaStatus;

   WCursor := TWaitCursor.Create;

   btLogar.color := clblack;

end;

procedure Tfrm_login.lblRecuperaSenhaClick(Sender: TObject);
begin
    //frmPrincipal := TfrmPrincipal.Create(nil);
    //frm_login.hide;
    //frmPrincipal.Show;
end;

procedure Tfrm_login.btLogarClick(Sender: TObject);
var objeto : TClassLogin;
    _sincronizar : TSincDownload;
 _db : TConexao;
begin

     try
       objeto := TClassLogin.Create;
       objeto.email := edtEmail.text;
       objeto.senha := edtSenha.text;
       objeto.apelido := edtApelido.text;
       Sessao.usuario := edtEmail.Text;
       Sessao.senha := edtSenha.Text;
       if edtApelido.visible then
       Begin
            if trim(edtApelido.Text) = '' then
            Begin
                 Messagedlg('Informe um apelido para este equipamento',mtError,[mbok],0);
                 exit;
            end;


            objeto.enviarRegistro;
            checaStatus;
       end else
       Begin

           if objeto.Primeiro_log then
           Begin
              try
                 WCursor.SetWait;
                 pnlRegistro.color := clblue;
                 pnlRegistro.Font.Size:= 10;
                 pnlRegistro.Enabled:= true;
                 pnlRegistro.visible:= false;

                 mProcesso.Visible:= true;
                 mProcesso.Lines.Clear;
                 mProcesso.Lines.Add('Iniciando Download');
                 Sessao.segundoplano := false;

                 btLogar.Enabled:=false;

                 _sincronizar := TSincDownload.Create(true,
                                                nil ,
                                                objeto.token_remoto,
                                                mProcesso
                                              );
                 _sincronizar.Start;

                 while not _sincronizar.Finished do
                     Application.ProcessMessages;


                 objeto.SetPrimeiroLogFalse;
                 if Assigned(_sincronizar.FatalException) then
                 Begin
                      Showmessage('Aplica????o Sera Finalizada');
                      Application.Terminate;
                      Abort;
                 end;


              finally
                   WCursor.SetNormal;
                   mProcesso.Clear;
                   mProcesso.Visible := false;
                   pnlRegistro.color := clDefault;
              end;
           end;

           Sessao.token  := objeto.token_remoto;

           if objeto.logar then
           Begin
                frmPrincipal := TfrmPrincipal.Create(nil);
                frm_login.Hide;
                Sessao.segundoplano := true;

                {$IFDEF MSWINDOWS}
                   frmPrincipal.Show;
                {$else}
                   frmPrincipal.ShowModal;
                {$ENDIF}
           end;
       end;

     finally
       FreeAndNil(Objeto);
       //pnlRegistro.visible:= false;
       pnlRegistro.Font.Size:= 20;
       btLogar.Enabled:=true;
     end;
end;

procedure Tfrm_login.edtSenhaKeyPress(Sender: TObject; var Key: char);
begin
   if key = #13 then
   Begin
         btLogarClick(self);
   end;
end;

procedure Tfrm_login.ApplicationProperties1Exception(Sender: TObject;
  E: Exception);
begin
  MessageDlg('Exception '+E.ClassName+' gerado',E.Message, mtError, [mbOK], 0);
end;

procedure Tfrm_login.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Screen.OnActiveControlChange := Nil;
end;

procedure Tfrm_login.Timer1Timer(Sender: TObject);
begin
   Dec(_cronometro);
   pnlRegistro.Caption:= _statusGlobal + ' ('+Inttostr(_cronometro)+')';
end;

procedure Tfrm_login.checaStatus;
var objeto : TClassLogin;

begin
try
   objeto := TClassLogin.Create;
  timer1.enabled := false;
  _cronometro:= 5;
  edtApelido.Visible:=false;
  lblApelido.Visible:= false;
  pnlRegistro.Visible:= false;

  Panel2.Height := 120;

  btLogar.Top:= 378;
  lblRecuperaSenha.Top:= 430;
  _statusGlobal:='N??o Registrado!';

  if not objeto.checaStatusRegistro then
  Begin
     pnlRegistro.Caption:='N??o Registrado!';
     pnlRegistro.Visible := true;
     lblApelido.Visible:= true;
     edtApelido.Visible:= true;

     Panel2.Height := 170;

     btLogar.Top:= 432;
     lblRecuperaSenha.Top:= 480;
  end else
  Begin
      _statusGlobal :=  objeto.status;
      if objeto.status = 'Aguardando libera????o' then
      Begin
           pnlRegistro.Caption:= _statusGlobal;
           pnlRegistro.Visible := true;
           timer1.Enabled:=true;
      end else
      if objeto.status = 'PDV bloqueado' then
      Begin
           pnlRegistro.Caption:= _statusGlobal;
           pnlRegistro.Visible := true;
           timer1.Enabled:=true;
      end else
      if objeto.status = 'PDV Cancelado' then
      Begin
           pnlRegistro.Caption:= _statusGlobal;
           pnlRegistro.Visible := true;
      end;
  end;

finally
  FreeAndNil(objeto);
end;

end;

procedure Tfrm_login.ControlChange(Sender: TObject);
begin
   if Assigned(CompAnt) then begin
   CompAnt.Color := clWindow;
   CompAnt.Font.Color := clWindowText;
   end;
   if (ActiveControl is TEdit) or
   (ActiveControl is TMemo)
   //(ActiveControl is TMaskEdit)
   // (ActiveControl is TMaskEdit) or
   //(ActiveControl is TDBEdit) or
   //(ActiveControl is TDBMemo)
   // (ActiveControl is TDateTimePicker)
   then begin
      //TEdit(ActiveControl).Color := $00E6E0B0;
      // TEdit(ActiveControl).Font.Color := clBlack;
      //CompAnt := TEdit(ActiveControl);
   end else CompAnt := nil;
   //if (ActiveControl is TDBLookupComboBox) then
   //TDBLookupComboBox(ActiveControl).DroppedDown:=True;
end;




end.

