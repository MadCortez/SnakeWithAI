unit UnitBot;

interface

Type
   TMatrix = array of array of Integer;

procedure StopBot;
procedure ClearBot;
procedure GameOverBot;
procedure EatAppleBot;
procedure CheckForLoseBot;
procedure GamePlayBot;
procedure RetWay(b: TMatrix);
function FillField(): TMatrix;
procedure CalcDir(x, y, Step: Integer; b: TMatrix; LocDir, LastLocDir: String);
procedure CheckNext(LocDir: String);
procedure CheckWay(LocDir: String);
procedure CheckNextWay(LocDir: String);
function RetDir(): String;
function Check180(NextDir: String): String;
procedure CheckNextWayField(x, y, Num: Integer);
function CheckDown: String;
function CheckUp: String;
function CheckLeft: String;
function CheckRight: String;
procedure CheckDownAndUp;
procedure CheckLeftAndRight;
procedure MoveSnakeBot;
procedure SpawnHeadBot;

implementation

Uses
   SysUtils, UnitGame, UnitMain, UnitPlayer;

procedure StopBot;
var
   i: Integer;
begin
   AHeadBot.SetX(999);
   for i := 1 to SnakeLenBot do
      ATailsBot[i].SetX(999);
   LoseFlag := True;
   Form1.TimerBot.Enabled := False;
end;

procedure ClearBot;
var
   i: Integer;
begin
   AHeadBot.Free;
   for i := 1 to SnakeLen do
      ATailsBot[i].Free;
end;

procedure GameOverBot;
var
   i: Integer;
   GameOverTxt: String;
begin
   Form1.TimerBot.Enabled := False;
   StopBot;
end;

procedure EatAppleBot;
var
   i: Integer;
begin
   Inc(ScoreBot);
   Form1.LabelPointBot.Caption := IntToStr(ScoreBot);
   for i := 1 to 30 do
      s[i] := ' ';
   S := 'Bot eat apple in ' + IntToStr(AHeadBot.GetX) + ' ' + IntToStr(AHeadBot.GetY) + #10#13;
   Write(MyFile, S);
   SpawnApple;
   Inc(SnakeLenBot);
   ATailsBot[SnakeLenBot] := TTail.Create(ATailsBot[SnakeLenBot - 1].GetX, ATailsBot[SnakeLenBot - 1].GetY, TailBotPic);
   if Form1.TimerBot.Interval > 55 then
      Form1.TimerBot.Interval := Form1.TimerBot.Interval - 5;
end;

procedure CheckForLoseBot;
var
   i, j: Integer;
begin
   for i := 1 to SnakeLenBot do
      if (AHeadBot.GetX = ATailsBot[i].GetX) and (AHeadBot.GetY = ATailsBot[i].GetY) then
         GameOverBot;
   for i := 1 to BoxNum do
      if (AHeadBot.GetX = ABoxs[i].GetX) and (AHeadBot.GetY = ABoxs[i].GetY) then
         GameOverBot;
   for i := 1 to SnakeLen do
      for j := 1 to SnakeLen do
         if (AHeadBot.GetX = ATails[i].GetX) and (AHeadBot.GetY = ATails[i].GetY) then
            GameOverBot;
end;

procedure GamePlayBot;
var
   i, j: Integer;
   Valid: Boolean;
begin
   if (AHeadBot.GetX = AApple.GetX) and (AHeadBot.GetY = AApple.GetY) then
      EatAppleBot;

   if AHeadBot.GetX < 0 then
      AHeadBot.SetX(19 * 24);
   if AHeadBot.GetY < 0 then
      AHeadBot.SetY(19 * 24);
   if AHeadBot.GetX >= 20 * 24 then
      AHeadBot.SetX(0);
   if AHeadBot.GetY >= 20 * 24 then
      AHeadBot.SetY(0);

   CheckForLoseBot;
end;

procedure RetWay(b: TMatrix);
var
   x, y, Step: Integer;
begin
   x := AApple.GetX div 24;
   y := AApple.GetY div 24;
   Step := b[x, y];
   SetLength(WayX, Step);
   SetLength(WayY, Step);
   Dec(Step);
   WayX[Step] := x;
   WayY[Step] := y;
   while Step > 0 do
   begin
      Inc(x);
      if (x >= 20) then
         x := 0;
      if b[x, y] = Step then
      begin
         Dec(Step);
         WayX[Step] := x;
         WayY[Step] := y;
         continue;
      end;
      Dec(x);
      if (x < 0) then
         x := 19;
      Dec(x);
      if (x < 0) then
         x := 19;
      if b[x, y] = Step then
      begin
         Dec(Step);
         WayX[Step] := x;
         WayY[Step] := y;
         continue;
      end;
      Inc(x);
      if (x >= 20) then
         x := 0;
      Dec(y);
      if (y < 0) then
         y := 19;
      if b[x, y] = Step then
      begin
         Dec(Step);
         WayX[Step] := x;
         WayY[Step] := y;
         continue;
      end;
      Inc(y);
      if (y >= 20) then
         y := 0;
      Inc(y);
      if (y >= 20) then
         y := 0;
      if b[x, y] = Step then
      begin
         Dec(Step);
         WayX[Step] := x;
         WayY[Step] := y;
         continue;
      end;
      Dec(y);
      if (y < 0) then
         y := 19;
   end;
