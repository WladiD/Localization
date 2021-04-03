program DemoFMXProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {MainForm},
  Localization in '..\Localization.pas',
  Localization.FMX.CommonBinding in '..\Localization.FMX.CommonBinding.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
