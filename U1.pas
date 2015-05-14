unit U1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, syncobjs, ExtCtrls;

//const
  //csLogDir = '\\nevz2\nevz\ASUP_Data1\BD-ASU\NET\LOG\';

type
  TFormZapuskatr1 = class(TForm)
    lst1: TListBox;
    lbl1: TLabel;
    stat1: TStatusBar;
    lbl2: TLabel;
    lbl3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lst1Click(Sender: TObject);
    procedure lst1DblClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure lst1KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure lbl4Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure lst1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbl2Click(Sender: TObject);
    procedure lbl3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Ochistka();
    procedure Indexation(); //заполнение ListBox
    function Analiz(j: Integer): Integer;
    //рекурсивное определение родительских элементов
    procedure GoToIn();
    //переход по выбору родительского элемента на следующий подуровень
    procedure GoToOut(); //выход на верхний подуровень
    procedure StartPr(); //запуск программы
    procedure HelpMsg(); //помощь
    procedure ShowParent();
    procedure Start(const s: string);
    procedure ProgramRuned(s3: string);
  end;
  Nastroiki = record
    iParent: Integer;
    iOrder: Integer;
    sText: string;
    sCmd: string;
    sType:string;
  end;
  TNastroiki = ^Nastroiki;
const
  //  csBack='[ '#171' Назад ]';
  csBack = '[ .. Назад ]';
var
  FormZapuskatr1: TFormZapuskatr1;
  pNastr: TNastroiki;
  //  lOrder, //индексы последних элементов по порядкам
  lNastr, //список настроек
  lNastrInd: TList; // список индексов настроек в отображаемых в ListBox
  piIndex, piOrder: PINT;
  ind: Integer;
  sFileNam, sFCaption, sHelpMsg: string;
  CheckEvent: TEvent;

  // iii,jjj:Integer;
   // родительский индекс текущего отображения содержится в поле Tag формы

implementation
uses LogFile;
var
  Log1: TLogFile;
  csLogDir: string;
  LogDirExist: boolean;
{$R *.dfm}
  { TODO -oСтеценко А.В. -cСделать : Возврат на родительский элемент в родительском уровне через анализ списка индексов }

procedure TFormZapuskatr1.ProgramRuned(s3: string);
var
  s: string;
