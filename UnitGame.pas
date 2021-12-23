unit UnitGame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UnitMain, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.StdCtrls, UnitBot;

type
   TArr = array of Integer;
  TForm1 = class(TForm)
    TimerPlayer: TTimer;
    MainMenu1: TMainMenu;
    Game1: TMenuItem;
    Respawn: TMenuItem;
    Level: TMenuItem;
    Level1: TMenuItem;
    Level2: TMenuItem;
    Level3: TMenuItem;
    Level4: TMenuItem;
    Info: TMenuItem;
    LabelScore: TLabel;
    LabelPoint: TLabel;
    TimerBot: TTimer;
    LabelScoreBot: TLabel;
    LabelPointBot: TLabel;
    Mode1: TMenuItem;
    PlayerandBot: TMenuItem;
    OnlyBot: TMenuItem;
    OnlyPlayer: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TimerPlayerTimer(Sender: TObject);
    procedure NewGame;
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReadMap(Path: String);
    procedure RespawnClick(Sender: TObject);
    procedure Level2Click(Sender: TObject);
    procedure Level3Click(Sender: TObject);
    procedure Level4Click(Sender: TObject);
    procedure Level1Click(Sender: TObject);
    procedure InfoClick(Sender: TObject);
    procedure TimerBotTimer(Sender: TObject);
    procedure GamePause;
    procedure GameStart;
    procedure PlayerandBotClick(Sender: TObject);
    procedure OnlyBotClick(Sender: TObject);
    procedure OnlyPlayerClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure SpawnApple;

var
  Form1: TForm1;
  SnakeLen, BoxNum, Score, Min, SnakeLenBot, ScoreBot, PlayerSpeed, BotSpeed: Integer;
  AHeadBot, AHead: THead;
  ATailsBot, ATails: array [1..500] of TTail;
  DirBot, Map, Dir, NextDirCol: String;
  AApple: TApple;
  ABoxs: array[1..100] of TBox;
  HeadPic, ApplePic, TailPic, BoxPic, HeadBotPic, TailBotPic: TBitmap;
  WayX, WayY: TArr;
  Flag, LoseFlag, CheckFlag, NextFlag, ModeFlag, PlayerAndBotFlag, OnlyBotFlag, OnlyPlayerFlag: Boolean;
  MyFile: File of String[30];
  S: String[30];
  Field: TMatrix;

implementation

Uses
   UnitPlayer;

{$R *.dfm}

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := MessageDlg('Вы уверены, что хотите выйти из программы?' +
      #10#13 + 'Все несохраненные данные будут утеряны.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   DoubleBuffered := True;
   Color := ClWhite;
   Width := 20 * 24 + 6;
   Height := 23 * 24 - 12;
   Map := 'lvl-1.txt';
   PlayerAndBotFlag := True;
   OnlyBotFlag := False;
   OnlyPlayerFlag := False;

   HeadPic := TBitmap.Create;
   HeadPic.LoadFromFile('yellow.bmp');
   ApplePic := TBitmap.Create;
   ApplePic.LoadFromFile('red.bmp');
   TailPic := TBitmap.Create;
   TailPic.LoadFromFile('green.bmp');
   BoxPic := TBitmap.Create;
   BoxPic.LoadFromFile('box.bmp');

   HeadBotPic := TBitmap.Create;
   HeadBotPic.LoadFromFile('green.bmp');
   TailBotPic := TBitmap.Create;
   TailBotPic.LoadFromFile('yellow.bmp');

   NewGame;
end;

procedure TForm1.GamePause;
begin
   TimerPlayer.Enabled := False;
   TimerBot.Enabled := False;
   MessageDlg('Game paused, click "OK" to continue', mtCustom, [mbOK], 0);
   TimerPlayer.Enabled := True;
   if not LoseFlag then
      TimerBot.Enabled := True;
end;

procedure TForm1.GameStart;
begin
   Dir := 'Down';
   DirBot := 'Down';
   if PlayerAndBotFlag then
   begin
      PlayerSpeed := 300;
      BotSpeed := 300;
   end;
   if OnlyBotFlag then
   begin
      PlayerSpeed := 0;
      BotSpeed := 55;
   end;
   if OnlyPlayerFlag then
   begin
      PlayerSpeed := 300;
      BotSpeed := 0;
   end;
   TimerPlayer.Enabled := True;
   TimerPlayer.Interval := PlayerSpeed;
   TimerBot.Enabled := True;
   TimerBot.Interval := BotSpeed;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = VK_LEFT) and (Dir <> 'Right') then
      Dir := 'Left';
   if (Key = VK_RIGHT) and (Dir <> 'Left') then
      Dir := 'Right';
   if (Key = VK_UP) and (Dir <> 'Down') then
      Dir := 'Up';
   if (Key = VK_DOWN) and (Dir <> 'Up') then
      Dir := 'Down';

   if Key = VK_ESCAPE then
      GamePause;
   if (Key = VK_RETURN) and (Dir = '') then
      GameStart;