end;

function FillField(): TMatrix;
var
   i: Integer;
   a: TMatrix;
begin
   SetLength(a, 22, 22);
   for i := 1 to BoxNum do
      a[ABoxs[i].GetX div 24, ABoxs[i].GetY div 24] := -1;
   for i := 1 to SnakeLen do
      a[ATails[i].GetX div 24, ATails[i].GetY div 24] := -1;
   for i := 1 to SnakeLenBot do
      a[ATailsBot[i].GetX div 24, ATailsBot[i].GetY div 24] := -1;
   a[AHead.GetX div 24, AHead.GetY div 24] := -1;
   Result := a;
end;

procedure CalcDir(x, y, Step: Integer; b: TMatrix; LocDir, LastLocDir: String);
var
   AppleX, AppleY, HeadX, HeadY, i: Integer;
   a: TMatrix;
begin
   if Flag then
      exit;

   if (x < 0) or (x > 20) or (y < 0) or (y > 20) then
      exit;


   if (LocDir = 'Right') and (LastLocDir = 'Left') then
      exit;
   if (LocDir = 'Left') and (LastLocDir = 'Right') then
      exit;
   if (LocDir = 'Down') and (LastLocDir = 'Up') then
      exit;
   if (LocDir = 'Up') and (LastLocDir = 'Down') then
      exit;

   SetLength(a, 22, 22);
   SetLength(b, 22, 22);
   a := FillField;

   if b[x, y] <> 0 then exit;

   b[x, y] := Step;

   AppleX := AApple.GetX div 24;
   AppleY := AApple.GetY div 24;
   if (x = AppleX) and (y = AppleY) then
   begin
      if Step < min then
      begin
         RetWay(b);
         Min := Step;
         Flag := True;
      end;
      exit;
   end;

   if (AppleX > x) and (LocDir <> 'Left') then
      CalcDir(x + 1, y, Step + 1, b, 'Right', LocDir);
   if (AppleX < x) and (LocDir <> 'Right') then
      CalcDir(x - 1, y, Step + 1, b, 'Left', LocDir);
   if (AppleY > y) and (LocDir <> 'Up') then
      CalcDir(x, y + 1, Step + 1, b, 'Down', LocDir);
   if (AppleY < y) and (LocDir <> 'Down') then
      CalcDir(x, y - 1, Step + 1, b, 'Up', LocDir);

end;

procedure CheckNext(LocDir: String);
var
   i, AHeadX, AHeadY: Integer;
begin
   if CheckFlag then
      exit;
   AHeadX := AHeadBot.GetX;
   AHeadY := AHeadBot.GetY;
   if LocDir = 'Left' then
      Dec(AHeadX, 24);
   if LocDir = 'Right' then
      Inc(AHeadX, 24);
   if LocDir = 'Up' then
      Dec(AHeadY, 24);
   if LocDir = 'Down' then
      Inc(AHeadY, 24);
   for i := 1 to BoxNum do
      if (AHeadX = ABoxs[i].GetX) and (AHeadY = ABoxs[i].GetY) then
         exit;
   for i := 1 to SnakeLenBot do
      if (AHeadX = ATailsBot[i].GetX) and (AHeadY = ATailsBot[i].GetY) then
         exit;
   for i := 1 to SnakeLen do
      if (AHeadX = ATails[i].GetX) and (AHeadY = ATails[i].GetY) then
         exit;
   CheckFlag := True;
   NextDirCol := LocDir;
end;

procedure CheckWay(LocDir: String);
begin
   CheckFlag := False;
   if LocDir = 'Up' then
   begin
      CheckNext('Up');
      CheckNext('Left');
      CheckNext('Right');
   end;
   if LocDir = 'Down' then
   begin
      CheckNext('Down');
      CheckNext('Left');
      CheckNext('Right');
   end;
   if LocDir = 'Left' then
   begin
      CheckNext('Left');
      CheckNext('Up');
      CheckNext('Down');
   end;
   if LocDir = 'Right' then
   begin
      CheckNext('Right');
      CheckNext('Up');
      CheckNext('Down');
   end;
