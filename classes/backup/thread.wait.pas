unit thread.wait;

{$mode delphi}

interface

uses
  Classes, SysUtils, uf_aguarde;

var fAguarde : Boolean;
  Fmsg : String;

type



  TWait = class(TThread)
   protected
     procedure Execute; override;
     Procedure AtualizaMsg;
   public
     Constructor Create(CreateSuspended : boolean);
     destructor Destroy; override;
   end;


  { TWaitProcess }

  TWaitProcess = Class
    private
        F_finalizado : boolean;
    public
       Procedure Inicia;
       Procedure Finaliza;
       Procedure msg(value:string);
       Constructor create;
  end;


implementation

{ TWaitProcess }

procedure TWaitProcess.Inicia;
var _ThreadSplash : TWait;
begin
  if F_finalizado = true then
  Begin
      F_finalizado := false;
      fAguarde:= true;


     _ThreadSplash := TWait.Create(true);
     _ThreadSplash.Start;
  end;
end;

procedure TWaitProcess.Finaliza;
begin
  fAguarde := false;
  F_finalizado := true;
end;

procedure TWaitProcess.msg(value:string);
begin
    Fmsg:= value;
end;

constructor TWaitProcess.create;
begin
  F_finalizado:= true;
end;

{ TWait }

procedure TWait.Execute;
begin
    while fAguarde do
    Begin
         with f_aguarde do
         Begin
              if _progress.Value = 100 then
                 _progress.Value:= 1;

              _progress.value := _progress.value+1;

              Synchronize(AtualizaMsg);
         end;
    end;
end;

procedure TWait.AtualizaMsg;
begin
  f_aguarde.lblMSG.Caption:= FMsg;
  f_aguarde.lblMSG.Repaint;
  f_aguarde.Panel1.Repaint;
end;


constructor TWait.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := true;
  fAguarde := true;
  f_aguarde.Show;
  inherited Create(CreateSuspended);
end;

destructor TWait.Destroy;
begin
  f_aguarde.Close;
  inherited Destroy;
end;

end.

