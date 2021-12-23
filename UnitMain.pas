unit UnitMain;

interface

Uses
   Classes, SysUtils, Graphics;

Type
   TBase = class
     private
      x, y: Integer;
      bitmap: TBitmap;
     public
      Constructor Create(x0, y0: Integer; bitmap0: TBitmap);

      procedure SetX(x0: Integer);
      procedure SetY(y0: Integer);
      procedure SetBitmap(bitmap0: TBitmap);

      function GetX: Integer;
      function GetY: Integer;
      function GetBitmap: TBitmap;
   end;

   TApple = class(TBase)

   end;

   THead = class(TBase)

   end;

   TTail = class(TBase)

   end;

   TBox = class(TBase)

   end;

implementation

{ TBase }

constructor TBase.Create(x0, y0: Integer; bitmap0: TBitmap);
begin
   x := x0;
   y := y0;
   bitmap := bitmap0;
end;

function TBase.GetBitmap: TBitmap;
begin
   Result := bitmap;
end;

function TBase.GetX: Integer;
begin
   Result := x;
end;

function TBase.GetY: Integer;
begin
   Result := y;
end;

procedure TBase.SetBitmap(bitmap0: TBitmap);
begin
   bitmap := bitmap0;
end;

procedure TBase.SetX(x0: Integer);
begin
   x := x0;
end;

procedure TBase.SetY(y0: Integer);
begin
   y := y0;
end;

end.