end;

procedure CheckNextWay(LocDir: String);
var
   i, AHeadX, AHeadY: Integer;
begin
   AHeadX := AHeadBot.GetX;
   AHeadY := AHeadBot.GetY;
   if LocDir = 'Left' then
      Dec(AHeadX, 24);
   if LocDir = 'Right' then
      Inc(AHeadX, 24);
   if LocDir = 'Up' then
      Dec(AHeadY, 24);
   if LocDir = 'Down' then
      Inc(AHeadY, 24);
   for i := 1 to BoxNum do
      if (AHeadX = ABoxs[i].GetX) and (AHeadY = ABoxs[i].GetY) then
         exit;
   for i := 1 to SnakeLenBot do
      if (AHeadX = ATailsBot[i].GetX) and (AHeadY = ATailsBot[i].GetY) then
         exit;
   for i := 1 to SnakeLen do
      if (AHeadX = ATails[i].GetX) and (AHeadY = ATails[i].GetY) then
         exit;
   NextFlag := True;
end;

function RetDir(): String;
var
   NextDir: String;
begin
   if (WayX[0] > AHeadBot.GetX div 24) and (DirBot <> 'Left') then
      NextDir := 'Right';
   if (WayX[0] < AHeadBot.GetX div 24) and (DirBot <> 'Right') then
      NextDir := 'Left';
   if (WayY[0] > AHeadBot.GetY div 24) and (DirBot <> 'Up') then
      NextDir := 'Down';
   if (WayY[0] < AHeadBot.GetY div 24) and (DirBot <> 'Down') then
      NextDir := 'Up';
   Result := NextDir;
end;

function Check180(NextDir: String): String;
begin
   if (NextDir = 'Up') and (DirBot = 'Down') then
      NextDir := 'Down';
   if (NextDir = 'Down') and (DirBot = 'Up') then
      NextDir := 'Up';
   if (NextDir = 'Right') and (DirBot = 'Left') then
      NextDir := 'Left';
   if (NextDir = 'Left') and (DirBot = 'Right') then
      NextDir := 'Right';
   Result := NextDir;
end;

procedure CheckNextWayField(x, y, Num: Integer);
begin
   if NextFlag then
      exit;
   if X < 0 then
      X := 19;
   if Y < 0 then
      Y := 19;
   if X >= 20 then
      X := 0;
   if Y >= 20 then
      Y := 0;
   if Field[x, y] = -1 then
      exit;
   Field[x, y] := -1;
   Inc(Num);
   if Num > SnakeLenBot then
   begin
      NextFlag := True;
      exit;
   end;
   CheckNextWayField(x - 1, y, Num);
   CheckNextWayField(x + 1, y, Num);
   CheckNextWayField(x, y - 1, Num);
   CheckNextWayField(x, y + 1, Num);
end;

function CheckDown: String;
var
   NextDir: String;
begin
   Field := FillField;
   CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY + 24) div 24, 0);
   if NextFlag then
      NextDir := 'Down'
   else
   begin
      Field := FillField;
      CheckNextWayField((AHeadBot.GetX + 24) div 24, AHeadBot.GetY div 24, 0);
      if NextFlag then
         NextDir := 'Right';
      if not(NextFlag) then
      begin
         Field := FillField;
         CheckNextWayField((AHeadBot.GetX - 24) div 24, AHeadBot.GetY div 24, 0);
         if NextFlag then
            NextDir := 'Left';
      end;
   end;
   Result := NextDir;
end;

function CheckUp: String;
var
   NextDir: String;
begin
   Field := FillField;
   CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY - 24) div 24, 0);
   if NextFlag then
      NextDir := 'Up'
   else
   begin
      Field := FillField;
      CheckNextWayField((AHeadBot.GetX + 24) div 24, AHeadBot.GetY div 24, 0);
      if NextFlag then
         NextDir := 'Right';
      if not(NextFlag) then
      begin
         Field := FillField;
         CheckNextWayField((AHeadBot.GetX - 24) div 24, AHeadBot.GetY div 24, 0);
         if NextFlag then
            NextDir := 'Left';
      end;
   end;
   Result := NextDir;
end;

function CheckLeft: String;
var
   NextDir: String;
begin
   Field := FillField;
   CheckNextWayField((AHeadBot.GetX - 24) div 24, AHeadBot.GetY div 24, 0);
   if NextFlag then
      NextDir := 'Left'
   else
   begin
      Field := FillField;
      CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY - 24) div 24, 0);
      if NextFlag then
         NextDir := 'Up';
      if not(NextFlag) then
      begin
         Field := FillField;
         CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY + 24) div 24, 0);
         if NextFlag then
            NextDir := 'Down';
      end;
   end;
   Result := NextDir;
