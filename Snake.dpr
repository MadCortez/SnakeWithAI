program Snake;

uses
  Vcl.Forms,
  UnitGame in 'UnitGame.pas' {Form1},
  UnitMain in 'UnitMain.pas',
  UnitPlayer in 'UnitPlayer.pas',
  UnitBot in 'UnitBot.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
