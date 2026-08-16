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
    FSelX: Integer;
    FSelY: Integer;
    FSelW: Integer;
    FSelH: Integer;
    function ImageToView(const P: TPoint): TPoint;
    function ViewToImage(const P: TPoint): TPoint;
    procedure ClampPan;
    procedure NormalizeSelection;
    procedure UpdateSpinLimits;
    procedure UpdateViewRect;
    procedure UpdateSpinFromSelection;
    procedure UpdateSelectionFromSpin;
  public
    function ExecuteCrop(const AFileName: string; var ASrcX, ASrcY, ASrcW, ASrcH: Integer): Boolean;
    function ExecuteCropWithScale(const AFileName: string; var ASrcX, ASrcY, ASrcW, ASrcH, AScalePercent: Integer): Boolean;
    procedure RenderSelectionToBitmap(ABitmap: TBitmap);
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

//======================================================
// Освобождает ресурсы формы.
procedure TForm3.FormDestroy(Sender: TObject);
begin
  FPicture.Free;
end;

//======================================================
// Обрабатывает изображение, масштаб или выбранную область.
function TForm3.ImageToView(const P: TPoint): TPoint;
begin
  Result.X := FViewRect.Left + MulDiv(P.X, FViewRect.Right - FViewRect.Left, FPicture.Width);
  Result.Y := FViewRect.Top + MulDiv(P.Y, FViewRect.Bottom - FViewRect.Top, FPicture.Height);
end;

//======================================================
// Обрабатывает изображение, масштаб или выбранную область.
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

//======================================================
// Выполняет действие формы или редактора.
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

//======================================================
// Синхронизирует строку таблицы с параметрами элемента.
procedure TForm3.NormalizeSelection;
begin
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;
  if FSelX < 0 then
    FSelX := 0;
  if FSelY < 0 then
    FSelY := 0;
  if FSelX > FPicture.Width - 1 then
    FSelX := FPicture.Width - 1;
  if FSelY > FPicture.Height - 1 then
    FSelY := FPicture.Height - 1;
  if FSelW < 1 then
    FSelW := 1;
  if FSelH < 1 then
    FSelH := 1;
  if FSelX + FSelW > FPicture.Width then
    FSelW := FPicture.Width - FSelX;
  if FSelY + FSelH > FPicture.Height then
    FSelH := FPicture.Height - FSelY;
end;

//======================================================
// Выполняет действие формы или редактора.
procedure TForm3.UpdateSpinLimits;
begin
  if (FPicture.Graphic <> nil) and (not FPicture.Graphic.Empty) then
  begin
    SpinEdit1.MaxValue := FPicture.Width - 1;
    SpinEdit2.MaxValue := FPicture.Height - 1;
    SpinEdit3.MaxValue := FPicture.Width;
    SpinEdit4.MaxValue := FPicture.Height;
  end;
end;

//======================================================
// Выполняет действие формы или редактора.
procedure TForm3.UpdateViewRect;
var
  Scale: Double;
  ViewW: Integer;
  ViewH: Integer;
begin
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
  begin
    FViewRect := Rect(0, 0, 0, 0);
    Exit;
  end;

  ClampPan;
  Scale := TrackBar1.Position / 100;
  ViewW := Round(FPicture.Width * Scale);
  ViewH := Round(FPicture.Height * Scale);
  if ViewW < 1 then
    ViewW := 1;
  if ViewH < 1 then
    ViewH := 1;

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
end;

//======================================================
// Синхронизирует строку таблицы с параметрами элемента.
procedure TForm3.UpdateSpinFromSelection;
begin
  FUpdating := True;
  try
    UpdateSpinLimits;
    SpinEdit1.Value := FSelX;
    SpinEdit2.Value := FSelY;
    SpinEdit3.Value := FSelW;
    SpinEdit4.Value := FSelH;
  finally
    FUpdating := False;
  end;
end;

//======================================================
// Синхронизирует строку таблицы с параметрами элемента.
procedure TForm3.UpdateSelectionFromSpin;
begin
  FSelX := SpinEdit1.Value;
  FSelY := SpinEdit2.Value;
  FSelW := SpinEdit3.Value;
  FSelH := SpinEdit4.Value;
  NormalizeSelection;
  UpdateSpinFromSelection;
end;

//======================================================
// Обрабатывает изображение, масштаб или выбранную область.
function TForm3.ExecuteCrop(const AFileName: string; var ASrcX, ASrcY, ASrcW, ASrcH: Integer): Boolean;
var
  ScalePercent: Integer;
begin
  ScalePercent := 100;
  Result := ExecuteCropWithScale(AFileName, ASrcX, ASrcY, ASrcW, ASrcH, ScalePercent);
end;

