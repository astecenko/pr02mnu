program PR02_Menu;

uses
  FastMM4,
  Fastcode,
  FastMove,
  VCLFixPack,
  Forms,
  U1 in 'U1.pas' {FormZapuskatr1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormZapuskatr1, FormZapuskatr1);
  Application.Run;
end.