end;

procedure TForm1.FormPaint(Sender: TObject);
var
   i: Integer;
begin
   if OnlyPlayerFlag or PlayerAndBotFlag then
   begin
      Canvas.Draw(AHead.GetX, AHead.GetY, AHead.GetBitmap);
      for i := 1 to SnakeLen do
         Canvas.Draw(ATails[i].GetX, ATails[i].GetY, ATails[i].GetBitmap);
   end;

   if OnlyBotFlag or PlayerAndBotFlag then
   begin
      for i := 1 to SnakeLenBot do
         Canvas.Draw(ATailsBot[i].GetX, ATailsBot[i].GetY, ATailsBot[i].GetBitmap);
      Canvas.Draw(AHeadBot.GetX, AHeadBot.GetY, AHeadBot.GetBitmap);
   end;
   Canvas.Draw(AApple.GetX, AApple.GetY, AApple.GetBitmap);
   for i := 1 to BoxNum do
      Canvas.Draw(ABoxs[i].GetX, ABoxs[i].GetY, ABoxs[i].GetBitmap);
end;

procedure SpawnApple;
var
   i: Integer;
   Valid: Boolean;
begin
   randomize;
      repeat
         Valid := True;
         AApple.SetX(random(18) * 24 + 24);
         AApple.SetY(random(18) * 24 + 24);
         for i := 1 to BoxNum do
            if (AApple.GetX = ABoxs[i].GetX) and (AApple.GetY = ABoxs[i].GetY) then
               Valid := False;
         for i := 1 to SnakeLen do
            if (AApple.GetX = ATails[i].GetX) and (AApple.GetY = ATails[i].GetY) then
               Valid := False;
         for i := 1 to SnakeLenBot do
            if (AApple.GetX = ATailsBot[i].GetX) and (AApple.GetY = ATailsBot[i].GetY) then
               Valid := False;
         if (AApple.GetX = AHead.GetX) and (AApple.GetY = AHead.GetY) then
            Valid := False;
         if (AApple.GetX = AHeadBot.GetX) and (AApple.GetY = AHeadBot.GetY) then
            Valid := False;
      until Valid;
   for i := 1 to 30 do
      s[i] := ' ';
   S := 'Apple spawned in ' + IntToStr(AApple.GetX) + ' ' + IntToStr(AApple.GetY) + #10#13;
   Write(MyFile, S);
end;

procedure TForm1.InfoClick(Sender: TObject);
var
   InfoText: String;
   FlagPlayer, FlagBot: Boolean;
begin
   InfoText := 'Press ENTER to START game' + #10#13 + 'Press ESC to PAUSE' + #10#13;
   InfoText := InfoText + 'Разработал Пестунов Илья, гр. 051007, в рамках курсового проекта';
   FlagPlayer := False;
   FlagBot := False;
   if TimerPlayer.Enabled = False then
      FlagPlayer := True;
   if TimerBot.Enabled = False then
      FlagBot := True;
   TimerPlayer.Enabled := False;
   TimerBot.Enabled := False;
   MessageDlg(InfoText, mtInformation, [mbOK], 0);
   if not(FlagPlayer) then
      TimerPlayer.Enabled := True;
   if not(LoseFlag) then
      if not(FlagBot) then
         TimerBot.Enabled := True;
end;