begin
  s := 'ZAPUSKATR_' + s3;
  CheckEvent := TEvent.Create(nil, false, true, s);
  if CheckEvent.WaitFor(10) <> wrSignaled then
  begin
    ShowMessage('Программа уже запущена'#13'Возможно она свернута на панели задач или запущена одна из программ комплекса');
    Application.Terminate;
  end;
end;

procedure WriteLog(const aLogItem: string);
begin
  if Assigned(Log1) then
    Log1.PutLine(aLogItem);
end;

procedure ClearListNastrInd;
var
  i, n: integer;
  pChist: PINT;
begin
  n := lNastrInd.Count - 1;
  for i := 0 to n do
  begin
    pChist := lnastrind[i];
    dispose(pChist);
    lNastrind[i] := nil;
  end;
  lNastrInd.Clear;
end;

procedure ClearListNastr;
var
  n, i: integer;
begin
  n := lNastr.Count - 1;
  for i := 0 to n do
  begin
    pNastr := lnastr[i];
    Dispose(pNastr);
    lNastr[i] := nil;
  end;
  lNastr.Clear;
end;

procedure FreeAllTList;
begin
  if Assigned(lNastr) then
  begin
    ClearListNastr;
    FreeAndNil(lNastr);
  end;
  if Assigned(lNastrInd) then
  begin
    ClearListNastrInd;
    FreeAndNil(lNastrInd);
  end;
end;

procedure TFormZapuskatr1.Start(const s: string);
var
  si: TStartupInfo;
  p: TProcessInformation;
  b: boolean;
begin
  b := True;
  FillChar(Si, SizeOf(Si), 0);
  with Si do
  begin
    cb := SizeOf(Si);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := SW_HIDE;
  end;
  //Form1.WindowState:=wsMinimized;
  ShowWindow(Application.Handle, SW_HIDE);
  Self.Hide;
  WriteLog('RUN ' + s);
  if Createprocess(nil, PAnsiChar(s), nil, nil, false,
    CREATE_DEFAULT_ERROR_MODE or CREATE_NO_WINDOW, nil, nil, si, p) then
  begin
    if Waitforsingleobject(p.hProcess,  INFINITE) = WAIT_TIMEOUT then
      //28800000 = 8 часов
    begin
      b := False;
      WriteLog('TIMESTOP ' + s);
      TerminateProcess(p.hProcess, 5);
      MessageBox(0,
        'За 48 часов Вы не успели завершить работу,'#13'произошло автоматическое экстренное завершение программы!'#13'Это могло повлечь за собой порчу либо потерю данных!'#13'Рекомендуется не оставлять работающей программу на ночь!',
        'Экстренное завершение', MB_ICONERROR or MB_OK);
    end
  end
  else
  begin
    b := False;
    WriteLog('ERROR ' + s);
    ShowMessage('Запуск программы "' + s + '" невозможен'#13'Код ошибки: ' +
      inttostr(GetLastError));
  end;
  CloseHandle(p.hProcess);
  if b then
    WriteLog('EXIT ' + s);
  ShowWindow(Application.Handle, SW_SHOW);
  Self.Show;

end;

{*--------------------
Вывод наименования радительского элемента
в верхней части экранной формы
----------------------}

procedure TFormZapuskatr1.ShowParent();
var
  i: integer;
begin
  if (Self.Tag = -1) or (lst1.Items.Count = 1) then
    lbl1.Caption := Self.Caption
  else
  begin
    i := lst1.ItemIndex;
    if i > 0 then
      Dec(i);
    lbl1.Caption :=
      TNastroiki(lNastr.Items[TNastroiki(lNastr.Items[PINT(lNastrInd.Items[i])^])^.iParent])^.sText;
  end;
end;

{*-------------------------
Вывод сообщения О программе
---------------------------}

procedure TFormZapuskatr1.HelpMsg();
var
  s: string;
begin
  s := sHelpMsg;
  ShowMessage(s);
end;

procedure TFormZapuskatr1.Ochistka();
begin

end;
{*---------------------------------
Заполнение lst1 элементами, а также заполнение lNastrInd индексами
элементов в lNastr. Предварительно в Form1.Tag надо установить индекс родительского
элемента
----------------------------------}

procedure TFormZapuskatr1.Indexation();
var
  i, fw, fh, j1, j2: Integer;
begin
  ClearListNastrInd;
  lst1.Items.Clear;
  j1 := 0;
  if Self.tag > -1 then
    lst1.Items.Add(csBack);
  for i := 0 to lNastr.Count - 2 do
  begin
    //sT.Add(inttostr(TNastroiki(lNastr.Items[i])^.iParent));
    if TNastroiki(lNastr.Items[i])^.iParent = Self.Tag then
    begin
      Self.lst1.Items.Add(TNastroiki(lNastr.Items[i])^.sText);
      j2 := Length(TNastroiki(lNastr.Items[i])^.sText);
      if j2 > j1 then
        j1 := j2;
      New(piIndex);
      piIndex^ := i; //запоминаем индекс в списке указателей
      lNastrInd.Add(piIndex);
    end;
  end;
  lst1.ItemIndex := 0;
  //--- меняем размер формы в соответствии с количеством элементов)
  fh := lbl1.Height + (lst1.ItemHeight * lst1.Count + 2) + lbl2.Height +
    stat1.Height + 30;
  if fh > Screen.Height - 30 then
  begin
    fh := Screen.Height - 30;
    self.Top := 1;
  end;
  self.Height := fh;
  fw := j1 * 12;
  if (Screen.Width < 800) and (fw > Screen.Width) then
    fw := Screen.Width
  else if fw < 375 then
    fw := 375
  else if fw > 800 then
    fw := 800;
  Self.Width := fw;
  Self.Left := (Screen.Width div 2) - (fw div 2);
  //--- конец изменения размера окна
  //FreeAndNil(sT);
  Self.ShowParent;
end;

procedure TFormZapuskatr1.ListBox1Click(Sender: TObject);
begin

end;

{*-----------------------------
Рекурсивный анализ списка элементов, установка родительских элементов
(построение дерева). На Выходе: в

@param j Индекс родительского элемента
-------------------------------}

function TFormZapuskatr1.Analiz(j: Integer): Integer;
var
  i: Integer;
begin
  //inc(iii);
  i := j + 1;
  while i < lNastr.Count - 1 do
  begin
    //      TNastroiki(lNastr.Items[i])^.iParent:=j;
    if (TNastroiki(lNastr.Items[i])^.iOrder = 1) and ((TNastroiki(lNastr.Items[i + 1])^.iOrder = 1) or (TNastroiki(lNastr.Items[i + 1])^.iOrder = 0)) then
    begin
      TNastroiki(lNastr.Items[i])^.iParent := -1;
      j := i;
      Inc(i);
    end
    else if TNastroiki(lNastr.Items[i])^.iOrder = TNastroiki(lNastr.Items[i +
      1])^.iOrder then
    begin
      TNastroiki(lNastr.Items[i])^.iParent := j;
      Inc(i);
    end
    else if TNastroiki(lNastr.Items[i])^.iOrder < TNastroiki(lNastr.Items[i +
      1])^.iOrder then
    begin
      if (TNastroiki(lNastr.Items[i])^.iOrder > 1) then
        //меняем родителя если не самый верхний уровень
        TNastroiki(lNastr.Items[i])^.iParent := j;
      i := Analiz(i);
    end
    else
    begin
      TNastroiki(lNastr.Items[i])^.iParent := j;
      Inc(i);
      Result := i;
      Exit;
    end;
  end;
  Result := lNastr.Count;
end;
{*-------------------
Обработка перехода на выбранный элемент в ListBox

---------------------}

procedure TFormZapuskatr1.GoToIn();
var
  s: string;
  i: Integer;
begin
  i := lst1.ItemIndex;
  if (lst1.Items[0] = csBack) and (lst1.ItemIndex = 0) then
    GoToOut
  else
  begin
    if Self.Tag > -1 then
      Dec(i);
    if lst1.ItemIndex < 0 then
      lst1.ItemIndex := 0;
    s := TNastroiki(lNastr.Items[PINT(lNastrInd.Items[i])^])^.sCmd;
    //lbl2.Caption:=s;
    if s = '0' then //подменю
    begin
      Self.Tag := PINT(lNastrInd.Items[i])^;
      Self.Indexation;

    end
    else
    begin //запуск команды
      Self.StartPr;
    end;
  end;
  ShowParent;
end;

{*-------------------
Обработка выхода в ListBox на уровень выше

---------------------}

procedure TFormZapuskatr1.GoToOut();
begin
  if Self.tag > -1 then
  begin
    Self.Tag := TNastroiki(lNastr.Items[Self.Tag])^.iParent;
    Self.Indexation;
    ShowParent;
  end
  else
    Self.Close;
end;

procedure TFormZapuskatr1.StartPr();
var
  s: string;
  i: Integer;
begin
  i := lst1.ItemIndex;
  if self.Tag > -1 then
    Dec(i);
  s := TNastroiki(lNastr.Items[PINT(lNastrInd.Items[i])^])^.sCmd;
  Self.Start(s);
end;

procedure TFormZapuskatr1.FormCreate(Sender: TObject);
var
  sFile, sT: TStringList;
  sPath, shelp1: string;
  i, n: Integer;
begin
  if ParamCount > 0 then
    if ParamStr(1) = '?' then
    begin
      shelp1 :=
        'Программа - меню-запускатр для запуска других программ'#13'Настройки хранятся в файле с с именем "программа.ехе.lst".'#13;
      shelp1 := shelp1 +
        #13'1-ая строка: заголовок окна.'#13'2-ая строка: Строка сообщения выводящегося по нажатию клавиши F1.'#13'3-ья и последующие строки: описание пунктов меню.'#13'Формат описания:'#13'-|1 пункт|команда'#13'-|2 пункт';
      shelp1 := shelp1 +
        #13'--|2.1 пункт|команда'#13'--|2.2 пункт|команда'#13'--|2.3 пункт'#13'---|2.3.1 пункт|команда'#13'--|2.4 пункт|команда'#13'-|3 пункт|команда'#13'и т.д.';
      shelp1 := shelp1 +
        #13'Вместо символа "-" для построения иерархии можно использовать любой другой символ.'#13#13'ЗАПУСТИТЬ 2 РАЗА ЗАПУСКАТР С ОДНИМ И ТЕМ ЖЕ ИМЕНЕМ ИСПОЛНЯЕМОГО МОДУЛЯ (ЕХЕ-ШНИКА) НЕЛЬЗЯ!!!';
      ShowMessage(shelp1);
    end;
  sFileNam := ExtractFileName(Application.ExeName);
  ProgramRuned(sFileNam);
  sPath := ExtractFilePath(Application.ExeName) + sFileNam + '.lst';
  if FileExists(sPath) then //если файл существует
  begin
    sFile := TStringList.Create;
    try
      sFile.LoadFromFile(sPath);
    except
      ShowMessage('Ошибка при загрузке файла настроек' + sPath);
      FreeAndNil(sFile);
      Application.Terminate;
    end;
    if sFile.Count > 3 then
    begin
      sT := TStringList.Create;
      lNastr := TList.Create;
      Self.Caption := sFile.Strings[0];
      Application.Title := Self.Caption;
      sHelpMsg := sFile.Strings[1];
      csLogDir := sFile.Strings[2];
      LogDirExist := DirectoryExists(csLogDir);
      if LogDirExist then
        Log1 := TLogFile.Create(csLogDir + ExtractFileName(Application.ExeName) +
          '.csv');
      WriteLog('START');
      n := sFile.Count - 1;
      for i := 3 to n do
      begin
        sT.Text := stringReplace(sFile.Strings[i], '|', #13#10, [rfReplaceAll]);
        New(pNastr);
        pNastr^.iOrder := Length(sT.Strings[0]);
        pNastr^.sText := sT.Strings[1];
        pNastr^.sType := 'win';
        if sT.Count < 3 then
          pNastr^.sCmd := '0'
        else
          begin
            pNastr^.sCmd := sT.Strings[2];
            if sT.Count=4 then
              pNastr^.sType := LowerCase(sT.Strings[3]);
          end;
        pNastr^.iParent := -1;
        lNastr.Add(pNastr);
      end; // при выходе имеем заполненый список указателей lNastr
      FreeAndNil(sT);
      { мнимый элемент, чтобы при рекурсии не заморачиватся с анализом последнего элемента }
      New(pNastr);
      pNastr^.iOrder := 0;
      pNastr^.sText := '';
      pNastr^.sCmd := '';
      pNastr^.iParent := -1;
      lNastr.Add(pNastr);
      lNastrInd := TList.Create;
      Self.Tag := -1;
      Analiz(-1);
      Self.Indexation();
    end
    else
    begin
      ShowMessage('Файл настройки имеет неверный формат');
      Application.Terminate;
    end;
    if Assigned(sFile) then
      FreeAndNil(sFile);
  end
  else
  begin
    ShowMessage('Файл ' + sPath + ' не существует!');
    Application.Terminate;
  end;
end;

procedure TFormZapuskatr1.lst1Click(Sender: TObject);
var
  i: integer;
begin
  i := lst1.ItemIndex;
  if lst1.Items[0] = csBack then
  begin
    if i = 0 then
      stat1.SimpleText := csBack
    else
      stat1.SimpleText := TNastroiki(lNastr.Items[PINT(lNastrInd.Items[i -
          1])^])^.sText
  end
  else
    stat1.SimpleText :=
      TNastroiki(lNastr.Items[PINT(lNastrInd.Items[i])^])^.sText

end;

procedure TFormZapuskatr1.lst1DblClick(Sender: TObject);
begin
  GoToIn;
end;

procedure TFormZapuskatr1.lst1KeyPress(Sender: TObject; var Key: Char);
var
  n: byte;
begin
  n := ord(key);
  case n of
    13: GoToIn;
    8, 27: GoToOut;
  end;
end;

procedure TFormZapuskatr1.FormShow(Sender: TObject);
begin
  Self.lst1.SetFocus;
end;

procedure TFormZapuskatr1.lbl4Click(Sender: TObject);
begin
  GoToOut;
end;

procedure TFormZapuskatr1.btn1Click(Sender: TObject);
begin
  HelpMsg;
end;

procedure TFormZapuskatr1.lst1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    HelpMsg;
end;

procedure TFormZapuskatr1.lbl2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TFormZapuskatr1.lbl3Click(Sender: TObject);
begin
  HelpMsg;
end;

procedure TFormZapuskatr1.FormDestroy(Sender: TObject);
begin
  if Assigned(Log1) then
  begin
    Log1.PutLine('CLOSE');
    FreeAndNil(Log1);
  end;
  FreeAllTList;
  if Assigned(CheckEvent) then
    FreeAndNil(CheckEvent);
end;

end.
