unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, ComCtrls, jpeg;

type
  TForm3 = class(TForm)
    PaintBox1: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label5: TLabel;
    TrackBar1: TTrackBar;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    TrackBar2: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpinEditChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
  private
    FPicture: TPicture;
    FImageName: string;
    FDragging: Boolean;
    FPanning: Boolean;
    FDragStart: TPoint;
    FPanStart: TPoint;
    FPanOrigin: TPoint;
    FUpdating: Boolean;
    FViewRect: TRect;
    FPanX: Integer;
    FPanY: Integer;
    function ImageToView(const P: TPoint): TPoint;
    function ViewToImage(const P: TPoint): TPoint;
    procedure ClampPan;
    procedure NormalizeSelection;
    procedure UpdateSpinLimits;
  public
    function ExecuteCrop(const AFileName: string; var ASrcX, ASrcY, ASrcW, ASrcH: Integer): Boolean;
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin
  FPicture := TPicture.Create;
  FDragging := False;
  FPanning := False;
  FUpdating := False;
  FPanX := 0;
  FPanY := 0;
  AlphaBlend := False;
  AlphaBlendValue := 255;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  FPicture.Free;
end;

function TForm3.ImageToView(const P: TPoint): TPoint;
begin
  Result.X := FViewRect.Left + MulDiv(P.X, FViewRect.Right - FViewRect.Left, FPicture.Width);
  Result.Y := FViewRect.Top + MulDiv(P.Y, FViewRect.Bottom - FViewRect.Top, FPicture.Height);
end;

function TForm3.ViewToImage(const P: TPoint): TPoint;
var
  ViewW: Integer;
  ViewH: Integer;
begin
  ViewW := FViewRect.Right - FViewRect.Left;
  ViewH := FViewRect.Bottom - FViewRect.Top;
  if ViewW <= 0 then
    ViewW := 1;
  if ViewH <= 0 then
    ViewH := 1;
  Result.X := MulDiv(P.X - FViewRect.Left, FPicture.Width, ViewW);
  Result.Y := MulDiv(P.Y - FViewRect.Top, FPicture.Height, ViewH);
  if Result.X < 0 then
    Result.X := 0;
  if Result.Y < 0 then
    Result.Y := 0;
  if Result.X > FPicture.Width then
    Result.X := FPicture.Width;
  if Result.Y > FPicture.Height then
    Result.Y := FPicture.Height;
end;

procedure TForm3.ClampPan;
var
  ViewW: Integer;
  ViewH: Integer;
begin
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;
  ViewW := Round(FPicture.Width * TrackBar1.Position / 100);
  ViewH := Round(FPicture.Height * TrackBar1.Position / 100);
  if ViewW <= PaintBox1.Width then
    FPanX := 0
  else
  begin
    if FPanX > 0 then
      FPanX := 0;
    if FPanX < PaintBox1.Width - ViewW then
      FPanX := PaintBox1.Width - ViewW;
  end;
  if ViewH <= PaintBox1.Height then
    FPanY := 0
  else
  begin
    if FPanY > 0 then
      FPanY := 0;
    if FPanY < PaintBox1.Height - ViewH then
      FPanY := PaintBox1.Height - ViewH;
  end;
end;

procedure TForm3.NormalizeSelection;
begin
  if SpinEdit1.Value < 0 then
    SpinEdit1.Value := 0;
  if SpinEdit2.Value < 0 then
    SpinEdit2.Value := 0;
  if SpinEdit1.Value > FPicture.Width - 1 then
    SpinEdit1.Value := FPicture.Width - 1;
  if SpinEdit2.Value > FPicture.Height - 1 then
    SpinEdit2.Value := FPicture.Height - 1;
  if SpinEdit3.Value < 1 then
    SpinEdit3.Value := 1;
  if SpinEdit4.Value < 1 then
    SpinEdit4.Value := 1;
  if SpinEdit1.Value + SpinEdit3.Value > FPicture.Width then
    SpinEdit3.Value := FPicture.Width - SpinEdit1.Value;
  if SpinEdit2.Value + SpinEdit4.Value > FPicture.Height then
    SpinEdit4.Value := FPicture.Height - SpinEdit2.Value;
end;

procedure TForm3.UpdateSpinLimits;
begin
  SpinEdit1.MaxValue := FPicture.Width;
  SpinEdit2.MaxValue := FPicture.Height;
  SpinEdit3.MaxValue := FPicture.Width;
  SpinEdit4.MaxValue := FPicture.Height;
end;

function TForm3.ExecuteCrop(const AFileName: string; var ASrcX, ASrcY, ASrcW, ASrcH: Integer): Boolean;
begin
  Result := False;
  if not FileExists(AFileName) then
    Exit;

  FImageName := AFileName;
  FPicture.LoadFromFile(AFileName);
  if (FPicture.Width <= 0) or (FPicture.Height <= 0) then
    Exit;

  Caption := 'Image area - ' + ExtractFileName(AFileName);
  UpdateSpinLimits;
  FUpdating := True;
  try
    SpinEdit1.Value := ASrcX;
    SpinEdit2.Value := ASrcY;
    TrackBar1.Position := 100;
    Label6.Caption := '100%';
    FPanX := 0;
    FPanY := 0;
    if ASrcW <= 0 then
      SpinEdit3.Value := FPicture.Width
    else
      SpinEdit3.Value := ASrcW;
    if ASrcH <= 0 then
      SpinEdit4.Value := FPicture.Height
    else
      SpinEdit4.Value := ASrcH;
    NormalizeSelection;
  finally
    FUpdating := False;
  end;

  PaintBox1.Invalidate;
  Result := ShowModal = mrOk;
  if Result then
  begin
    NormalizeSelection;
    ASrcX := SpinEdit1.Value;
    ASrcY := SpinEdit2.Value;
    ASrcW := SpinEdit3.Value;
    ASrcH := SpinEdit4.Value;
  end;