procedure TForm1.Level1Click(Sender: TObject);
begin
   TimerPlayer.Enabled := False;
   ClearPlayer;
   ClearBot;
   Map := 'lvl-1.txt';
   NewGame;
end;

procedure TForm1.Level2Click(Sender: TObject);
begin
   TimerPlayer.Enabled := False;
   ClearPlayer;
   ClearBot;
   Map := 'lvl-2.txt';
   NewGame;
end;

procedure TForm1.Level3Click(Sender: TObject);
begin
   TimerPlayer.Enabled := False;
   ClearPlayer;
   ClearBot;
   Map := 'lvl-3.txt';
   NewGame;
end;

procedure TForm1.Level4Click(Sender: TObject);
begin
   TimerPlayer.Enabled := False;
   ClearPlayer;
   ClearBot;
   Map := 'lvl-4.txt';
   NewGame;
end;

procedure TForm1.NewGame;
var
   i: Integer;
   Valid: Boolean;
begin
   AssignFile(MyFile, 'log.txt');
   Rewrite(MyFile);
   Reset(MyFile);
   TimerPlayer.Enabled := False;
   TimerBot.Enabled := False;
   LoseFlag := False;
   Flag := False;
   Score := 0;
   ScoreBot := 0;
   LabelPoint.Caption := IntToStr(Score);
   LabelPointBot.Caption := IntToStr(Score);
   ReadMap(Map);
   AApple := TApple.Create(random(18) * 24 + 24, random(18) * 24 + 24, ApplePic);

   AHead := THead.Create(random(20) * 24, random(20) * 24, HeadPic);
   SpawnHeadPlayer;
   SnakeLen := 2;
   ATails[1] := TTail.Create(AHead.GetX, AHead.GetY - 24, TailPic);
   ATails[2] := TTail.Create(AHead.GetX, AHead.GetY - 48, TailPic);

   AHeadBot := THead.Create(random(20) * 24, random(20) * 24, HeadBotPic);
   SpawnHeadBot;
   SnakeLenBot := 2;
   ATailsBot[1] := TTail.Create(AHeadBot.GetX, AHeadBot.GetY - 24, TailBotPic);
   ATailsBot[2] := TTail.Create(AHeadBot.GetX, AHeadBot.GetY - 48, TailBotPic);

   SpawnApple;

   DirBot := '';
   Dir := '';
   Repaint;
end;

procedure TForm1.OnlyBotClick(Sender: TObject);
begin
   StopPlayer;
   PlayerAndBotFlag := False;
   OnlyBotFlag := True;
   OnlyPlayerFlag := False;
   NewGame;
end;

procedure TForm1.OnlyPlayerClick(Sender: TObject);
begin
   StopBot;
   PlayerAndBotFlag := False;
   OnlyBotFlag := False;
   OnlyPlayerFlag := True;
   NewGame;
end;

procedure TForm1.PlayerAndBotClick(Sender: TObject);
begin
   ClearPlayer;
   ClearBot;
   PlayerAndBotFlag := True;
   OnlyBotFlag := False;
   OnlyPlayerFlag := False;
   NewGame;
end;

procedure TForm1.RespawnClick(Sender: TObject);
begin
   TimerPlayer.Enabled := False;
   TimerBot.Enabled := False;
   ClearPlayer;
   ClearBot;
   NewGame;
end;

procedure TForm1.ReadMap(Path: String);
var
   i, j: Integer;
   MyFile: TextFile;
   Cell: Char;
begin
   AssignFile(MyFile, Path);
   Reset(MyFile);
   BoxNum := 0;
   for i := 1 to 20 do
   begin
      for j := 1 to 20 do
      begin
         Read(MyFile, Cell);
         if Cell = '#' then
         begin
            Inc(BoxNum);
            ABoxs[BoxNum] := TBox.Create((j - 1) * 24, (i - 1) * 24, BoxPic);
         end;
      end;
      Readln(MyFile);
   end;
   CloseFile(MyFile);
end;

procedure TForm1.TimerBotTimer(Sender: TObject);
begin
   MoveSnakeBot;
   GamePlayBot;
   Repaint;
end;

procedure TForm1.TimerPlayerTimer(Sender: TObject);
begin
   MoveSnakePlayer;
   GamePlayPlayer;
   Repaint;
end;

end.
