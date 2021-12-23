object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Snake'
  ClientHeight = 275
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object LabelScore: TLabel
    Left = 0
    Top = 0
    Width = 34
    Height = 13
    Caption = 'Score: '
  end
  object LabelPoint: TLabel
    Left = 32
    Top = 0
    Width = 6
    Height = 13
    Caption = '0'
  end
  object LabelScoreBot: TLabel
    Left = 296
    Top = 0
    Width = 50
    Height = 13
    Caption = 'ScoreBot: '
  end
  object LabelPointBot: TLabel
    Left = 352
    Top = 0
    Width = 6
    Height = 13
    Caption = '0'
  end
  object TimerPlayer: TTimer
    Enabled = False
    Interval = 300
    OnTimer = TimerPlayerTimer
    Left = 488
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 488
    Top = 56
    object Game1: TMenuItem
      Caption = 'Game'
      object Respawn: TMenuItem
        Caption = 'NewGame(ReSpawn)'
        OnClick = RespawnClick
      end
    end
    object Level: TMenuItem
      Caption = 'Level'
      object Level1: TMenuItem
        Caption = '1'
        OnClick = Level1Click
      end
      object Level2: TMenuItem
        Caption = '2'
        OnClick = Level2Click
      end
      object Level3: TMenuItem
        Caption = '3'
        OnClick = Level3Click
      end
      object Level4: TMenuItem
        Caption = '4'
        OnClick = Level4Click
      end
    end
    object Mode1: TMenuItem
      Caption = 'Mode'
      object PlayerandBot: TMenuItem
        Caption = 'Player and Bot'
        OnClick = PlayerandBotClick
      end
      object OnlyBot: TMenuItem
        Caption = 'Only Bot'
        OnClick = OnlyBotClick
      end
      object OnlyPlayer: TMenuItem
        Caption = 'Only Player'
        OnClick = OnlyPlayerClick
      end
    end
    object Info: TMenuItem
      Caption = 'Info'
      OnClick = InfoClick
    end
  end
  object TimerBot: TTimer
    Enabled = False
    Interval = 300
    OnTimer = TimerBotTimer
    Left = 384
    Top = 248
  end
end