end;

procedure TForm3.PaintBox1Paint(Sender: TObject);
var
  Scale: Double;
  ViewW: Integer;
  ViewH: Integer;
  A: TPoint;
  B: TPoint;
begin
  PaintBox1.Canvas.Brush.Color := clBlack;
  PaintBox1.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;

  ClampPan;
  Scale := TrackBar1.Position / 100;
  ViewW := Round(FPicture.Width * Scale);
  ViewH := Round(FPicture.Height * Scale);
  FViewRect := Rect(FPanX, FPanY, FPanX + ViewW, FPanY + ViewH);
  if ViewW < PaintBox1.Width then
  begin
    FViewRect.Left := (PaintBox1.Width - ViewW) div 2;
    FViewRect.Right := FViewRect.Left + ViewW;
  end;
  if ViewH < PaintBox1.Height then
  begin
    FViewRect.Top := (PaintBox1.Height - ViewH) div 2;
    FViewRect.Bottom := FViewRect.Top + ViewH;
  end;

  PaintBox1.Canvas.StretchDraw(FViewRect, FPicture.Graphic);
  A := ImageToView(Point(SpinEdit1.Value, SpinEdit2.Value));
  B := ImageToView(Point(SpinEdit1.Value + SpinEdit3.Value, SpinEdit2.Value + SpinEdit4.Value));
  PaintBox1.Canvas.Brush.Style := bsClear;
  PaintBox1.Canvas.Pen.Color := clRed;
  PaintBox1.Canvas.Pen.Width := 2;
  PaintBox1.Canvas.Rectangle(Rect(A.X, A.Y, B.X, B.Y));
  PaintBox1.Canvas.Pen.Width := 1;
  PaintBox1.Canvas.Brush.Style := bsSolid;
end;

procedure TForm3.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    FPanning := True;
    FPanStart := Point(X, Y);
    FPanOrigin := Point(FPanX, FPanY);
    Exit;
  end;
  if Button <> mbLeft then
    Exit;
  FDragging := True;
  FDragStart := ViewToImage(Point(X, Y));
  SpinEdit1.Value := FDragStart.X;
  SpinEdit2.Value := FDragStart.Y;
  SpinEdit3.Value := 1;
  SpinEdit4.Value := 1;
end;

procedure TForm3.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if not FDragging then
  begin
    if FPanning then
    begin
      FPanX := FPanOrigin.X + X - FPanStart.X;
      FPanY := FPanOrigin.Y + Y - FPanStart.Y;
      ClampPan;
      PaintBox1.Invalidate;
    end;
    Exit;
  end;
  P := ViewToImage(Point(X, Y));
  if P.X < FDragStart.X then
  begin
    SpinEdit1.Value := P.X;
    SpinEdit3.Value := FDragStart.X - P.X;
  end
  else
  begin
    SpinEdit1.Value := FDragStart.X;
    SpinEdit3.Value := P.X - FDragStart.X;
  end;
  if P.Y < FDragStart.Y then
  begin
    SpinEdit2.Value := P.Y;
    SpinEdit4.Value := FDragStart.Y - P.Y;
  end
  else
  begin
    SpinEdit2.Value := FDragStart.Y;
    SpinEdit4.Value := P.Y - FDragStart.Y;
  end;
  NormalizeSelection;
  PaintBox1.Invalidate;
end;

procedure TForm3.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  FPanning := False;
  NormalizeSelection;
  PaintBox1.Invalidate;
end;

procedure TForm3.SpinEditChange(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if (FPicture.Graphic <> nil) and (not FPicture.Graphic.Empty) then
  begin
    FUpdating := True;
    try
      NormalizeSelection;
    finally
      FUpdating := False;
    end;
  end;
  PaintBox1.Invalidate;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;
  FUpdating := True;
  try
    SpinEdit1.Value := 0;
    SpinEdit2.Value := 0;
    SpinEdit3.Value := FPicture.Width;
    SpinEdit4.Value := FPicture.Height;
  finally
    FUpdating := False;
  end;
  PaintBox1.Invalidate;
end;

procedure TForm3.TrackBar1Change(Sender: TObject);
begin
  Label6.Caption := IntToStr(TrackBar1.Position) + '%';
  ClampPan;
  PaintBox1.Invalidate;
end;

procedure TForm3.TrackBar2Change(Sender: TObject);
begin
  Label8.Caption := IntToStr(TrackBar2.Position);
  AlphaBlendValue := TrackBar2.Position;
  AlphaBlend := TrackBar2.Position < 255;
end;

end.
