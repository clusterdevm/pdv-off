unit uf_download;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls,ACBrBase, ACBrDownload, ACBrDownloadClass, blcksock;

type

  { Tf_download }

  Tf_download = class(TForm)
    fACBrDownload: TACBrDownload;
    lConnectionInfo: TLabel;
    ProgressBar1: TProgressBar;
    procedure fACBrDownloadAfterDownload(Sender: TObject);
    procedure fACBrDownloadHookMonitor(Sender: TObject;
      const BytesToDownload: Integer; const BytesDownloaded: Integer;
      const AverageSpeed: Double; const Hour: Word; const Min: Word;
      const Sec: Word);
    procedure fACBrDownloadHookStatus(Sender: TObject;
      Reason: THookSocketReason; const BytesToDownload: Integer;
      const BytesDownloaded: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
        var _Diretorio, _NomeFile, _Url : string;
  public
      Sucesso : boolean;
  end;

var
  f_download: Tf_download;

implementation

{$R *.lfm}

{ Tf_download }

procedure Tf_download.fACBrDownloadHookMonitor(Sender: TObject;
  const BytesToDownload: Integer; const BytesDownloaded: Integer;
  const AverageSpeed: Double; const Hour: Word; const Min: Word; const Sec: Word
  );
var
  sConnectionInfo: string;
begin
  ProgressBar1.Position := BytesDownloaded;

  sConnectionInfo := sConnectionInfo + '  -  ' +
                     Format('%.2d:%.2d:%.2d', [Sec div 3600, (Sec div 60) mod 60, Sec mod 60]);

  sConnectionInfo := FormatFloat('0.00 KB/s'  , AverageSpeed) + sConnectionInfo;
  sConnectionInfo := FormatFloat('###,###,##0', BytesDownloaded / 1024) + ' / ' +
                     FormatFloat('###,###,##0', BytesToDownload / 1024) +' KB  -  ' + sConnectionInfo;

  lConnectionInfo.Caption := sConnectionInfo;

end;

procedure Tf_download.fACBrDownloadAfterDownload(Sender: TObject);
var _fileOld :String;
begin
  if fACBrDownload.DownloadStatus = stDownload then
  Begin
      ProgressBar1.Position := ProgressBar1.Max;

      {$IFDEF MSWINDOWS}
         _Diretorio := _Diretorio + '\';
         _fileOld := 'pdv.exe';
      {$else}
         _Diretorio := _Diretorio + '/';
         _fileOld := 'pdv';
      {$ENDIF}

      if FileExists(_Diretorio+_NomeFile) then
      Begin
          sucesso := true;

          if FileExists(_Diretorio+'old_'+_fileOld) then
             DeleteFile(_Diretorio+'old_'+_fileOld);

          RenameFile(_Diretorio+_fileOld,
                     _Diretorio+'old_'+_fileOld);

          if not FileExists(_Diretorio+_fileOld) then
             RenameFile(_Diretorio+_NomeFile,_Diretorio+_fileOld);
      end;

      Self.Close;
  end;
end;

procedure Tf_download.fACBrDownloadHookStatus(Sender: TObject;
  Reason: THookSocketReason; const BytesToDownload: Integer;
  const BytesDownloaded: Integer);
begin
  case Reason of
    HR_Connect :
    begin
      ProgressBar1.Position := 0;
    end;
    HR_ReadCount :
    begin
      ProgressBar1.Max        := BytesToDownload;
      ProgressBar1.Position   := BytesDownloaded;
//       lConnectionInfo.Caption := 'Baixando...';
    end;
    HR_SocketClose :
    begin
      case fACBrDownload.DownloadStatus of
        stStop :
        begin
          ProgressBar1.Position  := 0;
          lConnectionInfo.Caption := 'Download Encerrado...';
        end;

        stPause :
          lConnectionInfo.Caption := 'Download Pausado...';

        stDownload :
//           lConnectionInfo.Caption := 'Download Finalizado.';

      end;
    end;
  end;
end;

procedure Tf_download.FormActivate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
     _Diretorio := extractfiledir(paramstr(0));
    _NomeFile := 'new_pdv.exe';
    _Url := 'http://www.clustersistemas.com.br/download/new_pdv.exe';
  {$else}
     _Diretorio := extractfiledir(paramstr(0));
     _NomeFile := 'new_pdv';
     _Url := 'http://www.clustersistemas.com.br/download/new_pdv';
  {$ENDIF}

  fACBrDownload.DownloadDest    := _Diretorio;
  fACBrDownload.DownloadNomeArq := _NomeFile;
  fACBrDownload.DownloadUrl     := _Url;
  fACBrDownload.StartDownload;

end;

procedure Tf_download.FormShow(Sender: TObject);
begin

end;


procedure Tf_download.Timer1Timer(Sender: TObject);
Begin

end;

end.