//======================================================
// Обрабатывает изображение, масштаб или выбранную область.
function TForm3.ExecuteCropWithScale(const AFileName: string; var ASrcX, ASrcY, ASrcW, ASrcH, AScalePercent: Integer): Boolean;
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
    TrackBar1.Position := 100;
    Label6.Caption := '100%';
    FPanX := 0;
    FPanY := 0;
    FSelX := ASrcX;
    FSelY := ASrcY;
    if ASrcW <= 0 then
      FSelW := FPicture.Width
    else
      FSelW := ASrcW;
    if ASrcH <= 0 then
      FSelH := FPicture.Height
    else
      FSelH := ASrcH;
    NormalizeSelection;
  finally
    FUpdating := False;
  end;

  UpdateSpinFromSelection;
  PaintBox1.Invalidate;
  Result := ShowModal = mrOk;
  if Result then
  begin
    UpdateSelectionFromSpin;
    ASrcX := FSelX;
    ASrcY := FSelY;
    ASrcW := FSelW;
    ASrcH := FSelH;
    AScalePercent := TrackBar1.Position;
    if AScalePercent < 1 then
      AScalePercent := 1;
  end;
end;
//======================================================
// Рисует или обрабатывает виртуальный LCD и область предпросмотра.
procedure TForm3.PaintBox1Paint(Sender: TObject);
var
  SelTopLeft, SelBottomRight: TPoint;
begin
  PaintBox1.Canvas.Brush.Color := clBlack;
  PaintBox1.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;

  UpdateViewRect;
  PaintBox1.Canvas.StretchDraw(FViewRect, FPicture.Graphic);
  SelTopLeft := ImageToView(Point(FSelX, FSelY));
  SelBottomRight := ImageToView(Point(FSelX + FSelW, FSelY + FSelH));
  PaintBox1.Canvas.Brush.Style := bsClear;
  PaintBox1.Canvas.Pen.Color := clRed;
  PaintBox1.Canvas.Pen.Width := 2;
  PaintBox1.Canvas.Rectangle(Rect(SelTopLeft.X, SelTopLeft.Y,
    SelBottomRight.X, SelBottomRight.Y));
  PaintBox1.Canvas.Pen.Width := 1;
  PaintBox1.Canvas.Brush.Style := bsSolid;
end;

//======================================================
// Рисует или обрабатывает виртуальный LCD и область предпросмотра.
procedure TForm3.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
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
  UpdateViewRect;
  P := ViewToImage(Point(X, Y));
  FDragging := True;
  FDragStart := P;
  FSelX := P.X;
  FSelY := P.Y;
  FSelW := 1;
  FSelH := 1;
  NormalizeSelection;
  UpdateSpinFromSelection;
  PaintBox1.Invalidate;
end;

//======================================================
// Рисует или обрабатывает виртуальный LCD и область предпросмотра.
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
  UpdateViewRect;
  P := ViewToImage(Point(X, Y));
  if P.X < FDragStart.X then
  begin
    FSelX := P.X;
    FSelW := FDragStart.X - P.X;
  end
  else
  begin
    FSelX := FDragStart.X;
    FSelW := P.X - FDragStart.X;
  end;
  if P.Y < FDragStart.Y then
  begin
    FSelY := P.Y;
    FSelH := FDragStart.Y - P.Y;
  end
  else
  begin
    FSelY := FDragStart.Y;
    FSelH := P.Y - FDragStart.Y;
  end;
  NormalizeSelection;
  UpdateSpinFromSelection;
  PaintBox1.Invalidate;
end;

//======================================================
// Рисует или обрабатывает виртуальный LCD и область предпросмотра.
procedure TForm3.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  FPanning := False;
  NormalizeSelection;
  PaintBox1.Invalidate;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm3.SpinEditChange(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if (FPicture.Graphic <> nil) and (not FPicture.Graphic.Empty) then
    UpdateSelectionFromSpin;
  PaintBox1.Invalidate;
end;
//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm3.Button3Click(Sender: TObject);
begin
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;
  FUpdating := True;
  try
    FSelX := 0;
    FSelY := 0;
    FSelW := FPicture.Width;
    FSelH := FPicture.Height;
    NormalizeSelection;
  finally
    FUpdating := False;
  end;
  UpdateSpinFromSelection;
  PaintBox1.Invalidate;
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm3.TrackBar1Change(Sender: TObject);
begin
  Label6.Caption := IntToStr(TrackBar1.Position) + '%';
  ClampPan;
  UpdateViewRect;
  PaintBox1.Invalidate;
end;

//======================================================
// Синхронизирует строку таблицы с параметрами элемента.
procedure TForm3.RenderSelectionToBitmap(ABitmap: TBitmap);
var
  DestRect: TRect;
begin
  if ABitmap = nil then
    Exit;
  NormalizeSelection;
  UpdateViewRect;
  ABitmap.PixelFormat := pf24bit;
  ABitmap.Width := FSelW;
  ABitmap.Height := FSelH;
  ABitmap.Canvas.Brush.Color := clBlack;
  ABitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));
  if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    Exit;
  DestRect := Rect(FViewRect.Left - FSelX, FViewRect.Top - FSelY,
    FViewRect.Right - FSelX, FViewRect.Bottom - FSelY);
  ABitmap.Canvas.StretchDraw(DestRect, FPicture.Graphic);
end;

//======================================================
// Обрабатывает действие пользователя на форме.
procedure TForm3.TrackBar2Change(Sender: TObject);
begin
  Label8.Caption := IntToStr(TrackBar2.Position);
  AlphaBlendValue := TrackBar2.Position;
  AlphaBlend := TrackBar2.Position < 255;
end;

end.