end;

function CheckRight: String;
var
   NextDir: String;
begin
   Field := FillField;
   CheckNextWayField((AHeadBot.GetX + 24) div 24, AHeadBot.GetY div 24, 0);
   if NextFlag then
      NextDir := 'Right'
   else
   begin
      Field := FillField;
      CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY - 24) div 24, 0);
      if NextFlag then
         NextDir := 'Up';
      if not(NextFlag) then
      begin
         Field := FillField;
         CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY + 24) div 24, 0);
         if NextFlag then
            NextDir := 'Down';
      end;
   end;
   Result := NextDir;
end;

procedure CheckDownAndUp;
begin
   Field := FillField;
   CheckNextWayField((AHeadBot.GetX - 24) div 24, AHeadBot.GetY div 24, 0);
   if NextFlag then
      DirBot := 'Left'
   else
   begin
      Field := FillField;
      CheckNextWayField((AHeadBot.GetX + 24) div 24, AHeadBot.GetY div 24, 0);
      if NextFlag then
         DirBot := 'Right';
   end;
end;

procedure CheckLeftAndRight;
begin
   Field := FillField;
   CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY + 24) div 24, 0);
   if NextFlag then
      DirBot := 'Down'
   else
   begin
      Field := FillField;
      CheckNextWayField(AHeadBot.GetX div 24, (AHeadBot.GetY - 24) div 24, 0);
      if NextFlag then
         DirBot := 'Up';
   end;
end;

procedure MoveSnakeBot;
var
   i, HeadBotX, HeadBotY: Integer;
   a: TMatrix;
   NextDir: String;
   Label l1;
begin
   for i := SnakeLenBot downto 2 do
   begin
      ATailsBot[i].SetX(ATailsBot[i - 1].GetX);
      ATailsBot[i].SetY(ATailsBot[i - 1].GetY);
   end;
   ATailsBot[i].SetX(AHeadBot.GetX);
   ATailsBot[i].SetY(AHeadBot.GetY);

   Min := 999999;
   NextDir := DirBot;
   CalcDir(AHeadBot.GetX div 24, AHeadBot.GetY div 24, 0, 0, DirBot, '');

   NextDir := RetDir;
   NextDir := Check180(NextDir);

   if NextDir = DirBot then
   begin
      NextDirCol := NextDir;
      CheckWay(DirBot);
      NextDir := NextDirCol;
   end;

   NextFlag := False;
   if (NextDir = 'Down') then
      NextDir := CheckDown
   else
      if (NextDir = 'Up') then
         NextDir := CheckUp
      else
         if (NextDir = 'Left') then
            NextDir := CheckLeft
         else
            if (NextDir = 'Right') then
               NextDir := CheckRight;
   if NextFlag then
      DirBot := NextDir
   else
   begin
      SetLength(a, 22, 22);
      if (DirBot = 'Down') or (DirBot = 'Up') then
         CheckDownAndUp;
      if NextFlag then
         goto l1;
      if (DirBot = 'Left') or (DirBot = 'Right') then
         CheckLeftAndRight;
   end;
l1:
   for i := 0 to High(WayX) do
   begin
      WayX[i] := 0;
      WayY[i] := 0;
   end;
   Flag := False;

   if DirBot = 'Down' then
      AHeadBot.SetY(AHeadBot.GetY + 24);
   if DirBot = 'Up' then
      AHeadBot.SetY(AHeadBot.GetY - 24);
   if DirBot = 'Left' then
      AHeadBot.SetX(AHeadBot.GetX - 24);
   if DirBot = 'Right' then
      AHeadBot.SetX(AHeadBot.GetX + 24);
   for i := 1 to 30 do
      s[i] := ' ';
   S := 'Move Bot to ' + IntToStr(AHeadBot.GetX) + ' ' + IntToStr(AHeadBot.GetY) + #10#13;
   Write(MyFile, S);
end;

procedure SpawnHeadBot;
var
   Valid: Boolean;
   i: Integer;
begin
   repeat
      Valid := True;
      AHeadBot.SetX(random(20) * 24);
      AHeadBot.SetY(random(20) * 24);
      for i := 1 to BoxNum do
         if (AHeadBot.GetX = ABoxs[i].GetX) and (AHeadBot.GetY = ABoxs[i].GetY) then
            Valid := False;
      if (AHeadBot.GetX = AHead.GetX) and (AHeadBot.GetY = AHead.GetY) then
            Valid := False;
   until Valid;
end;

end.
