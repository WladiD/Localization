program DemoFMXProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  Localization in '..\Localization.pas',
  Localization.FMX.CommonBinding in '..\Localization.FMX.CommonBinding.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
