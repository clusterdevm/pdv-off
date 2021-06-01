unit wcursos;

{$mode delphi}

//A mousecursor hourglass/normal changer tool. Supports layered requests.
{
WCursor.SetWait     = mouse cursor as Hourglass
WCursor.SetWaitSQL  = mouse cursor as SQL Hourglass
WCursor.SetNormal   = mouse cursor as normal

example:
    WCursor.setWait;
    try
      DoSometingVerySlow;
    finally
      WCursor.setNormal;
    end;
}

interface

type
TWaitCursor = class
private
   FCursor : integer;
   FCnt : integer;
public
   constructor Create;
   destructor  Destroy; override;
   procedure   SetCursor(Index: integer);
   procedure   SetWait;
   procedure   SetWaitSQL;
   procedure   SetNormal;
end;

var
WCursor : TWaitCursor;

implementation

uses Forms, Controls;

constructor TWaitCursor.Create;
begin
inherited;
// depth is zero
FCnt := 0;

// remember default cursor
FCursor := Screen.Cursor;
end;

destructor TWaitCursor.Destroy;
begin
// Reset to default cursor
Screen.Cursor := FCursor;
inherited;
end;

procedure TWaitCursor.SetCursor(Index: integer);
begin
// select cursor
    Screen.Cursor := Index;
end;

procedure TWaitCursor.SetNormal;
begin
   SetCursor(crDefault);
end;

procedure TWaitCursor.SetWait;
begin
   SetCursor(crHourglass);
end;

procedure TWaitCursor.SetWaitSQL;
begin
// increase depth
Inc(FCnt);

// select wait cursor
SetCursor(crSQLWait);
end;

end.

