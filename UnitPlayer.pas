unit UnitPlayer;

interface

procedure GameOverPlayer;
procedure ClearPlayer;
procedure EatApplePlayer;
procedure CheckForLosePlayer;
procedure GamePlayPlayer;
procedure MoveSnakePlayer;
procedure SpawnHeadPlayer;
procedure StopPlayer;

implementation

Uses
   SysUtils, UnitGame, UnitMain, Classes, Vcl.Dialogs, UnitBot;

procedure GameOverPlayer;
var
   i: Integer;
   GameOverTxt: String;
begin
   Form1.TimerPlayer.Enabled := False;
   Form1.TimerBot.Enabled := False;
   StopBot;
   GameOverTxt := 'Game Over' + #10#13 + 'Your score = ' + IntToStr(Score);
   MessageDlg(GameOverTxt, mtCustom, [mbOK], 0);
   ClearPlayer;
   Form1.NewGame;
end;

procedure ClearPlayer;
var
   i: Integer;
begin
   AHead.Free;
   AApple.Free;
   for i := 1 to SnakeLen do
      ATails[i].Free;
   for i := 1 to BoxNum do
      ABoxs[i].Free;
end;

procedure EatApplePlayer;
begin
   Inc(Score);
   Form1.LabelPoint.Caption := IntToStr(Score);
   SpawnApple;
   Inc(SnakeLen);
   ATails[SnakeLen] := TTail.Create(ATails[SnakeLen - 1].GetX, ATails[SnakeLen - 1].GetY, TailPic);
   if Form1.TimerPlayer.Interval > 55 then
      Form1.TimerPlayer.Interval := Form1.TimerPlayer.Interval - 5;
end;

procedure CheckForLosePlayer;
var
   i: Integer;
begin
   for i := 1 to SnakeLen do
      if (AHead.GetX = ATails[i].GetX) and (AHead.GetY = ATails[i].GetY) then
         GameOverPlayer;
   for i := 1 to BoxNum do
      if (AHead.GetX = ABoxs[i].GetX) and (AHead.GetY = ABoxs[i].GetY) then
         GameOverPlayer;
   for i := 1 to SnakeLenBot do
      if (AHead.GetX = ATailsBot[i].GetX) and (AHead.GetY = ATailsBot[i].GetY) then
         GameOverPlayer;
end;

procedure GamePlayPlayer;
var
   i: Integer;
   Valid: Boolean;
begin
   if (AHead.GetX = AApple.GetX) and (AHead.GetY = AApple.GetY) then
      EatApplePlayer;

   if AHead.GetX < 0 then
      AHead.SetX(19 * 24);
   if AHead.GetY < 0 then
      AHead.SetY(19 * 24);
   if AHead.GetX >= 20 * 24 then
      AHead.SetX(0);
   if AHead.GetY >= 20 * 24 then
      AHead.SetY(0);

   CheckForLosePlayer;
end;

procedure MoveSnakePlayer;
var
   i: Integer;
begin
   for i := SnakeLen downto 2 do
   begin
      ATails[i].SetX(ATails[i - 1].GetX);
      ATails[i].SetY(ATails[i - 1].GetY);
   end;
   ATails[i].SetX(AHead.GetX);
   ATails[i].SetY(AHead.GetY);

   if Dir = 'Down' then
      AHead.SetY(AHead.GetY + 24);
   if Dir = 'Up' then
      AHead.SetY(AHead.GetY - 24);
   if Dir = 'Left' then
      AHead.SetX(AHead.GetX - 24);
   if Dir = 'Right' then
      AHead.SetX(AHead.GetX + 24);
end;

procedure SpawnHeadPlayer;
var
   Valid: Boolean;
   i: Integer;
begin
   repeat
      Valid := True;
      AHead.SetX(random(20) * 24);
      AHead.SetY(random(20) * 24);
      for i := 1 to BoxNum do
         if (AHead.GetX = ABoxs[i].GetX) and (AHead.GetY = ABoxs[i].GetY) then
            Valid := False;
   until Valid;
end;

procedure StopPlayer;
var
   i: Integer;
begin
   AHead.SetX(999);
   for i := 1 to SnakeLen do
      ATails[i].SetX(999);
   Form1.TimerPlayer.Enabled := False;
end;

end.
