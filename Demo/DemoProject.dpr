program DemoProject;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Localization in '..\Localization.pas',
  ProcedureHook in '..\ProcedureHook.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
