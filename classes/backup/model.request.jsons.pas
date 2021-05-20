unit model.request.jsons;

{$mode delphi}

interface

uses
  Classes, SysUtils;

   Function jsonToFPJsonArray(value:string):TjsonArray;

implementation

function jsonToFPJsonArray(value: string): TjsonArray;
begin
   Result := TJSONArray(GetJSON(value));
end;



end.

