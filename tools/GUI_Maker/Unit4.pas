unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm4 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    procedure Memo1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
  private
    function MessageVisible(const AText: string): Boolean;
  public
    procedure AddMessage(const AText: string);
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Memo1DblClick(Sender: TObject);
begin
Memo1.Lines.Clear;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
  Close;
end;

function TForm4.MessageVisible(const AText: string): Boolean;
var
  TextUpper: string;
begin
  TextUpper := UpperCase(Trim(AText));

  if (Pos('RX: IP|', TextUpper) = 1) or
    (Pos('UDP RX: IP|', TextUpper) = 1) then
    Result := CheckBox3.Checked
  else if (Pos('RX:', TextUpper) = 1) or
    (Pos('UDP RX:', TextUpper) = 1) or
    (Pos('TOUCH ', TextUpper) = 1) then
    Result := CheckBox1.Checked
  else if (Pos('TX:', TextUpper) = 1) or
    (Pos('LINE SENT:', TextUpper) = 1) or
    (Pos('LCD CLEAR SENT:', TextUpper) = 1) or
    (Pos('UPLOAD SENT:', TextUpper) = 1) or
    (Pos('SHOWIP SENT', TextUpper) = 1) or
    (Pos('SD UPLOAD ', TextUpper) = 1) or
    (Pos('SCRIPT SAVED TO SD:', TextUpper) = 1) then
    Result := CheckBox2.Checked
  else
    Result := CheckBox3.Checked;
end;

procedure TForm4.AddMessage(const AText: string);
begin
  if not MessageVisible(AText) then
    Exit;

  Memo1.Lines.Add(FormatDateTime('hh:nn:ss ', Now) + AText);
  while Memo1.Lines.Count > 500 do
    Memo1.Lines.Delete(0);
  Memo1.SelStart := Length(Memo1.Text);
  Memo1.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TForm4.CheckBox4Click(Sender: TObject);
begin
  Memo1.WordWrap := CheckBox4.Checked;
  if Memo1.WordWrap then
    Memo1.ScrollBars := ssVertical
  else
    Memo1.ScrollBars := ssBoth;
end;

end.
